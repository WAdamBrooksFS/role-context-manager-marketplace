#!/usr/bin/env bash

# path-config.sh - Core path configuration library
#
# Functions:
#   - load_path_config: Load configuration from manifest/env/defaults
#   - get_claude_dir_name: Get the claude directory name (.claude by default)
#   - get_role_guides_dir: Get the role-guides directory name
#   - validate_path_config: Validate path configuration
#   - clear_path_config_cache: Clear the configuration cache
#
# Environment Variables:
#   RCM_CLAUDE_DIR_NAME: Override claude directory name (default: .claude)
#   RCM_ROLE_GUIDES_DIR: Override role-guides directory name (default: role-guides)
#   RCM_PATHS_MANIFEST: Override paths manifest file location (default: paths.json)
#   RCM_CACHE_ENABLED: Enable/disable caching (default: true)
#
# Exit codes:
#   0 - Success
#   1 - Validation error
#   2 - System error

set -euo pipefail

# =============================================================================
# Global Configuration Cache
# =============================================================================

# Cache for path configuration values (requires bash 4.0+)
declare -gA PATH_CONFIG_CACHE 2>/dev/null || {
    echo "Error: Bash 4.0+ required for associative arrays" >&2
    exit 2
}

# Cache initialization flag
PATH_CONFIG_INITIALIZED=false

# Cache timestamp for invalidation
PATH_CONFIG_CACHE_TIME=0

# Cache timeout in seconds (5 seconds for fresh data)
PATH_CONFIG_CACHE_TIMEOUT=5

# =============================================================================
# Security Validation Functions
# =============================================================================

# Usage: validate_path_component component_name
# Returns: 0 if valid, 1 if invalid
# Exits: 1 on path traversal attempt
validate_path_component() {
    local component="$1"

    # Check for empty component first
    if [[ -z "$component" ]]; then
        echo "Error: Path component cannot be empty" >&2
        return 1
    fi

    # Check for null bytes by comparing string length
    # If string contains null byte, bash string length will differ from byte length
    local str_len=${#component}
    local byte_len
    byte_len=$(printf '%s' "$component" | wc -c)
    if [[ $str_len -ne $byte_len ]]; then
        echo "Error: Path component contains null byte or invalid characters" >&2
        return 1
    fi

    # Check for parent directory traversal
    if [[ "$component" == *".."* ]]; then
        echo "Error: Path component contains '..' (path traversal attempt)" >&2
        return 1
    fi

    # Check for absolute paths (leading slash)
    if [[ "$component" == /* ]]; then
        echo "Error: Path component cannot start with '/' (must be relative)" >&2
        return 1
    fi

    # Check for whitespace-only component
    if [[ "$component" =~ ^[[:space:]]+$ ]]; then
        echo "Error: Path component cannot be whitespace-only" >&2
        return 1
    fi

    return 0
}

# Usage: validate_path_config
# Returns: 0 if configuration is valid, 1 if invalid
# Exits: non-zero on validation failure
validate_path_config() {
    local claude_dir
    local role_guides_dir

    # Get configured values
    claude_dir="$(get_claude_dir_name)" || return 1
    role_guides_dir="$(get_role_guides_dir)" || return 1

    # Validate claude directory name
    if ! validate_path_component "$claude_dir"; then
        echo "Error: Invalid claude directory name: $claude_dir" >&2
        return 1
    fi

    # Validate role guides directory name
    if ! validate_path_component "$role_guides_dir"; then
        echo "Error: Invalid role guides directory name: $role_guides_dir" >&2
        return 1
    fi

    return 0
}

# =============================================================================
# Cache Management Functions
# =============================================================================

# Usage: is_cache_valid
# Returns: 0 if cache is valid, 1 if expired or disabled
is_cache_valid() {
    # Check if caching is disabled
    if [[ "${RCM_CACHE_ENABLED:-true}" == "false" ]]; then
        return 1
    fi

    # Check if cache is initialized
    if [[ "$PATH_CONFIG_INITIALIZED" != "true" ]]; then
        return 1
    fi

    # Check cache timeout
    local current_time
    current_time=$(date +%s)
    local cache_age=$((current_time - PATH_CONFIG_CACHE_TIME))

    if [[ $cache_age -gt $PATH_CONFIG_CACHE_TIMEOUT ]]; then
        return 1
    fi

    return 0
}

# Usage: clear_path_config_cache
# Returns: 0 always
# Exits: never
clear_path_config_cache() {
    PATH_CONFIG_CACHE=()
    PATH_CONFIG_INITIALIZED=false
    PATH_CONFIG_CACHE_TIME=0
    return 0
}

# Usage: update_cache_timestamp
# Returns: 0 always
update_cache_timestamp() {
    PATH_CONFIG_CACHE_TIME=$(date +%s)
    return 0
}

# =============================================================================
# Manifest Parsing Functions
# =============================================================================

# Usage: find_paths_manifest [search_dir]
# Returns: Path to paths.json manifest if found, empty if not
# Exits: 0 on success, 1 if not found
find_paths_manifest() {
    local search_dir="${1:-$PWD}"

    # Check environment variable override first
    if [[ -n "${RCM_PATHS_MANIFEST:-}" ]]; then
        if [[ -f "$RCM_PATHS_MANIFEST" ]]; then
            echo "$RCM_PATHS_MANIFEST"
            return 0
        fi
    fi

    # Search upward for paths.json in .claude directories
    local dir="$search_dir"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.claude/paths.json" ]]; then
            echo "$dir/.claude/paths.json"
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    # Check global config
    if [[ -f "$HOME/.claude/paths.json" ]]; then
        echo "$HOME/.claude/paths.json"
        return 0
    fi

    # Not found
    return 1
}

# Usage: read_manifest_value manifest_file key
# Returns: Value from manifest or empty string
# Exits: 0 on success
read_manifest_value() {
    local manifest_file="$1"
    local key="$2"

    if [[ ! -f "$manifest_file" ]]; then
        return 1
    fi

    # Try with jq first
    if command -v jq &> /dev/null; then
        local value
        value=$(jq -r ".$key // empty" "$manifest_file" 2>/dev/null)
        if [[ -n "$value" ]]; then
            echo "$value"
            return 0
        fi
    else
        # Fallback without jq - simple grep and sed
        local value
        value=$(grep -o "\"$key\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$manifest_file" 2>/dev/null | \
            sed 's/.*"\([^"]*\)"/\1/' | head -1)
        if [[ -n "$value" ]]; then
            echo "$value"
            return 0
        fi
    fi

    return 1
}

# =============================================================================
# Configuration Loading Functions
# =============================================================================

# Usage: load_path_config [search_dir]
# Returns: 0 on success
# Exits: 0 on success, 2 on system error
load_path_config() {
    local search_dir="${1:-$PWD}"

    # Check if cache is valid
    if is_cache_valid; then
        return 0
    fi

    # Find paths manifest
    local manifest_file
    manifest_file="$(find_paths_manifest "$search_dir")" || manifest_file=""

    # Load claude directory name
    local claude_dir_name=""

    # Priority 1: Environment variable
    if [[ -n "${RCM_CLAUDE_DIR_NAME:-}" ]]; then
        claude_dir_name="$RCM_CLAUDE_DIR_NAME"
    # Priority 2: Manifest file
    elif [[ -n "$manifest_file" ]]; then
        claude_dir_name="$(read_manifest_value "$manifest_file" "claude_dir_name")" || claude_dir_name=""
    fi

    # Priority 3: Default
    if [[ -z "$claude_dir_name" ]]; then
        claude_dir_name=".claude"
    fi

    # Load role guides directory name
    local role_guides_dir=""

    # Priority 1: Environment variable
    if [[ -n "${RCM_ROLE_GUIDES_DIR:-}" ]]; then
        role_guides_dir="$RCM_ROLE_GUIDES_DIR"
    # Priority 2: Manifest file
    elif [[ -n "$manifest_file" ]]; then
        role_guides_dir="$(read_manifest_value "$manifest_file" "role_guides_dir")" || role_guides_dir=""
    fi

    # Priority 3: Default
    if [[ -z "$role_guides_dir" ]]; then
        role_guides_dir="role-guides"
    fi

    # Store in cache
    PATH_CONFIG_CACHE[claude_dir_name]="$claude_dir_name"
    PATH_CONFIG_CACHE[role_guides_dir]="$role_guides_dir"
    PATH_CONFIG_CACHE[manifest_file]="$manifest_file"

    # Mark as initialized
    PATH_CONFIG_INITIALIZED=true
    update_cache_timestamp

    return 0
}

# =============================================================================
# Configuration Accessor Functions
# =============================================================================

# Usage: get_claude_dir_name
# Returns: Claude directory name (e.g., .claude)
# Exits: 0 on success
get_claude_dir_name() {
    # Ensure config is loaded
    if ! is_cache_valid; then
        load_path_config || return 2
    fi

    # Return from cache
    echo "${PATH_CONFIG_CACHE[claude_dir_name]}"
    return 0
}

# Usage: get_role_guides_dir
# Returns: Role guides directory name (e.g., role-guides)
# Exits: 0 on success
get_role_guides_dir() {
    # Ensure config is loaded
    if ! is_cache_valid; then
        load_path_config || return 2
    fi

    # Return from cache
    echo "${PATH_CONFIG_CACHE[role_guides_dir]}"
    return 0
}

# Usage: get_manifest_path
# Returns: Path to active manifest file or empty string
# Exits: 0 always
get_manifest_path() {
    # Ensure config is loaded
    if ! is_cache_valid; then
        load_path_config || return 2
    fi

    # Return from cache
    echo "${PATH_CONFIG_CACHE[manifest_file]:-}"
    return 0
}

# Usage: get_full_claude_path [base_dir]
# Returns: Full path to claude directory
# Exits: 0 on success
get_full_claude_path() {
    local base_dir="${1:-$PWD}"
    local claude_dir_name

    claude_dir_name="$(get_claude_dir_name)" || return 2

    echo "$base_dir/$claude_dir_name"
    return 0
}

# Usage: get_full_role_guides_path [base_dir]
# Returns: Full path to role-guides directory
# Exits: 0 on success
get_full_role_guides_path() {
    local base_dir="${1:-$PWD}"
    local claude_dir_name
    local role_guides_dir

    claude_dir_name="$(get_claude_dir_name)" || return 2
    role_guides_dir="$(get_role_guides_dir)" || return 2

    echo "$base_dir/$claude_dir_name/$role_guides_dir"
    return 0
}

# =============================================================================
# Utility Functions
# =============================================================================

# Usage: show_path_config
# Returns: 0 always
# Exits: never
show_path_config() {
    # Ensure config is loaded
    if ! is_cache_valid; then
        load_path_config || return 2
    fi

    local manifest_file="${PATH_CONFIG_CACHE[manifest_file]:-none}"

    echo "Path Configuration:"
    echo "  Claude directory: ${PATH_CONFIG_CACHE[claude_dir_name]}"
    echo "  Role guides directory: ${PATH_CONFIG_CACHE[role_guides_dir]}"
    echo "  Manifest file: $manifest_file"
    echo "  Cache enabled: ${RCM_CACHE_ENABLED:-true}"
    echo "  Cache age: $(($(date +%s) - PATH_CONFIG_CACHE_TIME))s"

    return 0
}

# Usage: create_default_manifest claude_dir
# Returns: 0 on success
# Exits: 0 on success, 1 on error
create_default_manifest() {
    local claude_dir="$1"
    local manifest_file="$claude_dir/paths.json"

    # Don't overwrite existing manifest
    if [[ -f "$manifest_file" ]]; then
        echo "Error: Manifest already exists: $manifest_file" >&2
        return 1
    fi

    # Create directory if needed
    mkdir -p "$claude_dir"

    # Create manifest with jq if available
    if command -v jq &> /dev/null; then
        jq -n \
            --arg claude_dir ".claude" \
            --arg role_guides "role-guides" \
            '{
                claude_dir_name: $claude_dir,
                role_guides_dir: $role_guides,
                version: "1.0.0",
                description: "Path configuration for Role Context Manager"
            }' > "$manifest_file"
    else
        # Fallback without jq
        cat > "$manifest_file" <<'EOF'
{
  "claude_dir_name": ".claude",
  "role_guides_dir": "role-guides",
  "version": "1.0.0",
  "description": "Path configuration for Role Context Manager"
}
EOF
    fi

    echo "Created default manifest: $manifest_file" >&2
    return 0
}

# =============================================================================
# Main Function (for testing and CLI usage)
# =============================================================================

main() {
    local command="${1:-show}"
    shift || true

    case "$command" in
        load)
            load_path_config "$@"
            echo "Configuration loaded successfully"
            ;;
        show)
            show_path_config
            ;;
        validate)
            if validate_path_config; then
                echo "Configuration is valid"
                return 0
            else
                echo "Configuration validation failed" >&2
                return 1
            fi
            ;;
        clear-cache)
            clear_path_config_cache
            echo "Cache cleared"
            ;;
        get-claude-dir)
            get_claude_dir_name
            ;;
        get-role-guides-dir)
            get_role_guides_dir
            ;;
        get-manifest)
            get_manifest_path
            ;;
        create-manifest)
            local claude_dir="${1:-.claude}"
            create_default_manifest "$claude_dir"
            ;;
        *)
            echo "Usage: $0 {load|show|validate|clear-cache|get-claude-dir|get-role-guides-dir|get-manifest|create-manifest} [args...]" >&2
            echo "" >&2
            echo "Commands:" >&2
            echo "  load [dir]              Load path configuration from directory" >&2
            echo "  show                    Display current configuration" >&2
            echo "  validate                Validate current configuration" >&2
            echo "  clear-cache             Clear configuration cache" >&2
            echo "  get-claude-dir          Get claude directory name" >&2
            echo "  get-role-guides-dir     Get role guides directory name" >&2
            echo "  get-manifest            Get manifest file path" >&2
            echo "  create-manifest [dir]   Create default manifest file" >&2
            return 2
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
