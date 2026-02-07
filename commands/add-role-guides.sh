#!/usr/bin/env bash
# Add role guides to existing organizational setup
#
# This command allows adding role guides after initial template setup,
# supporting both template-based guides and custom placeholder guides.

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"

# Handle --help flag
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    if [ -f "$SCRIPT_DIR/add-role-guides.md" ]; then
        cat "$SCRIPT_DIR/add-role-guides.md"
    else
        echo "Usage: /add-role-guides <guide1> [guide2] [CUSTOM:name] ..."
        echo ""
        echo "Add role guides to your organizational setup."
        echo ""
        echo "Examples:"
        echo "  /add-role-guides software-engineer-guide.md"
        echo "  /add-role-guides qa-engineer-guide.md CUSTOM:devops-lead"
        echo ""
        echo "For full documentation, see commands/add-role-guides.md"
    fi
    exit 0
fi

# Source role-manager.sh to get cmd_add_role_guides function
if [ ! -f "$PLUGIN_DIR/scripts/role-manager.sh" ]; then
    echo "Error: role-manager.sh not found at $PLUGIN_DIR/scripts/" >&2
    exit 1
fi

source "$PLUGIN_DIR/scripts/role-manager.sh"

# Call the command function with all arguments
cmd_add_role_guides "$@"
