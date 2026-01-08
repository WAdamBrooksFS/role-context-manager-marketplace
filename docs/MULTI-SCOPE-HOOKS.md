# Multi-Scope Hook Behavior

## Overview

Starting with v1.3.0, the role-context-manager plugin supports multi-scope configuration, allowing hooks to be configured at either the global level (`~/.claude/`) or project level (`./.claude/`). This document explains how hooks work with multi-scope support.

## Hook Configuration Scopes

### Global Hooks (~/.claude/settings.json)

**When to use:**
- You want validation and sync checks to run for all projects
- You have personal preferences that should apply everywhere
- You want consistent behavior across all projects

**How to configure:**
```bash
# Using the setup command
/setup-plugin-hooks --global

# Or manually via environment variable
SCOPE=global bash ~/.claude/plugins/role-context-manager/scripts/post-install.sh
```

**Behavior:**
- Hooks run for all projects unless overridden by project-specific hooks
- Validates global config (~/.claude/) when no project config exists
- Validates both global and project configs when in a project

### Project Hooks (./.claude/settings.json)

**When to use:**
- You want project-specific validation rules
- Your team has standardized hooks for this project
- You want to override global hook behavior for this project

**How to configure:**
```bash
# Using the setup command
/setup-plugin-hooks --project

# Or manually via environment variable
SCOPE=project bash ~/.claude/plugins/role-context-manager/scripts/post-install.sh
```

**Behavior:**
- Hooks run only for this project
- Override global hooks when both exist
- Validate project config (./.claude/)

### Auto (Default)

**Behavior:**
- If in project with `.claude/`: Configure project-level hooks
- Otherwise: Configure global-level hooks
- Smart default that adapts to context

```bash
# Using the setup command (defaults to auto)
/setup-plugin-hooks

# Or explicitly
/setup-plugin-hooks --scope auto
```

## Hook Execution Behavior

### SessionStart Hook

The SessionStart hook runs two commands:

1. **`/validate-setup --quiet`**
   - Validates .claude directory structure
   - Verifies role guides exist
   - Validates configuration files
   - **Multi-scope behavior:**
     - If global hook: Validates global config, and project config if in project
     - If project hook: Validates project config only
     - Only shows output if problems found

2. **`/sync-template --check-only`**
   - Checks if template updates available
   - Compares template version with registry
   - **Multi-scope behavior:**
     - If global hook: Checks both global and project template versions
     - If project hook: Checks project template version only
     - Respects `auto_update_templates` preference
     - Never applies updates automatically (check-only mode)

## Configuration Precedence

When both global and project hooks are configured:

1. **Project hooks take precedence** - Project settings.json overrides global
2. **Commands validate both scopes** - Even with project hooks, commands can validate both global and project configs
3. **Independent marker files** - Each scope has its own setup-complete marker

## Hook Configuration Files

### Global Hook Configuration
- **Settings file**: `~/.claude/settings.json`
- **Marker file**: `~/.claude/.role-context-manager-setup-complete`
- **Affects**: All projects (unless overridden)

### Project Hook Configuration
- **Settings file**: `./.claude/settings.json`
- **Marker file**: `./.claude/.role-context-manager-setup-complete`
- **Affects**: Current project only

## Example Scenarios

### Scenario 1: Global Hooks Only

**Setup:**
```bash
cd ~
SCOPE=global bash ~/.claude/plugins/role-context-manager/scripts/post-install.sh
```

**Behavior:**
- Hooks run for all projects
- Validates global config when outside projects
- Validates both global and project configs when in projects
- Consistent behavior everywhere

### Scenario 2: Project Hooks Only

**Setup:**
```bash
cd /path/to/my-project
SCOPE=project bash ~/.claude/plugins/role-context-manager/scripts/post-install.sh
```

**Behavior:**
- Hooks run only in this project
- Other projects have no hooks
- Validates project config only
- Good for team-standardized setups

### Scenario 3: Global + Project Override

**Setup:**
```bash
# Configure global hooks
cd ~
SCOPE=global bash ~/.claude/plugins/role-context-manager/scripts/post-install.sh

# Configure project-specific hooks in special project
cd /path/to/special-project
SCOPE=project bash ~/.claude/plugins/role-context-manager/scripts/post-install.sh
```

**Behavior:**
- Most projects use global hooks
- `special-project` uses project-specific hooks
- Project hooks override global in that project
- Flexibility for special cases

## Customizing Hook Behavior

### Minimal Validation (Global)

Edit `~/.claude/settings.json`:
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --silent"
    ]
  }
}
```

### Standard (Recommended - Project)

Edit `./.claude/settings.json`:
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --quiet",
      "/sync-template --check-only"
    ]
  }
}
```

### Verbose with Role Context (Global)

Edit `~/.claude/settings.json`:
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup",
      "/sync-template --check-only",
      "/show-role-context --summary"
    ]
  }
}
```

### Different Hooks Per Scope

**Global** (`~/.claude/settings.json`):
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --global --quiet"
    ]
  }
}
```

**Project** (`./.claude/settings.json`):
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --project",
      "/sync-template --project"
    ]
  }
}
```

This configuration validates only the specific scope in each context.

## Troubleshooting

### Hooks Not Running

**Check hook configuration:**
```bash
# For global
cat ~/.claude/settings.json

# For project
cat ./.claude/settings.json
```

**Verify marker files:**
```bash
# Global
ls -la ~/.claude/.role-context-manager-setup-complete

# Project
ls -la ./.claude/.role-context-manager-setup-complete
```

**Re-configure if needed:**
```bash
# Remove marker file
rm ./.claude/.role-context-manager-setup-complete  # or ~/.claude/...

# Re-run setup
/setup-plugin-hooks --scope [global|project|auto]
```

### Wrong Scope Being Validated

**Problem:** Hook is validating wrong scope or not finding config

**Solution:** Check which hooks are configured:
```bash
# Check both settings files
echo "Global hooks:"
jq '.hooks.SessionStart' ~/.claude/settings.json 2>/dev/null || echo "None"

echo "Project hooks:"
jq '.hooks.SessionStart' ./.claude/settings.json 2>/dev/null || echo "None"
```

**Reconfigure to desired scope:**
```bash
/setup-plugin-hooks --scope [desired-scope]
```

### Validation Errors on Startup

**Problem:** SessionStart hook shows errors every time

**Solution:** Run full validation to see details:
```bash
/validate-setup --verbose
```

Fix reported issues, then hooks will run clean.

## Best Practices

### For Individual Users

1. **Use global hooks** for personal consistency
2. Configure once in `~/.claude/`
3. Works across all projects automatically
4. Override with project hooks only when needed

### For Teams

1. **Use project hooks** for team standards
2. Commit `.claude/settings.json` to git
3. Ensure all team members run `/setup-plugin-hooks` after clone
4. Document project-specific hook configuration

### For Mixed Environments

1. **Global hooks** for personal preferences
2. **Project hooks** for team requirements
3. Project hooks override global automatically
4. Clean separation of concerns

## Migration Guide

### From Project-Only to Multi-Scope

**Before (project-only):**
```bash
# Hooks only worked in projects
cd /path/to/project
# Hooks would run
```

**After (multi-scope):**
```bash
# Configure global hooks for all projects
SCOPE=global bash ~/.claude/plugins/role-context-manager/scripts/post-install.sh

# Keep project-specific hooks where needed
cd /path/to/special-project
SCOPE=project bash ~/.claude/plugins/role-context-manager/scripts/post-install.sh
```

**Benefits:**
- Hooks work everywhere (not just in projects)
- Consistent validation across all work
- Project overrides when needed

## Related Documentation

- [Setup Plugin Hooks Command](../commands/setup-plugin-hooks.md)
- [Validate Setup Command](../commands/validate-setup.md)
- [Sync Template Command](../commands/sync-template.md)
- [Multi-Scope Configuration Plan](../.claude/plans/mutable-gliding-castle.md)
