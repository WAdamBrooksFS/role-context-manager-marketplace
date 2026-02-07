# Role Context Manager - Cheatsheet

**Plugin Version:** 1.7.0
**Description:** Role-based document context manager for Claude Code with hierarchical organizations

---

## Table of Contents

- [Initial Setup Phase](#initial-setup-phase)
- [Configuration Phase](#configuration-phase)
- [Daily Usage Phase](#daily-usage-phase)
- [Maintenance Phase](#maintenance-phase)
- [Understanding Scope](#understanding-scope)
- [Quick Reference](#quick-reference)
- [Common Patterns](#common-patterns)
- [SessionStart Hook](#sessionstart-hook)

---

## Initial Setup Phase

**When to use:** First-time user or new project initialization

### Commands

#### `/init-org-template [--global|--project]`

**Purpose:** Initialize organizational framework from a template

**What it does:**
- Invokes Template Setup Assistant agent
- Analyzes your project structure
- Presents available templates (software-org, startup-org)
- Applies chosen template to appropriate scope
- Records template tracking for auto-updates

**Flags:** `--global` (apply to ~/.claude/), `--project` (apply to ./.claude/)

---

#### `/setup-plugin-hooks [--global|--project]`

**Purpose:** Configure SessionStart hook for automatic validation

**What it configures:**
- Adds SessionStart hook to settings.json
- Sets up automatic validation and update checks
- Creates setup marker file

---

#### `/set-role [role-name] [--global|--project]`

**Purpose:** Set your current role to determine which documents load

**Parameters:** role-name (required, e.g., software-engineer, product-manager)

**What it does:**
- Validates role exists at current organizational level
- Updates preferences.json with your role
- Initializes role-specific document references
- Displays documents that will load on next session

---

#### `/set-org-level [level] [--global|--project]`

**Purpose:** Explicitly set organizational level

**Levels:**
- **company** - Root level (CTO, CPO, CISO, VP Engineering)
- **system** - Coordination level (Engineering Manager, Platform Engineer)
- **product** - Product management level (Product Manager, QA Manager, UX Designer)
- **project** - Implementation level (Software Engineer, DevOps Engineer, QA Engineer)

**When to use:** Directory structure doesn't match standard patterns, want to override automatic detection

---

#### `/configure-paths [OPTIONS]`

**Purpose:** Configure custom directory names for .claude and role-guides directories

**Options:**
- `--claude-dir=NAME` - Set claude directory name (default: .claude)
- `--role-guides-dir=NAME` - Set role guides directory name (default: role-guides)
- `--global` - Create configuration in $HOME (user-wide)
- `--local` - Create configuration in current directory (default)
- `--dry-run` - Preview changes without applying
- `--migrate OLD NEW` - Migrate existing directories to new names

**Examples:**
```bash
# Set custom directory names
/configure-paths --claude-dir=.myorg --role-guides-dir=guides

# Create global configuration
/configure-paths --global --claude-dir=.myorg

# Preview migration
/configure-paths --dry-run --migrate .claude .myorg-rcm

# Execute migration
/configure-paths --migrate .claude .myorg-rcm
```

**When to use:**
- Match organizational directory naming standards
- Avoid conflicts with other tools
- Rebrand internal tooling
- Migrate from existing setup

See [Path Configuration](docs/PATH-CONFIGURATION.md) for complete details.

---

#### `/add-role-guides [guide1] [guide2] [CUSTOM:name]`

**Purpose:** Add role guides to existing organizational setup after initialization

**Arguments:**
- `guide-name` - One or more role guide filenames from templates
- `CUSTOM:name` - Create custom role guide with specified name

**What it does:**
- Validates .claude directory exists
- Determines current organizational level
- Filters guides based on parent-level inheritance (hierarchical organizations)
- Copies selected guides from template to .claude/role-guides/
- Generates placeholder markdown for custom guides
- Reports what was added, skipped, or filtered

**Examples:**
```bash
# Add single guide
/add-role-guides software-engineer-guide.md

# Add multiple guides
/add-role-guides qa-engineer-guide.md devops-engineer-guide.md

# Create custom guide
/add-role-guides CUSTOM:platform-sre

# Mix template and custom
/add-role-guides software-engineer-guide.md CUSTOM:devops-lead
```

**When to use:**
- Team is growing, need additional role guides
- Need specialized role not in template
- Adding guides incrementally after initial setup
- Working in hierarchical organization (respects parent-child relationships)

**Hierarchical Filtering:**
If working in child organization (e.g., project under product), automatically filters out guides that should be inherited from parent level, preventing duplication.

---

#### `/show-paths [OPTIONS]`

**Purpose:** Display current path configuration

**Options:**
- `--verbose` - Show detailed configuration including source
- `--json` - Output in JSON format

**Output:**
- Current claude directory name
- Current role guides directory name
- Configuration source (environment, local manifest, global manifest, or defaults)

**Example:**
```bash
/show-paths

# Output:
# Path Configuration:
#   Claude directory: .myorg
#   Role guides directory: guides
#   Source: Local manifest (./.myorg/paths.json)
```

---

### Agent: Template Setup Assistant

**Invoked by:** `/init-org-template`

**Purpose:** Guide users through template selection and setup

**Capabilities:**
- Analyzes current directory structure
- Loads available templates from plugin's templates/ directory
- Presents template options with recommendations
- Asks clarifying questions about organization size and stage
- Applies selected template with user confirmation
- Guides user to next steps (/set-role)

---

## Configuration Phase

**When to use:** Setting up or adjusting your role and preferences

### Commands

#### `/show-role-context`

**Purpose:** Display current role and document loading status

**Shows:**
- Configuration hierarchy (both global and project configs)
- Current organizational level
- Current role (with source scope indicator)
- Documents that will load (✓ exists, ! missing, - excluded)
- Custom additions and removals

---

#### `/update-role-docs [+/-]file ... [--global|--project]`

**Purpose:** Customize which documents load for your role

**Syntax:**
- `+path/to/doc.md` - Add a document
- `-/quality-standards.md` - Remove a document (absolute path with /)
- `+new.md -old.md +another.md` - Multiple changes

**Supports:** Relative paths (relative to current directory), Absolute paths (from repository root, start with /)

---

#### `/init-role-docs [--reset]`

**Purpose:** Initialize or reset document references to role guide defaults

**Flags:** `--reset` - Reset to defaults, clearing customizations

**When to use:** First time setting up a role, want to reset customizations, role guide has been updated

---

### Agent: Role Guide Generator

**Invoked by:** `/create-role-guide [role-name]`

**Purpose:** Create custom role guides following established patterns

**What it creates:**
- Role overview and responsibilities
- Deterministic behaviors (AI MUST follow)
- Agentic opportunities (AI SHOULD suggest)
- Common workflows and example scenarios
- Document references
- Integration with other roles

---

## Organizational Commands (Hierarchical Organizations)

**When to use:** Working in multi-level organizational structures

### Understanding Organizational Hierarchy

Role Context Manager supports four organizational levels in parent-child relationships:

**Company** (root level)
  └─ **System** (coordination level)
      └─ **Product** (feature groups)
          └─ **Project** (implementation)

**Key Features:**
- Automatic parent detection (scans upward for parent .claude directories)
- Role guide inheritance (child inherits from parent, avoids duplication)
- Level-based filtering (templates apply appropriate guides for each level)
- Parent-child validation (ensures valid relationships)

### Hierarchy-Aware Commands

#### Automatic Parent Detection

When running `/set-org-level` or `/init-org-template` in a directory with parent `.claude`:
- Detects parent organizational level automatically
- Shows parent context in prompts
- Filters available level options based on parent
- Validates selected level against parent
- Records parent path in `organizational-level.json`

#### Role Guide Inheritance

When adding guides with `/add-role-guides` in child organization:
- Automatically skips parent-level roles (inherited from parent)
- Shows which guides were filtered: "Skipped: qa-manager-guide.md (inherited from parent product level)"
- Only copies guides appropriate for child level
- Prevents duplication across hierarchy

#### Template Application with Hierarchy

When running `/init-org-template` in child organization:
- Template only applies guides for current level
- Parent-level guides are inherited, not copied
- Shows filtering feedback during application
- Respects organizational boundaries

### Hierarchical Organization Examples

**Example 1: Company → Product → Project Structure**

```bash
# Company level (root)
cd /company-root
/init-org-template --project
/set-org-level company
/set-role cto

# Product level (child of company)
cd /company-root/product-a
/init-org-template
# Automatically detects parent (company level)
# Prompts: "Recommended level: product (child of company)"
/set-org-level product
/set-role product-manager
# qa-manager-guide inherited from parent

# Project level (child of product)
cd /company-root/product-a/project-x
/init-org-template
# Detects parent chain: company → product
# Prompts: "Recommended level: project (child of product)"
/set-org-level project
/set-role software-engineer
# Inherits product-manager, qa-manager from ancestors
```

**Example 2: Adding Guides with Inheritance**

```bash
# At product level
cd /company-root/product-a
/add-role-guides product-manager-guide.md qa-manager-guide.md
# ✓ Added product-manager-guide.md
# ✓ Added qa-manager-guide.md

# At project level (child of product)
cd /company-root/product-a/project-x
/add-role-guides qa-manager-guide.md software-engineer-guide.md
# Skipped: qa-manager-guide.md (inherited from parent product level)
# ✓ Added: software-engineer-guide.md
```

### Organizational Level Detection

**Automatic Detection Strategies:**

1. **Explicit Marker**: Reads `.claude/organizational-level.json`
2. **Parent Context**: Scans for parent `.claude` directories
3. **Heuristic Detection**:
   - Company: Repository root, executive role guides, strategy docs
   - System: System role guides, coordination docs
   - Product: Product-level guides, PRDs, roadmaps
   - Project: Implementation guides, package.json, src/ directory
4. **User Prompt**: If ambiguous, prompts with parent-aware recommendations

### See Also

- [Hierarchical Organizations Guide](docs/HIERARCHICAL-ORGANIZATIONS.md) - Complete hierarchy documentation
- [Combined Features Guide](docs/COMBINED-FEATURES.md) - Using hierarchy with custom paths

---

## Daily Usage Phase

**When to use:** Working on projects with established configuration

### Commands

#### `/generate-document [type] [--auto]`

**Purpose:** Generate documents from templates using role context

**Supported Document Types:**
- **Technical:** ADR, TDD, API docs, operational runbook
- **Product:** PRD, feature spec, user story, product overview
- **Strategic:** OKRs, roadmap, strategy, vision
- **Standards:** Engineering standards, quality standards, security policy
- **Process:** Contributing guide, development setup, team handbook

**Flags:** `--auto` - Batch mode with minimal interaction

---

### Agent: Document Generator

**Invoked by:** `/generate-document`

**Purpose:** Generate high-quality organizational documents from templates

**Capabilities:**
- Reads user's role and role guide
- Accesses bundled document templates
- Understands organizational context and level
- Asks document-specific questions
- Generates documents with appropriate structure
- Places documents in correct location
- Updates cross-references

---

## Maintenance Phase

**When to use:** Validating setup, syncing updates, troubleshooting

### Commands

#### `/validate-setup [flags] [--global|--project]`

**Purpose:** Validate .claude directory structure and configuration

**Flags:**
- `--quick` - Essential checks only
- `--fix` - Auto-fix issues with confirmation
- `--silent` - No output unless issues found (for SessionStart hook)
- `--quiet` - One-line summary only (for SessionStart hook)
- `--summary` - Brief checklist of results

**Checks:**
- Directory structure exists and is complete
- JSON files are valid
- Role guides exist and are populated
- Reference integrity (roles, documents, templates)
- Cross-references between files

---

#### `/sync-template [flags] [--global|--project]`

**Purpose:** Synchronize template updates while preserving customizations

**Flags:**
- `--check-only` - Check for updates without applying (for SessionStart hook)
- `--quiet` - Minimal output with check-only
- `--preview` - Show changes without applying
- `--force` - Force update check even if recently checked

**What it does:**
- Compares your template version with registry
- Analyzes differences (new files, updates, conflicts)
- Creates automatic backup before changes
- Performs intelligent three-way merge
- Handles conflicts with user input
- Generates detailed migration report

---

#### `/create-role-guide [role-name]`

**Purpose:** Create custom role guides following organizational patterns

Invokes the Role Guide Generator agent to create a comprehensive role guide.

---

### Agents: Framework Validator & Template Sync

#### Framework Validator

**Invoked by:** `/validate-setup`

**Purpose:** Comprehensive validation of .claude directory setup

**Special Modes:**
- **First-Run Mode:** Detects missing .claude, offers initialization
- **Silent Mode (--silent):** No output unless issues found
- **Quiet Mode (--quiet):** One-line summary only
- **Summary Mode (--summary):** Brief checklist

**Validation Checks:** Critical (directory exists, JSON valid), Important (multiple roles, current role valid), Quality (documents exist, no broken references)

---

#### Template Sync

**Invoked by:** `/sync-template`

**Purpose:** Intelligent template synchronization with customization preservation

**Capabilities:**
- Version detection (compares current vs latest)
- Difference analysis (file-level and content-level diffs)
- Change categorization (safe to auto-apply, merge required, conflict, preserve)
- Backup creation (timestamped backup before changes)
- Intelligent merge (three-way merge, additive merge)
- Conflict resolution (presents options to user)
- Update tracking and validation

---

## Combined Workflows (v1.7.0)

**When to use:** Using custom paths AND hierarchical organizations together

### Scenario 1: Custom Paths in Hierarchical Structure

Use custom directory names across organizational hierarchy:

```bash
# Configure custom paths globally
/configure-paths --global --claude-dir=.myorg --role-guides-dir=guides

# Company level with custom paths
cd /company-root
/init-org-template --project
# Creates: .myorg/ and .myorg/guides/
/set-org-level company
/set-role cto

# Product level (child) with inherited custom paths
cd /company-root/product-a
/init-org-template
# Creates: .myorg/ (inherits path config from parent or global)
# Detects parent: /company-root/.myorg
/set-org-level product
/set-role product-manager
```

**Result:** Hierarchical structure with consistent custom directory naming.

### Scenario 2: Mixed Path Configuration

Parent uses default paths, child uses custom paths:

```bash
# Parent with defaults
cd /parent-org
/init-org-template
# Creates: .claude/ and .claude/role-guides/
/set-org-level company

# Child with custom paths
cd /parent-org/child-project
/configure-paths --local --claude-dir=.custom
/init-org-template
# Creates: .custom/ and .custom/role-guides/
# Still detects parent at ../claude
/set-org-level project
```

**Result:** Hierarchy detection works across different directory names.

### Scenario 3: Migrating Hierarchical Setup

Migrate existing hierarchy to custom paths:

```bash
# Step 1: Configure new paths globally
/configure-paths --global --claude-dir=.myorg

# Step 2: Migrate each level (top to bottom)
cd /company-root
/configure-paths --migrate .claude .myorg
# Migrates: .claude → .myorg (preserves organizational-level.json)

cd /company-root/product-a
/configure-paths --migrate .claude .myorg
# Migrates: .claude → .myorg (updates parent paths automatically)

cd /company-root/product-a/project-x
/configure-paths --migrate .claude .myorg
# Migrates: .claude → .myorg (maintains hierarchy references)
```

**Result:** Entire hierarchy uses new directory names with preserved relationships.

### Scenario 4: Adding Guides with Custom Paths and Hierarchy

```bash
# At product level with custom paths
cd /company/.myorg-product
export RCM_CLAUDE_DIR_NAME=".myorg"
export RCM_ROLE_GUIDES_DIR="guides"

/add-role-guides product-manager-guide.md
# Adds to: .myorg/guides/product-manager-guide.md

# At child project level
cd /company/.myorg-product/project-x
/add-role-guides software-engineer-guide.md qa-manager-guide.md
# Adds to: .myorg/guides/software-engineer-guide.md
# Skips: qa-manager-guide.md (inherited from parent .myorg-product)
```

**Result:** Combined path customization and hierarchical filtering.

### Key Benefits of Combined Features

1. **Organizational Flexibility**: Custom directory names + multi-level structure
2. **Consistent Naming**: Same custom paths across entire hierarchy
3. **Inheritance Works**: Parent detection works with any directory names
4. **Migration Safe**: Can migrate hierarchies without breaking relationships
5. **Security Maintained**: Path validation applies to hierarchical detection

### Validation with Combined Features

```bash
/validate-setup

# Checks both features:
# ✓ Path configuration valid (.myorg/paths.json)
# ✓ Claude directory exists: .myorg/
# ✓ Role guides directory exists: .myorg/guides/
# ✓ Organizational level valid: project
# ✓ Parent organizational level detected: product
# ✓ Parent path: /parent/.myorg
# ✓ Hierarchy relationship valid (project child of product)
# ✓ Role guide inheritance working correctly
```

See [Combined Features Guide](docs/COMBINED-FEATURES.md) for advanced workflows, edge cases, and best practices.

---

## Understanding Scope

### How Scope Affects Your Reference Files

> **Important:** Scope determines where your configuration is stored and which settings take precedence.

### The Three Scopes

| Scope | Location | Purpose | When to Use |
|-------|----------|---------|-------------|
| **Global** | `~/.claude/` | Personal defaults that apply across all projects | You want consistent role and document settings everywhere |
| **Project** | `./.claude/` | Project-specific configuration that overrides global defaults | Your team has standardized roles and documents for a project |
| **Auto** | (Dynamic) | Automatically chooses project or global based on context | You want smart defaults without thinking about scope |

### Configuration Hierarchy

```
┌─────────────────────────────────────────────┐
│  1. Project Config (./.claude/)             │  ← Highest Priority
│     - Project-specific settings             │
│     - Team standards                        │
│     - Overrides global config               │
├─────────────────────────────────────────────┤
│  2. Global Config (~/.claude/)              │  ← Fallback
│     - Your personal defaults                │
│     - Applies when no project override      │
│     - Cross-project consistency             │
├─────────────────────────────────────────────┤
│  3. Plugin Defaults (bundled templates/)    │  ← Last Resort
│     - Built-in templates                    │
│     - Used during initial setup             │
└─────────────────────────────────────────────┘
```

> **Key Concept:** Project configuration ALWAYS overrides global configuration when both exist. This allows teams to enforce standards while letting individuals maintain personal preferences elsewhere.

---

## Quick Reference

### All Slash Commands

| Command | Purpose | Key Flags |
|---------|---------|-----------|
| `/init-org-template` | Initialize organizational framework | `--global`, `--project` |
| `/setup-plugin-hooks` | Configure SessionStart hook | `--global`, `--project` |
| `/set-role` | Set your current role | `--global`, `--project`, `--scope` |
| `/set-org-level` | Set organizational level | `--global`, `--project` |
| `/show-role-context` | Display current configuration | (none) |
| `/load-role-context` | Load role guide and documents into context | `--quiet`, `--verbose` |
| `/update-role-docs` | Customize document references | `--global`, `--project` |
| `/init-role-docs` | Reset to role guide defaults | `--reset` |
| `/generate-document` | Generate documents from templates | `--auto` |
| `/create-role-guide` | Create custom role guide | (none) |
| `/validate-setup` | Validate .claude directory | `--quick`, `--fix`, `--silent`, `--quiet`, `--summary` |
| `/sync-template` | Synchronize template updates | `--check-only`, `--quiet`, `--preview`, `--force` |
| `/configure-paths` | Configure custom directory names | `--claude-dir`, `--role-guides-dir`, `--migrate`, `--global`, `--local`, `--dry-run` |
| `/show-paths` | Display path configuration | `--verbose`, `--json` |
| `/add-role-guides` | Add role guides after initialization | `guide1`, `guide2`, `CUSTOM:name` |

### All Agents

| Agent | Invoked By | Purpose |
|-------|-----------|---------|
| Template Setup Assistant | `/init-org-template` | Guide template selection and setup |
| Role Guide Generator | `/create-role-guide` | Create custom role guides |
| Document Generator | `/generate-document` | Generate organizational documents |
| Framework Validator | `/validate-setup` | Validate .claude directory setup |
| Template Sync | `/sync-template` | Synchronize template updates |

### Key Configuration Files

| File | Purpose | Contains |
|------|---------|----------|
| `preferences.json` | User preferences | Current role, auto_update_templates, applied_template info |
| `role-references.json` | Team defaults | Default document references per role |
| `role-references.local.json` | Personal customizations | User-specific document additions/removals (gitignored) |
| `organizational-level.json` | Org level tracking | Current organizational level (company/system/product/project) |
| `settings.json` | Hook configuration | SessionStart hook commands |

---

## Common Patterns

### Pattern 1: Individual Developer (Global Only)

```bash
/init-org-template --global
/set-role software-engineer --global
# Works everywhere automatically
```

### Pattern 2: Team Project (Project Only)

```bash
cd team-project
/init-org-template --project
/set-role qa-engineer --project
git add .claude/
git commit -m "Add team configuration"
```

### Pattern 3: Hybrid (Recommended)

```bash
# Global defaults for personal work
/set-role software-engineer --global

# Override for specific projects
cd special-project
/set-role devops-engineer --project
```

---

## SessionStart Hook

**Purpose:** Automatic validation and update checks when starting a new session

### Default Configuration

`.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --quiet",
      "/sync-template --check-only",
      "/load-role-context --quiet"
    ]
  }
}
```

### What Happens

- `/validate-setup --quiet` - Validates setup, shows one-line summary
- `/sync-template --check-only` - Checks for updates (respects auto_update_templates preference)
- `/load-role-context --quiet` - Loads your role guide and referenced documents into context

### Example Outputs

Success:
```
✓ Setup valid
✓ Template up-to-date (software-org v1.0.0)
✓ Role context loaded: software-engineer (5 documents)
```

Issues detected:
```
⚠ Setup incomplete - run /init-org-template to initialize
ℹ Template update available (v1.0.0 → v1.1.0). Run /sync-template to update.
```

---

**For more information:** Visit the plugin repository or check the documentation in your .claude/docs/ directory.

**Generated with:** Claude Code • Role Context Manager Plugin v1.3.0
