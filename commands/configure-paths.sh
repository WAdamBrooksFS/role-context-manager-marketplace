#!/usr/bin/env bash

# configure-paths.sh - Interactive path configuration and migration command
#
# Purpose:
#   Configure custom directory names for Role Context Manager paths and
#   migrate existing .claude directories to new naming conventions.
#
# Usage:
#   /configure-paths [OPTIONS]
#   /configure-paths --claude-dir=NAME --role-guides-dir=NAME
#   /configure-paths --migrate OLD NEW
#
# Exit codes:
#   0 - Success
#   1 - Validation error or user cancellation
#   2 - System error

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PATH_CONFIG_LIB="$PROJECT_ROOT/scripts/path-config.sh"

# Source the path-config library
if [[ ! -f "$PATH_CONFIG_LIB" ]]; then
    echo "Error: path-config.sh library not found at $PATH_CONFIG_LIB" >&2
    exit 2
fi

# shellcheck source=../scripts/path-config.sh
source "$PATH_CONFIG_LIB"

# =============================================================================
# Global Variables
# =============================================================================

DRY_RUN=false
GLOBAL_CONFIG=false
LOCAL_CONFIG=true
MIGRATE_MODE=false
OLD_DIR_NAME=""
NEW_DIR_NAME=""
CLAUDE_DIR_NAME=""
ROLE_GUIDES_DIR_NAME=""
INTERACTIVE_MODE=true

# =============================================================================
# Help and Usage
# =============================================================================

show_help() {
    cat <<'EOF'
/configure-paths - Configure custom directory names for Role Context Manager

USAGE:
    /configure-paths [OPTIONS]
    /configure-paths --claude-dir=NAME --role-guides-dir=NAME
    /configure-paths --migrate OLD NEW

DESCRIPTION:
    Configure custom directory names for the Role Context Manager. This command
    allows you to customize the claude directory name (default: .claude) and
    the role-guides directory name (default: role-guides).

    The configuration can be set globally (in $HOME) or locally (in current
    directory). When both exist, local configuration takes precedence.

OPTIONS:
    --help
        Show this help message

    --dry-run
        Preview changes without applying them

    --global
        Create configuration in $HOME/.claude/paths.json

    --local
        Create configuration in ./.claude/paths.json (default)

    --claude-dir=NAME
        Set the claude directory name (e.g., .myorg, .custom)
        Must be a relative path, cannot contain '..' or start with '/'

    --role-guides-dir=NAME
        Set the role guides directory name (e.g., guides, role-docs)
        Must be a relative path, cannot contain '..' or start with '/'

    --migrate OLD NEW
        Migrate existing directories from OLD name to NEW name
        Example: --migrate .claude .myorg-rcm
        This will:
        - Rename all matching directories in the current tree
        - Create or update paths.json with the new name
        - Validate before executing

EXAMPLES:
    # Interactive mode (prompts for values)
    /configure-paths

    # Set custom directory names directly
    /configure-paths --claude-dir=.myorg --role-guides-dir=my-guides

    # Create global configuration
    /configure-paths --global --claude-dir=.myorg

    # Preview changes without applying
    /configure-paths --dry-run --claude-dir=.custom

    # Migrate existing .claude directories to new name
    /configure-paths --migrate .claude .myorg-rcm

    # Dry run migration to preview changes
    /configure-paths --dry-run --migrate .claude .myorg-rcm

INTERACTIVE MODE:
    When run without arguments, the command enters interactive mode and prompts
    for configuration values. You can review the configuration before applying.

MIGRATION:
    The --migrate option renames existing directories and updates or creates
    the paths.json manifest. This is useful when adopting organizational
    naming conventions or rebranding.

    Migration steps:
    1. Validates the old and new directory names
    2. Searches for directories matching the old name
    3. Shows a preview of changes
    4. Prompts for confirmation (unless --dry-run)
    5. Renames directories and updates configuration

EXIT CODES:
    0 - Success
    1 - Validation error or user cancellation
    2 - System error (missing dependencies, permissions)

SEE ALSO:
    scripts/path-config.sh - Path configuration library
    /validate-setup - Validate current configuration
EOF
}

# =============================================================================
# Validation Functions
# =============================================================================

# Validate directory name using path-config.sh library
validate_dir_name() {
    local dir_name="$1"
    local label="$2"

    if ! validate_path_component "$dir_name"; then
        echo "Error: Invalid $label: $dir_name" >&2
        return 1
    fi

    return 0
}

# Check if directory exists
dir_exists() {
    local dir_path="$1"
    [[ -d "$dir_path" ]]
}

# Check if file exists
file_exists() {
    local file_path="$1"
    [[ -f "$file_path" ]]
}

# =============================================================================
# Interactive Prompts
# =============================================================================

# Prompt for yes/no confirmation
confirm() {
    local prompt="$1"
    local response

    read -r -p "$prompt (y/n): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Prompt for directory name with validation
prompt_for_dir_name() {
    local label="$1"
    local default="$2"
    local value=""

    while true; do
        read -r -p "$label [default: $default]: " value

        # Use default if empty
        if [[ -z "$value" ]]; then
            value="$default"
        fi

        # Validate
        if validate_dir_name "$value" "$label"; then
            echo "$value"
            return 0
        fi

        echo "Please enter a valid directory name." >&2
    done
}

# =============================================================================
# Configuration Creation
# =============================================================================

# Create paths.json manifest
create_paths_manifest() {
    local target_dir="$1"
    local claude_dir="$2"
    local role_guides_dir="$3"
    local manifest_path="$target_dir/paths.json"

    # Create directory if needed
    if [[ ! -d "$target_dir" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[DRY RUN] Would create directory: $target_dir"
        else
            mkdir -p "$target_dir"
            echo "Created directory: $target_dir"
        fi
    fi

    # Create manifest
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would create manifest: $manifest_path"
        echo "[DRY RUN] Configuration:"
        echo "  claude_dir_name: $claude_dir"
        echo "  role_guides_dir: $role_guides_dir"
    else
        if command -v jq &> /dev/null; then
            jq -n \
                --arg claude_dir "$claude_dir" \
                --arg role_guides "$role_guides_dir" \
                '{
                    claude_dir_name: $claude_dir,
                    role_guides_dir: $role_guides,
                    version: "1.0.0",
                    description: "Path configuration for Role Context Manager"
                }' > "$manifest_path"
        else
            # Fallback without jq
            cat > "$manifest_path" <<EOF
{
  "claude_dir_name": "$claude_dir",
  "role_guides_dir": "$role_guides_dir",
  "version": "1.0.0",
  "description": "Path configuration for Role Context Manager"
}
EOF
        fi

        echo "Created manifest: $manifest_path"
        echo "Configuration:"
        echo "  claude_dir_name: $claude_dir"
        echo "  role_guides_dir: $role_guides_dir"
    fi

    return 0
}

# Update existing paths.json manifest
update_paths_manifest() {
    local manifest_path="$1"
    local claude_dir="$2"
    local role_guides_dir="$3"

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would update manifest: $manifest_path"
        echo "[DRY RUN] New configuration:"
        echo "  claude_dir_name: $claude_dir"
        echo "  role_guides_dir: $role_guides_dir"
        return 0
    fi

    # Backup existing manifest
    cp "$manifest_path" "$manifest_path.bak"

    # Update with jq if available
    if command -v jq &> /dev/null; then
        jq --arg claude_dir "$claude_dir" \
           --arg role_guides "$role_guides_dir" \
           '.claude_dir_name = $claude_dir | .role_guides_dir = $role_guides' \
           "$manifest_path.bak" > "$manifest_path"
    else
        # Fallback: recreate the file
        cat > "$manifest_path" <<EOF
{
  "claude_dir_name": "$claude_dir",
  "role_guides_dir": "$role_guides_dir",
  "version": "1.0.0",
  "description": "Path configuration for Role Context Manager"
}
EOF
    fi

    echo "Updated manifest: $manifest_path"
    echo "Backup saved: $manifest_path.bak"

    return 0
}

# =============================================================================
# Migration Functions
# =============================================================================

# Find all directories matching a name
find_matching_dirs() {
    local dir_name="$1"
    local search_root="${2:-.}"

    # Use find to locate all matching directories
    find "$search_root" -type d -name "$dir_name" 2>/dev/null || true
}

# Migrate a single directory
migrate_directory() {
    local old_path="$1"
    local new_name="$2"
    local parent_dir
    local new_path

    parent_dir="$(dirname "$old_path")"
    new_path="$parent_dir/$new_name"

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would rename: $old_path -> $new_path"
        return 0
    fi

    # Check if target already exists
    if [[ -e "$new_path" ]]; then
        echo "Warning: Target already exists, skipping: $new_path" >&2
        return 1
    fi

    # Rename directory
    mv "$old_path" "$new_path"
    echo "Renamed: $old_path -> $new_path"

    return 0
}

# Perform migration of directories
perform_migration() {
    local old_name="$1"
    local new_name="$2"
    local matching_dirs
    local dir_count
    local manifest_dir
    local manifest_path

    echo "Searching for directories named '$old_name'..."

    # Find all matching directories
    mapfile -t matching_dirs < <(find_matching_dirs "$old_name" ".")
    dir_count=${#matching_dirs[@]}

    if [[ $dir_count -eq 0 ]]; then
        echo "No directories found matching '$old_name'"
        return 0
    fi

    # Show preview
    echo "Found $dir_count director(y|ies) to migrate:"
    for dir in "${matching_dirs[@]}"; do
        echo "  - $dir -> $(dirname "$dir")/$new_name"
    done
    echo ""

    # Confirm unless dry run
    if [[ "$DRY_RUN" != true ]]; then
        if ! confirm "Proceed with migration?"; then
            echo "Migration cancelled"
            return 1
        fi
    fi

    # Migrate each directory
    for dir in "${matching_dirs[@]}"; do
        migrate_directory "$dir" "$new_name"
    done

    # Update or create manifest
    echo ""
    echo "Updating configuration..."

    # Determine manifest location
    if [[ "$GLOBAL_CONFIG" == true ]]; then
        manifest_dir="$HOME/$new_name"
    else
        manifest_dir="./$new_name"
    fi

    manifest_path="$manifest_dir/paths.json"

    # Create or update manifest
    if file_exists "$manifest_path"; then
        update_paths_manifest "$manifest_path" "$new_name" "$ROLE_GUIDES_DIR_NAME"
    else
        # Use default role-guides-dir if not specified
        local role_guides_dir="${ROLE_GUIDES_DIR_NAME:-role-guides}"
        create_paths_manifest "$manifest_dir" "$new_name" "$role_guides_dir"
    fi

    echo ""
    echo "Migration complete!"

    return 0
}

# =============================================================================
# Interactive Configuration
# =============================================================================

run_interactive_mode() {
    echo "=== Configure Paths for Role Context Manager ==="
    echo ""
    echo "This will configure custom directory names for the Role Context Manager."
    echo ""

    # Prompt for claude directory name
    CLAUDE_DIR_NAME=$(prompt_for_dir_name "Claude directory name" ".claude")

    # Prompt for role guides directory name
    ROLE_GUIDES_DIR_NAME=$(prompt_for_dir_name "Role guides directory name" "role-guides")

    # Prompt for scope
    echo ""
    if confirm "Create global configuration in $HOME?"; then
        GLOBAL_CONFIG=true
        LOCAL_CONFIG=false
    else
        GLOBAL_CONFIG=false
        LOCAL_CONFIG=true
    fi

    # Show preview
    echo ""
    echo "=== Configuration Preview ==="
    echo "Claude directory: $CLAUDE_DIR_NAME"
    echo "Role guides directory: $ROLE_GUIDES_DIR_NAME"

    if [[ "$GLOBAL_CONFIG" == true ]]; then
        echo "Scope: Global ($HOME/$CLAUDE_DIR_NAME/paths.json)"
    else
        echo "Scope: Local (./$CLAUDE_DIR_NAME/paths.json)"
    fi
    echo ""

    # Confirm
    if ! confirm "Apply this configuration?"; then
        echo "Configuration cancelled"
        return 1
    fi

    # Apply configuration
    local target_dir
    if [[ "$GLOBAL_CONFIG" == true ]]; then
        target_dir="$HOME/$CLAUDE_DIR_NAME"
    else
        target_dir="./$CLAUDE_DIR_NAME"
    fi

    create_paths_manifest "$target_dir" "$CLAUDE_DIR_NAME" "$ROLE_GUIDES_DIR_NAME"

    echo ""
    echo "Configuration complete!"
    echo ""
    echo "Next steps:"
    echo "  1. Run /validate-setup to verify configuration"
    echo "  2. Create role guides in $CLAUDE_DIR_NAME/$ROLE_GUIDES_DIR_NAME/"
    echo "  3. Set your current role with /set-role <role-name>"

    return 0
}

# =============================================================================
# Direct Configuration
# =============================================================================

run_direct_mode() {
    # Validate inputs
    if ! validate_dir_name "$CLAUDE_DIR_NAME" "claude directory"; then
        return 1
    fi

    if ! validate_dir_name "$ROLE_GUIDES_DIR_NAME" "role guides directory"; then
        return 1
    fi

    # Determine target directory
    local target_dir
    if [[ "$GLOBAL_CONFIG" == true ]]; then
        target_dir="$HOME/$CLAUDE_DIR_NAME"
    else
        target_dir="./$CLAUDE_DIR_NAME"
    fi

    # Show preview
    echo "=== Configuration Preview ==="
    echo "Claude directory: $CLAUDE_DIR_NAME"
    echo "Role guides directory: $ROLE_GUIDES_DIR_NAME"

    if [[ "$GLOBAL_CONFIG" == true ]]; then
        echo "Scope: Global ($target_dir/paths.json)"
    else
        echo "Scope: Local ($target_dir/paths.json)"
    fi
    echo ""

    # Create configuration
    create_paths_manifest "$target_dir" "$CLAUDE_DIR_NAME" "$ROLE_GUIDES_DIR_NAME"

    if [[ "$DRY_RUN" != true ]]; then
        echo ""
        echo "Configuration complete!"
    fi

    return 0
}

# =============================================================================
# Argument Parsing
# =============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)
                show_help
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --global)
                GLOBAL_CONFIG=true
                LOCAL_CONFIG=false
                shift
                ;;
            --local)
                GLOBAL_CONFIG=false
                LOCAL_CONFIG=true
                shift
                ;;
            --migrate)
                MIGRATE_MODE=true
                INTERACTIVE_MODE=false
                OLD_DIR_NAME="$2"
                NEW_DIR_NAME="$3"
                shift 3
                ;;
            --claude-dir=*)
                CLAUDE_DIR_NAME="${1#*=}"
                INTERACTIVE_MODE=false
                shift
                ;;
            --role-guides-dir=*)
                ROLE_GUIDES_DIR_NAME="${1#*=}"
                INTERACTIVE_MODE=false
                shift
                ;;
            *)
                echo "Error: Unknown option: $1" >&2
                echo "Run --help for usage information" >&2
                exit 1
                ;;
        esac
    done

    return 0
}

# =============================================================================
# Main Function
# =============================================================================

main() {
    # Parse command-line arguments
    parse_arguments "$@"

    # Handle migration mode
    if [[ "$MIGRATE_MODE" == true ]]; then
        if [[ -z "$OLD_DIR_NAME" ]] || [[ -z "$NEW_DIR_NAME" ]]; then
            echo "Error: --migrate requires two arguments: OLD_NAME NEW_NAME" >&2
            exit 1
        fi

        # Validate directory names
        if ! validate_dir_name "$OLD_DIR_NAME" "old directory name"; then
            exit 1
        fi

        if ! validate_dir_name "$NEW_DIR_NAME" "new directory name"; then
            exit 1
        fi

        # Perform migration
        perform_migration "$OLD_DIR_NAME" "$NEW_DIR_NAME"
        exit $?
    fi

    # Handle interactive mode
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        run_interactive_mode
        exit $?
    fi

    # Handle direct configuration mode
    if [[ -z "$CLAUDE_DIR_NAME" ]]; then
        echo "Error: --claude-dir is required in non-interactive mode" >&2
        echo "Run --help for usage information" >&2
        exit 1
    fi

    # Use default role-guides-dir if not specified
    if [[ -z "$ROLE_GUIDES_DIR_NAME" ]]; then
        ROLE_GUIDES_DIR_NAME="role-guides"
    fi

    run_direct_mode
    exit $?
}

# Run main function
main "$@"
