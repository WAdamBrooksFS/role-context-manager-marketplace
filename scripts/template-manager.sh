#!/usr/bin/env bash

# template-manager.sh - Template management utilities for role-context-manager plugin
# Part of role-context-manager v1.1.0

set -euo pipefail

# Get plugin directory
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="$PLUGIN_DIR/templates"
REGISTRY_FILE="$TEMPLATES_DIR/registry.json"

# Source hierarchy detection functions
HIERARCHY_DETECTOR="$PLUGIN_DIR/scripts/hierarchy-detector.sh"
if [ -f "$HIERARCHY_DETECTOR" ]; then
  source "$HIERARCHY_DETECTOR"
fi

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
# Role Guide Filtering by Organizational Level
# =============================================================================

# Determine which role guides belong to each organizational level
# Returns: newline-separated list of role guide filename patterns for the level
get_role_guides_for_level() {
  local level="$1"

  case "$level" in
    company)
      # Company level roles: executives and C-level
      echo "cto-guide.md"
      echo "cto-vp-engineering-guide.md"
      echo "cpo-guide.md"
      echo "cpo-vp-product-guide.md"
      echo "ciso-guide.md"
      echo "vp-engineering-guide.md"
      echo "vp-product-guide.md"
      echo "director-qa-guide.md"
      ;;
    system)
      # System level roles: architects, platform, managers
      echo "engineering-manager-guide.md"
      echo "platform-engineer-guide.md"
      echo "cloud-architect-guide.md"
      echo "security-architect-guide.md"
      echo "data-architect-guide.md"
      echo "technical-program-manager-guide.md"
      echo "data-engineer-guide.md"
      echo "security-engineer-guide.md"
      ;;
    product)
      # Product level roles: product, design, QA leadership
      echo "qa-manager-guide.md"
      echo "ui-designer-guide.md"
      echo "ux-designer-guide.md"
      echo "product-manager-guide.md"
      echo "technical-product-manager-guide.md"
      ;;
    project)
      # Project level roles: individual contributors
      echo "software-engineer-guide.md"
      echo "frontend-engineer-guide.md"
      echo "backend-engineer-guide.md"
      echo "full-stack-engineer-guide.md"
      echo "qa-engineer-guide.md"
      echo "sdet-guide.md"
      echo "devops-engineer-guide.md"
      echo "sre-guide.md"
      echo "mobile-engineer-guide.md"
      echo "data-analyst-guide.md"
      echo "data-scientist-guide.md"
      echo "scrum-master-guide.md"
      ;;
    *)
      echo "Error: Unknown organizational level: $level" >&2
      return 1
      ;;
  esac
}

# Check if a role guide should be included based on current and parent level
# Args:
#   $1: role guide filename
#   $2: current organizational level
#   $3: parent organizational level (empty if no parent)
# Returns:
#   0 if should include, 1 if should skip
should_include_role_guide() {
  local role_guide="$1"
  local current_level="$2"
  local parent_level="${3:-}"

  # If no parent (root level), include all role guides for this level
  if [ -z "$parent_level" ]; then
    # Check if role guide belongs to current level
    local guides_for_level
    guides_for_level=$(get_role_guides_for_level "$current_level" 2>/dev/null || echo "")
    if echo "$guides_for_level" | grep -q "^${role_guide}$"; then
      return 0
    fi
  else
    # Has parent - only include guides for current level and below, skip parent levels
    # Get all levels from parent upward (company, system, product) to exclude
    local exclude_levels=()
    case "$parent_level" in
      company)
        exclude_levels=("company")
        ;;
      system)
        exclude_levels=("company" "system")
        ;;
      product)
        exclude_levels=("company" "system" "product")
        ;;
    esac

    # Check if this role guide belongs to any excluded level
    for level in "${exclude_levels[@]}"; do
      local guides_for_level
      guides_for_level=$(get_role_guides_for_level "$level" 2>/dev/null || echo "")
      if echo "$guides_for_level" | grep -q "^${role_guide}$"; then
        # This role guide belongs to parent level or above, skip it
        return 1
      fi
    done

    # Role guide doesn't belong to parent levels, include it
    return 0
  fi

  # Default: include the role guide
  return 0
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

# Generate a placeholder markdown template for a custom role guide
# Usage: generate_custom_role_guide_placeholder <role-name> <org-level>
# Output: Markdown content to stdout
generate_custom_role_guide_placeholder() {
  local role_name="$1"
  local org_level="${2:-project}"

  # Convert kebab-case to Title Case for display
  local display_name=$(echo "$role_name" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

  cat <<EOF
# $display_name - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** [Define the main purpose of this role]
**Organizational Level:** $org_level
**Key Documents Created:** [List documents this role typically creates]
**Key Documents Consumed:** [List documents this role uses for context]

## Deterministic Behaviors

### When [Primary Task Context]

**AI MUST:**
- [Define specific rules Claude must follow]
- [Add validation requirements]
- [Add security or compliance checks]
- [Add quality standards that must be met]

**Validation Checklist:**
- [ ] [Specific validation item 1]
- [ ] [Specific validation item 2]
- [ ] [Specific validation item 3]

### When [Secondary Task Context]

**AI MUST:**
- [Define rules for secondary workflow]
- [Add relevant checks]

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest when [scenario where AI can add value]
- Recommend [opportunities for improvement]
- Identify when [conditions that warrant attention]
- Propose [optimizations or enhancements]
- Flag when [risks or issues are detected]

### [Role-Specific] Support

**AI CAN help with:**
- [Task category 1]
- [Task category 2]
- [Task category 3]
- [Task category 4]

**AI CANNOT:**
- [Boundary: things AI should not do]
- [Limitation: actions requiring human judgment]
- [Restriction: decisions outside AI scope]

## Common Workflows

### Workflow 1: [Primary Workflow Name]

\`\`\`
1. $display_name: "[User initiates workflow]"
2. AI: [AI responds with...]
   - [Action 1]
   - [Action 2]
3. AI: [AI performs next step...]
4. $display_name: [User validates or provides input]
5. AI: [AI completes workflow]
\`\`\`

**Workflow Checkpoints:**
- After step 2: [What to validate]
- After step 3: [What to verify]
- Completion: [Final checks before marking done]

### Workflow 2: [Secondary Workflow Name]

\`\`\`
1. $display_name: "[User initiates alternate workflow]"
2. AI: [Steps for alternate workflow...]
\`\`\`

## Document Integration

**When working with this role, Claude should reference:**
- [Document type 1] - [Why it's relevant]
- [Document type 2] - [How to use it]
- [Document type 3] - [When to update it]

**Cross-references to other roles:**
- Collaborates with: [Related role 1], [Related role 2]
- Reports to: [Management role]
- Supports: [Dependent roles]

---

> **Note:** This is a placeholder template. Run \`/generate-role-guide\` for an AI-assisted customization workflow,
> or manually edit this guide to add role-specific deterministic rules, agentic behaviors, and workflows.
>
> **For guidance on customizing role guides:** See \`.claude/document-guides/role-guide-creation.md\` (if available)
EOF
}

# Apply template with specific mode
apply_template_with_mode() {
  local template_id="$1"
  local mode="${2:-standard}"  # minimal, standard, or complete
  local target_dir="${3:-.}"   # Default to current directory
  local selected_role_guides="${4:-}"  # Optional: comma-separated list of role guides to include

  echo "Applying template: $template_id (mode: $mode)"

  # Parse selected role guides if provided
  local -a role_guides_to_copy=()
  local -a custom_guides=()

  if [ -n "$selected_role_guides" ]; then
    echo "Processing role guide selection: $selected_role_guides"

    # Split by comma and process each entry
    IFS=',' read -ra guides <<< "$selected_role_guides"
    for guide in "${guides[@]}"; do
      # Trim whitespace
      guide=$(echo "$guide" | xargs)

      # Check for CUSTOM: prefix
      if [[ "$guide" =~ ^CUSTOM: ]]; then
        # Extract custom guide name (everything after "CUSTOM:")
        local custom_name="${guide#CUSTOM:}"
        custom_name=$(echo "$custom_name" | xargs)

        # Validate custom name (no path traversal, kebab-case format)
        if [[ "$custom_name" =~ \.\. ]] || [[ "$custom_name" =~ / ]]; then
          echo "Error: Invalid custom guide name '$custom_name' (no path traversal allowed)" >&2
          return 1
        fi

        if [[ ! "$custom_name" =~ ^[a-z][a-z0-9-]*$ ]]; then
          echo "Error: Custom guide name '$custom_name' must be kebab-case (lowercase, hyphens only)" >&2
          return 1
        fi

        custom_guides+=("$custom_name")
      else
        # Regular guide file - validate no path traversal
        if [[ "$guide" =~ \.\. ]] || [[ "$guide" =~ / ]]; then
          echo "Error: Invalid guide name '$guide' (no path traversal allowed)" >&2
          return 1
        fi

        role_guides_to_copy+=("$guide")
      fi
    done

    echo "Selected guides to copy: ${role_guides_to_copy[*]}"
    if [ ${#custom_guides[@]} -gt 0 ]; then
      echo "Custom guides to create: ${custom_guides[*]}"
    fi
  fi

  # Detect parent context for hierarchy-aware role guide filtering
  local parent_claude_dir=""
  local parent_level=""
  local current_level=""

  if [ -f "$HIERARCHY_DETECTOR" ]; then
    # Get nearest parent .claude directory
    parent_claude_dir=$(get_nearest_parent "$target_dir" 2>/dev/null || echo "")

    if [ -n "$parent_claude_dir" ]; then
      # Get parent's organizational level
      parent_level=$(get_level_value "$parent_claude_dir" 2>/dev/null || echo "")

      if [ -n "$parent_level" ]; then
        echo "Detected parent context: $parent_level at $parent_claude_dir"
        echo "Will filter role guides to exclude parent-level roles (inherited from parent)"
      fi
    else
      echo "No parent context detected - this will be a root-level setup"
    fi

    # Try to determine current level from target directory's organizational-level.json if it exists
    if [ -f "$target_dir/.claude/organizational-level.json" ]; then
      current_level=$(jq -r '.level // empty' "$target_dir/.claude/organizational-level.json" 2>/dev/null || echo "")
    fi
  fi

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
  if [ -d "$target_dir/.claude" ]; then
    echo "Warning: .claude directory already exists" >&2
    echo "Use template-sync agent for updating existing setups" >&2
    return 1
  fi

  # Detect existing CLAUDE.md files before applying template
  local preserved_claude_md=()
  if [ -x "$PLUGIN_DIR/scripts/claude-md-analyzer.sh" ]; then
    local scan_result
    scan_result=$(bash "$PLUGIN_DIR/scripts/claude-md-analyzer.sh" --scan "$target_dir" 2>/dev/null || echo '{"files": []}')

    # Extract file paths from scan result
    if command -v jq &>/dev/null; then
      while IFS= read -r file; do
        if [ -n "$file" ] && [ "$file" != "null" ]; then
          preserved_claude_md+=("$file")
          echo "Detected existing CLAUDE.md: $file" >&2
        fi
      done < <(echo "$scan_result" | jq -r '.files[]?.path // empty' 2>/dev/null)
    fi
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
          # Skip CLAUDE.md if it already exists (case-insensitive check)
          if [[ "$file" =~ [Cc][Ll][Aa][Uu][Dd][Ee]\.md$ ]] && [ -f "$target_dir/CLAUDE.md" ]; then
            echo "Skipping $file - preserving existing CLAUDE.md" >&2
            continue
          fi
          cp "$template_path/$file" "$target_dir/"
        fi
      done
    elif [ "$section" = "claude_config" ] && [ -n "$parent_level" ]; then
      # Special handling for claude_config when parent context exists
      # Copy the directory structure, but filter role guides
      mkdir -p "$dest_path"

      # Copy all non-role-guide content
      find "$source_path" -mindepth 1 -maxdepth 1 ! -name 'role-guides' -exec cp -r {} "$dest_path/" \;

      # Handle role-guides with filtering
      if [ -d "$source_path/role-guides" ]; then
        mkdir -p "$dest_path/role-guides"

        local role_guides_source="$source_path/role-guides"
        local role_guides_dest="$dest_path/role-guides"
        local filtered_count=0
        local copied_count=0

        # Check if user provided explicit selection
        if [ ${#role_guides_to_copy[@]} -gt 0 ] || [ ${#custom_guides[@]} -gt 0 ]; then
          echo "Copying selected role guides only"

          # Copy explicitly selected guides
          for guide_name in "${role_guides_to_copy[@]}"; do
            local guide_file="$role_guides_source/$guide_name"

            if [ ! -f "$guide_file" ]; then
              echo "Warning: Selected guide '$guide_name' not found in template" >&2
              continue
            fi

            # Check if guide should be included (respects parent filtering)
            if should_include_role_guide "$guide_name" "${current_level:-project}" "$parent_level"; then
              cp "$guide_file" "$role_guides_dest/"
              echo "  Copied: $guide_name"
              ((copied_count++))
            else
              echo "  Skipped: $guide_name (inherited from parent $parent_level level)" >&2
              ((filtered_count++))
            fi
          done

          # Generate custom guide placeholders
          for custom_name in "${custom_guides[@]}"; do
            local custom_file="$role_guides_dest/${custom_name}-guide.md"

            # Generate placeholder content
            if generate_custom_role_guide_placeholder "$custom_name" "${current_level:-project}" > "$custom_file"; then
              echo "  Created custom guide: ${custom_name}-guide.md"
              ((copied_count++))
            else
              echo "Warning: Failed to create custom guide: $custom_name" >&2
            fi
          done

          echo "Role guide selection: copied $copied_count guides, filtered $filtered_count (inherited from parent)"

        else
          # No explicit selection - copy all with parent filtering (backward compatible)
          echo "Filtering role guides based on parent level: $parent_level"

          # Copy role guides selectively
          for guide_file in "$role_guides_source"/*.md; do
            if [ -f "$guide_file" ]; then
              local guide_name
              guide_name=$(basename "$guide_file")

              # Check if we should include this guide
              if should_include_role_guide "$guide_name" "${current_level:-project}" "$parent_level"; then
                cp "$guide_file" "$role_guides_dest/"
                ((copied_count++))
              else
                echo "  Skipping $guide_name (inherited from parent $parent_level level)" >&2
                ((filtered_count++))
              fi
            fi
          done

          echo "Role guide filtering: copied $copied_count, filtered $filtered_count (inherited from parent)"
        fi
      fi
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
  record_applied_template "$template_id" "$mode" "$target_dir/.claude/preferences.json"

  # Record preserved CLAUDE.md files in preferences.json
  if [ ${#preserved_claude_md[@]} -gt 0 ]; then
    local prefs_file="$target_dir/.claude/preferences.json"
    if [ -f "$prefs_file" ] && command -v jq &>/dev/null; then
      local preserved_json
      preserved_json=$(printf '%s\n' "${preserved_claude_md[@]}" | jq -R . | jq -s .)
      jq --argjson preserved "$preserved_json" '.preserved_claude_md = $preserved' "$prefs_file" > "$prefs_file.tmp" && mv "$prefs_file.tmp" "$prefs_file"
      echo "Recorded ${#preserved_claude_md[@]} preserved CLAUDE.md file(s)" >&2
    fi
  fi

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
