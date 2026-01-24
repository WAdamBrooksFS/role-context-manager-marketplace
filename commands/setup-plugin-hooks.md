# Setup Plugin Hooks Command

Configure SessionStart hook for role-context-manager plugin.

## Purpose

This command is used once after plugin installation to configure the SessionStart hook in settings (global or project). It ensures that the plugin's validation and template sync checks run automatically when you start a new Claude Code session. Can be configured at global level (~/.claude/settings.json) or project level (./.claude/settings.json).

## Arguments

- `--global`: Configure hook in global settings (~/.claude/settings.json)
- `--project`: Configure hook in project settings (./.claude/settings.json)
- `--scope <auto|global|project>`: Explicitly specify scope (default: auto)

## Scope Behavior

### Auto (default)
- If in project with `.claude/`: Configure project-level hook
- Otherwise: Configure global-level hook

### Global (`--global`)
- Configure hook in `~/.claude/settings.json`
- Works across all projects unless project has its own hook

### Project (`--project`)
- Configure hook in `./.claude/settings.json`
- Only affects current project
- Overrides global hook if both exist

## When to Use

- **First time using the plugin**: Hooks are usually configured automatically on first command use
- **Re-configuration needed**: If hooks were manually disabled or removed
- **Troubleshooting**: If SessionStart hook isn't running as expected

## Instructions for Claude

When this command is executed:

### Step 1: Determine Scope

1. Parse scope arguments:
   - Extract scope flags (--global, --project, --scope)
   - Determine scope value:
     - If `--global` present: scope = "global" (configure in ~/.claude/)
     - If `--project` present: scope = "project" (configure in ./.claude/)
     - If `--scope <value>` present: scope = value
     - Otherwise: scope = "auto" (project if in project context, else global)

2. Determine target settings file:
   - Global scope: `~/.claude/settings.json`
   - Project scope: `./.claude/settings.json`

### Step 2: Check Current Configuration

1. Check if hook is already configured in target scope:
   - Read appropriate `settings.json` (or `settings.local.json` if it exists)
   - Look for `hooks.SessionStart` array
   - Check if it includes `/validate-setup --quiet`, `/sync-template --check-only`, and `/load-role-context --quiet`

2. Check for marker file in appropriate location:
   - Global: `~/.claude/.role-context-manager-setup-complete`
   - Project: `./.claude/.role-context-manager-setup-complete`

### Step 3: Configure Hook if Needed

If not already configured:

1. Run the post-install script with scope:
   ```bash
   SCOPE=[scope] bash scripts/post-install.sh
   ```

2. Capture the output and check exit code:
   - Exit code 0: Success
   - Exit code 1: Failed (jq not installed or other error)

### Step 4: Display Result

**If already configured:**
```
SessionStart hook is already set up ([scope] scope).

Location: [~/.claude/settings.json OR ./.claude/settings.json]

Current configuration:
  - /validate-setup --quiet (validates .claude directory)
  - /sync-template --check-only (checks for template updates)
  - /load-role-context --quiet (loads role guide and documents)

No action needed. The hook will run on your next session start.
```

**If newly configured:**
```
✓ SessionStart hook configured successfully! ([scope] scope)

Location: [~/.claude/settings.json OR ./.claude/settings.json]

The following commands will now run when you start a Claude Code session:
  1. /validate-setup --quiet - Validates .claude directory setup
  2. /sync-template --check-only - Checks for template updates
  3. /load-role-context --quiet - Loads your role guide and documents

Restart Claude Code or start a new session to activate the hook.
```

**If configuration failed:**
```
⚠ Automatic configuration failed.

Error: [error message from script]

Please configure manually by adding the following to .claude/settings.json:

{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {"type": "command", "command": "/validate-setup --quiet"},
          {"type": "command", "command": "/sync-template --check-only"},
          {"type": "command", "command": "/load-role-context --quiet"}
        ]
      }
    ]
  }
}
```

## Manual Setup Instructions

If the automatic script fails, you can manually add the hook configuration:

1. **Choose target file**:
   - Global: `~/.claude/settings.json` (affects all projects)
   - Project: `./.claude/settings.json` (affects only this project)

2. **Open or create** the target settings file

3. **Add the hooks configuration**:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {"type": "command", "command": "/validate-setup --quiet"},
         {"type": "command", "command": "/sync-template --check-only"},
         {"type": "command", "command": "/load-role-context --quiet"}
       ]
     }
   }
   ```

4. **If settings.json already has content**, merge the hooks section carefully:
   ```json
   {
     "existing": "configuration",
     "hooks": {
       "SessionStart": [
         {
           "matcher": "",
           "hooks": [
             {"type": "command", "command": "/validate-setup --quiet"},
             {"type": "command", "command": "/sync-template --check-only"},
             {"type": "command", "command": "/load-role-context --quiet"}
           ]
         }
       ]
     }
   }
   ```

5. **Save the file** and restart Claude Code

## Global vs Project Hooks

**Global hooks** (`~/.claude/settings.json`):
- Run for all projects
- Convenient default for consistent behavior
- Can be overridden by project-specific hooks

**Project hooks** (`./.claude/settings.json`):
- Run only in this project
- Override global hooks when present
- Useful for project-specific validation needs

**Recommendation**: Use global hooks for personal preferences, project hooks for team standards.

## Troubleshooting

**Hook isn't running:**
- Verify `.claude/settings.json` exists and contains the hooks configuration
- Check file permissions on settings.json (should be readable)
- Try running `/validate-setup --quiet` manually to test
- Restart Claude Code completely (not just new session)

**jq not found error:**
- Install jq:
  - macOS: `brew install jq`
  - Ubuntu/Debian: `sudo apt-get install jq`
  - CentOS/RHEL: `sudo yum install jq`
- After installing jq, run this command again

**Hook runs but validation fails:**
- Run `/validate-setup` (without --quiet) to see detailed issues
- Fix any reported problems
- Hook will continue to report issues until resolved

## What the Hook Does

When configured, the SessionStart hook runs automatically:

1. **Setup Validation** (`/validate-setup --quiet`):
   - Checks .claude directory structure
   - Verifies role guides exist
   - Validates configuration files
   - Only shows output if problems found

2. **Template Sync Check** (`/sync-template --check-only`):
   - Checks if template updates available (only if `auto_update_templates` is true)
   - Compares your template version with latest
   - Notifies you if update available
   - Never applies updates automatically

3. **Role Context Loading** (`/load-role-context --quiet`):
   - Loads your configured role guide into session context
   - Loads all documents referenced in the role guide
   - Enables Claude to immediately understand your role requirements
   - Silent if no role is configured (graceful degradation)

## Customizing Hook Behavior

You can customize what runs on session start by editing `.claude/settings.json`:

**Minimal** (validation + role loading):
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {"type": "command", "command": "/validate-setup --quiet"},
          {"type": "command", "command": "/load-role-context --quiet"}
        ]
      }
    ]
  }
}
```

**Standard** (validation + update check + role loading) - recommended:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {"type": "command", "command": "/validate-setup --quiet"},
          {"type": "command", "command": "/sync-template --check-only"},
          {"type": "command", "command": "/load-role-context --quiet"}
        ]
      }
    ]
  }
}
```

**Verbose** (full output with metadata):
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {"type": "command", "command": "/validate-setup"},
          {"type": "command", "command": "/sync-template"},
          {"type": "command", "command": "/load-role-context --verbose"}
        ]
      }
    ]
  }
}
```

**Disabled** (no automatic hooks):
```json
{
  "hooks": {
    "SessionStart": []
  }
}
```

## Related Commands

- `/validate-setup` - Run validation manually with full output
- `/sync-template` - Manually sync template updates
- `/show-role-context` - View your current role and loaded documents
