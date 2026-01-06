# Show Role Context Command

Display your current role and the documents that will load in Claude Code sessions.

## Command

```bash
/show-role-context
```

## Arguments

None

## What This Command Does

1. Displays your current organizational level
2. Shows your current role
3. Lists all documents that will load on next session
4. Shows existence status for each document (exists, missing, can be generated)
5. Displays any custom additions or removals

## Usage Examples

```bash
# Show current context
/show-role-context
```

## Instructions for Claude

When this command is executed:

1. Call the role-manager.sh script with the show-role-context command:
   ```bash
   bash ~/.claude/plugins/role-context-manager/scripts/role-manager.sh show-role-context
   ```

2. The script will:
   - Detect the organizational level
   - Read current role from `.claude/preferences.json`
   - Merge team defaults from `.claude/role-references.json`
   - Apply user overrides from `.claude/role-references.local.json`
   - Check existence of each document
   - Display formatted output

3. If no role is set, display available roles and prompt to use `/set-role`

4. Show legend explaining status indicators:
   - ✓ Document exists
   - ! Document missing
   - ? Document can be generated from template

5. **NEW: Proactively suggest document generation**:
   - If any documents are missing (! status), suggest:
     "Would you like me to generate the missing documents? Use /generate-document or I can generate them now."
   - If user wants generation, ask which documents to generate or offer to generate all missing ones
   - For each missing document, can invoke document-generator agent

## Example Output

### When Role is Set

```
Organizational level: project
Current role: software-engineer

Documents that will load on next session:

  ✓ /engineering-standards.md
  ✓ /quality-standards.md
  ✓ /security-policy.md
  ✓ contributing.md
  ! development-setup.md
  ✓ +docs/team-practices.md (custom addition)
  - /quality-standards.md (custom removal)

Legend: ✓ exists | ! missing | ? can be generated

💡 Tip: Use /generate-document to create missing documents
    Example: /generate-document development-setup

Start a new session to load this context.
```

### When No Role is Set

```
Organizational level: project

No role set.

Available roles:
  - software-engineer
  - frontend-engineer
  - backend-engineer
  - devops-engineer
  - qa-engineer

Use /set-role [role-name] to set your role.
```

## Related Commands

- `/set-role` - Set your role
- `/update-role-docs` - Add or remove documents
- `/init-role-docs` - Reset to defaults
- `/set-org-level` - Change organizational level
