# Setup Plugin Hooks Command

Configure SessionStart hook for role-context-manager plugin.

## Purpose

This command is used once after plugin installation to configure the SessionStart hook in project settings. It ensures that the plugin's validation and template sync checks run automatically when you start a new Claude Code session.

## When to Use

- **First time using the plugin**: Hooks are usually configured automatically on first command use
- **Re-configuration needed**: If hooks were manually disabled or removed
- **Troubleshooting**: If SessionStart hook isn't running as expected

## Instructions for Claude

When this command is executed:

### Step 1: Check Current Configuration

1. Check if hook is already configured:
   - Read `.claude/settings.json` (or `.claude/settings.local.json` if it exists)
   - Look for `hooks.SessionStart` array
   - Check if it includes `/validate-setup --quiet` and `/sync-template --check-only`

2. Check for marker file: `.claude/.role-context-manager-setup-complete`

### Step 2: Configure Hook if Needed

If not already configured:

1. Run the post-install script:
   ```bash
   bash scripts/post-install.sh
   ```

2. Capture the output and check exit code:
   - Exit code 0: Success
   - Exit code 1: Failed (jq not installed or other error)

### Step 3: Display Result

**If already configured:**
```
SessionStart hook is already set up.

Current configuration:
  - /validate-setup --quiet (validates .claude directory)
  - /sync-template --check-only (checks for template updates)

No action needed. The hook will run on your next session start.
```

**If newly configured:**
```
✓ SessionStart hook configured successfully!

The following commands will now run when you start a Claude Code session:
  1. /validate-setup --quiet - Validates .claude directory setup
  2. /sync-template --check-only - Checks for template updates

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
      "/validate-setup --quiet",
      "/sync-template --check-only"
    ]
  }
}
```

## Manual Setup Instructions

If the automatic script fails, you can manually add the hook configuration:

1. **Open or create** `.claude/settings.json` in your project root

2. **Add the hooks configuration**:
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

3. **If settings.json already has content**, merge the hooks section carefully:
   ```json
   {
     "existing": "configuration",
     "hooks": {
       "SessionStart": [
         "/validate-setup --quiet",
         "/sync-template --check-only"
       ]
     }
   }
   ```

4. **Save the file** and restart Claude Code

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

## Customizing Hook Behavior

You can customize what runs on session start by editing `.claude/settings.json`:

**Minimal** (validation only):
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --silent"
    ]
  }
}
```

**Standard** (validation + update check) - recommended:
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

**Verbose** (validation + updates + role context):
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
