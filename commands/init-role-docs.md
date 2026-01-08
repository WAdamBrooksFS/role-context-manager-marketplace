# Init Role Docs Command

Initialize or reset your role's document references to defaults from the role guide.

## Command

```bash
/init-role-docs [--reset]
```

## Arguments

- No arguments: Initialize document references if not set (preserves existing customizations)
- `--reset`: Reset to defaults, clearing all user customizations
- `--global`: Apply to global config (~/.claude/)
- `--project`: Apply to project config (./.claude/)
- `--scope <auto|global|project>`: Explicitly specify scope (default: auto)

## What This Command Does

1. Reads your current role from preferences
2. Finds the role guide file for your role
3. Extracts document references from the role guide's "Document References" section
4. Updates `.claude/role-references.json` with these defaults
5. Optionally clears user customizations if `--reset` flag is used

## Usage Examples

```bash
# Initialize if not set (keeps customizations)
/init-role-docs

# Reset to defaults (clears customizations)
/init-role-docs --reset
```

## When to Use This Command

**Initialize (no --reset)**:
- First time setting up a role
- Role guide has been updated with new document references
- Want to ensure you have all default documents

**Reset (with --reset)**:
- Made too many customizations and want to start fresh
- Role guide has significantly changed
- Want to revert to team defaults

## Instructions for Claude

When this command is executed:

1. Parse arguments to extract:
   - Reset flag (--reset)
   - Scope flags (--global, --project, --scope)

2. Determine scope value:
   - If `--global` present: scope = "global"
   - If `--project` present: scope = "project"
   - If `--scope <value>` present: scope = value
   - Otherwise: scope = "auto" (default)

3. Call the role-manager.sh script with scope and flags:
   ```bash
   # Without reset
   SCOPE=[scope] bash ~/.claude/plugins/role-context-manager/scripts/role-manager.sh init-role-docs

   # With reset
   SCOPE=[scope] bash ~/.claude/plugins/role-context-manager/scripts/role-manager.sh init-role-docs --reset
   ```

4. The script will:
   - Use scope to determine config directory
   - Read current role from appropriate `preferences.json`
   - Find role guide at appropriate `.claude/role-guides/[role]-guide.md`
   - Parse the "Document References" section
   - Extract all markdown file references
   - Update appropriate `role-references.json` with defaults
   - If --reset, clear appropriate `role-references.local.json` customizations
   - Display which config was updated and success message

5. If no role is set, display error and prompt to use `/set-role` first

6. If role guide is not found, display error with available roles

7. After initialization, automatically show context with `/show-role-context`

## Role Guide Format

The role guide should have a "Document References" section with markdown list items:

```markdown
## Document References

### Documents Engineer References
- `/engineering-standards.md`
- `/quality-standards.md`
- `/security-policy.md`
- `contributing.md` (project-level)
- `development-setup.md` (project-level)
- PRDs from product team

### Templates Engineer Uses
- `/docs/templates/architecture-decision-record-template.md`
- `/docs/templates/technical-design-document-template.md`
```

The command extracts paths from:
- Code-formatted paths: `` `/path/to/doc.md` ``
- Plain markdown list items with .md extension

## Example Output

### Without --reset

```
✓ Initialized role documents for: software-engineer

Organizational level: project
Current role: software-engineer

Documents that will load on next session:

  ✓ /engineering-standards.md
  ✓ /quality-standards.md
  ✓ /security-policy.md
  ✓ contributing.md
  ? development-setup.md
  ✓ +docs/my-notes.md (custom addition - preserved)
  - /quality-standards.md (custom removal - preserved)

Legend: ✓ exists | ! missing | ? can be generated

Start a new session to load this context.
```

### With --reset

```
✓ Reset role documents to defaults for: software-engineer

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

## What Gets Updated

**Team defaults** (`.claude/role-references.json`):
- Always updated with role guide references
- Committed to git
- Shared across team

**User customizations** (`.claude/role-references.local.json`):
- Preserved if no --reset flag
- Cleared if --reset flag is used
- Gitignored (personal)

## Related Commands

- `/set-role` - Set your role
- `/show-role-context` - View current documents
- `/update-role-docs` - Add or remove documents manually
