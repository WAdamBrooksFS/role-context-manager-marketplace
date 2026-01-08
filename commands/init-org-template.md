# Init Org Template Command

Initialize your organizational framework from a template.

## Purpose

This command helps users who don't yet have a `.claude` directory structure to select and apply an appropriate organizational template. It's the starting point for setting up role-based context management.

## When to Use

- You don't have a `.claude` directory yet (either globally or in project)
- Your `.claude/role-guides/` directory is empty
- You want to switch to a different organizational template
- You're setting up the plugin for the first time
- You want to set up global default templates (use --global)
- You want to set up project-specific templates (use --project)

## Arguments

- `--global`: Initialize template in global config (~/.claude/)
- `--project`: Initialize template in project config (./.claude/)
- `--scope <auto|global|project>`: Explicitly specify scope (default: auto)

## Instructions for Claude

When this command is executed, you should invoke the **template-setup-assistant agent** to guide the user through template selection and setup.

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

**Implementation**:

1. **Parse scope arguments**:
   - Extract scope flags (--global, --project, --scope)
   - Determine scope value:
     - If `--global` present: scope = "global" (initialize in ~/.claude/)
     - If `--project` present: scope = "project" (initialize in ./.claude/)
     - If `--scope <value>` present: scope = value
     - Otherwise: scope = "auto" (project if in project context, else global)

2. **Invoke the agent with scope**:
   ```
   Use the Task tool with:
   - subagent_type: 'template-setup-assistant'
   - description: 'Initialize organizational template'
   - prompt: 'Help the user select and apply an appropriate organizational template to [scope] config. Analyze their current directory structure, present available templates, guide template selection, and apply the chosen template to the appropriate scope (global ~/.claude/ or project ./.claude/).'
   ```

3. **The agent will**:
   - Determine target directory based on scope (~/.claude/ or ./.claude/)
   - Check if target `.claude` directory already exists
   - Analyze the current directory to understand the context
   - Load available templates from the plugin's `templates/` directory
   - Present template options with descriptions and recommendations
   - Ask clarifying questions to determine the best fit
   - Get user approval before applying template
   - Copy template files to appropriate `.claude/` directory (global or project)
   - Set up initial configuration in appropriate scope
   - Record applied template in appropriate preferences file
   - Guide user to next steps (/set-role with appropriate scope)

4. **After agent completes**:
   - Summarize what was set up
   - Show available roles from the applied template
   - Suggest running `/set-role` to complete setup

## Example Usage

```bash
# Initialize template (auto-detects scope)
/init-org-template

# Initialize global template (applies to ~/.claude/)
/init-org-template --global

# Initialize project template (applies to ./.claude/)
/init-org-template --project

# Agent will present options like:
# "Based on your project structure, I recommend the Startup Organization template.
#  This is ideal for teams of 0-10 people focused on speed and iteration.
#
#  Would you like to:
#  1. Use Startup Organization template (Recommended)
#  2. Use Full Software Organization template
#  3. Learn more about templates
#
#  Which option?"

# After global template applied:
# "✓ Startup Organization template applied successfully to global config!
#  Location: ~/.claude/
#
#  This template will be used across all projects unless overridden.
#
#  Next steps:
#  1. Set your global role: /set-role founder-ceo --global
#  2. View your context: /show-role-context
#  3. Customize if needed: /update-role-docs --global
#
#  Available roles: founder-ceo, technical-cofounder, founding-engineer"

# After project template applied:
# "✓ Startup Organization template applied successfully to project!
#  Location: ./.claude/
#
#  Next steps:
#  1. Set your role: /set-role founder-ceo
#  2. View your context: /show-role-context
#  3. Customize if needed: /update-role-docs
#
#  Available roles: founder-ceo, technical-cofounder, founding-engineer"
```

## Error Handling

**If .claude already exists and is complete**:
- Agent will detect this and ask if user wants to switch templates or cancel
- Offer to back up existing setup before switching

**If plugin templates can't be found**:
- Agent will report the error
- Suggest checking plugin installation
- Provide manual setup instructions as fallback

**If user cancels during setup**:
- Don't create partial `.claude` structure
- Leave project in original state
- User can run command again when ready

## Notes

- This command is designed to be safe and non-destructive
- Agent always gets user approval before making changes
- Existing customizations are preserved when possible
- Template can be changed later by running command again
