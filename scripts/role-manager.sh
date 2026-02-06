#!/usr/bin/env bash

# role-manager.sh - Core role management logic
#
# Functions:
#   - set_role: Set user role
#   - show_role_context: Display current role and documents
#   - update_role_docs: Add/remove documents
#   - init_role_docs: Initialize role documents from guide
#   - get_role_guide_path: Find role guide file
#   - extract_document_references: Parse documents from role guide
#   - merge_role_references: Merge team defaults with user overrides
#
# Exit codes:
#   0 - Success
#   1 - Validation/logic error
#   2 - System error (file not found, permissions, etc.)

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source path configuration library
source "$SCRIPT_DIR/path-config.sh"
load_path_config

# Source helper scripts
source "$SCRIPT_DIR/level-detector.sh" 2>/dev/null || true
source "$SCRIPT_DIR/doc-validator.sh" 2>/dev/null || true

# =============================================================================
# Multi-Scope Configuration Support (v1.4.0)
# =============================================================================

# Find project-level .claude directory (searches upward from PWD)
find_claude_dir_upward() {
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/$claude_dir_name" ]]; then
            echo "$dir/$claude_dir_name"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    return 1
}

# Backward compatibility alias
find_claude_dir() {
    find_claude_dir_upward
}

# Check if running in project context (has .claude directory)
is_project_context() {
    find_claude_dir_upward &>/dev/null
}

# Find configuration directory with scope support
# Args:
#   $1: scope (auto|project|global) - default: auto
# Returns:
#   Path to config directory
find_config_dir() {
    local scope="${1:-auto}"
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"

    case "$scope" in
        global)
            # Force global config
            echo "$HOME/$claude_dir_name"
            return 0
            ;;
        project)
            # Force project config (must exist)
            find_claude_dir_upward || return 1
            ;;
        auto)
            # Try project first, fallback to global
            find_claude_dir_upward || echo "$HOME/$claude_dir_name"
            return 0
            ;;
        *)
            echo "Error: Invalid scope '$scope'. Use auto, project, or global." >&2
            return 1
            ;;
    esac
}

# Get effective config directory (project overrides global)
get_effective_config_dir() {
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    find_claude_dir_upward || echo "$HOME/$claude_dir_name"
}

# Ensure global config directory exists with defaults
ensure_global_config() {
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    local global_claude_dir="$HOME/$claude_dir_name"

    if [[ ! -d "$global_claude_dir" ]]; then
        mkdir -p "$global_claude_dir"
        echo "✓ Created global config directory: ~/$claude_dir_name/" >&2

        # Initialize with sensible defaults
        cat > "$global_claude_dir/preferences.json" <<'EOF'
{
  "user_role": null,
  "auto_update_templates": true,
  "applied_template": null
}
EOF
        echo "✓ Initialized global preferences" >&2
    fi
}

# Get plugin installation directory
get_plugin_dir() {
    # Claude Code sets CLAUDE_PLUGIN_DIR when plugin loads
    echo "${CLAUDE_PLUGIN_DIR:-$SCRIPT_DIR/..}"
}

# Resolve template path from plugin installation
get_template_path() {
    local template_name="$1"
    local plugin_dir="$(get_plugin_dir)"
    echo "$plugin_dir/templates/$template_name"
}

# Resolve document paths with multi-scope support
# Args:
#   $1: document path (absolute from root or relative)
# Returns:
#   Resolved absolute path if found, otherwise original path
resolve_document_path() {
    local doc_path="$1"

    # Absolute path from project root (starts with /)
    if [[ "$doc_path" =~ ^/ ]]; then
        local project_root
        project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
        local resolved="$project_root${doc_path}"
        if [[ -f "$resolved" ]]; then
            echo "$resolved"
            return 0
        fi
        # Return path even if not found, for error reporting
        echo "$resolved"
        return 1
    fi

    # Relative path - search in order of precedence

    # 1. Current directory
    if [[ -f "$PWD/$doc_path" ]]; then
        echo "$PWD/$doc_path"
        return 0
    fi

    # 2. Project root (if in project context)
    if is_project_context; then
        local project_root
        project_root="$(dirname "$(find_claude_dir_upward)")"
        if [[ -f "$project_root/$doc_path" ]]; then
            echo "$project_root/$doc_path"
            return 0
        fi
    fi

    # 3. Global .claude directory (for global-only docs)
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    if [[ -f "$HOME/$claude_dir_name/$doc_path" ]]; then
        echo "$HOME/$claude_dir_name/$doc_path"
        return 0
    fi

    # Not found - return original for error reporting
    echo "$doc_path"
    return 1
}

# Read preference with scope hierarchy (project overrides global)
# Args:
#   $1: preference key (e.g., "user_role")
# Returns:
#   Preference value (project > global > empty)
get_preference() {
    local key="$1"

    # Try project config first
    if is_project_context; then
        local project_config="$(find_claude_dir_upward)/preferences.json"
        if [[ -f "$project_config" ]]; then
            local value
            if command -v jq &> /dev/null; then
                value=$(jq -r ".$key // empty" "$project_config" 2>/dev/null)
            else
                value=$(grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$project_config" 2>/dev/null | \
                    sed 's/.*"\([^"]*\)"/\1/')
            fi
            if [[ -n "$value" ]]; then
                echo "$value"
                return 0
            fi
        fi
    fi

    # Fallback to global config
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    local global_config="$HOME/$claude_dir_name/preferences.json"
    if [[ -f "$global_config" ]]; then
        if command -v jq &> /dev/null; then
            jq -r ".$key // empty" "$global_config" 2>/dev/null || echo ""
        else
            grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$global_config" 2>/dev/null | \
                sed 's/.*"\([^"]*\)"/\1/' || echo ""
        fi
    fi
}

# Set preference with scope control
# Args:
#   $1: key
#   $2: value
#   $3: scope (auto|project|global) - default: auto
set_preference() {
    local key="$1"
    local value="$2"
    local scope="${3:-auto}"
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"

    local config_dir
    case "$scope" in
        global)
            config_dir="$HOME/$claude_dir_name"
            ensure_global_config
            ;;
        project)
            config_dir="$(find_claude_dir_upward)"
            if [[ -z "$config_dir" ]]; then
                echo "Error: Not in a project context. Cannot use --project scope." >&2
                return 1
            fi
            ;;
        auto)
            # Write to project if in project, else global
            if is_project_context; then
                config_dir="$(find_claude_dir_upward)"
            else
                config_dir="$HOME/$claude_dir_name"
                ensure_global_config
            fi
            ;;
        *)
            echo "Error: Invalid scope '$scope'" >&2
            return 1
            ;;
    esac

    mkdir -p "$config_dir"
    local prefs_file="$config_dir/preferences.json"

    # Create file if doesn't exist
    if [[ ! -f "$prefs_file" ]]; then
        echo "{}" > "$prefs_file"
    fi

    # Update using jq
    if command -v jq &> /dev/null; then
        local temp_file
        temp_file="$(mktemp)"
        jq --arg key "$key" --arg value "$value" '.[$key] = $value' "$prefs_file" > "$temp_file"
        mv "$temp_file" "$prefs_file"
    else
        # Fallback: simple sed replacement
        if grep -q "\"$key\"" "$prefs_file"; then
            sed -i.bak "s/\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"$key\": \"$value\"/" "$prefs_file"
            rm -f "$prefs_file.bak"
        else
            sed -i.bak 's/{/{\n  "'"$key"'": "'"$value"'",/' "$prefs_file"
            rm -f "$prefs_file.bak"
        fi
    fi

    echo "✓ Updated $key in: $prefs_file" >&2
}

# Ensure .claude directory exists
ensure_claude_dir() {
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    if [[ ! -d "$claude_dir_name" ]]; then
        mkdir -p "$claude_dir_name"
        echo "Created $claude_dir_name directory" >&2
    fi
}

# Read current role from preferences.json
get_current_role() {
    local claude_dir="$1"
    local prefs_file="$claude_dir/preferences.json"

    if [[ ! -f "$prefs_file" ]]; then
        echo ""
        return 1
    fi

    if command -v jq &> /dev/null; then
        jq -r '.user_role // empty' "$prefs_file" 2>/dev/null || echo ""
    else
        grep -o '"user_role"[[:space:]]*:[[:space:]]*"[^"]*"' "$prefs_file" 2>/dev/null | \
            sed 's/.*"\([^"]*\)"/\1/' || echo ""
    fi
}

# Update role in preferences.json
set_user_role() {
    local claude_dir="$1"
    local role="$2"
    local prefs_file="$claude_dir/preferences.json"

    # Create preferences.json if it doesn't exist
    if [[ ! -f "$prefs_file" ]]; then
        echo "{}" > "$prefs_file"
    fi

    if command -v jq &> /dev/null; then
        local temp_file
        temp_file="$(mktemp)"
        jq --arg role "$role" '.user_role = $role' "$prefs_file" > "$temp_file"
        mv "$temp_file" "$prefs_file"
    else
        # Fallback: simple sed replacement or append
        if grep -q '"user_role"' "$prefs_file"; then
            sed -i.bak "s/\"user_role\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"user_role\": \"$role\"/" "$prefs_file"
            rm -f "$prefs_file.bak"
        else
            # Add user_role field
            sed -i.bak 's/{/{\n  "user_role": "'"$role"'",/' "$prefs_file"
            rm -f "$prefs_file.bak"
        fi
    fi

    echo "✓ Role set to: $role" >&2
    echo "✓ Updated: $prefs_file" >&2
}

# Get role guide path for given role and level
get_role_guide_path() {
    local claude_dir="$1"
    local role="$2"
    local role_guides_dir
    role_guides_dir="$(get_role_guides_dir)"

    local role_guide="$claude_dir/$role_guides_dir/${role}-guide.md"

    if [[ -f "$role_guide" ]]; then
        echo "$role_guide"
        return 0
    fi

    # Try without -guide suffix
    role_guide="$claude_dir/$role_guides_dir/${role}.md"
    if [[ -f "$role_guide" ]]; then
        echo "$role_guide"
        return 0
    fi

    echo "" >&2
    return 1
}

# List available roles for current level
list_available_roles() {
    local claude_dir="$1"
    local role_guides_dirname
    role_guides_dirname="$(get_role_guides_dir)"
    local role_guides_dir="$claude_dir/$role_guides_dirname"

    if [[ ! -d "$role_guides_dir" ]]; then
        echo "No roles defined at this level" >&2
        return 1
    fi

    echo "Available roles:" >&2
    for guide in "$role_guides_dir"/*.md; do
        if [[ -f "$guide" ]]; then
            local basename="$(basename "$guide" .md)"
            # Remove -guide suffix if present
            basename="${basename%-guide}"
            echo "  - $basename" >&2
        fi
    done
}

# Extract document references from role guide
extract_document_references() {
    local role_guide="$1"

    if [[ ! -f "$role_guide" ]]; then
        echo "[]"
        return 1
    fi

    local docs=()
    local in_section=false

    while IFS= read -r line; do
        # Check if we're entering the Document References section
        if [[ "$line" =~ ^##[[:space:]]*Document[[:space:]]*References ]]; then
            in_section=true
            continue
        fi

        # Check if we're leaving the section (next ## heading)
        if [[ "$line" =~ ^##[[:space:]] ]] && [[ "$in_section" == "true" ]]; then
            break
        fi

        # Extract document paths from markdown list items
        if [[ "$in_section" == "true" ]]; then
            # Match: - `path.md`
            if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*\`([^\`]+\.md)\` ]]; then
                local doc_path="${BASH_REMATCH[1]}"
                docs+=("$doc_path")
            # Match: - /absolute/path.md
            elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(/[^[:space:]]+\.md) ]]; then
                local doc_path="${BASH_REMATCH[1]}"
                docs+=("$doc_path")
            # Match: - relative/path.md
            elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*([^[:space:]]+\.md) ]]; then
                local doc_path="${BASH_REMATCH[1]}"
                docs+=("$doc_path")
            fi
        fi
    done < "$role_guide"

    # Output as JSON array
    if command -v jq &> /dev/null; then
        printf '%s\n' "${docs[@]}" | jq -R -s -c 'split("\n") | map(select(length > 0))'
    else
        # Fallback without jq
        echo -n "["
        local first=true
        for doc in "${docs[@]}"; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo -n ","
            fi
            echo -n "\"$doc\""
        done
        echo "]"
    fi
}

# Read role-references.json (team defaults or local overrides)
read_role_references() {
    local claude_dir="$1"
    local role="$2"
    local use_local="${3:-false}"

    local ref_file="$claude_dir/role-references.json"
    if [[ "$use_local" == "true" ]]; then
        ref_file="$claude_dir/role-references.local.json"
    fi

    if [[ ! -f "$ref_file" ]]; then
        echo "{}"
        return 1
    fi

    if command -v jq &> /dev/null; then
        jq --arg role "$role" '.[$role] // {}' "$ref_file" 2>/dev/null || echo "{}"
    else
        echo "{}"
    fi
}

# Write role-references.json
write_role_references() {
    local claude_dir="$1"
    local role="$2"
    local default_docs="$3"
    local custom_docs="$4"
    local use_local="${5:-false}"

    local ref_file="$claude_dir/role-references.json"
    if [[ "$use_local" == "true" ]]; then
        ref_file="$claude_dir/role-references.local.json"
    fi

    if command -v jq &> /dev/null; then
        local temp_file
        temp_file="$(mktemp)"

        # Read existing file or create empty object
        if [[ -f "$ref_file" ]]; then
            cat "$ref_file" > "$temp_file"
        else
            echo "{}" > "$temp_file"
        fi

        # Update role entry
        jq --arg role "$role" \
           --argjson defaults "$default_docs" \
           --argjson customs "$custom_docs" \
           '.[$role] = {default_documents: $defaults, user_customizations: $customs}' \
           "$temp_file" > "$ref_file"

        rm -f "$temp_file"
    else
        # Fallback - simple write
        cat > "$ref_file" <<EOF
{
  "$role": {
    "default_documents": $default_docs,
    "user_customizations": $custom_docs
  }
}
EOF
    fi
}

# Merge team defaults with local overrides
merge_role_documents() {
    local claude_dir="$1"
    local role="$2"

    # Read team defaults
    local team_defaults
    team_defaults="$(read_role_references "$claude_dir" "$role" false)"

    # Read local overrides
    local local_overrides
    local_overrides="$(read_role_references "$claude_dir" "$role" true)"

    # Extract default documents
    local default_docs
    if command -v jq &> /dev/null; then
        default_docs="$(echo "$team_defaults" | jq -r '.default_documents[]? // empty' 2>/dev/null)"
    else
        default_docs=""
    fi

    # Extract customizations from local
    local custom_docs
    if command -v jq &> /dev/null; then
        custom_docs="$(echo "$local_overrides" | jq -r '.user_customizations[]? // empty' 2>/dev/null)"
    else
        custom_docs=""
    fi

    # Build final list
    local final_docs=()

    # Add default docs
    while IFS= read -r doc; do
        [[ -z "$doc" ]] && continue
        final_docs+=("$doc")
    done <<< "$default_docs"

    # Apply customizations
    while IFS= read -r custom; do
        [[ -z "$custom" ]] && continue

        if [[ "$custom" =~ ^\+ ]]; then
            # Add document
            local doc_to_add="${custom#+}"
            final_docs+=("$doc_to_add")
        elif [[ "$custom" =~ ^\- ]]; then
            # Remove document
            local doc_to_remove="${custom#-}"
            local new_docs=()
            for doc in "${final_docs[@]}"; do
                if [[ "$doc" != "$doc_to_remove" ]]; then
                    new_docs+=("$doc")
                fi
            done
            final_docs=("${new_docs[@]}")
        fi
    done <<< "$custom_docs"

    # Output final list
    printf '%s\n' "${final_docs[@]}"
}

# Display role context
cmd_show_role_context() {
    local claude_dir
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    claude_dir="$(find_claude_dir)" || {
        echo "Error: No $claude_dir_name directory found" >&2
        return 2
    }

    # Get organizational level
    local org_level
    org_level="$(detect_by_heuristics "$claude_dir" 2>/dev/null)" || org_level="project"

    echo "Organizational level: $org_level"
    echo ""

    # Get current role
    local current_role
    current_role="$(get_current_role "$claude_dir")"

    if [[ -z "$current_role" ]]; then
        echo "No role set."
        echo ""
        list_available_roles "$claude_dir"
        echo ""
        echo "Use /set-role [role-name] to set your role."
        return 0
    fi

    echo "Current role: $current_role"
    echo ""

    # Get merged documents
    echo "Documents that will load on next session:"
    echo ""

    local docs
    docs=($(merge_role_documents "$claude_dir" "$current_role"))

    if [[ ${#docs[@]} -eq 0 ]]; then
        echo "  No documents configured."
        echo ""
        echo "Use /init-role-docs to initialize from role guide."
        return 0
    fi

    # Check existence and display
    for doc in "${docs[@]}"; do
        local indicator
        local resolved

        # Skip wildcards or show them specially
        if [[ "$doc" == *"*"* ]]; then
            echo "  ~ $doc (pattern)"
            continue
        fi

        resolved="$(resolve_path "$doc" 2>/dev/null)" || true

        if [[ -n "$resolved" ]]; then
            indicator="✓"
        else
            if is_standardized_document "$doc"; then
                indicator="?"
            else
                indicator="!"
            fi
        fi

        echo "  $indicator $doc"
    done

    echo ""
    echo "Legend: ✓ exists | ! missing | ? can be generated"
    echo ""
    echo "Start a new session to load this context."
}

# Set role command
cmd_set_role() {
    local role="$1"

    if [[ -z "$role" ]]; then
        echo "Usage: /set-role [role-name]" >&2
        return 1
    fi

    local claude_dir
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    claude_dir="$(find_claude_dir)" || {
        ensure_claude_dir
        claude_dir="./$claude_dir_name"
    }

    # Check if role exists
    local role_guide
    role_guide="$(get_role_guide_path "$claude_dir" "$role")"

    if [[ -z "$role_guide" ]]; then
        echo "Error: Role '$role' not found at this organizational level" >&2
        echo "" >&2
        list_available_roles "$claude_dir"
        return 1
    fi

    # Set role in preferences
    set_user_role "$claude_dir" "$role"

    # Initialize role documents if not exists
    local ref_file="$claude_dir/role-references.json"
    if [[ ! -f "$ref_file" ]] || ! grep -q "\"$role\"" "$ref_file" 2>/dev/null; then
        echo "" >&2
        echo "Initializing document references from role guide..." >&2
        cmd_init_role_docs
    else
        echo "" >&2
        cmd_show_role_context
    fi
}

# Initialize role documents from guide
cmd_init_role_docs() {
    local reset="${1:-false}"
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"

    local claude_dir
    claude_dir="$(find_claude_dir)" || {
        echo "Error: No $claude_dir_name directory found" >&2
        return 2
    }

    local current_role
    current_role="$(get_current_role "$claude_dir")"

    if [[ -z "$current_role" ]]; then
        echo "Error: No role set. Use /set-role first." >&2
        return 1
    fi

    # Get role guide
    local role_guide
    role_guide="$(get_role_guide_path "$claude_dir" "$current_role")"

    if [[ -z "$role_guide" ]]; then
        echo "Error: Role guide not found for role: $current_role" >&2
        return 1
    fi

    # Extract document references
    local doc_refs
    doc_refs="$(extract_document_references "$role_guide")"

    # Write to role-references.json
    if [[ "$reset" == "--reset" ]] || [[ "$reset" == "true" ]]; then
        # Reset: clear customizations
        write_role_references "$claude_dir" "$current_role" "$doc_refs" "[]" false
        echo "✓ Reset role documents to defaults for: $current_role"
    else
        # Initialize: keep existing customizations if any
        local existing_customs
        existing_customs="$(read_role_references "$claude_dir" "$current_role" false | jq -c '.user_customizations // []' 2>/dev/null)" || existing_customs="[]"
        write_role_references "$claude_dir" "$current_role" "$doc_refs" "$existing_customs" false
        echo "✓ Initialized role documents for: $current_role"
    fi

    echo ""
    cmd_show_role_context
}

# Update role documents (+/- syntax)
cmd_update_role_docs() {
    local modifications=("$@")

    if [[ ${#modifications[@]} -eq 0 ]]; then
        echo "Usage: /update-role-docs [+/-]file ..." >&2
        echo "Examples:" >&2
        echo "  /update-role-docs +docs/custom.md" >&2
        echo "  /update-role-docs -/quality-standards.md" >&2
        echo "  /update-role-docs +new.md -old.md" >&2
        return 1
    fi

    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    local claude_dir
    claude_dir="$(find_claude_dir)" || {
        echo "Error: No $claude_dir_name directory found" >&2
        return 2
    }

    local current_role
    current_role="$(get_current_role "$claude_dir")"

    if [[ -z "$current_role" ]]; then
        echo "Error: No role set. Use /set-role first." >&2
        return 1
    fi

    # Read existing customizations from local file
    local ref_file_local="$claude_dir/role-references.local.json"
    local existing_customs=()

    if [[ -f "$ref_file_local" ]]; then
        while IFS= read -r custom; do
            [[ -z "$custom" ]] && continue
            existing_customs+=("$custom")
        done < <(jq -r --arg role "$current_role" '.[$role].user_customizations[]? // empty' "$ref_file_local" 2>/dev/null)
    fi

    # Apply modifications
    local additions=()
    local removals=()

    for mod in "${modifications[@]}"; do
        if [[ "$mod" =~ ^\+ ]]; then
            local doc_path="${mod#+}"
            # Check if already in customizations
            local already_exists=false
            for existing in "${existing_customs[@]}"; do
                if [[ "$existing" == "+$doc_path" ]]; then
                    already_exists=true
                    break
                fi
            done
            if [[ "$already_exists" == "false" ]]; then
                existing_customs+=("$mod")
                additions+=("$doc_path")
            fi
        elif [[ "$mod" =~ ^\- ]]; then
            local doc_path="${mod#-}"
            # Check if removal already in customizations
            local already_exists=false
            for existing in "${existing_customs[@]}"; do
                if [[ "$existing" == "-$doc_path" ]]; then
                    already_exists=true
                    break
                fi
            done
            if [[ "$already_exists" == "false" ]]; then
                existing_customs+=("$mod")
                removals+=("$doc_path")
            fi
        else
            echo "Warning: Invalid modification format: $mod (must start with + or -)" >&2
        fi
    done

    # Convert to JSON array
    local customs_json
    if command -v jq &> /dev/null; then
        customs_json="$(printf '%s\n' "${existing_customs[@]}" | jq -R -s -c 'split("\n") | map(select(length > 0))')"
    else
        customs_json="["
        local first=true
        for custom in "${existing_customs[@]}"; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                customs_json+=","
            fi
            customs_json+="\"$custom\""
        done
        customs_json+="]"
    fi

    # Write to local file
    write_role_references "$claude_dir" "$current_role" "[]" "$customs_json" true

    echo "✓ Updated role documents for: $current_role"
    echo ""

    if [[ ${#additions[@]} -gt 0 ]]; then
        echo "Added:"
        for doc in "${additions[@]}"; do
            echo "  + $doc"
        done
        echo ""
    fi

    if [[ ${#removals[@]} -gt 0 ]]; then
        echo "Removed:"
        for doc in "${removals[@]}"; do
            echo "  - $doc"
        done
        echo ""
    fi

    cmd_show_role_context
}

# Load role context for session (automatic loading on SessionStart)
cmd_load_role_context() {
    local mode="normal"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --quiet)
                mode="quiet"
                shift
                ;;
            --verbose)
                mode="verbose"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # Get effective config directory (project overrides global)
    local config_dir
    config_dir="$(get_effective_config_dir)"

    # Get current role using multi-scope hierarchy
    local current_role
    current_role="$(get_preference "user_role")"

    # No role set - exit silently (not an error)
    if [[ -z "$current_role" || "$current_role" == "null" ]]; then
        exit 0
    fi

    # Get role guide path
    local role_guide
    role_guide="$(get_role_guide_path "$config_dir" "$current_role")"

    # Role guide missing - exit silently in quiet mode, warn in normal/verbose
    if [[ -z "$role_guide" || ! -f "$role_guide" ]]; then
        if [[ "$mode" != "quiet" ]]; then
            echo "Warning: Role guide not found for role: $current_role" >&2
        fi
        exit 0
    fi

    # Read role guide content
    local role_guide_content
    role_guide_content="$(cat "$role_guide")"

    # Extract document references
    local doc_refs_json
    doc_refs_json="$(extract_document_references "$role_guide")"

    # Parse document references into array
    local doc_paths=()
    if command -v jq &> /dev/null; then
        while IFS= read -r doc_path; do
            [[ -n "$doc_path" ]] && doc_paths+=("$doc_path")
        done < <(echo "$doc_refs_json" | jq -r '.[]' 2>/dev/null)
    fi

    # Read each document (best effort)
    local doc_contents=()
    local loaded_count=0

    for doc_path in "${doc_paths[@]}"; do
        local resolved_path
        resolved_path="$(resolve_document_path "$doc_path" 2>/dev/null)" || resolved_path=""

        if [[ -n "$resolved_path" && -f "$resolved_path" ]]; then
            local doc_content
            doc_content="$(cat "$resolved_path" 2>/dev/null)" || doc_content=""

            if [[ -n "$doc_content" ]]; then
                doc_contents+=("$doc_path|$doc_content")
                ((loaded_count++))
            fi
        fi
    done

    # Output based on mode
    case "$mode" in
        quiet)
            # One-line summary for SessionStart hook
            echo "✓ Role context loaded: $current_role ($loaded_count documents)"
            ;;
        verbose)
            # Full output with metadata
            echo "=== ROLE CONTEXT LOADED ==="
            echo ""
            echo "Role: $current_role"
            echo "Scope: $(is_project_context && echo "project" || echo "global")"
            echo "Role guide: $role_guide"
            echo "Documents loaded: $loaded_count/${#doc_paths[@]}"
            echo ""

            if [[ $loaded_count -gt 0 ]]; then
                echo "Document list:"
                for doc_info in "${doc_contents[@]}"; do
                    local doc_path="${doc_info%%|*}"
                    echo "  - $doc_path"
                done
                echo ""
            fi

            echo "You are collaborating with a user in the role: $current_role"
            echo ""
            echo "The following role guide defines how you should assist this user:"
            echo ""
            echo "---"
            echo "$role_guide_content"
            echo "---"
            echo ""

            if [[ $loaded_count -gt 0 ]]; then
                echo "## Referenced Documents"
                echo ""
                echo "The following documents are part of this role's context:"
                echo ""

                for doc_info in "${doc_contents[@]}"; do
                    local doc_path="${doc_info%%|*}"
                    local doc_content="${doc_info#*|}"

                    echo "### Document: $doc_path"
                    echo "---"
                    echo "$doc_content"
                    echo "---"
                    echo ""
                done
            fi

            echo "This context is automatically loaded for this session. Follow the"
            echo "deterministic behaviors and leverage the agentic opportunities defined above."
            echo ""
            echo "=== END ROLE CONTEXT ==="
            ;;
        *)
            # Normal mode - full role guide + documents with context wrapper
            echo "=== ROLE CONTEXT LOADED ==="
            echo ""
            echo "You are collaborating with a user in the role: $current_role"
            echo ""
            echo "The following role guide defines how you should assist this user:"
            echo ""
            echo "---"
            echo "$role_guide_content"
            echo "---"
            echo ""

            if [[ $loaded_count -gt 0 ]]; then
                echo "## Referenced Documents"
                echo ""
                echo "The following documents are part of this role's context:"
                echo ""

                for doc_info in "${doc_contents[@]}"; do
                    local doc_path="${doc_info%%|*}"
                    local doc_content="${doc_info#*|}"

                    echo "### Document: $doc_path"
                    echo "---"
                    echo "$doc_content"
                    echo "---"
                    echo ""
                done
            fi

            echo "This context is automatically loaded for this session. Follow the"
            echo "deterministic behaviors and leverage the agentic opportunities defined above."
            echo ""
            echo "=== END ROLE CONTEXT ==="
            ;;
    esac

    exit 0
}

# =============================================================================
# Template Integration Functions (v1.1.0)
# =============================================================================

# Check if .claude setup is complete and ready to use
check_setup_complete() {
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    local role_guides_dirname
    role_guides_dirname="$(get_role_guides_dir)"
    local claude_dir="${1:-$claude_dir_name}"

    # Check if .claude directory exists
    if [[ ! -d "$claude_dir" ]]; then
        return 1
    fi

    # Check if role-guides directory exists and has files
    if [[ ! -d "$claude_dir/$role_guides_dirname" ]]; then
        return 1
    fi

    local guide_count
    guide_count=$(find "$claude_dir/$role_guides_dirname" -name "*.md" 2>/dev/null | wc -l)
    if [[ $guide_count -eq 0 ]]; then
        return 1
    fi

    # Check if organizational-level.json exists
    if [[ ! -f "$claude_dir/organizational-level.json" ]]; then
        # This is not critical, but preferred
        :
    fi

    # Check if preferences.json exists
    if [[ ! -f "$claude_dir/preferences.json" ]]; then
        # This will be created on first use, so not critical
        :
    fi

    # Setup appears complete
    return 0
}

# Get list of missing setup items
get_missing_setup_items() {
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    local role_guides_dirname
    role_guides_dirname="$(get_role_guides_dir)"
    local claude_dir="${1:-$claude_dir_name}"
    local missing=()

    if [[ ! -d "$claude_dir" ]]; then
        missing+=("$claude_dir_name directory")
    fi

    if [[ ! -d "$claude_dir/$role_guides_dirname" ]]; then
        missing+=("$role_guides_dirname directory")
    elif [[ $(find "$claude_dir/$role_guides_dirname" -name "*.md" 2>/dev/null | wc -l) -eq 0 ]]; then
        missing+=("role guide files")
    fi

    if [[ ! -f "$claude_dir/organizational-level.json" ]]; then
        missing+=("organizational-level.json (recommended)")
    fi

    if [[ ! -f "$claude_dir/preferences.json" ]]; then
        missing+=("preferences.json (will be created)")
    fi

    if [[ ! -f "$claude_dir/role-references.json" ]]; then
        missing+=("role-references.json (will be created)")
    fi

    # Print missing items as JSON array for easy parsing
    if command -v jq &>/dev/null; then
        printf '%s\n' "${missing[@]}" | jq -R . | jq -s .
    else
        # Fallback to newline-separated list
        printf '%s\n' "${missing[@]}"
    fi
}

# Check if template updates are available
check_template_updates() {
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)"
    local claude_dir="${1:-$claude_dir_name}"

    # Source template-manager.sh to access its functions
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    if [[ -f "$script_dir/template-manager.sh" ]]; then
        source "$script_dir/template-manager.sh"

        local version_check
        version_check=$(check_template_version "$claude_dir/preferences.json" 2>/dev/null)

        if [[ $version_check == update-available:* ]]; then
            echo "true"
            return 0
        fi
    fi

    echo "false"
    return 0
}

# =============================================================================
# Role Selection Assistant Helper Functions (v1.4.0)
# =============================================================================

# List all available roles as JSON array
cmd_list_roles_json() {
    local claude_dir
    claude_dir="$(find_claude_dir)" || {
        echo "[]"
        return 0
    }

    local role_guides_dirname
    role_guides_dirname="$(get_role_guides_dir)"
    local role_guides_dir="$claude_dir/$role_guides_dirname"

    if [[ ! -d "$role_guides_dir" ]]; then
        echo "[]"
        return 0
    fi

    # Build JSON array of role names
    local roles=()
    while IFS= read -r file; do
        local basename=$(basename "$file" .md)
        # Remove -guide suffix if present
        basename=${basename%-guide}
        roles+=("\"$basename\"")
    done < <(find "$role_guides_dir" -maxdepth 1 -name "*.md" 2>/dev/null | sort)

    # Generate JSON array
    if [[ ${#roles[@]} -eq 0 ]]; then
        echo "[]"
    else
        echo "["
        local first=true
        for role in "${roles[@]}"; do
            if [[ "$first" == "true" ]]; then
                echo -n "  $role"
                first=false
            else
                echo ","
                echo -n "  $role"
            fi
        done
        echo ""
        echo "]"
    fi
}

# Infer organizational level from role name using heuristics
infer_org_level_from_role() {
    local role="$1"

    # Convert to lowercase for matching
    local role_lower=$(echo "$role" | tr '[:upper:]' '[:lower:]')

    # Executive roles -> company
    if [[ "$role_lower" =~ ^(cto|cpo|ciso|vp-|chief-|executive) ]]; then
        echo "company"
        return 0
    fi

    # Management/architect roles -> system
    if [[ "$role_lower" =~ (manager|architect|platform-engineer|technical-lead|director|lead) ]]; then
        echo "system"
        return 0
    fi

    # Product roles -> product
    if [[ "$role_lower" =~ (product-manager|designer|ux-|ui-|qa-manager|product-owner) ]]; then
        echo "product"
        return 0
    fi

    # Default to project (implementation roles)
    echo "project"
    return 0
}

# Get all roles grouped by organizational level as JSON
cmd_get_all_roles_by_level() {
    local claude_dir
    claude_dir="$(find_claude_dir)" || {
        echo '{"company":[],"system":[],"product":[],"project":[]}'
        return 0
    }

    local role_guides_dirname
    role_guides_dirname="$(get_role_guides_dir)"
    local role_guides_dir="$claude_dir/$role_guides_dirname"

    if [[ ! -d "$role_guides_dir" ]]; then
        echo '{"company":[],"system":[],"product":[],"project":[]}'
        return 0
    fi

    # Initialize associative arrays for levels
    declare -A levels
    levels[company]=""
    levels[system]=""
    levels[product]=""
    levels[project]=""

    # Read each role guide and categorize
    while IFS= read -r file; do
        local basename=$(basename "$file" .md)
        # Remove -guide suffix if present
        basename=${basename%-guide}

        # Try to extract org level from file content
        local org_level=""
        if grep -qi "Organizational Level:" "$file"; then
            # Extract the level from the file (case-insensitive)
            org_level=$(grep -i "Organizational Level:" "$file" | head -1 | \
                sed 's/.*[Oo]rganizational [Ll]evel: *\([^ ,]*\).*/\1/' | \
                tr '[:upper:]' '[:lower:]')

            # Validate the extracted level
            if [[ ! "$org_level" =~ ^(company|system|product|project)$ ]]; then
                org_level=""
            fi
        fi

        # If no explicit level found, use heuristic
        if [[ -z "$org_level" ]]; then
            org_level=$(infer_org_level_from_role "$basename")
        fi

        # Add to appropriate level
        if [[ -n "${levels[$org_level]}" ]]; then
            levels[$org_level]="${levels[$org_level]},\"$basename\""
        else
            levels[$org_level]="\"$basename\""
        fi
    done < <(find "$role_guides_dir" -maxdepth 1 -name "*.md" 2>/dev/null | sort)

    # Build JSON output
    echo "{"
    echo "  \"company\": [${levels[company]}],"
    echo "  \"system\": [${levels[system]}],"
    echo "  \"product\": [${levels[product]}],"
    echo "  \"project\": [${levels[project]}]"
    echo "}"
}

# =============================================================================
# Main dispatcher (not typically called directly)
# =============================================================================

main() {
    local command="${1:-}"
    shift || true

    case "$command" in
        show|show-role-context)
            cmd_show_role_context "$@"
            ;;
        set|set-role)
            cmd_set_role "$@"
            ;;
        init|init-role-docs)
            cmd_init_role_docs "$@"
            ;;
        update|update-role-docs)
            cmd_update_role_docs "$@"
            ;;
        load|load-role-context)
            cmd_load_role_context "$@"
            ;;
        list-roles-json)
            cmd_list_roles_json "$@"
            ;;
        get-all-roles-by-level)
            cmd_get_all_roles_by_level "$@"
            ;;
        *)
            echo "Usage: $0 {show|set|init|update|load|list-roles-json|get-all-roles-by-level} [args...]" >&2
            exit 2
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
