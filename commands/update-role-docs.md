# Update Role Docs Command

Add or remove documents from your role's reference list using +/- syntax.

## Command

```bash
/update-role-docs [+/-]file ...
```

## Arguments

- `+file.md` - Add a document to your role's reference list
- `-file.md` - Remove a document from your role's reference list
- Multiple modifications can be specified in one command
- `--global` - Apply changes to global config (~/.claude/)
- `--project` - Apply changes to project config (./.claude/)
- `--scope <auto|global|project>` - Explicitly specify scope (default: auto)

## What This Command Does

1. Reads your current role from preferences
2. Updates your personal document customizations (stored in `.claude/role-references.local.json`)
3. Validates added documents exist (prompts to create if standardized)
4. Displays updated document list with status indicators

## Usage Examples

```bash
# Add a custom document (auto-detects scope)
/update-role-docs +docs/team-practices.md

# Remove a default document
/update-role-docs -/quality-standards.md

# Multiple modifications at once
/update-role-docs +docs/custom.md -/old-doc.md +another.md

# Add document to global config
/update-role-docs +/docs/company-wide-guide.md --global

# Add document to project config
/update-role-docs +../shared/common-practices.md --project

# Multiple modifications with scope
/update-role-docs +new-doc.md -old-doc.md --scope project
```

## Path Types

**Absolute paths** (start with `/`):
- Resolved from repository root
- Example: `/engineering-standards.md` → `/path/to/repo/engineering-standards.md`

**Relative paths**:
- Resolved from current directory upward
- First match found in directory hierarchy
- Example: `contributing.md` → first `contributing.md` found walking up from current dir

## Instructions for Claude

When this command is executed:

1. Parse the arguments to extract:
   - Additions (+) and removals (-)
   - Scope flags (--global, --project, --scope)

2. Determine scope value:
   - If `--global` present: scope = "global"
   - If `--project` present: scope = "project"
   - If `--scope <value>` present: scope = value
   - Otherwise: scope = "auto" (default)

3. Call the role-manager.sh script with scope and modifications:
   ```bash
   SCOPE=[scope] bash ~/.claude/plugins/role-context-manager/scripts/role-manager.sh update-role-docs [+/-]file ...
   ```

4. The script will:
   - Use scope to determine config directory
   - Read current role from appropriate `preferences.json`
   - Load existing customizations from appropriate `role-references.local.json`
   - Apply the new modifications
   - Check if added documents exist
   - Save updated customizations to local file in appropriate scope
   - Display which config was updated and changes made

5. If no role is set, display error and prompt to use `/set-role` first

6. For added documents that don't exist:
   - If standardized document, offer to generate from template
   - If custom document, note it as missing

7. After modifications, automatically show updated context with `/show-role-context`

## Example Output

```
✓ Updated role documents for: software-engineer

Added:
  + docs/team-testing-guide.md

Removed:
  - /quality-standards.md

Organizational level: project
Current role: software-engineer

Documents that will load on next session:

  ✓ /engineering-standards.md
  ✓ /security-policy.md
  ✓ contributing.md
  ? development-setup.md
  ✓ +docs/team-testing-guide.md (custom addition)
  - /quality-standards.md (custom removal)

Legend: ✓ exists | ! missing | ? can be generated

Start a new session to load this context.
```

## How Customizations Work

**Team defaults** (`.claude/role-references.json`):
- Committed to git
- Shared across team
- Set by role guides or team preferences

**User overrides** (`.claude/role-references.local.json`):
- Gitignored (personal)
- Contains only your +/- modifications
- Takes precedence over team defaults

**Final document list**:
1. Start with team defaults
2. Add documents marked with +
3. Remove documents marked with -
4. Result is your personalized context

## Related Commands

- `/show-role-context` - View current documents
- `/set-role` - Set your role
- `/init-role-docs` - Reset customizations to defaults
