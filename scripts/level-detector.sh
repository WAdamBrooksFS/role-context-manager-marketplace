#!/usr/bin/env bash

# level-detector.sh - Detect organizational level of current directory
#
# Returns: company, system, product, or project
# Exit codes:
#   0 - Level detected successfully
#   1 - Unable to detect, user input required
#   2 - Error occurred

set -euo pipefail

# Source path configuration library
source "$(dirname "$0")/path-config.sh"

# Find nearest .claude directory
find_claude_dir() {
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)" || claude_dir_name=".claude"

    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/$claude_dir_name" ]]; then
            echo "$dir/$claude_dir_name"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo ""
    return 1
}

# Check if organizational-level.json exists and read it
read_explicit_level() {
    local claude_dir="$1"
    local level_file="$claude_dir/organizational-level.json"

    if [[ -f "$level_file" ]]; then
        if command -v jq &> /dev/null; then
            jq -r '.level // empty' "$level_file" 2>/dev/null || echo ""
        else
            # Fallback without jq
            grep -o '"level"[[:space:]]*:[[:space:]]*"[^"]*"' "$level_file" 2>/dev/null | \
                sed 's/.*"\([^"]*\)"/\1/' || echo ""
        fi
    else
        echo ""
    fi
}

# Detect level based on heuristics
detect_by_heuristics() {
    local claude_dir="$1"
    local project_dir="$(dirname "$claude_dir")"

    local score_project=0
    local score_product=0
    local score_system=0
    local score_company=0

    # Check for project-level indicators
    if [[ -f "$project_dir/package.json" ]] || \
       [[ -f "$project_dir/pom.xml" ]] || \
       [[ -f "$project_dir/Cargo.toml" ]] || \
       [[ -f "$project_dir/go.mod" ]] || \
       [[ -f "$project_dir/requirements.txt" ]] || \
       [[ -f "$project_dir/Gemfile" ]] || \
       [[ -f "$project_dir/composer.json" ]]; then
        ((score_project+=3))
    fi

    if [[ -d "$project_dir/src" ]] || [[ -d "$project_dir/lib" ]] || [[ -d "$project_dir/app" ]]; then
        ((score_project+=2))
    fi

    # Check for implementation roles in role-guides
    local role_guides_dir
    role_guides_dir="$(get_role_guides_dir)" || role_guides_dir="role-guides"

    if [[ -d "$claude_dir/$role_guides_dir" ]]; then
        if ls "$claude_dir/$role_guides_dir"/*engineer*.md &>/dev/null || \
           ls "$claude_dir/$role_guides_dir"/*developer*.md &>/dev/null || \
           ls "$claude_dir/$role_guides_dir"/sdet*.md &>/dev/null || \
           ls "$claude_dir/$role_guides_dir"/qa-engineer*.md &>/dev/null; then
            ((score_project+=2))
        fi
    fi

    # Check for product-level indicators
    if [[ -f "$project_dir/product-overview.md" ]] || \
       [[ -f "$project_dir/roadmap.md" ]]; then
        ((score_product+=2))
    fi

    # Check for multiple project-like subdirectories
    local project_subdirs=0
    for dir in "$project_dir"/*/; do
        if [[ -f "${dir}package.json" ]] || [[ -f "${dir}pom.xml" ]] || [[ -d "${dir}src" ]]; then
            ((project_subdirs++))
        fi
    done
    if (( project_subdirs >= 2 )); then
        ((score_product+=3))
    fi

    # Check for coordination roles
    if [[ -d "$claude_dir/$role_guides_dir" ]]; then
        if ls "$claude_dir/$role_guides_dir"/*qa-manager*.md &>/dev/null || \
           ls "$claude_dir/$role_guides_dir"/*designer*.md &>/dev/null; then
            ((score_product+=2))
        fi
    fi

    # Check for system-level indicators
    if [[ -f "$project_dir/objectives-and-key-results.md" ]]; then
        # Could be system or company, check for subdirectories
        local product_subdirs=0
        for dir in "$project_dir"/*/; do
            if [[ -f "${dir}product-overview.md" ]] || [[ -f "${dir}roadmap.md" ]]; then
                ((product_subdirs++))
            fi
        done
        if (( product_subdirs >= 2 )); then
            ((score_system+=3))
        else
            ((score_company+=2))
        fi
    fi

    # Check for system roles
    if [[ -d "$claude_dir/$role_guides_dir" ]]; then
        if ls "$claude_dir/$role_guides_dir"/*manager*.md &>/dev/null || \
           ls "$claude_dir/$role_guides_dir"/*platform*.md &>/dev/null || \
           ls "$claude_dir/$role_guides_dir"/technical-*.md &>/dev/null; then
            ((score_system+=2))
        fi
    fi

    # Check for company-level indicators
    if [[ -f "$project_dir/strategy.md" ]]; then
        ((score_company+=3))
    fi

    # Check if at repository root
    if [[ -d "$project_dir/.git" ]]; then
        local parent_git="$(dirname "$project_dir")/.git"
        if [[ ! -d "$parent_git" ]]; then
            # This is the git root
            ((score_company+=2))
        fi
    fi

    # Check for executive roles
    if [[ -d "$claude_dir/$role_guides_dir" ]]; then
        if ls "$claude_dir/$role_guides_dir"/cto*.md &>/dev/null || \
           ls "$claude_dir/$role_guides_dir"/cpo*.md &>/dev/null || \
           ls "$claude_dir/$role_guides_dir"/ciso*.md &>/dev/null || \
           ls "$claude_dir/$role_guides_dir"/*vp-*.md &>/dev/null; then
            ((score_company+=3))
        fi
    fi

    # Determine winner
    local max_score=0
    local detected_level=""

    if (( score_project > max_score )); then
        max_score=$score_project
        detected_level="project"
    fi
    if (( score_product > max_score )); then
        max_score=$score_product
        detected_level="product"
    fi
    if (( score_system > max_score )); then
        max_score=$score_system
        detected_level="system"
    fi
    if (( score_company > max_score )); then
        max_score=$score_company
        detected_level="company"
    fi

    # Need at least score of 3 to be confident
    if (( max_score >= 3 )); then
        echo "$detected_level"
        return 0
    else
        echo ""
        return 1
    fi
}

# Prompt user for level
prompt_user_for_level() {
    echo "Unable to automatically detect organizational level." >&2
    echo "" >&2
    echo "Current directory: $PWD" >&2
    echo "" >&2
    echo "Please specify the organizational level:" >&2
    echo "  1. Company (root level, executive roles)" >&2
    echo "  2. System (major initiative/platform)" >&2
    echo "  3. Product (group of related projects)" >&2
    echo "  4. Project (individual codebase)" >&2
    echo "" >&2
    echo -n "Enter choice [1-4]: " >&2

    read -r choice

    case "$choice" in
        1) echo "company" ;;
        2) echo "system" ;;
        3) echo "product" ;;
        4) echo "project" ;;
        *)
            echo "Invalid choice. Defaulting to project." >&2
            echo "project"
            ;;
    esac
}

# Save level to organizational-level.json
save_level() {
    local claude_dir="$1"
    local level="$2"
    local level_file="$claude_dir/organizational-level.json"
    local level_name="$(basename "$(dirname "$claude_dir")")"

    if command -v jq &> /dev/null; then
        jq -n \
            --arg level "$level" \
            --arg name "$level_name" \
            '{level: $level, level_name: $name}' \
            > "$level_file"
    else
        # Fallback without jq
        cat > "$level_file" <<EOF
{
  "level": "$level",
  "level_name": "$level_name"
}
EOF
    fi

    echo "Saved organizational level to: $level_file" >&2
}

# Main function
main() {
    local claude_dir
    local claude_dir_name
    claude_dir_name="$(get_claude_dir_name)" || claude_dir_name=".claude"

    claude_dir="$(find_claude_dir)" || {
        echo "Error: No $claude_dir_name directory found in current path" >&2
        exit 2
    }

    # Check for explicit level
    local explicit_level
    explicit_level="$(read_explicit_level "$claude_dir")"

    if [[ -n "$explicit_level" ]]; then
        echo "$explicit_level"
        exit 0
    fi

    # Try heuristic detection
    local detected_level
    if detected_level="$(detect_by_heuristics "$claude_dir")"; then
        # Save detected level for future use
        save_level "$claude_dir" "$detected_level"
        echo "$detected_level"
        exit 0
    fi

    # Prompt user
    local user_level
    user_level="$(prompt_user_for_level)"
    save_level "$claude_dir" "$user_level"
    echo "$user_level"
    exit 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
