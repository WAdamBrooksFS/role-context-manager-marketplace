#!/usr/bin/env bash

# hierarchy-detector.sh - Detect and manage organizational hierarchy
#
# Functions:
#   - find_parent_claude_dirs: Search upward to find all parent .claude directories
#   - get_nearest_parent: Return path to immediate parent .claude directory
#   - read_level_from_claude_dir: Parse organizational-level.json from a path
#   - build_hierarchy_path: Construct full hierarchy array from root to current
#   - is_valid_child_level: Validate parent-child relationships
#   - save_level_with_hierarchy: Write organizational-level.json with extended schema
#
# Exit codes:
#   0 - Success
#   1 - Validation/logic error
#   2 - System error (file not found, permissions, etc.)

set -euo pipefail

# =============================================================================
# Core Hierarchy Detection Functions
# =============================================================================

# Find all parent .claude directories from current location to root
# Args:
#   $1: starting directory (default: PWD)
# Returns:
#   Newline-separated list of .claude directory paths (nearest to farthest)
find_parent_claude_dirs() {
    local start_dir="${1:-$PWD}"
    local dir="$start_dir"
    local parent_dirs=()

    # Start from parent of current directory to avoid including current .claude
    dir="$(dirname "$dir")"

    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.claude" ]]; then
            parent_dirs+=("$dir/.claude")
        fi
        dir="$(dirname "$dir")"
    done

    # Output parent directories (nearest first)
    printf '%s\n' "${parent_dirs[@]}"
}

# Get the nearest parent .claude directory
# Args:
#   $1: starting directory (default: PWD)
# Returns:
#   Path to nearest parent .claude directory, or empty string if none found
get_nearest_parent() {
    local start_dir="${1:-$PWD}"
    local dir="$start_dir"

    # Start from parent of current directory
    dir="$(dirname "$dir")"

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

# Read organizational level information from a .claude directory
# Args:
#   $1: path to .claude directory
# Returns:
#   JSON object with level information, or empty object if not found
read_level_from_claude_dir() {
    local claude_dir="$1"
    local level_file="$claude_dir/organizational-level.json"

    if [[ ! -f "$level_file" ]]; then
        echo "{}"
        return 1
    fi

    if command -v jq &> /dev/null; then
        jq -c '.' "$level_file" 2>/dev/null || echo "{}"
    else
        # Fallback without jq - just output the file
        cat "$level_file" 2>/dev/null || echo "{}"
    fi
}

# Extract just the level value from a .claude directory
# Args:
#   $1: path to .claude directory
# Returns:
#   Level string (company|system|product|project) or empty string
get_level_value() {
    local claude_dir="$1"
    local level_file="$claude_dir/organizational-level.json"

    if [[ ! -f "$level_file" ]]; then
        echo ""
        return 1
    fi

    if command -v jq &> /dev/null; then
        jq -r '.level // empty' "$level_file" 2>/dev/null || echo ""
    else
        # Fallback without jq
        grep -o '"level"[[:space:]]*:[[:space:]]*"[^"]*"' "$level_file" 2>/dev/null | \
            sed 's/.*"\([^"]*\)"/\1/' || echo ""
    fi
}

# Build full hierarchy path from root to current level
# Args:
#   $1: current .claude directory
# Returns:
#   JSON array of levels from root to current (e.g., ["company", "system", "product", "project"])
build_hierarchy_path() {
    local current_claude_dir="$1"
    local hierarchy=()

    # Find all parent .claude directories (including ancestors)
    local current_dir="$(dirname "$current_claude_dir")"
    local all_dirs=()

    # Collect all .claude directories from root to current
    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/.claude" && "$current_dir/.claude" != "$current_claude_dir" ]]; then
            all_dirs=("$current_dir/.claude" "${all_dirs[@]}")
        fi
        current_dir="$(dirname "$current_dir")"
    done

    # Add current directory
    all_dirs+=("$current_claude_dir")

    # Extract levels from each directory
    for dir in "${all_dirs[@]}"; do
        local level
        level="$(get_level_value "$dir")"
        if [[ -n "$level" ]]; then
            hierarchy+=("$level")
        fi
    done

    # Output as JSON array
    if command -v jq &> /dev/null; then
        printf '%s\n' "${hierarchy[@]}" | jq -R -s -c 'split("\n") | map(select(length > 0))'
    else
        # Fallback without jq
        echo -n "["
        local first=true
        for level in "${hierarchy[@]}"; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo -n ","
            fi
            echo -n "\"$level\""
        done
        echo "]"
    fi
}

# Validate parent-child organizational level relationship
# Args:
#   $1: parent level (company|system|product|project)
#   $2: child level (company|system|product|project)
# Returns:
#   0 if valid relationship, 1 if invalid
# Rules:
#   - company → system, product, project (all valid)
#   - system → product, project (valid)
#   - product → project (valid)
#   - project → (no children allowed)
is_valid_child_level() {
    local parent_level="$1"
    local child_level="$2"

    # Validate inputs
    if [[ ! "$parent_level" =~ ^(company|system|product|project)$ ]]; then
        echo "Error: Invalid parent level: $parent_level" >&2
        return 1
    fi

    if [[ ! "$child_level" =~ ^(company|system|product|project)$ ]]; then
        echo "Error: Invalid child level: $child_level" >&2
        return 1
    fi

    # A level cannot be a child of itself
    if [[ "$parent_level" == "$child_level" ]]; then
        return 1
    fi

    # Apply validation rules
    case "$parent_level" in
        company)
            # Company can contain: system, product, project
            if [[ "$child_level" =~ ^(system|product|project)$ ]]; then
                return 0
            fi
            ;;
        system)
            # System can contain: product, project
            if [[ "$child_level" =~ ^(product|project)$ ]]; then
                return 0
            fi
            ;;
        product)
            # Product can contain: project only
            if [[ "$child_level" == "project" ]]; then
                return 0
            fi
            ;;
        project)
            # Project cannot have children
            return 1
            ;;
    esac

    # Default: invalid relationship
    return 1
}

# Save organizational level with extended hierarchy information
# Args:
#   $1: .claude directory path
#   $2: level (company|system|product|project)
#   $3: level_name (optional, defaults to directory name)
# Returns:
#   0 on success, 1 on validation error, 2 on system error
save_level_with_hierarchy() {
    local claude_dir="$1"
    local level="$2"
    local level_name="${3:-}"

    # Validate level
    if [[ ! "$level" =~ ^(company|system|product|project)$ ]]; then
        echo "Error: Invalid level: $level" >&2
        echo "Must be one of: company, system, product, project" >&2
        return 1
    fi

    # Default level_name to parent directory name
    if [[ -z "$level_name" ]]; then
        level_name="$(basename "$(dirname "$claude_dir")")"
    fi

    # Ensure .claude directory exists
    if [[ ! -d "$claude_dir" ]]; then
        mkdir -p "$claude_dir" || {
            echo "Error: Cannot create directory: $claude_dir" >&2
            return 2
        }
    fi

    local level_file="$claude_dir/organizational-level.json"

    # Find parent .claude directory
    local parent_dir
    parent_dir="$(get_nearest_parent "$(dirname "$claude_dir")")" || parent_dir=""

    # Get parent level if parent exists
    local parent_level=""
    if [[ -n "$parent_dir" ]]; then
        parent_level="$(get_level_value "$parent_dir")"

        # Validate parent-child relationship
        if [[ -n "$parent_level" ]]; then
            if ! is_valid_child_level "$parent_level" "$level"; then
                echo "Error: Invalid hierarchy - $level cannot be a child of $parent_level" >&2
                return 1
            fi
        fi
    fi

    # Determine if this is root (no parent)
    local is_root="false"
    if [[ -z "$parent_dir" ]]; then
        is_root="true"
    fi

    # Build hierarchy path
    local hierarchy_path
    if [[ -n "$parent_dir" ]]; then
        # Get parent's hierarchy and append current level
        local parent_hierarchy
        parent_hierarchy="$(build_hierarchy_path "$parent_dir")"
        # Append current level to parent hierarchy
        if command -v jq &> /dev/null; then
            hierarchy_path="$(echo "$parent_hierarchy" | jq -c --arg level "$level" '. + [$level]')"
        else
            # Fallback without jq - remove trailing ] and append
            hierarchy_path="${parent_hierarchy%]}"
            if [[ "$hierarchy_path" == "[" ]]; then
                hierarchy_path="[\"$level\"]"
            else
                hierarchy_path="${hierarchy_path},\"$level\"]"
            fi
        fi
    else
        # Root level - create single-element array
        hierarchy_path="[\"$level\"]"
    fi

    # Write extended organizational-level.json
    if command -v jq &> /dev/null; then
        jq -n \
            --arg level "$level" \
            --arg name "$level_name" \
            --arg parent_dir "$parent_dir" \
            --arg parent_level "$parent_level" \
            --argjson is_root "$is_root" \
            --argjson hierarchy "$hierarchy_path" \
            '{
                level: $level,
                level_name: $name,
                parent_claude_dir: (if $parent_dir == "" then null else $parent_dir end),
                parent_level: (if $parent_level == "" then null else $parent_level end),
                is_root: $is_root,
                hierarchy_path: $hierarchy
            }' > "$level_file"
    else
        # Fallback without jq
        cat > "$level_file" <<EOF
{
  "level": "$level",
  "level_name": "$level_name",
  "parent_claude_dir": $(if [[ -z "$parent_dir" ]]; then echo "null"; else echo "\"$parent_dir\""; fi),
  "parent_level": $(if [[ -z "$parent_level" ]]; then echo "null"; else echo "\"$parent_level\""; fi),
  "is_root": $is_root,
  "hierarchy_path": $hierarchy_path
}
EOF
    fi

    echo "✓ Saved organizational level to: $level_file" >&2
    echo "  Level: $level" >&2
    echo "  Name: $level_name" >&2
    if [[ -n "$parent_dir" ]]; then
        echo "  Parent: $parent_level at $parent_dir" >&2
    else
        echo "  Root: true" >&2
    fi
    echo "  Hierarchy: $(echo "$hierarchy_path" | tr -d '[]"' | tr ',' ' ')" >&2

    return 0
}

# =============================================================================
# Validation and Helper Functions
# =============================================================================

# Check if current directory is within a valid organizational hierarchy
# Returns:
#   0 if valid hierarchy, 1 if issues found
validate_hierarchy() {
    local current_dir="${1:-$PWD}"

    # Find current .claude directory
    local dir="$current_dir"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.claude" ]]; then
            local claude_dir="$dir/.claude"
            local level_file="$claude_dir/organizational-level.json"

            if [[ ! -f "$level_file" ]]; then
                echo "Warning: No organizational-level.json found at: $claude_dir" >&2
                return 1
            fi

            # Read current level
            local current_level
            current_level="$(get_level_value "$claude_dir")"

            if [[ -z "$current_level" ]]; then
                echo "Warning: Cannot read level from: $level_file" >&2
                return 1
            fi

            # Check parent relationship if parent exists
            local parent_dir
            parent_dir="$(get_nearest_parent "$dir")" || parent_dir=""

            if [[ -n "$parent_dir" ]]; then
                local parent_level
                parent_level="$(get_level_value "$parent_dir")"

                if [[ -n "$parent_level" ]]; then
                    if ! is_valid_child_level "$parent_level" "$current_level"; then
                        echo "Error: Invalid hierarchy - $current_level cannot be child of $parent_level" >&2
                        echo "  Current: $claude_dir" >&2
                        echo "  Parent: $parent_dir" >&2
                        return 1
                    fi
                fi
            fi

            echo "✓ Valid hierarchy at: $claude_dir" >&2
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    echo "No .claude directory found in current path" >&2
    return 1
}

# Display hierarchy information for current location
# Returns:
#   Human-readable hierarchy information
show_hierarchy() {
    local current_dir="${1:-$PWD}"

    # Find current .claude directory
    local dir="$current_dir"
    local found=false

    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.claude" ]]; then
            found=true
            local claude_dir="$dir/.claude"

            echo "Current organizational context:"
            echo ""

            # Read level info
            local level_info
            level_info="$(read_level_from_claude_dir "$claude_dir")"

            if [[ "$level_info" != "{}" ]]; then
                if command -v jq &> /dev/null; then
                    local level=$(echo "$level_info" | jq -r '.level // "unknown"')
                    local name=$(echo "$level_info" | jq -r '.level_name // "unnamed"')
                    local is_root=$(echo "$level_info" | jq -r '.is_root // false')
                    local parent_level=$(echo "$level_info" | jq -r '.parent_level // "none"')
                    local hierarchy=$(echo "$level_info" | jq -r '.hierarchy_path // [] | join(" → ")')

                    echo "  Location: $claude_dir"
                    echo "  Level: $level"
                    echo "  Name: $name"
                    echo "  Root: $is_root"
                    if [[ "$parent_level" != "none" && "$parent_level" != "null" ]]; then
                        echo "  Parent level: $parent_level"
                    fi
                    if [[ -n "$hierarchy" ]]; then
                        echo "  Hierarchy: $hierarchy"
                    fi
                else
                    echo "  Location: $claude_dir"
                    echo "  Level info: $level_info"
                fi
            else
                echo "  Location: $claude_dir"
                echo "  No level information available"
            fi

            break
        fi
        dir="$(dirname "$dir")"
    done

    if [[ "$found" == "false" ]]; then
        echo "No .claude directory found in current path"
        return 1
    fi
}

# =============================================================================
# Main dispatcher (for direct script execution)
# =============================================================================

main() {
    local command="${1:-}"
    shift || true

    case "$command" in
        find-parents)
            find_parent_claude_dirs "$@"
            ;;
        get-parent)
            get_nearest_parent "$@"
            ;;
        read-level)
            read_level_from_claude_dir "$@"
            ;;
        build-hierarchy)
            build_hierarchy_path "$@"
            ;;
        validate-child)
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 validate-child <parent-level> <child-level>" >&2
                exit 1
            fi
            if is_valid_child_level "$1" "$2"; then
                echo "Valid: $2 can be a child of $1"
                exit 0
            else
                echo "Invalid: $2 cannot be a child of $1"
                exit 1
            fi
            ;;
        save-level)
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 save-level <claude-dir> <level> [level-name]" >&2
                exit 1
            fi
            save_level_with_hierarchy "$@"
            ;;
        validate)
            validate_hierarchy "$@"
            ;;
        show)
            show_hierarchy "$@"
            ;;
        *)
            echo "Usage: $0 {find-parents|get-parent|read-level|build-hierarchy|validate-child|save-level|validate|show} [args...]" >&2
            echo "" >&2
            echo "Commands:" >&2
            echo "  find-parents [dir]              - Find all parent .claude directories" >&2
            echo "  get-parent [dir]                - Get nearest parent .claude directory" >&2
            echo "  read-level <claude-dir>         - Read organizational-level.json" >&2
            echo "  build-hierarchy <claude-dir>    - Build hierarchy path array" >&2
            echo "  validate-child <parent> <child> - Validate parent-child relationship" >&2
            echo "  save-level <dir> <level> [name] - Save level with hierarchy info" >&2
            echo "  validate [dir]                  - Validate hierarchy at directory" >&2
            echo "  show [dir]                      - Show hierarchy information" >&2
            exit 2
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
