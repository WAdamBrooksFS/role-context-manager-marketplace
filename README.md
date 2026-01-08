# Role Context Manager for Claude Code

A Claude Code marketplace plugin that manages role-based document context loading. Set your role, customize document references, and automatically load relevant context based on your organizational level.

## Overview

This plugin helps teams organize and load documentation based on roles within an organizational hierarchy (company → system → product → project). It integrates with role-guide systems and allows both team-wide defaults and user-specific customizations.

## Features

### Core Features (v1.0.0)
- **Role-based context loading**: Automatically determine which documents to load based on your role
- **Organizational hierarchy support**: Works at company, system, product, and project levels
- **Flexible document management**: Add or remove documents using simple +/- syntax
- **Team defaults + user overrides**: Share team configurations while allowing personal customizations
- **Smart level detection**: Automatically detects organizational level or prompts when ambiguous
- **Integration with role guides**: Reads document references from existing role-guide files

### New in v1.3.0: Complete Template Bundles & Multi-Scope Configuration
- **Multi-Scope Configuration**: Global and project-level configuration support
  - **Global scope** (~/.claude/): Personal defaults that apply everywhere
  - **Project scope** (./.claude/): Project-specific settings that override global
  - **Auto mode**: Intelligently chooses project or global based on context
  - **Configuration hierarchy**: Project > Global > Plugin Defaults
  - Works when installed globally (`local-user`) or per-project
  - See [SCOPES.md](SCOPES.md) for detailed documentation
- **Complete Templates**: Full organizational frameworks bundled with the plugin
  - **Software Organization** (748KB): Document templates, process guides, hierarchical examples
  - **Startup Organization** (260KB): Fundraising docs, strategic planning, lean workflows
- **Application Modes**: Choose how much to install
  - **Minimal**: Just .claude/ directory for AI collaboration
  - **Standard**: .claude/ + organizational documents (recommended)
  - **Complete**: Everything including document templates and examples
- **Template Content Discovery**: Agents can access bundled templates
  - Document generator uses bundled templates (PRD, ADR, RFC, etc.)
  - Role guide generator references example guides
  - Template setup assistant offers mode selection
- **Enhanced Manifests**: Detailed content structure and inventory
- **No External Dependencies**: Everything users need is in the plugin

### Templates & Intelligent Agents (v1.1.0+)
- **Template Discovery**: Initialize organizational frameworks from bundled templates
- **Intelligent Setup Assistant**: AI guides you through template selection based on your context
- **Document Generation**: Generate organizational documents from templates with role-aware content
- **Custom Role Guides**: Create new role guides following your organization's patterns
- **Setup Validation**: Comprehensive checks with automated fixes for configuration issues
- **Auto-Update Templates**: Keep organizational standards synchronized across teams

## Installation

### Installation Scopes (New in v1.3.0)

The plugin now supports two installation scopes:

**Global Installation** (Recommended for individuals):
- Plugin installed once for your user account
- Config stored in `~/.claude/`
- Works across all projects
- Personal defaults with project overrides

**Project Installation** (For teams):
- Plugin installed in specific project
- Config stored in project's `.claude/`
- Team-wide standards
- Committed to git for consistency

### Step 1: Add the marketplace

First, add this repository as a marketplace source:

```bash
claude plugin marketplace add https://github.com/WAdamBrooksFS/role-context-manager-marketplace
```

### Step 2: Install the plugin

**Global installation** (recommended):
```bash
claude plugin install role-context-manager
```

**Project installation** (for teams):
```bash
cd your-project
claude plugin install role-context-manager --scope project
```

### Manual Installation

1. Clone this repository
2. Run `claude plugin validate .` to verify the plugin structure
3. Link or copy the plugin directory to your Claude Code plugins folder
4. Restart Claude Code

## SessionStart Hook

The plugin automatically validates your setup and checks for template updates when you start a new Claude Code session.

### What Happens on Session Start

**Automatic checks** (configured by default):
1. **Setup validation** (`/validate-setup --quiet`): Checks if .claude directory is properly configured
2. **Template sync check** (`/sync-template --check-only`): Checks for template updates (if `auto_update_templates` is enabled)

### Output Examples

**When everything is healthy:**
```
✓ Setup valid
✓ Template up-to-date (software-org v1.0.0)
```

**When setup is incomplete:**
```
⚠ Setup incomplete - run /init-org-template to initialize
```

**When template update is available:**
```
ℹ Template update available (v1.0.0 → v1.1.0) - run /sync-template to update
```

**First-time use:**
```
👋 Welcome to role-context-manager!

This plugin helps you organize documentation and maintain
role-based context for Claude Code sessions.

To get started, you need to initialize your organizational framework.

Would you like to initialize your organizational framework now?
```

### Customizing Hook Behavior

The SessionStart hook is automatically configured when you first use any plugin command. You can customize what runs on session start by editing `.claude/settings.json`:

**Minimal** (validation only):
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --silent"
    ]
  }
}
```

**Standard** (validation + update check) - default:
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --quiet",
      "/sync-template --check-only"
    ]
  }
}
```

**Verbose** (validation + updates + role context):
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup",
      "/sync-template --check-only",
      "/show-role-context --summary"
    ]
  }
}
```

**Disabled** (no automatic hooks):
```json
{
  "hooks": {
    "SessionStart": []
  }
}
```

### Troubleshooting Hook Setup

If hooks aren't running automatically:
1. Verify `.claude/settings.json` exists with SessionStart configuration
2. Check that `.claude/.role-context-manager-setup-complete` marker file exists
3. Run `/setup-plugin-hooks` to reconfigure if needed
4. Restart Claude Code completely (not just new session)

## Quick Start

### Choose Your Configuration Approach

**Option 1: Global Defaults (Recommended for individuals)**
```bash
# Initialize global template
/init-org-template --global

# Set your default role
/set-role software-engineer --global

# Works everywhere, override in projects as needed
```

**Option 2: Project-Specific (Recommended for teams)**
```bash
cd your-project

# Initialize project template
/init-org-template --project

# Set project role
/set-role qa-engineer --project

# Commit .claude/ to git for team
```

**Option 3: Hybrid (Best of both worlds)**
```bash
# Set global defaults
/init-org-template --global
/set-role software-engineer --global

# Override in specific projects
cd special-project
/set-role devops-engineer --project
```

See [SCOPES.md](SCOPES.md) for detailed guidance on choosing the right approach.

### For New Users (v1.1.0+): Initialize from Template

If you don't have a `.claude` directory yet, start with a template:

```bash
/init-org-template        # Auto-detects scope
# or
/init-org-template --global   # For global config
/init-org-template --project  # For project config
```

The setup assistant will:
- Analyze your project structure
- Recommend appropriate template (startup vs enterprise)
- Guide you through template selection
- Initialize role guides and organizational documents
- Help you set your role

### For Existing Users: Traditional Setup

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
- Auto-trigger template setup if .claude directory is incomplete
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
- Suggestions for generating missing documents

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

All commands support scope parameters (new in v1.3.0):
- `--global`: Apply to global config (~/.claude/)
- `--project`: Apply to project config (./.claude/)
- `--scope <auto|global|project>`: Explicitly specify scope
- No flag: Auto-detects (project if exists, else global)

### `/set-role [role-name] [--global|--project]`

**Purpose**: Set your current role

**Usage**:
- `/set-role software-engineer` - Auto-detects scope
- `/set-role software-engineer --global` - Set global default
- `/set-role qa-engineer --project` - Set project role
- `/set-role product-manager --scope global` - Explicit scope

**What it does**:
1. Validates role exists at current organizational level
2. Updates appropriate `preferences.json` (global or project)
3. Initializes role-specific document references from role guide
4. Displays what will load on next session
5. Shows which scope was updated

### `/show-role-context`

**Purpose**: Display current role and document loading status

**Usage**:
- `/show-role-context` - Shows configuration hierarchy

**What it shows** (v1.3.0+):
- **Configuration Hierarchy**: Both global and project configs (if they exist)
- **Global config**: Your personal defaults from ~/.claude/
- **Project config**: Project-specific settings from ./.claude/
- **Effective Configuration**: What actually applies in current directory
- Current organizational level
- Current role (showing which scope it comes from)
- Documents that will load (with ✓ exists, ! missing, - excluded)
- Custom additions and removals
- Source indicators (from global vs from project)

### `/update-role-docs [+/-]file ... [--global|--project]`

**Purpose**: Customize which documents load for your role

**Usage**:
- `/update-role-docs +path/to/doc.md` - Add a document (auto scope)
- `/update-role-docs +doc.md --global` - Add to global config
- `/update-role-docs -/quality-standards.md --project` - Remove from project
- `/update-role-docs +new.md -old.md` - Multiple changes

**Supports**:
- Relative paths (relative to current directory)
- Absolute paths (from repository root, start with `/`)
- Scope parameters to target global or project config
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

### File Locations (v1.3.0+)

Configuration files can exist in two locations:

**Global Config** (~/.claude/):
- `preferences.json` - Your global role and settings
- `role-references.json` - Global default document references
- `role-references.local.json` - Your global document customizations
- `settings.json` - Global hook configuration
- `role-guides/` - Available role definitions
- `.role-context-manager-setup-complete` - Setup marker

**Project Config** (./.claude/):
- `preferences.json` - Project role and settings (overrides global)
- `role-references.json` - Project document references (overrides global)
- `role-references.local.json` - Your project document customizations
- `settings.json` - Project hook configuration (overrides global)
- `role-guides/` - Project-specific role definitions
- `.role-context-manager-setup-complete` - Setup marker

**Precedence**: Project > Global > Plugin Defaults

### Created in Your Project (Legacy Documentation)

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

## Multi-Scope Configuration (v1.3.0+)

### Understanding Scopes

The plugin now supports three configuration scopes:

1. **Global** (~/.claude/): Personal defaults for all projects
2. **Project** (./.claude/): Project-specific overrides
3. **Auto**: Intelligently chooses based on context

See [SCOPES.md](SCOPES.md) for comprehensive documentation.

### Common Patterns

**Pattern 1: Individual Developer**
```bash
# Set global defaults
/init-org-template --global
/set-role software-engineer --global

# Works everywhere automatically
cd any-project
/show-role-context  # Uses global config
```

**Pattern 2: Team Project**
```bash
cd team-project

# Set team standards
/init-org-template --project
/set-role qa-engineer --project

# Commit for team
git add .claude/
git commit -m "Add team configuration"
```

**Pattern 3: Hybrid (Recommended)**
```bash
# Global defaults for personal work
/set-role software-engineer --global

# Override for specific projects
cd work-project
/set-role devops-engineer --project

# work-project uses devops-engineer
# other projects use software-engineer
```

### Checking Active Configuration

```bash
/show-role-context
```

Shows:
- Global config (if exists)
- Project config (if exists)
- Effective configuration (what's actually used)
- Which scope each setting comes from

### Migration from v1.2.0

Existing project-only setups work without changes. To add global config:

```bash
/init-org-template --global
/set-role your-role --global
```

Now plugin works both in and outside projects.

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

- **Issues**: https://github.com/WAdamBrooksFS/role-context-manager-marketplace/issues
- **Discussions**: https://github.com/WAdamBrooksFS/role-context-manager-marketplace/discussions
- **Documentation**: https://github.com/WAdamBrooksFS/role-context-manager-marketplace/wiki

## Changelog

### v1.3.0 (2026-01-08) - Multi-Scope Configuration & Global Installation Support

**Major Features**:
- **Multi-Scope Configuration**: Plugin now works at global and project levels
  - **Global scope** (~/.claude/): Personal defaults across all projects
  - **Project scope** (./.claude/): Project-specific settings that override global
  - **Auto mode**: Intelligently chooses project or global based on context
  - **Configuration hierarchy**: Project > Global > Plugin Defaults
  - Works when installed globally (`local-user`) or per-project

**All Commands Updated with Scope Support**:
- `/set-role [role] --global|--project|--scope <auto|global|project>`
- `/init-org-template --global|--project`
- `/update-role-docs [+/-]files --global|--project`
- `/init-role-docs --reset --global|--project`
- `/set-org-level [level] --global|--project`
- `/validate-setup --global|--project` - Validates both scopes
- `/sync-template --global|--project` - Syncs both scopes
- `/show-role-context` - Shows configuration hierarchy
- `/setup-plugin-hooks --global|--project` - Configures hooks at either scope

**Core Script Enhancements**:
- `role-manager.sh`: Added multi-scope functions
  - `find_config_dir()` - Scope-aware config directory resolution
  - `get_effective_config_dir()` - Hierarchy with fallback
  - `ensure_global_config()` - Auto-creates global config on first use
  - `get_preference()` - Reads with global fallback
  - `set_preference()` - Writes to appropriate scope
- `post-install.sh`: Updated for multi-scope hook installation
- Template and validation scripts: Support both scopes

**Hook Improvements**:
- SessionStart hooks work at both global and project levels
- Global hooks run for all projects
- Project hooks override global when both exist
- Independent marker files per scope

**New Documentation**:
- `SCOPES.md` - Comprehensive scope configuration guide
- `docs/MULTI-SCOPE-HOOKS.md` - Multi-scope hook behavior
- `docs/TEST-PLAN.md` - Comprehensive test plan for multi-scope

**Enhanced Commands**:
- `/show-role-context` - Now displays configuration hierarchy
  - Shows global config (if exists)
  - Shows project config (if exists)
  - Shows effective configuration (what's actually used)
  - Indicates source of each setting

**Backward Compatibility**:
- Existing project-only setups continue to work unchanged
- No migration required for v1.2.0 users
- Auto mode provides seamless experience

**Use Cases Enabled**:
- Personal defaults with project overrides
- Works outside projects (not just in .claude directories)
- Team standards with personal customizations
- Flexible development environments

**Migration Path**:
- v1.2.0 and earlier: Project-only configuration continues to work
- Add global config optionally: `/init-org-template --global`
- Existing projects unaffected, global config adds convenience

### v1.2.0 (2026-01-05) - SessionStart Hook & Auto-Validation
**New Features**:
- **SessionStart Hook**: Automatic validation and update checks on session start
- **First-Run Initialization**: Guided setup on first use with welcome flow
- **Auto-Configuration**: Hook setup automatic on first command use

**New Command**:
- `/setup-plugin-hooks` - Configure SessionStart hook (manual fallback)

**Enhanced Commands with New Flags**:
- `/validate-setup --silent` - No output unless issues found
- `/validate-setup --quiet` - One-line summary only
- `/validate-setup --summary` - Brief checklist of results
- `/sync-template --check-only` - Check for updates without applying
- `/sync-template --quiet` - Minimal output with check-only
- `/show-role-context --summary` - One-line role context summary

**Agent Enhancements**:
- **framework-validator**: Added hook modes (silent, quiet, summary) and first-run detection
- **template-sync**: Added check-only mode for non-intrusive update checks

**Hook Integration**:
- Pre-flight checks in all major commands to configure hook on first use
- Non-intrusive session start validation
- Automatic template update detection (respects auto_update_templates preference)
- First-run welcome and initialization offer

**Scripts**:
- New `post-install.sh` for automatic hook configuration

**Documentation**:
- New SessionStart Hook section in README
- SessionStart Hook Integration section in TEMPLATES.md
- Updated command documentation with flag usage
- Hook customization examples and troubleshooting

**User Experience**:
- Zero manual configuration required
- Seamless onboarding for new users
- Quiet operation for established users
- Setup always validated on session start

### v1.1.0 (2026-01-05) - Templates & Intelligent Agents
**New Commands**:
- `/init-org-template` - Initialize organizational framework from templates
- `/generate-document` - Generate documents from templates with role context
- `/create-role-guide` - Create custom role guides following patterns
- `/validate-setup` - Validate and troubleshoot .claude directory
- `/sync-template` - Sync template updates while preserving customizations

**New Intelligent Agents**:
- **template-setup-assistant** - Analyzes context, recommends templates, guides setup
- **document-generator** - Creates role-aware documents from templates
- **role-guide-generator** - Generates custom role guides learning from existing patterns
- **framework-validator** - Deep validation with explanations and automated fixes
- **template-sync** - Intelligent merge of template updates with customization preservation

**Bundled Templates**:
- **software-org** v1.0.0 - Full organizational framework (6 role guides, 3 document guides, 14 org docs)
- **startup-org** v1.0.0 - Lean startup framework (flat structure, fundraising support)

**Enhanced Features**:
- Auto-trigger template setup when .claude is incomplete
- Proactive document generation suggestions
- Template version tracking and auto-update support (opt-in/out)
- Backup and rollback capabilities for template operations
- Enhanced commands with template integration

**Configuration**:
- New `auto_update_templates` preference (default: true)
- New `applied_template` tracking (id, version, applied_date)
- Template registry system for version management

**Scripts**:
- New `template-manager.sh` for template operations
- Enhanced `role-manager.sh` with setup checking functions

### v1.0.0 (Initial Release)
- Role-based context management
- Organizational level detection
- Document customization with +/- syntax
- Team defaults + user overrides
- Integration with role guides
- Five commands: set-role, show-role-context, update-role-docs, init-role-docs, set-org-level
