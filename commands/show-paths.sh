#!/usr/bin/env bash

# show-paths.sh - Display current path configuration with source attribution
#
# Usage:
#   show-paths.sh [OPTIONS]
#
# Options:
#   --help      Show help message
#   --json      Output in JSON format
#   --verbose   Include full paths and additional details
#
# Exit codes:
#   0 - Success
#   1 - Invalid arguments
#   2 - System error

set -euo pipefail

# =============================================================================
# Script Setup
# =============================================================================

# Determine script directory (works even when sourced)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source the path-config library
# shellcheck source=../scripts/path-config.sh
if [[ -f "$PROJECT_ROOT/scripts/path-config.sh" ]]; then
    source "$PROJECT_ROOT/scripts/path-config.sh"
else
    echo "Error: path-config.sh not found at $PROJECT_ROOT/scripts/path-config.sh" >&2
    exit 2
fi

# =============================================================================
# Configuration Source Detection
# =============================================================================

# Usage: detect_claude_dir_source
# Returns: Source type (environment, manifest, default)
detect_claude_dir_source() {
    if [[ -n "${RCM_CLAUDE_DIR_NAME:-}" ]]; then
        echo "environment"
    else
        local manifest_path
        manifest_path="$(get_manifest_path)"
        if [[ -n "$manifest_path" ]]; then
            local manifest_value
            manifest_value="$(read_manifest_value "$manifest_path" "claude_dir_name" 2>/dev/null)" || manifest_value=""
            if [[ -n "$manifest_value" ]]; then
                echo "manifest"
                return 0
            fi
        fi
        echo "default"
    fi
}

# Usage: detect_role_guides_dir_source
# Returns: Source type (environment, manifest, default)
detect_role_guides_dir_source() {
    if [[ -n "${RCM_ROLE_GUIDES_DIR:-}" ]]; then
        echo "environment"
    else
        local manifest_path
        manifest_path="$(get_manifest_path)"
        if [[ -n "$manifest_path" ]]; then
            local manifest_value
            manifest_value="$(read_manifest_value "$manifest_path" "role_guides_dir" 2>/dev/null)" || manifest_value=""
            if [[ -n "$manifest_value" ]]; then
                echo "manifest"
                return 0
            fi
        fi
        echo "default"
    fi
}

# Usage: detect_manifest_source
# Returns: Source type (environment, found, not_found)
detect_manifest_source() {
    if [[ -n "${RCM_PATHS_MANIFEST:-}" ]]; then
        echo "environment"
    else
        local manifest_path
        manifest_path="$(get_manifest_path)"
        if [[ -n "$manifest_path" ]]; then
            echo "found"
        else
            echo "not_found"
        fi
    fi
}

# =============================================================================
# Output Functions
# =============================================================================

# Usage: show_human_readable [verbose]
# Returns: 0 always
show_human_readable() {
    local verbose="${1:-false}"

    # Load configuration
    load_path_config

    # Get configuration values
    local claude_dir_name
    local role_guides_dir
    local manifest_path

    claude_dir_name="$(get_claude_dir_name)"
    role_guides_dir="$(get_role_guides_dir)"
    manifest_path="$(get_manifest_path)"

    # Detect sources
    local claude_dir_source
    local role_guides_source
    local manifest_source

    claude_dir_source="$(detect_claude_dir_source)"
    role_guides_source="$(detect_role_guides_dir_source)"
    manifest_source="$(detect_manifest_source)"

    # Display header
    echo "Current Path Configuration:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Display claude_dir_name
    echo "  claude_dir_name:    $claude_dir_name"
    case "$claude_dir_source" in
        environment)
            echo "    Source: environment variable (RCM_CLAUDE_DIR_NAME)"
            ;;
        manifest)
            echo "    Source: manifest ($manifest_path)"
            ;;
        default)
            echo "    Source: default"
            ;;
    esac

    if [[ "$verbose" == "true" ]]; then
        local full_path
        full_path="$(get_full_claude_path)"
        echo "    Full path: $full_path"
    fi
    echo ""

    # Display role_guides_dir
    echo "  role_guides_dir:    $role_guides_dir"
    case "$role_guides_source" in
        environment)
            echo "    Source: environment variable (RCM_ROLE_GUIDES_DIR)"
            ;;
        manifest)
            echo "    Source: manifest ($manifest_path)"
            ;;
        default)
            echo "    Source: default"
            ;;
    esac

    if [[ "$verbose" == "true" ]]; then
        local full_path
        full_path="$(get_full_role_guides_path)"
        echo "    Full path: $full_path"
    fi
    echo ""

    # Display manifest_path
    echo "  manifest_path:      ${manifest_path:-(none)}"
    case "$manifest_source" in
        environment)
            echo "    Source: environment variable (RCM_PATHS_MANIFEST)"
            ;;
        found)
            echo "    Source: auto-discovered"
            ;;
        not_found)
            echo "    Source: not found"
            ;;
    esac

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Additional verbose information
    if [[ "$verbose" == "true" ]]; then
        echo ""
        echo "Additional Details:"
        echo "  Working directory:  $PWD"
        echo "  Cache enabled:      ${RCM_CACHE_ENABLED:-true}"
        echo "  Cache age:          $(($(date +%s) - PATH_CONFIG_CACHE_TIME))s"
        echo ""
        echo "Environment Variables:"
        echo "  RCM_CLAUDE_DIR_NAME:  ${RCM_CLAUDE_DIR_NAME:-(not set)}"
        echo "  RCM_ROLE_GUIDES_DIR:  ${RCM_ROLE_GUIDES_DIR:-(not set)}"
        echo "  RCM_PATHS_MANIFEST:   ${RCM_PATHS_MANIFEST:-(not set)}"
    fi
}

# Usage: show_json
# Returns: 0 always
show_json() {
    # Load configuration
    load_path_config

    # Get configuration values
    local claude_dir_name
    local role_guides_dir
    local manifest_path

    claude_dir_name="$(get_claude_dir_name)"
    role_guides_dir="$(get_role_guides_dir)"
    manifest_path="$(get_manifest_path)"

    # Detect sources
    local claude_dir_source
    local role_guides_source
    local manifest_source

    claude_dir_source="$(detect_claude_dir_source)"
    role_guides_source="$(detect_role_guides_dir_source)"
    manifest_source="$(detect_manifest_source)"

    # Build JSON output
    if command -v jq &> /dev/null; then
        # Use jq for proper JSON formatting
        jq -n \
            --arg claude_dir "$claude_dir_name" \
            --arg claude_source "$claude_dir_source" \
            --arg role_guides "$role_guides_dir" \
            --arg role_guides_source "$role_guides_source" \
            --arg manifest "${manifest_path:-null}" \
            --arg manifest_source "$manifest_source" \
            '{
                claude_dir_name: {
                    value: $claude_dir,
                    source: $claude_source
                },
                role_guides_dir: {
                    value: $role_guides,
                    source: $role_guides_source
                },
                manifest_path: {
                    value: (if $manifest == "null" then null else $manifest end),
                    source: $manifest_source
                }
            }'
    else
        # Fallback without jq - manual JSON construction
        local manifest_value
        if [[ -n "$manifest_path" ]]; then
            manifest_value="\"$manifest_path\""
        else
            manifest_value="null"
        fi

        cat <<EOF
{
  "claude_dir_name": {
    "value": "$claude_dir_name",
    "source": "$claude_dir_source"
  },
  "role_guides_dir": {
    "value": "$role_guides_dir",
    "source": "$role_guides_source"
  },
  "manifest_path": {
    "value": $manifest_value,
    "source": "$manifest_source"
  }
}
EOF
    fi
}

# Usage: show_help
# Returns: 0 always
show_help() {
    cat <<'EOF'
show-paths.sh - Display current path configuration

Usage:
  show-paths.sh [OPTIONS]

Options:
  --help      Show this help message
  --json      Output in JSON format
  --verbose   Include full paths and additional details

Description:
  Displays the current path configuration with source attribution for each
  configuration value. Shows whether values come from environment variables,
  manifest files, or defaults.

  Default output is human-readable with clear formatting. Use --json for
  machine-readable output suitable for scripts and automation.

Examples:
  # Show current configuration (human-readable)
  show-paths.sh

  # Show configuration in JSON format
  show-paths.sh --json

  # Show configuration with verbose details
  show-paths.sh --verbose

Configuration Sources:
  1. Environment variables (highest priority)
     - RCM_CLAUDE_DIR_NAME
     - RCM_ROLE_GUIDES_DIR
     - RCM_PATHS_MANIFEST

  2. Manifest file (paths.json)
     - Searched in .claude/paths.json (upward from current directory)
     - Or in ~/.claude/paths.json

  3. Defaults (lowest priority)
     - claude_dir_name: .claude
     - role_guides_dir: role-guides

Exit Codes:
  0 - Success
  1 - Invalid arguments
  2 - System error
EOF
}

# =============================================================================
# Main Function
# =============================================================================

main() {
    local output_mode="human"
    local verbose=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)
                show_help
                return 0
                ;;
            --json)
                output_mode="json"
                shift
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            *)
                echo "Error: Unknown option: $1" >&2
                echo "Run 'show-paths.sh --help' for usage information" >&2
                return 1
                ;;
        esac
    done

    # Display output based on mode
    case "$output_mode" in
        json)
            show_json
            ;;
        human)
            show_human_readable "$verbose"
            ;;
    esac

    return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
