#!/usr/bin/env bash

# claude-md-analyzer.sh - Detect and analyze CLAUDE.md files
# Part of role-context-manager v1.1.0
#
# Functions:
#   - scan_for_claude_md: Case-insensitive detection up to 4 directory levels
#   - analyze_claude_md_content: Analyze content and structure
#
# Exit codes:
#   0 - Success (even if no files found - non-blocking)
#   1 - Error occurred

set -euo pipefail

# Get plugin directory
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# =============================================================================
# CLAUDE.md Detection Functions
# =============================================================================

# Scan for CLAUDE.md files (case-insensitive, up to 4 levels deep)
scan_for_claude_md() {
    local search_dir="${1:-.}"
    local max_depth="${2:-4}"

    if [ ! -d "$search_dir" ]; then
        echo "Error: Directory not found: $search_dir" >&2
        return 1
    fi

    # Find CLAUDE.md files case-insensitively
    local -a found_files=()

    while IFS= read -r -d '' file; do
        found_files+=("$file")
    done < <(find "$search_dir" -maxdepth "$max_depth" -iname "claude.md" -type f -print0 2>/dev/null)

    # Output JSON array of found files
    if command -v jq &>/dev/null; then
        printf '%s\n' "${found_files[@]}" | jq -R -s 'split("\n") | map(select(length > 0))'
    else
        # Fallback without jq
        echo "["
        local first=true
        for file in "${found_files[@]}"; do
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            printf '  "%s"' "$file"
        done
        echo ""
        echo "]"
    fi

    return 0
}

# Analyze CLAUDE.md content
analyze_claude_md_content() {
    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        echo "Error: File not found: $file_path" >&2
        return 1
    fi

    # Count lines
    local line_count
    line_count=$(wc -l < "$file_path" 2>/dev/null || echo "0")

    # Count sections (markdown headers)
    local section_count
    section_count=$(grep -c '^#' "$file_path" 2>/dev/null || echo "0")

    # Detect key sections
    local has_mission=false
    local has_capabilities=false
    local has_guidelines=false
    local has_tools=false
    local has_examples=false

    if grep -qi '##.*mission' "$file_path" 2>/dev/null; then
        has_mission=true
    fi

    if grep -qi '##.*capabilit' "$file_path" 2>/dev/null; then
        has_capabilities=true
    fi

    if grep -qi '##.*guideline' "$file_path" 2>/dev/null; then
        has_guidelines=true
    fi

    if grep -qi '##.*tool' "$file_path" 2>/dev/null; then
        has_tools=true
    fi

    if grep -qi '##.*example' "$file_path" 2>/dev/null; then
        has_examples=true
    fi

    # Get relative path
    local rel_path="$file_path"
    if [[ "$file_path" = /* ]]; then
        rel_path=$(realpath --relative-to="$PWD" "$file_path" 2>/dev/null || echo "$file_path")
    fi

    # Output JSON analysis
    if command -v jq &>/dev/null; then
        jq -n \
            --arg path "$rel_path" \
            --arg abs_path "$file_path" \
            --argjson lines "$line_count" \
            --argjson sections "$section_count" \
            --argjson mission "$has_mission" \
            --argjson capabilities "$has_capabilities" \
            --argjson guidelines "$has_guidelines" \
            --argjson tools "$has_tools" \
            --argjson examples "$has_examples" \
            '{
                path: $path,
                absolute_path: $abs_path,
                line_count: $lines,
                section_count: $sections,
                has_standard_sections: {
                    mission: $mission,
                    capabilities: $capabilities,
                    guidelines: $guidelines,
                    tools: $tools,
                    examples: $examples
                }
            }'
    else
        # Fallback without jq
        cat <<EOF
{
  "path": "$rel_path",
  "absolute_path": "$file_path",
  "line_count": $line_count,
  "section_count": $section_count,
  "has_standard_sections": {
    "mission": $has_mission,
    "capabilities": $has_capabilities,
    "guidelines": $has_guidelines,
    "tools": $has_tools,
    "examples": $has_examples
  }
}
EOF
    fi

    return 0
}

# =============================================================================
# Suggestion Generation Functions
# =============================================================================

# Generate enhancement suggestions based on CLAUDE.md analysis
suggest_enhancements() {
    local file_path="$1"
    local template_id="${2:-software-org}"

    if [ ! -f "$file_path" ]; then
        echo "Error: File not found: $file_path" >&2
        return 1
    fi

    # Analyze the file first
    local analysis
    analysis=$(analyze_claude_md_content "$file_path" 2>/dev/null)

    if [ -z "$analysis" ]; then
        echo "Error: Failed to analyze file" >&2
        return 1
    fi

    # Extract analysis data
    local line_count
    local has_mission
    local has_capabilities
    local has_guidelines
    local has_tools
    local has_examples

    if command -v jq &>/dev/null; then
        line_count=$(echo "$analysis" | jq -r '.line_count')
        has_mission=$(echo "$analysis" | jq -r '.has_standard_sections.mission')
        has_capabilities=$(echo "$analysis" | jq -r '.has_standard_sections.capabilities')
        has_guidelines=$(echo "$analysis" | jq -r '.has_standard_sections.guidelines')
        has_tools=$(echo "$analysis" | jq -r '.has_standard_sections.tools')
        has_examples=$(echo "$analysis" | jq -r '.has_standard_sections.examples')
    else
        line_count=0
    fi

    # Determine suggestion depth based on file size
    local -a suggestions=()

    # Generate suggestions based on missing sections and file size
    if [ "$line_count" -lt 100 ]; then
        # Small file - generate 2-3 high-level suggestions
        if [ "$has_mission" = "false" ]; then
            suggestions+=('{"type": "add_section", "priority": "high", "section": "Mission Statement", "description": "Add a clear mission statement describing the purpose and goals of your project", "rationale": "Helps Claude understand project objectives"}')
        fi

        if [ "$has_capabilities" = "false" ]; then
            suggestions+=('{"type": "add_section", "priority": "high", "section": "Key Capabilities", "description": "Document the main features and capabilities of your project", "rationale": "Provides context for code modifications"}')
        fi

        if [ "$has_guidelines" = "false" ]; then
            suggestions+=('{"type": "add_section", "priority": "medium", "section": "Development Guidelines", "description": "Add coding standards and development practices", "rationale": "Ensures consistent code quality"}')
        fi
    else
        # Large file - generate 5-7 detailed suggestions with examples
        if [ "$has_mission" = "false" ]; then
            suggestions+=('{"type": "add_section", "priority": "high", "section": "Mission Statement", "description": "Add a comprehensive mission statement with objectives and success criteria", "rationale": "Critical for AI to align code changes with project goals", "example": "## Mission\n\nThis project aims to [objective]. Success is measured by [criteria]."}')
        fi

        if [ "$has_capabilities" = "false" ]; then
            suggestions+=('{"type": "add_section", "priority": "high", "section": "Capabilities", "description": "Document all major capabilities with technical details", "rationale": "Enables AI to understand system architecture and suggest appropriate solutions", "example": "## Capabilities\n\n- **Feature A**: Description and technical approach\n- **Feature B**: Description and technical approach"}')
        fi

        if [ "$has_guidelines" = "false" ]; then
            suggestions+=('{"type": "add_section", "priority": "high", "section": "Development Guidelines", "description": "Comprehensive coding standards, testing requirements, and best practices", "rationale": "Ensures AI generates code that meets project standards", "example": "## Guidelines\n\n### Code Style\n- Use ESLint configuration\n- Follow naming conventions\n\n### Testing\n- Unit tests required for all features"}')
        fi

        if [ "$has_tools" = "false" ]; then
            suggestions+=('{"type": "add_section", "priority": "medium", "section": "Tools and Dependencies", "description": "List development tools, frameworks, and key dependencies", "rationale": "Helps AI understand the technology stack and suggest compatible solutions", "example": "## Tools\n\n- Language: Python 3.9+\n- Framework: Django 4.0\n- Database: PostgreSQL"}')
        fi

        if [ "$has_examples" = "false" ]; then
            suggestions+=('{"type": "add_section", "priority": "medium", "section": "Examples", "description": "Add code examples showing common patterns and usage", "rationale": "Provides concrete patterns for AI to follow", "example": "## Examples\n\n### Creating a new API endpoint\n```python\n# example code\n```"}')
        fi

        # Additional suggestions for larger files
        suggestions+=('{"type": "enhancement", "priority": "low", "section": "Role-Guides Reference", "description": "Link to .claude/role-guides/ for specialized roles", "rationale": "Enables switching to specialized agent contexts", "example": "## Role-Specific Guidance\n\nFor specialized tasks, see role guides in .claude/role-guides/"}')

        suggestions+=('{"type": "enhancement", "priority": "low", "section": "Plugin Features", "description": "Document how to use role-context-manager plugin features", "rationale": "Ensures team knows about available automation", "example": "## Available Commands\n\n- /load-role-context [role] - Load specialized role context"}')
    fi

    # Output suggestions as JSON
    if command -v jq &>/dev/null; then
        printf '%s\n' "${suggestions[@]}" | jq -s '{
            file: "'$file_path'",
            line_count: '$line_count',
            suggestion_count: length,
            enhancements: .
        }'
    else
        # Fallback without jq
        echo "{"
        echo "  \"file\": \"$file_path\","
        echo "  \"line_count\": $line_count,"
        echo "  \"suggestion_count\": ${#suggestions[@]},"
        echo "  \"enhancements\": ["
        local first=true
        for suggestion in "${suggestions[@]}"; do
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            echo "    $suggestion"
        done
        echo ""
        echo "  ]"
        echo "}"
    fi

    return 0
}

# =============================================================================
# CLI Interface
# =============================================================================

show_usage() {
    cat <<EOF
Usage: claude-md-analyzer.sh [OPTIONS] [DIRECTORY]

Detect and analyze CLAUDE.md files in a directory tree.

OPTIONS:
    --scan [DIR]           Scan for CLAUDE.md files (default: current directory)
    --analyze FILE         Analyze a specific CLAUDE.md file
    --suggest FILE [TMPL]  Generate enhancement suggestions for CLAUDE.md
    --help                 Show this help message

EXAMPLES:
    # Scan current directory
    claude-md-analyzer.sh --scan

    # Scan specific directory
    claude-md-analyzer.sh --scan /path/to/project

    # Analyze specific file
    claude-md-analyzer.sh --analyze /path/to/CLAUDE.md

    # Generate suggestions for a file
    claude-md-analyzer.sh --suggest /path/to/CLAUDE.md software-org

OUTPUT:
    JSON format with file paths and analysis results
EOF
}

# Main function
main() {
    local action=""
    local target=""
    local template_id="software-org"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --scan)
                action="scan"
                target="${2:-.}"
                if [[ $# -gt 1 && ! "$2" =~ ^-- ]]; then
                    shift
                fi
                shift
                ;;
            --analyze)
                action="analyze"
                if [ $# -lt 2 ]; then
                    echo "Error: --analyze requires a file path" >&2
                    exit 1
                fi
                target="$2"
                shift 2
                ;;
            --suggest)
                action="suggest"
                if [ $# -lt 2 ]; then
                    echo "Error: --suggest requires a file path" >&2
                    exit 1
                fi
                target="$2"
                if [[ $# -gt 2 && ! "$3" =~ ^-- ]]; then
                    template_id="$3"
                    shift
                fi
                shift 2
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                if [ -z "$action" ]; then
                    action="scan"
                    target="$1"
                fi
                shift
                ;;
        esac
    done

    # Default action
    if [ -z "$action" ]; then
        action="scan"
        target="."
    fi

    # Execute action
    case "$action" in
        scan)
            # Scan and return found files with analysis
            local files_json
            files_json=$(scan_for_claude_md "$target")

            if ! command -v jq &>/dev/null; then
                echo "$files_json"
                return 0
            fi

            # Analyze each found file
            local -a analyses=()
            while IFS= read -r file; do
                if [ -n "$file" ] && [ "$file" != "null" ]; then
                    local analysis
                    analysis=$(analyze_claude_md_content "$file" 2>/dev/null || echo "{}")
                    analyses+=("$analysis")
                fi
            done < <(echo "$files_json" | jq -r '.[]')

            # Output combined result
            if [ ${#analyses[@]} -gt 0 ]; then
                printf '%s\n' "${analyses[@]}" | jq -s '{files: .}'
            else
                echo '{"files": []}'
            fi
            ;;

        analyze)
            analyze_claude_md_content "$target"
            ;;

        suggest)
            # Generate suggestions and optionally save to .claude/
            local suggestions
            suggestions=$(suggest_enhancements "$target" "$template_id")

            echo "$suggestions"

            # Save to .claude/claude-md-suggestions.json if .claude exists
            local claude_dir
            if [ -d ".claude" ]; then
                echo "$suggestions" > .claude/claude-md-suggestions.json
                echo "Saved suggestions to .claude/claude-md-suggestions.json" >&2
            fi
            ;;

        *)
            echo "Error: Unknown action: $action" >&2
            show_usage
            exit 1
            ;;
    esac

    return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
