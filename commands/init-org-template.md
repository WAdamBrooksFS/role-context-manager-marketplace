# Init Org Template Command

Initialize your organizational framework from a template.

## Purpose

This command helps users who don't yet have a `.claude` directory structure to select and apply an appropriate organizational template. It's the starting point for setting up role-based context management.

## When to Use

- You don't have a `.claude` directory yet
- Your `.claude/role-guides/` directory is empty
- You want to switch to a different organizational template
- You're setting up the plugin for the first time

## Instructions for Claude

When this command is executed, you should invoke the **template-setup-assistant agent** to guide the user through template selection and setup.

**Implementation**:

1. **Invoke the agent**:
   ```
   Use the Task tool with:
   - subagent_type: 'template-setup-assistant'
   - description: 'Initialize organizational template'
   - prompt: 'Help the user select and apply an appropriate organizational template. Analyze their current directory structure, present available templates, guide template selection, and apply the chosen template.'
   ```

2. **The agent will**:
   - Check if `.claude` directory already exists
   - Analyze the current directory to understand the project context
   - Load available templates from the plugin's `templates/` directory
   - Present template options with descriptions and recommendations
   - Ask clarifying questions to determine the best fit
   - Get user approval before applying template
   - Copy template files to `.claude/` directory
   - Set up initial configuration
   - Record applied template in preferences
   - Guide user to next steps (/set-role)

3. **After agent completes**:
   - Summarize what was set up
   - Show available roles from the applied template
   - Suggest running `/set-role` to complete setup

## Example Usage

```bash
# User runs the command
/init-org-template

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

# After template applied:
# "✓ Startup Organization template applied successfully!
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
