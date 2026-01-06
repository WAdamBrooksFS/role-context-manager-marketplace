#!/usr/bin/env bash

# post-install.sh - Configure SessionStart hook for role-context-manager
# Part of role-context-manager v1.2.0
#
# This script automatically configures the SessionStart hook in project settings
# when the plugin is first used. It ensures the hook is added to .claude/settings.json
# so that validation and template sync checks run on every session start.
#
# Exit codes:
#   0 - Success
#   1 - Configuration failed (jq not found or error)

set -euo pipefail

# Determine project root and settings location
PROJECT_ROOT="${PWD}"
CLAUDE_DIR=".claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
MARKER_FILE="$CLAUDE_DIR/.role-context-manager-setup-complete"

# Check if already set up
if [[ -f "$MARKER_FILE" ]]; then
    echo "SessionStart hook already configured."
    exit 0
fi

# Ensure .claude directory exists
if [[ ! -d "$CLAUDE_DIR" ]]; then
    mkdir -p "$CLAUDE_DIR"
    echo "Created $CLAUDE_DIR directory"
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
        "/validate-setup --quiet",
        "/sync-template --check-only"
    ]' "$SETTINGS_FILE" > "$temp_file"

    mv "$temp_file" "$SETTINGS_FILE"

    echo "✓ SessionStart hook configured"
    touch "$MARKER_FILE"

    echo ""
    echo "Configuration complete! The following commands will run on session start:"
    echo "  1. /validate-setup --quiet - Validates .claude directory setup"
    echo "  2. /sync-template --check-only - Checks for template updates"
    echo ""
    echo "Restart Claude Code or start a new session to activate the hook."
else
    echo "Error: jq not found. Please install jq to continue." >&2
    echo ""echo "Manual setup instructions:" >&2
    echo "Add the following to $SETTINGS_FILE:" >&2
    echo '  "hooks": {' >&2
    echo '    "SessionStart": [' >&2
    echo '      "/validate-setup --quiet",' >&2
    echo '      "/sync-template --check-only"' >&2
    echo '    ]' >&2
    echo '  }' >&2
    exit 1
fi
