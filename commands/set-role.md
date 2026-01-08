# Set Role Command

Set your current role to determine which documents load for context in Claude Code sessions.

## Command

```bash
/set-role [role-name]
```

## Arguments

- `role-name`: The role to set (e.g., software-engineer, product-manager, devops-engineer)
- `--global`: Force setting role in global config (~/.claude/)
- `--project`: Force setting role in project config (./.claude/)
- `--scope <auto|global|project>`: Explicitly specify scope (default: auto)

## Behavior by Scope

### Auto (default)
- If in project with `.claude/`: Update project config
- Otherwise: Update global config in `~/.claude/`
- This allows the plugin to work both globally and at project level

### Global (`--global`)
- Always update `~/.claude/preferences.json`
- Works from any directory
- Useful for setting default role across all projects

### Project (`--project`)
- Update project's `.claude/preferences.json`
- Error if not in a project context
- Useful for project-specific role overrides

## What This Command Does

1. Validates the specified role exists at your current organizational level
2. Updates `.claude/preferences.json` with your role
3. Initializes role-specific document references from the role guide if not already set
4. Displays which documents will load on your next Claude Code session

## Usage Examples

```bash
# Set role to software engineer (auto-detects scope)
/set-role software-engineer

# Set role globally (affects all projects)
/set-role software-engineer --global

# Set role for current project only
/set-role qa-engineer --project

# Explicitly specify scope
/set-role product-manager --scope global

# Set role to product manager
/set-role product-manager

# Set role to QA engineer
/set-role qa-engineer
```

## Instructions for Claude

When this command is executed:

**PRE-FLIGHT: Configure SessionStart Hook (First-Time Setup)**

**This check runs before anything else - only on first use of any plugin command:**

1. **Check if SessionStart hook is configured**:
   ```bash
   # Check for marker file indicating hook setup is complete
   if [ ! -f .claude/.role-context-manager-setup-complete ]; then
     # Hook not configured yet - this is first-time use
   fi
   ```

2. **If hook not configured** (marker file missing):
   - Inform user: "First-time setup: Configuring SessionStart hook..."
   - Run post-install script:
     ```bash
     bash ~/.claude/plugins/role-context-manager/scripts/post-install.sh
     ```
   - Check exit code:
     - If exit code 0: Continue with command
     - If exit code 1: Show error message and suggest running `/setup-plugin-hooks` manually
   - Display: "✓ SessionStart hook configured. Validation will run automatically on future sessions."

3. **If hook already configured** (marker file exists):
   - Skip this check silently and proceed to main command logic

**IMPORTANT: Check for complete setup**

1. **Before proceeding, check if setup is complete**:
   ```bash
   # Check if .claude/role-guides directory exists and has files
   if [ ! -d .claude/role-guides ] || [ $(find .claude/role-guides -name "*.md" 2>/dev/null | wc -l) -eq 0 ]; then
     # Setup is incomplete - need to initialize template first
   fi
   ```

2. **If setup is incomplete** (no .claude directory or no role guides):
   - Inform user: "Your .claude directory needs to be initialized before setting a role."
   - Ask: "Would you like me to set up your organizational framework now?"
   - If yes, invoke the template-setup-assistant agent:
     ```
     Use Task tool with:
     - subagent_type: 'template-setup-assistant'
     - description: 'Initialize organizational template'
     - prompt: 'The user wants to set their role, but .claude directory is not properly set up. Help them select and apply an appropriate organizational template first. After template is applied, continue with setting their role to [role-name].'
     ```
   - After template setup completes, proceed with step 3

3. **Parse scope arguments**:
   - Extract role name and any scope flags (--global, --project, --scope)
   - Determine scope value:
     - If `--global` present: scope = "global"
     - If `--project` present: scope = "project"
     - If `--scope <value>` present: scope = value
     - Otherwise: scope = "auto" (default)

4. **If setup is complete**, call the role-manager.sh script with scope:
   ```bash
   # Pass scope as environment variable
   SCOPE=[scope] bash ~/.claude/plugins/role-context-manager/scripts/role-manager.sh set-role [role-name]
   ```

5. The script will:
   - Use the scope parameter to determine config directory (find_config_dir function)
   - Validate the role exists in `.claude/role-guides/`
   - Update appropriate `preferences.json` (global or project) with `user_role` field
   - Initialize `role-references.json` if needed
   - Display which config was updated and the document list with existence status

6. If the role is invalid, the script will list available roles for the current organizational level

7. After successful execution, inform the user:
   - Which documents will load on next session
   - Which documents exist (✓), are missing (!), or can be generated (?)
   - For missing documents, suggest: "Use /generate-document to create missing documents"
   - Remind them to start a new session to load the context

## Example Output

```
✓ Role set to: software-engineer
✓ Updated: .claude/preferences.json (project scope)

Initializing document references from role guide...

✓ Initialized role documents for: software-engineer

Organizational level: project
Current role: software-engineer

Documents that will load on next session:

  ✓ /engineering-standards.md
  ✓ /quality-standards.md
  ✓ /security-policy.md
  ✓ contributing.md
  ? development-setup.md

Legend: ✓ exists | ! missing | ? can be generated

Start a new session to load this context.
```

**Example with global scope:**
```
✓ Role set to: software-engineer
✓ Updated: ~/.claude/preferences.json (global scope)

This role will be used across all projects unless overridden.

Start a new session to load this context.
```

## Related Commands

- `/show-role-context` - View current role and documents
- `/update-role-docs` - Customize document list
- `/init-role-docs` - Reset to defaults
- `/set-org-level` - Set organizational level
