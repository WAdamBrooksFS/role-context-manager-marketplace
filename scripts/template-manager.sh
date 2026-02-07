#!/usr/bin/env bash

# template-manager.sh - Template management utilities for role-context-manager plugin
# Part of role-context-manager v1.1.0

set -euo pipefail

# Source path configuration library
source "$(dirname "$0")/path-config.sh"

# Source hierarchy detection library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/hierarchy-detector.sh"

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

  local claude_dir_name
  claude_dir_name="$(get_claude_dir_name)" || claude_dir_name=".claude"
  local role_guides_dir
  role_guides_dir="$(get_role_guides_dir)" || role_guides_dir="role-guides"

  if [ ! -d "$template_path/$claude_dir_name" ]; then
    echo "Error: Missing $claude_dir_name directory" >&2
    ((errors++))
  fi

  if [ ! -d "$template_path/$claude_dir_name/$role_guides_dir" ]; then
    echo "Error: Missing $claude_dir_name/$role_guides_dir directory" >&2
    ((errors++))
  fi

  # Check if role-guides has at least one file
  local guide_count
  guide_count=$(find "$template_path/$claude_dir_name/$role_guides_dir" -name "*.md" 2>/dev/null | wc -l)
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

# Apply template to current directory (backward compatible - uses standard mode)
apply_template() {
  local template_id="$1"
  local target_dir="${2:-.}" # Default to current directory

  # Use the new mode-based function with standard mode for backward compatibility
  apply_template_with_mode "$template_id" "standard" "$target_dir"
}

# =============================================================================
# Template Version Management
# =============================================================================

# Check template version and compare with applied version
check_template_version() {
  local claude_dir_name
  claude_dir_name="$(get_claude_dir_name)" || claude_dir_name=".claude"
  local prefs_file="${1:-$claude_dir_name/preferences.json}"

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
  local claude_dir_name
  claude_dir_name="$(get_claude_dir_name)" || claude_dir_name=".claude"
  local prefs_file="${1:-$claude_dir_name/preferences.json}"

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
  local mode="${2:-standard}"  # Application mode
  local prefs_file="$3"

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

  # Update applied_template object with mode
  local temp_file
  temp_file=$(mktemp)
  jq --arg id "$template_id" \
     --arg ver "$version" \
     --arg date "$applied_date" \
     --arg mode "$mode" \
     '.applied_template = {id: $id, version: $ver, applied_date: $date, mode: $mode}' \
     "$prefs_file" > "$temp_file"

  mv "$temp_file" "$prefs_file"

  echo "✓ Recorded template: $template_id v$version (mode: $mode)"
  return 0
}

# =============================================================================
# Backup Functions
# =============================================================================

# Create backup of .claude directory before template operations
create_template_backup() {
  local claude_dir_name
  claude_dir_name="$(get_claude_dir_name)" || claude_dir_name=".claude"
  local claude_dir="${1:-$claude_dir_name}"
  local reason="${2:-manual-backup}"

  if [ ! -d "$claude_dir" ]; then
    echo "Error: $claude_dir_name directory not found" >&2
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
  local claude_dir_name
  claude_dir_name="$(get_claude_dir_name)" || claude_dir_name=".claude"
  local claude_dir="${1:-$claude_dir_name}"
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
# Template Content Discovery Functions
# =============================================================================

# Get path to specific template content (for agent use)
get_template_content_reference() {
  local template_id="$1"
  local content_type="$2"  # role_guides, document_guides, document_templates, etc.

  if [ -z "$template_id" ] || [ -z "$content_type" ]; then
    echo "Error: Template ID and content type required" >&2
    echo "Usage: get_template_content_reference <template-id> <content-type>" >&2
    return 1
  fi

  local template_path
  template_path=$(get_template_path "$template_id")
  if [ $? -ne 0 ]; then
    return 1
  fi

  local manifest_path="$template_path/manifest.json"
  if [ ! -f "$manifest_path" ]; then
    echo "Error: Manifest not found at $manifest_path" >&2
    return 1
  fi

  # Extract content structure path from manifest
  local content_path
  content_path=$(jq -r ".content_structure.$content_type.path // empty" "$manifest_path" 2>/dev/null)

  if [ -z "$content_path" ]; then
    echo "Error: Content type '$content_type' not found in template manifest" >&2
    return 1
  fi

  local full_path="$template_path/$content_path"
  if [ ! -d "$full_path" ] && [ ! -f "$full_path" ]; then
    echo "Error: Content path does not exist: $full_path" >&2
    return 1
  fi

  echo "$full_path"
  return 0
}

# List template contents from manifest
list_template_contents() {
  local template_id="$1"

  if [ -z "$template_id" ]; then
    echo "Error: Template ID required" >&2
    return 1
  fi

  local manifest
  manifest=$(get_template_manifest "$template_id")
  if [ $? -ne 0 ]; then
    return 1
  fi

  local template_name
  local template_version
  template_name=$(echo "$manifest" | jq -r '.name')
  template_version=$(echo "$manifest" | jq -r '.version')

  echo "Template: $template_name (v$template_version)"
  echo ""
  echo "Contents:"

  # Iterate through content_structure
  echo "$manifest" | jq -r '
    .content_structure | to_entries[] |
    "  \(.key):",
    "    Path: \(.value.path)",
    "    Purpose: \(.value.purpose)",
    "    Files: \(.value.count // (.value.files | length) // "N/A")",
    ""
  '
}

# Get template size
get_template_size() {
  local template_id="$1"

  if [ -z "$template_id" ]; then
    echo "Error: Template ID required" >&2
    return 1
  fi

  local template_path
  template_path=$(get_template_path "$template_id")
  if [ $? -ne 0 ]; then
    return 1
  fi

  # Get size in KB
  local size_kb
  size_kb=$(du -sk "$template_path" | awk '{print $1}')

  # Get file count
  local file_count
  file_count=$(find "$template_path" -type f | wc -l)

  echo "Template: $template_id"
  echo "Size: ${size_kb}KB"
  echo "Files: $file_count"
}

# Apply template with specific mode
apply_template_with_mode() {
  local template_id="$1"
  local mode="${2:-standard}"  # minimal, standard, or complete
  local target_dir="${3:-.}"   # Default to current directory

  echo "Applying template: $template_id (mode: $mode)"

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

  # Get manifest to determine what to copy
  local manifest_path="$template_path/manifest.json"
  if [ ! -f "$manifest_path" ]; then
    echo "Error: Manifest not found, cannot determine application mode" >&2
    return 1
  fi

  # Check if .claude already exists
  local claude_dir_name
  claude_dir_name="$(get_claude_dir_name)" || claude_dir_name=".claude"

  if [ -d "$target_dir/$claude_dir_name" ]; then
    echo "Warning: $claude_dir_name directory already exists" >&2
    echo "Use template-sync agent for updating existing setups" >&2
    return 1
  fi

  # Get includes for this mode
  local includes
  includes=$(jq -r ".application_modes.$mode.includes[]" "$manifest_path" 2>/dev/null)

  if [ -z "$includes" ]; then
    echo "Error: Application mode '$mode' not found in template" >&2
    echo "Available modes: minimal, standard, complete" >&2
    return 1
  fi

  echo "Mode: $mode"
  echo "Copying content sections: $(echo "$includes" | tr '\n' ' ')"
  echo ""

  # Copy content based on includes
  while IFS= read -r section; do
    local section_path
    section_path=$(jq -r ".content_structure.$section.path" "$manifest_path" 2>/dev/null)

    if [ -z "$section_path" ] || [ "$section_path" = "null" ]; then
      echo "Warning: Section '$section' not found in manifest, skipping" >&2
      continue
    fi

    local source_path="$template_path/$section_path"
    local dest_path="$target_dir/$section_path"

    if [ ! -e "$source_path" ]; then
      echo "Warning: Source path does not exist: $source_path, skipping" >&2
      continue
    fi

    echo "Copying $section from $section_path..."

    # Handle special case for root_docs (files in root)
    if [ "$section" = "root_docs" ]; then
      # Copy individual files listed in manifest
      jq -r ".content_structure.root_docs.files[]" "$manifest_path" | while read -r file; do
        if [ -f "$template_path/$file" ]; then
          cp "$template_path/$file" "$target_dir/"
        fi
      done
    elif [ -d "$source_path" ]; then
      # Copy directory
      mkdir -p "$(dirname "$dest_path")"
      cp -r "$source_path" "$dest_path"
    elif [ -f "$source_path" ]; then
      # Copy file
      mkdir -p "$(dirname "$dest_path")"
      cp "$source_path" "$dest_path"
    fi
  done <<< "$includes"

  # Record applied template with mode
  local claude_dir_name
  claude_dir_name="$(get_claude_dir_name)" || claude_dir_name=".claude"
  record_applied_template "$template_id" "$mode" "$target_dir/$claude_dir_name/preferences.json"

  echo -e "${GREEN}✓${NC} Template applied successfully (mode: $mode)"
  return 0
}

# =============================================================================
# Main CLI Interface
# =============================================================================

# Show usage information
show_usage() {
  cat <<EOF
Template Manager - role-context-manager v1.3.0

Usage: $0 <command> [arguments]

Commands:
  list                              List available templates
  manifest <template-id>            Show template manifest
  contents <template-id>            List template contents from manifest
  validate <template-id>            Validate template structure
  apply <template-id> [mode]        Apply template (modes: minimal, standard, complete)
  apply-mode <id> <mode> [dir]      Apply template with specific mode
  get-content-reference <id> <type> Get path to template content (for agents)
  size <template-id>                Show template size and file count
  check-version                     Check for template updates
  backup [reason]                   Create backup of .claude directory
  list-backups                      List available backups

Examples:
  $0 list
  $0 manifest software-org
  $0 contents software-org
  $0 apply software-org standard
  $0 apply-mode software-org complete /path/to/project
  $0 get-content-reference software-org document_templates
  $0 size software-org
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
    contents)
      if [ $# -lt 2 ]; then
        echo "Error: Template ID required" >&2
        echo "Usage: $0 contents <template-id>" >&2
        exit 1
      fi
      list_template_contents "$2"
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
        echo "Usage: $0 apply <template-id> [mode]" >&2
        exit 1
      fi
      local mode="${3:-standard}"
      apply_template_with_mode "$2" "$mode"
      ;;
    apply-mode)
      if [ $# -lt 3 ]; then
        echo "Error: Template ID and mode required" >&2
        echo "Usage: $0 apply-mode <template-id> <mode> [target-dir]" >&2
        exit 1
      fi
      local target_dir="${4:-.}"
      apply_template_with_mode "$2" "$3" "$target_dir"
      ;;
    get-content-reference)
      if [ $# -lt 3 ]; then
        echo "Error: Template ID and content type required" >&2
        echo "Usage: $0 get-content-reference <template-id> <content-type>" >&2
        exit 1
      fi
      get_template_content_reference "$2" "$3"
      ;;
    size)
      if [ $# -lt 2 ]; then
        echo "Error: Template ID required" >&2
        echo "Usage: $0 size <template-id>" >&2
        exit 1
      fi
      get_template_size "$2"
      ;;
    check-version)
      check_template_version
      ;;
    backup)
      local reason="${2:-manual-backup}"
      local claude_dir_name
      claude_dir_name="$(get_claude_dir_name)" || claude_dir_name=".claude"
      local backup_path
      backup_path=$(create_template_backup "$claude_dir_name" "$reason")
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
