#!/usr/bin/env bash

# post-install.sh - Configure SessionStart hook for role-context-manager
# Part of role-context-manager v1.3.0
#
# This script automatically configures the SessionStart hook in settings
# when the plugin is first used. It ensures the hook is added to settings.json
# so that validation and template sync checks run on every session start.
#
# Supports multi-scope configuration:
#   SCOPE=global - Configure in ~/.claude/settings.json
#   SCOPE=project - Configure in ./.claude/settings.json
#   SCOPE=auto (default) - Configure in project if exists, else global
#
# Exit codes:
#   0 - Success
#   1 - Configuration failed (jq not found or error)

set -euo pipefail

# Source path-config.sh library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./path-config.sh
source "$SCRIPT_DIR/path-config.sh"
load_path_config

# Get dynamic claude directory name
CLAUDE_DIR_NAME="$(get_claude_dir_name)"

# Get scope from environment variable (default: auto)
SCOPE="${SCOPE:-auto}"

# Function to check if we're in a project context
is_project_context() {
    [[ -d "$CLAUDE_DIR_NAME" ]] || [[ -d "./$CLAUDE_DIR_NAME" ]]
}

# Determine target directory based on scope
determine_target_dir() {
    case "$SCOPE" in
        global)
            echo "$HOME/$CLAUDE_DIR_NAME"
            ;;
        project)
            if ! is_project_context; then
                echo "Error: Not in a project context. Cannot use --project scope." >&2
                exit 1
            fi
            echo "$CLAUDE_DIR_NAME"
            ;;
        auto)
            if is_project_context; then
                echo "$CLAUDE_DIR_NAME"
            else
                echo "$HOME/$CLAUDE_DIR_NAME"
            fi
            ;;
        *)
            echo "Error: Invalid scope '$SCOPE'. Use: global, project, or auto" >&2
            exit 1
            ;;
    esac
}

# Determine project root and settings location
PROJECT_ROOT="${PWD}"
CLAUDE_DIR="$(determine_target_dir)"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
MARKER_FILE="$CLAUDE_DIR/.role-context-manager-setup-complete"

# Determine actual scope for display
if [[ "$CLAUDE_DIR" == "$HOME/$CLAUDE_DIR_NAME" ]]; then
    ACTUAL_SCOPE="global"
    SCOPE_DISPLAY="Global (~/$CLAUDE_DIR_NAME/)"
else
    ACTUAL_SCOPE="project"
    SCOPE_DISPLAY="Project (./$CLAUDE_DIR_NAME/)"
fi

# Check if already set up
if [[ -f "$MARKER_FILE" ]]; then
    echo "SessionStart hook already configured ($SCOPE_DISPLAY)."
    exit 0
fi

# Ensure .claude directory exists
if [[ ! -d "$CLAUDE_DIR" ]]; then
    mkdir -p "$CLAUDE_DIR"
    echo "Created $SCOPE_DISPLAY directory"
fi

# Check if settings file exists, create if needed
if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo '{}' > "$SETTINGS_FILE"
    echo "Created $SETTINGS_FILE"
fi

# Add SessionStart hook to settings
if command -v jq &>/dev/null; then
    # Use jq to safely add hook
    temp_file=$(mktemp)

    # Read existing settings and add/update hooks.SessionStart
    jq '.hooks.SessionStart = [
        {
            "matcher": "",
            "hooks": [
                {"type": "command", "command": "/validate-setup --quiet"},
                {"type": "command", "command": "/sync-template --check-only"},
                {"type": "command", "command": "/load-role-context --quiet"}
            ]
        }
    ]' "$SETTINGS_FILE" > "$temp_file"

    mv "$temp_file" "$SETTINGS_FILE"

    echo "✓ SessionStart hook configured ($SCOPE_DISPLAY)"
    touch "$MARKER_FILE"

    echo ""
    echo "Configuration complete!"
    echo "Scope: $SCOPE_DISPLAY"
    echo "Settings file: $SETTINGS_FILE"
    echo ""
    echo "The following commands will run on session start:"
    echo "  1. /validate-setup --quiet - Validates .claude directory setup"
    echo "  2. /sync-template --check-only - Checks for template updates"
    echo "  3. /load-role-context --quiet - Loads your role guide and documents"
    echo ""

    if [[ "$ACTUAL_SCOPE" == "global" ]]; then
        echo "This hook will run for all projects unless overridden by project-specific hooks."
    else
        echo "This hook will run for this project only."
    fi
    echo ""
    echo "Restart Claude Code or start a new session to activate the hook."
else
    echo "Error: jq not found. Please install jq to continue." >&2
    echo "" >&2
    echo "Manual setup instructions:" >&2
    echo "Add the following to $SETTINGS_FILE:" >&2
    echo '  "hooks": {' >&2
    echo '    "SessionStart": [' >&2
    echo '      {' >&2
    echo '        "matcher": "",' >&2
    echo '        "hooks": [' >&2
    echo '          {"type": "command", "command": "/validate-setup --quiet"},' >&2
    echo '          {"type": "command", "command": "/sync-template --check-only"},' >&2
    echo '          {"type": "command", "command": "/load-role-context --quiet"}' >&2
    echo '        ]' >&2
    echo '      }' >&2
    echo '    ]' >&2
    echo '  }' >&2
    exit 1
fi
