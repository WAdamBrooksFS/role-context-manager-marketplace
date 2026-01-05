# Role Context Manager for Claude Code

A Claude Code marketplace plugin that manages role-based document context loading. Set your role, customize document references, and automatically load relevant context based on your organizational level.

## Overview

This plugin helps teams organize and load documentation based on roles within an organizational hierarchy (company → system → product → project). It integrates with role-guide systems and allows both team-wide defaults and user-specific customizations.

## Features

- **Role-based context loading**: Automatically determine which documents to load based on your role
- **Organizational hierarchy support**: Works at company, system, product, and project levels
- **Flexible document management**: Add or remove documents using simple +/- syntax
- **Team defaults + user overrides**: Share team configurations while allowing personal customizations
- **Smart level detection**: Automatically detects organizational level or prompts when ambiguous
- **Integration with role guides**: Reads document references from existing role-guide files

## Installation

### From Claude Code Marketplace

```bash
# Install the plugin
claude-code plugin install role-context-manager
```

### Manual Installation

1. Clone this repository
2. Copy the plugin directory to your Claude Code plugins folder
3. Reload Claude Code

## Quick Start

### 1. Set Your Organizational Level

If your project structure isn't automatically detected:

```bash
/set-org-level project
```

### 2. Set Your Role

```bash
/set-role software-engineer
```

This will:
- Update your preferences.json with the role
- Initialize role-specific document references
- Show which documents will load on next session

### 3. View Your Context

```bash
/show-role-context
```

Shows:
- Current role
- Documents that will load (with existence status)
- Custom additions and removals

### 4. Customize Documents

Add a custom document:
```bash
/update-role-docs +docs/team-practices.md
```

Remove a default document:
```bash
/update-role-docs -/quality-standards.md
```

Add and remove multiple at once:
```bash
/update-role-docs +docs/custom.md -/old-doc.md +another.md
```

### 5. Reset to Defaults

```bash
/init-role-docs --reset
```

## Commands Reference

### `/set-role [role-name]`

**Purpose**: Set your current role

**Usage**:
- `/set-role software-engineer`
- `/set-role product-manager`
- `/set-role devops-engineer`

**What it does**:
1. Validates role exists at current organizational level
2. Updates `.claude/preferences.json`
3. Initializes role-specific document references from role guide
4. Displays what will load on next session

### `/show-role-context`

**Purpose**: Display current role and document loading status

**Usage**:
- `/show-role-context`

**What it shows**:
- Current organizational level
- Current role
- Documents that will load (with ✓ exists, ! missing, - excluded)
- Custom additions and removals

### `/update-role-docs [+/-]file ...`

**Purpose**: Customize which documents load for your role

**Usage**:
- `/update-role-docs +path/to/doc.md` - Add a document
- `/update-role-docs -/quality-standards.md` - Remove a document
- `/update-role-docs +new.md -old.md` - Multiple changes

**Supports**:
- Relative paths (relative to current directory)
- Absolute paths (from repository root, start with `/`)
- Multiple modifications in one command

### `/init-role-docs [--reset]`

**Purpose**: Initialize or reset document references to role guide defaults

**Usage**:
- `/init-role-docs` - Initialize if not set
- `/init-role-docs --reset` - Reset to defaults, clearing customizations

**When to use**:
- First time setting up a role
- Want to reset customizations back to team defaults
- Role guide has been updated

### `/set-org-level [level]`

**Purpose**: Explicitly set organizational level

**Usage**:
- `/set-org-level` - Show current level and available roles
- `/set-org-level company` - Set to company level
- `/set-org-level system` - Set to system level
- `/set-org-level product` - Set to product level
- `/set-org-level project` - Set to project level

**When to use**:
- Directory structure doesn't match standard patterns
- Want to override automatic detection
- Working in incomplete/custom structure

## Configuration Files

### Created in Your Project

After using the plugin, these files are created in `.claude/`:

**`.claude/preferences.json`** (updated):
```json
{
  "user_role": "software-engineer"
}
```

**`.claude/role-references.json`** (team defaults, committed to git):
```json
{
  "software-engineer": {
    "default_documents": [
      "/engineering-standards.md",
      "/quality-standards.md",
      "contributing.md"
    ],
    "user_customizations": []
  }
}
```

**`.claude/role-references.local.json`** (user overrides, gitignored):
```json
{
  "software-engineer": {
    "user_customizations": [
      "+docs/my-notes.md",
      "-/quality-standards.md"
    ]
  }
}
```

**`.claude/organizational-level.json`** (detected or specified level):
```json
{
  "level": "project",
  "level_name": "my-project"
}
```

### Git Configuration

Add to your `.gitignore`:
```
# User-specific role document preferences
.claude/role-references.local.json
```

Keep in git:
```
# Team-shared role document defaults
.claude/role-references.json
.claude/organizational-level.json
```

## Organizational Hierarchy

The plugin supports four organizational levels:

### Company Level (Root)
**Typical roles**: CTO, CPO, CISO, VP Engineering, VP Product, Director QA, Cloud Architect

**Documents**: Strategy, company OKRs, high-level policies

### System Level
**Typical roles**: Engineering Manager, Platform Engineer, Data Engineer, Security Engineer, Technical Product Manager, Technical Program Manager

**Documents**: System OKRs, system architecture, cross-product decisions

### Product Level
**Typical roles**: QA Manager, UX Designer, UI Designer

**Documents**: Product roadmaps, PRDs, product overview, release notes

### Project Level
**Typical roles**: Software Engineer, Frontend Engineer, Backend Engineer, Full Stack Engineer, DevOps Engineer, SRE, Data Scientist, Data Analyst, SDET, QA Engineer, Scrum Master

**Documents**: Contributing guide, development setup, technical design, API docs, operational runbooks

## Integration with Role Guides

This plugin reads document references from role-guide files. A role guide should have a "Documents [Role] References" section:

**Example from `software-engineer-guide.md`**:
```markdown
## Document References

### Documents Engineer References
- `/engineering-standards.md`
- `/quality-standards.md`
- `/security-policy.md`
- `contributing.md` (project-level)
- `development-setup.md` (project-level)
- PRDs from product team
```

The plugin extracts these references and uses them as defaults for the role.

## How It Works

### Level Detection

The plugin uses these strategies to detect organizational level:

1. **Check explicit marker** (`.claude/organizational-level.json`)
2. **Heuristic detection**:
   - **Project**: Has `package.json`, `src/` directory, implementation role guides
   - **Product**: Contains multiple project subdirectories, coordination role guides
   - **System**: Contains multiple product directories, system role guides
   - **Company**: At repository root, executive role guides, strategy documents
3. **Prompt user** if ambiguous
4. **Default to project** if detection fails

### Document Resolution

When loading documents:

1. Read role from `.claude/preferences.json`
2. Load role guide and extract document references
3. Check `.claude/role-references.local.json` for user overrides
4. Fall back to `.claude/role-references.json` for team defaults
5. Resolve paths (relative from current dir, absolute from repo root)
6. Check document existence
7. Display status for each document

### Path Resolution

- **Absolute paths** (start with `/`): Resolved from repository root
- **Relative paths**: Resolved from current directory upward (first match wins)
- **Explicit paths**: Users can always specify exact paths

## Troubleshooting

### "Unable to detect organizational level"

**Solution**: Explicitly set your level:
```bash
/set-org-level project
```

### "Role not found at current level"

**Cause**: The role doesn't exist at the detected organizational level

**Solution**:
1. Check your level: `/set-org-level`
2. Set correct level if needed
3. Or choose a role appropriate for your level

### "Document not found"

**Cause**: Referenced document doesn't exist yet

**Solution**:
- Create the document manually
- Or let the plugin prompt you to generate from template (for standardized docs)

### "Invalid JSON in preferences.json"

**Cause**: Malformed JSON file

**Solution**:
1. Check `.claude/preferences.json` for syntax errors
2. Validate JSON using a linter
3. Or delete the file and reinitialize

### Documents not loading in Claude session

**Cause**: Changes only take effect on new sessions

**Solution**: Start a new Claude Code session to load updated context

## Examples

### Example 1: Software Engineer at Project Level

```bash
# Set up
/set-org-level project
/set-role software-engineer

# Customize
/update-role-docs +docs/testing-guide.md
/update-role-docs -/quality-standards.md

# View
/show-role-context
```

**Output**:
```
Organizational level: project
Current role: software-engineer

Documents that will load on next session:
  Default documents:
    ✓ /engineering-standards.md (exists)
    ✓ /security-policy.md (exists)
    ✓ contributing.md (exists)
    ✓ development-setup.md (exists)

  Custom additions:
    ✓ +docs/testing-guide.md (exists)

  Custom removals:
    - /quality-standards.md (excluded)

Start a new session to load this context.
```

### Example 2: Product Manager at Product Level

```bash
/set-org-level product
/set-role product-manager
/show-role-context
```

**Output**:
```
Organizational level: product
Current role: product-manager

Documents that will load on next session:
  Default documents:
    ✓ /objectives-and-key-results.md (exists)
    ✓ /strategy.md (exists)
    ✓ roadmap.md (exists)
    ✓ product-overview.md (exists)

  No customizations.

Start a new session to load this context.
```

### Example 3: Reset Customizations

```bash
# Made too many changes, want to start fresh
/init-role-docs --reset

# Back to team defaults
/show-role-context
```

## Requirements

- **Claude Code**: Latest version
- **jq**: >=1.6 (for JSON parsing)
- **bash**: >=4.0

### Installing jq

**macOS**:
```bash
brew install jq
```

**Ubuntu/Debian**:
```bash
sudo apt-get install jq
```

**CentOS/RHEL**:
```bash
sudo yum install jq
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - See LICENSE file for details

## Support

- **Issues**: https://github.com/practice-adam-brooks/role-context-manager/issues
- **Discussions**: https://github.com/practice-adam-brooks/role-context-manager/discussions
- **Documentation**: https://github.com/practice-adam-brooks/role-context-manager/wiki

## Changelog

### v1.0.0 (Initial Release)
- Role-based context management
- Organizational level detection
- Document customization with +/- syntax
- Team defaults + user overrides
- Integration with role guides
- Five commands: set-role, show-role-context, update-role-docs, init-role-docs, set-org-level
