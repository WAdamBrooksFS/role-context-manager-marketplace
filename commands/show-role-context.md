# Show Role Context Command

Display your current role and the documents that will load in Claude Code sessions.

## Command

```bash
/show-role-context

# Or with summary flag for concise output
/show-role-context --summary
```

## Arguments

- `--summary` (optional): Display one-line summary instead of full output

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

**1. Parse command arguments**:
   - Check for `--summary` flag (one-line summary output)

**2. If `--summary` flag present**:

Use summary mode with one-line output format:

```
Role: [role-name] | Docs: [X] loaded, [Y] missing | Org: [level]
```

**Implementation for summary mode**:
- Read preferences.json to get user_role and organizational level
- Count documents from role-references (merged with local overrides)
- Check existence of each document to count loaded vs missing
- Output single-line summary
- Do NOT show document list, legend, or suggestions
- Exit after displaying summary

**Examples**:
- `Role: software-engineer | Docs: 5 loaded, 2 missing | Org: project`
- `Role: product-manager | Docs: 8 loaded, 0 missing | Org: product`
- `Role: not set | Docs: 0 loaded | Org: project` (if no role)

**3. If `--summary` flag NOT present (standard mode)**:

Call the role-manager.sh script with the show-role-context command:
   ```bash
   bash ~/.claude/plugins/role-context-manager/scripts/role-manager.sh show-role-context
   ```

**4. The script will (standard mode)**:
   - Detect the organizational level
   - Read current role from `.claude/preferences.json`
   - Merge team defaults from `.claude/role-references.json`
   - Apply user overrides from `.claude/role-references.local.json`
   - Check existence of each document
   - Display formatted output

**5. If no role is set (standard mode)**, display available roles and prompt to use `/set-role`

**6. Show legend explaining status indicators (standard mode)**:
   - ✓ Document exists
   - ! Document missing
   - ? Document can be generated from template

**7. NEW: Proactively suggest document generation (standard mode)**:
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
