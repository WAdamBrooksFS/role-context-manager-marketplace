# Set Role Command

Set your current role to determine which documents load for context in Claude Code sessions.

## Command

```bash
/set-role [role-name]
```

## Arguments

- `role-name`: The role to set (e.g., software-engineer, product-manager, devops-engineer)

## What This Command Does

1. Validates the specified role exists at your current organizational level
2. Updates `.claude/preferences.json` with your role
3. Initializes role-specific document references from the role guide if not already set
4. Displays which documents will load on your next Claude Code session

## Usage Examples

```bash
# Set role to software engineer
/set-role software-engineer

# Set role to product manager
/set-role product-manager

# Set role to QA engineer
/set-role qa-engineer
```

## Instructions for Claude

When this command is executed:

1. Call the role-manager.sh script with the set-role command:
   ```bash
   bash ~/.claude/plugins/role-context-manager/scripts/role-manager.sh set-role [role-name]
   ```

2. The script will:
   - Find the nearest `.claude` directory
   - Validate the role exists in `.claude/role-guides/`
   - Update `.claude/preferences.json` with `user_role` field
   - Initialize `.claude/role-references.json` if needed
   - Display the document list with existence status

3. If the role is invalid, the script will list available roles for the current organizational level

4. After successful execution, inform the user:
   - Which documents will load on next session
   - Which documents exist (✓), are missing (!), or can be generated (?)
   - Remind them to start a new session to load the context

## Example Output

```
✓ Role set to: software-engineer
✓ Updated: .claude/preferences.json

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

## Related Commands

- `/show-role-context` - View current role and documents
- `/update-role-docs` - Customize document list
- `/init-role-docs` - Reset to defaults
- `/set-org-level` - Set organizational level
