#!/usr/bin/env bash

# template-manager.sh - Template management utilities for role-context-manager plugin
# Part of role-context-manager v1.1.0

set -euo pipefail

# Get plugin directory
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="$PLUGIN_DIR/templates"
REGISTRY_FILE="$TEMPLATES_DIR/registry.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# =============================================================================
# Template Discovery Functions
# =============================================================================

# List all available templates (bundled + external)
list_available_templates() {
  local format="${1:-json}" # json or text

  if [ ! -f "$REGISTRY_FILE" ]; then
    echo "Error: Template registry not found at $REGISTRY_FILE" >&2
    return 1
  fi

  if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed" >&2
    return 1
  fi

  if [ "$format" = "text" ]; then
    echo "Available Templates:"
    echo ""
    jq -r '.bundled[] | "  \(.id) - \(.name) v\(.version)\n    \(.description)\n    Target: \(.target_audience)\n"' "$REGISTRY_FILE"
  else
    jq '.bundled' "$REGISTRY_FILE"
  fi
}

# Get template manifest by ID
get_template_manifest() {
  local template_id="$1"

  if [ -z "$template_id" ]; then
    echo "Error: Template ID required" >&2
    return 1
  fi

  local template_path
  template_path=$(jq -r ".bundled[] | select(.id==\"$template_id\") | .path" "$REGISTRY_FILE")

  if [ -z "$template_path" ] || [ "$template_path" = "null" ]; then
    echo "Error: Template '$template_id' not found in registry" >&2
    return 1
  fi

  local manifest_file="$PLUGIN_DIR/$template_path/manifest.json"

  if [ ! -f "$manifest_file" ]; then
    echo "Error: Manifest not found at $manifest_file" >&2
    return 1
  fi

  cat "$manifest_file"
}

# Get template path by ID
get_template_path() {
  local template_id="$1"

  local template_path
  template_path=$(jq -r ".bundled[] | select(.id==\"$template_id\") | .path" "$REGISTRY_FILE")

  if [ -z "$template_path" ] || [ "$template_path" = "null" ]; then
    echo "Error: Template '$template_id' not found" >&2
    return 1
  fi

  echo "$PLUGIN_DIR/$template_path"
}

# =============================================================================
# Template Validation Functions
# =============================================================================

# Validate template structure before applying
validate_template() {
  local template_path="$1"

  if [ ! -d "$template_path" ]; then
    echo "Error: Template directory not found: $template_path" >&2
    return 1
  fi

  # Check for required files/directories
  local errors=0

  if [ ! -f "$template_path/manifest.json" ]; then
    echo "Error: Missing manifest.json" >&2
    ((errors++))
  fi

  if [ ! -d "$template_path/.claude" ]; then
    echo "Error: Missing .claude directory" >&2
    ((errors++))
  fi

  if [ ! -d "$template_path/.claude/role-guides" ]; then
    echo "Error: Missing .claude/role-guides directory" >&2
    ((errors++))
  fi

  # Check if role-guides has at least one file
  local guide_count
  guide_count=$(find "$template_path/.claude/role-guides" -name "*.md" 2>/dev/null | wc -l)
  if [ "$guide_count" -eq 0 ]; then
    echo "Warning: No role guide files found in template" >&2
  fi

  # Validate manifest.json structure
  if [ -f "$template_path/manifest.json" ]; then
    if ! jq empty "$template_path/manifest.json" 2>/dev/null; then
      echo "Error: Invalid JSON in manifest.json" >&2
      ((errors++))
    fi

    # Check required manifest fields
    local required_fields=("id" "name" "version" "description")
    for field in "${required_fields[@]}"; do
      local value
      value=$(jq -r ".$field" "$template_path/manifest.json" 2>/dev/null)
      if [ -z "$value" ] || [ "$value" = "null" ]; then
        echo "Error: Missing required field in manifest: $field" >&2
        ((errors++))
      fi
    done
  fi

  if [ $errors -gt 0 ]; then
    return 1
  fi

  echo "✓ Template structure valid"
  return 0
}

# =============================================================================
# Template Application Functions
# =============================================================================

# Apply template to current directory
apply_template() {
  local template_id="$1"
  local target_dir="${2:-.}" # Default to current directory

  echo "Applying template: $template_id"

  # Get template path
  local template_path
  template_path=$(get_template_path "$template_id")
  if [ $? -ne 0 ]; then
    return 1
  fi

  # Validate template
  if ! validate_template "$template_path"; then
    echo "Error: Template validation failed" >&2
    return 1
  fi

  # Check if .claude already exists
  if [ -d "$target_dir/.claude" ]; then
    echo "Warning: .claude directory already exists" >&2
    echo "Use template-sync agent for updating existing setups" >&2
    return 1
  fi

  # Copy .claude directory
  echo "Copying .claude directory..."
  if [ ! -d "$template_path/.claude" ]; then
    echo "Error: Template .claude directory not found" >&2
    return 1
  fi

  mkdir -p "$target_dir/.claude"
  cp -r "$template_path/.claude"/* "$target_dir/.claude/"

  # Record applied template
  record_applied_template "$template_id" "$target_dir/.claude/preferences.json"

  echo -e "${GREEN}✓${NC} Template applied successfully"
  return 0
}

# =============================================================================
# Template Version Management
# =============================================================================

# Check template version and compare with applied version
check_template_version() {
  local prefs_file="${1:-.claude/preferences.json}"

  if [ ! -f "$prefs_file" ]; then
    echo "No preferences file found" >&2
    return 1
  fi

  # Get applied template info
  local applied_id
  local applied_version
  applied_id=$(jq -r '.applied_template.id // empty' "$prefs_file" 2>/dev/null)
  applied_version=$(jq -r '.applied_template.version // empty' "$prefs_file" 2>/dev/null)

  if [ -z "$applied_id" ]; then
    echo "No template currently applied"
    return 1
  fi

  # Get latest version from registry
  local latest_version
  latest_version=$(jq -r ".bundled[] | select(.id==\"$applied_id\") | .version" "$REGISTRY_FILE" 2>/dev/null)

  if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
    echo "Template not found in registry: $applied_id" >&2
    return 1
  fi

  # Compare versions
  if [ "$applied_version" = "$latest_version" ]; then
    echo "up-to-date:$applied_version"
    return 0
  else
    echo "update-available:$applied_version:$latest_version"
    return 0
  fi
}

# Check if auto-update is enabled
should_auto_update() {
  local prefs_file="${1:-.claude/preferences.json}"

  if [ ! -f "$prefs_file" ]; then
    # Default to true if preferences file doesn't exist
    echo "true"
    return 0
  fi

  local auto_update
  auto_update=$(jq -r '.auto_update_templates // true' "$prefs_file" 2>/dev/null)

  echo "$auto_update"
  return 0
}

# =============================================================================
# Template Tracking Functions
# =============================================================================

# Record applied template in preferences
record_applied_template() {
  local template_id="$1"
  local prefs_file="$2"

  # Get template version from registry
  local version
  version=$(jq -r ".bundled[] | select(.id==\"$template_id\") | .version" "$REGISTRY_FILE" 2>/dev/null)

  if [ -z "$version" ] || [ "$version" = "null" ]; then
    echo "Error: Could not determine template version" >&2
    return 1
  fi

  # Get current date in ISO format
  local applied_date
  applied_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Create or update preferences file
  if [ ! -f "$prefs_file" ]; then
    mkdir -p "$(dirname "$prefs_file")"
    echo '{}' > "$prefs_file"
  fi

  # Update applied_template object
  local temp_file
  temp_file=$(mktemp)
  jq --arg id "$template_id" \
     --arg ver "$version" \
     --arg date "$applied_date" \
     '.applied_template = {id: $id, version: $ver, applied_date: $date}' \
     "$prefs_file" > "$temp_file"

  mv "$temp_file" "$prefs_file"

  echo "✓ Recorded template: $template_id v$version"
  return 0
}

# =============================================================================
# Backup Functions
# =============================================================================

# Create backup of .claude directory before template operations
create_template_backup() {
  local claude_dir="${1:-.claude}"
  local reason="${2:-manual-backup}"

  if [ ! -d "$claude_dir" ]; then
    echo "Error: .claude directory not found" >&2
    return 1
  fi

  # Create backup directory with timestamp
  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_dir="$claude_dir/.backups/$timestamp"

  mkdir -p "$backup_dir"

  # Copy all files except .backups directory itself
  find "$claude_dir" -mindepth 1 -maxdepth 1 ! -name '.backups' -exec cp -r {} "$backup_dir/" \;

  # Create backup manifest
  local prefs_file="$claude_dir/preferences.json"
  local manifest_file="$backup_dir/backup-manifest.json"

  if [ -f "$prefs_file" ]; then
    local applied_id
    local applied_version
    applied_id=$(jq -r '.applied_template.id // "unknown"' "$prefs_file" 2>/dev/null)
    applied_version=$(jq -r '.applied_template.version // "unknown"' "$prefs_file" 2>/dev/null)

    cat > "$manifest_file" <<EOF
{
  "backup_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "reason": "$reason",
  "template_info": {
    "id": "$applied_id",
    "version": "$applied_version"
  }
}
EOF
  fi

  echo "$backup_dir"
  return 0
}

# List available backups
list_backups() {
  local claude_dir="${1:-.claude}"
  local backups_dir="$claude_dir/.backups"

  if [ ! -d "$backups_dir" ]; then
    echo "No backups found"
    return 0
  fi

  echo "Available backups:"
  for backup in "$backups_dir"/*; do
    if [ -d "$backup" ]; then
      local backup_name
      backup_name=$(basename "$backup")
      local manifest="$backup/backup-manifest.json"

      if [ -f "$manifest" ]; then
        local date reason template_id template_version
        date=$(jq -r '.backup_date' "$manifest" 2>/dev/null)
        reason=$(jq -r '.reason' "$manifest" 2>/dev/null)
        template_id=$(jq -r '.template_info.id' "$manifest" 2>/dev/null)
        template_version=$(jq -r '.template_info.version' "$manifest" 2>/dev/null)
        echo "  $backup_name - $reason (Template: $template_id v$template_version) - $date"
      else
        echo "  $backup_name"
      fi
    fi
  done
}

# =============================================================================
# Main CLI Interface
# =============================================================================

# Show usage information
show_usage() {
  cat <<EOF
Template Manager - role-context-manager v1.1.0

Usage: $0 <command> [arguments]

Commands:
  list                    List available templates
  manifest <template-id>  Show template manifest
  validate <template-id>  Validate template structure
  apply <template-id>     Apply template to current directory
  check-version           Check for template updates
  backup [reason]         Create backup of .claude directory
  list-backups            List available backups

Examples:
  $0 list
  $0 manifest software-org
  $0 apply software-org
  $0 check-version
  $0 backup "before-manual-edit"

EOF
}

# Main command dispatcher
main() {
  local command="${1:-}"

  case "$command" in
    list)
      list_available_templates "text"
      ;;
    manifest)
      if [ $# -lt 2 ]; then
        echo "Error: Template ID required" >&2
        echo "Usage: $0 manifest <template-id>" >&2
        exit 1
      fi
      get_template_manifest "$2"
      ;;
    validate)
      if [ $# -lt 2 ]; then
        echo "Error: Template ID required" >&2
        echo "Usage: $0 validate <template-id>" >&2
        exit 1
      fi
      local path
      path=$(get_template_path "$2")
      validate_template "$path"
      ;;
    apply)
      if [ $# -lt 2 ]; then
        echo "Error: Template ID required" >&2
        echo "Usage: $0 apply <template-id>" >&2
        exit 1
      fi
      apply_template "$2"
      ;;
    check-version)
      check_template_version
      ;;
    backup)
      local reason="${2:-manual-backup}"
      local backup_path
      backup_path=$(create_template_backup ".claude" "$reason")
      echo -e "${GREEN}✓${NC} Backup created: $backup_path"
      ;;
    list-backups)
      list_backups
      ;;
    -h|--help|help)
      show_usage
      ;;
    "")
      echo "Error: Command required" >&2
      show_usage
      exit 1
      ;;
    *)
      echo "Error: Unknown command: $command" >&2
      show_usage
      exit 1
      ;;
  esac
}

# Run main if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  main "$@"
fi
