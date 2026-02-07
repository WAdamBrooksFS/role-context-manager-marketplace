#!/usr/bin/env bash

# level-detector.sh - Detect organizational level of current directory
#
# Returns: company, system, product, or project
# Exit codes:
#   0 - Level detected successfully
#   1 - Unable to detect, user input required
#   2 - Error occurred

set -euo pipefail

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source path configuration library
source "$SCRIPT_DIR/path-config.sh"

# Source hierarchy detection functions (after path-config per C8)
source "$SCRIPT_DIR/hierarchy-detector.sh" 2>/dev/null || true

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

    # Detect parent context if hierarchy-detector is available
    local parent_dir=""
    local parent_level=""
    local valid_options=()
    local recommended=""

    if command -v get_nearest_parent &> /dev/null; then
        parent_dir="$(get_nearest_parent "$PWD" 2>/dev/null)" || parent_dir=""

        if [[ -n "$parent_dir" ]] && command -v get_level_value &> /dev/null; then
            parent_level="$(get_level_value "$parent_dir" 2>/dev/null)" || parent_level=""

            if [[ -n "$parent_level" ]]; then
                echo "Detected parent organizational level: $parent_level" >&2
                echo "" >&2

                # Determine valid child levels based on parent
                case "$parent_level" in
                    company)
                        valid_options=("system" "product" "project")
                        recommended="system"
                        ;;
                    system)
                        valid_options=("product" "project")
                        recommended="product"
                        ;;
                    product)
                        valid_options=("project")
                        recommended="project"
                        ;;
                    project)
                        echo "Warning: Parent is project level, which cannot have children" >&2
                        echo "Creating sibling project instead" >&2
                        valid_options=("project")
                        recommended="project"
                        ;;
                esac
            fi
        fi
    fi

    # If no parent detected or hierarchy-detector not available, allow all options
    if [[ ${#valid_options[@]} -eq 0 ]]; then
        valid_options=("company" "system" "product" "project")
        recommended="project"
    fi

    # Display options
    echo "Please specify the organizational level:" >&2
    local option_num=1
    local choice_map=()

    for level in "company" "system" "product" "project"; do
        # Check if this level is valid
        local is_valid=false
        for valid in "${valid_options[@]}"; do
            if [[ "$valid" == "$level" ]]; then
                is_valid=true
                break
            fi
        done

        if [[ "$is_valid" == "true" ]]; then
            local label=""
            case "$level" in
                company) label="Company (root level, executive roles)" ;;
                system) label="System (major initiative/platform)" ;;
                product) label="Product (group of related projects)" ;;
                project) label="Project (individual codebase)" ;;
            esac

            if [[ "$level" == "$recommended" ]]; then
                echo "  $option_num. $label [RECOMMENDED]" >&2
            else
                echo "  $option_num. $label" >&2
            fi

            choice_map+=("$level")
            ((option_num++))
        fi
    done

    echo "" >&2
    echo -n "Enter choice [1-${#choice_map[@]}]: " >&2

    read -r choice

    # Validate choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#choice_map[@]} )); then
        local selected_level="${choice_map[$((choice-1))]}"

        # Validate against parent if hierarchy-detector available
        if [[ -n "$parent_level" ]] && command -v is_valid_child_level &> /dev/null; then
            if is_valid_child_level "$parent_level" "$selected_level" 2>/dev/null; then
                echo "$selected_level"
            else
                echo "Warning: Invalid hierarchy relationship, but proceeding anyway" >&2
                echo "$selected_level"
            fi
        else
            echo "$selected_level"
        fi
    else
        echo "Invalid choice. Using recommended: $recommended" >&2
        echo "$recommended"
    fi
}

# Save level to organizational-level.json
save_level() {
    local claude_dir="$1"
    local level="$2"
    local level_name="$(basename "$(dirname "$claude_dir")")"

    # Use hierarchy-aware save if available
    if command -v save_level_with_hierarchy &> /dev/null; then
        save_level_with_hierarchy "$claude_dir" "$level" "$level_name"
        return $?
    fi

    # Fallback to basic save if hierarchy-detector not available
    local level_file="$claude_dir/organizational-level.json"

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
