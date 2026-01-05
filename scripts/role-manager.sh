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

# Source helper scripts
source "$SCRIPT_DIR/level-detector.sh" 2>/dev/null || true
source "$SCRIPT_DIR/doc-validator.sh" 2>/dev/null || true

# Find nearest .claude directory
find_claude_dir() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.claude" ]]; then
            echo "$dir/.claude"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo ""
    return 1
}

# Ensure .claude directory exists
ensure_claude_dir() {
    if [[ ! -d ".claude" ]]; then
        mkdir -p ".claude"
        echo "Created .claude directory" >&2
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

    local role_guide="$claude_dir/role-guides/${role}-guide.md"

    if [[ -f "$role_guide" ]]; then
        echo "$role_guide"
        return 0
    fi

    # Try without -guide suffix
    role_guide="$claude_dir/role-guides/${role}.md"
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
    local role_guides_dir="$claude_dir/role-guides"

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
    claude_dir="$(find_claude_dir)" || {
        echo "Error: No .claude directory found" >&2
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
    claude_dir="$(find_claude_dir)" || {
        ensure_claude_dir
        claude_dir="./.claude"
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

    local claude_dir
    claude_dir="$(find_claude_dir)" || {
        echo "Error: No .claude directory found" >&2
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

    local claude_dir
    claude_dir="$(find_claude_dir)" || {
        echo "Error: No .claude directory found" >&2
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

# Main dispatcher (not typically called directly)
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
        *)
            echo "Usage: $0 {show|set|init|update} [args...]" >&2
            exit 2
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
