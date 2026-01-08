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

1. Displays configuration hierarchy (global and project configs)
2. Shows your current organizational level
3. Shows your current role (from both global and project if applicable)
4. Lists all documents that will load on next session
5. Shows existence status for each document (exists, missing, can be generated)
6. Displays any custom additions or removals
7. Shows effective configuration (what will actually be used in current context)

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
   - Check if both global (~/.claude/) and project (./.claude/) configs exist
   - Display configuration hierarchy showing:
     * Global config (if exists): role, organizational level, documents
     * Project config (if exists): role, organizational level, documents, and what overrides global
   - Show effective configuration (what will be used in current context)
   - Detect the organizational level (project overrides global)
   - Read current role from both configs (project overrides global)
   - Merge team defaults from `.claude/role-references.json`
   - Apply user overrides from `.claude/role-references.local.json`
   - Check existence of each document
   - Display formatted output with hierarchy

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

### When Both Global and Project Configs Exist

```
Configuration Hierarchy:

  Global config: ~/.claude/
    Role: software-engineer
    Org level: project
    Docs: /engineering-standards.md, /quality-standards.md

  Project config: /home/user/my-project/.claude/
    Role: qa-engineer (overrides global)
    Org level: project
    Docs: +test-plan.md, -/quality-standards.md

─────────────────────────────────────────────────────

Effective Configuration (in current directory):
  Role: qa-engineer
  Organizational level: project

Documents that will load on next session:

  ✓ /engineering-standards.md (from global)
  ✓ test-plan.md (added in project)
  - /quality-standards.md (removed in project)

Legend: ✓ exists | ! missing | ? can be generated

💡 Tip: Use /set-role --global to change global role
💡 Tip: Use /set-role --project to change project role

Start a new session to load this context.
```

### When Only Global Config Exists

```
Configuration Hierarchy:

  Global config: ~/.claude/
    Role: software-engineer
    Org level: project
    Docs: /engineering-standards.md, /quality-standards.md, /security-policy.md

  Project config: none

─────────────────────────────────────────────────────

Effective Configuration (in current directory):
  Role: software-engineer (from global)
  Organizational level: project

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

### When Only Project Config Exists

```
Configuration Hierarchy:

  Global config: none

  Project config: /home/user/my-project/.claude/
    Role: software-engineer
    Org level: project
    Docs: /engineering-standards.md, /quality-standards.md

─────────────────────────────────────────────────────

Effective Configuration (in current directory):
  Role: software-engineer
  Organizational level: project

Documents that will load on next session:

  ✓ /engineering-standards.md
  ✓ /quality-standards.md
  ✓ /security-policy.md
  ✓ contributing.md

Legend: ✓ exists | ! missing | ? can be generated

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
