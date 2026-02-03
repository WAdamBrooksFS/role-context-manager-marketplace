# Role Context Manager Plugin

## Overview

The **role-context-manager** is a Claude Code plugin that enables role-based context management with hierarchical organizational awareness. It allows Claude to load contextual information based on the user's current role and organizational position within a company/system/product/project hierarchy.

## Purpose

**For Users:**
- Automatically load relevant context based on their role (engineer, manager, designer, etc.)
- Navigate multi-level organizational structures (company → system → product → project)
- Inherit role guides and documentation from parent organizational levels
- Maintain consistent context across team hierarchies

**For Claude:**
- Understand the user's current role and organizational context
- Access role-specific guides, templates, and documentation
- Respect organizational boundaries and hierarchies
- Provide role-appropriate assistance

## Core Capabilities

### 1. Hierarchical Awareness (v1.5.0)

The plugin detects and manages multi-level organizational structures:

**Organizational Levels:**
- **Company**: Top-level organization (executive roles: CTO, CPO, CISO)
- **System**: Major platforms/initiatives (management roles: Engineering Manager, Architect)
- **Product**: Feature groups (coordination roles: QA Manager, Designer, Product Manager)
- **Project**: Individual codebases (implementation roles: Software Engineer, DevOps, QA Engineer)

**Parent-Child Relationships:**
```
company
├── system (valid)
├── product (valid)
└── project (valid)

system
├── product (valid)
└── project (valid)

product
└── project (valid)

project
└── (no children - leaf node)
```

**Automatic Parent Detection:**
- Scans upward in directory tree to find parent `.claude` directories
- Validates parent-child level relationships
- Inherits role guides from parent levels (avoids duplication)
- Filters template application based on organizational position

### 2. Role-Based Context Loading

**On Session Start:**
- Automatically loads current role from `.claude/preferences.json`
- Injects role guide and referenced documents into Claude's context
- Provides role-specific capabilities and guidelines

**Role Guides:**
- Define responsibilities, capabilities, and workflows for each role
- Reference additional documents (strategy, architecture, processes)
- Customize Claude's behavior based on role requirements

### 3. Template Management

**Organizational Templates:**
- `software-org`: Software development organization
- `startup-org`: Startup/small team structure
- `custom`: User-defined templates

**Application Modes:**
- **minimal**: Basic .claude structure only
- **standard**: Structure + root documentation
- **complete**: Structure + docs + examples + templates

**Level-Based Filtering:**
When applying templates in a hierarchy, only copies role guides appropriate for the current level. Parent-level roles are inherited from the parent `.claude` directory.

## Architecture

### Core Scripts

#### **scripts/hierarchy-detector.sh** (NEW in v1.5.0)
Core hierarchy detection and validation engine.

**Key Functions:**
- `find_parent_claude_dirs()` - Finds all parent `.claude` directories
- `get_nearest_parent()` - Gets immediate parent
- `read_level_from_claude_dir()` - Reads organizational level from path
- `build_hierarchy_path()` - Constructs full hierarchy array
- `is_valid_child_level()` - Validates parent-child relationships
- `save_level_with_hierarchy()` - Writes extended organizational-level.json

**Usage:**
```bash
# Find parent .claude directory
parent=$(bash scripts/hierarchy-detector.sh get-parent)

# Validate relationship
bash scripts/hierarchy-detector.sh is-valid-child company product
# Returns: 0 (valid)

# Build hierarchy path
bash scripts/hierarchy-detector.sh build-hierarchy
# Returns: ["company", "system", "product", "project"]
```

#### **scripts/level-detector.sh**
Enhanced with parent-aware prompts and validation.

**Key Changes (v1.5.0):**
- Detects parent context before prompting user
- Filters level options based on parent level
- Shows recommended level based on parent
- Validates selected level against parent
- Calls `save_level_with_hierarchy()` for extended format

#### **scripts/template-manager.sh**
Enhanced with level-based role guide filtering.

**Key Changes (v1.5.0):**
- Detects parent organizational level before applying template
- Filters role guides based on current level
- Skips parent-level role guides (inherited from parent)
- Shows detailed feedback: "Skipping qa-manager-guide.md (inherited from parent product level)"

**Role Guide Mapping:**
```bash
# Company level: CTO, CPO, CISO, VPs
# System level: Engineering Manager, Platform Engineer, Architects
# Product level: QA Manager, Designers, Product Managers
# Project level: Engineers, QA, DevOps, SRE, Mobile, Data roles
```

#### **scripts/role-manager.sh**
Manages role loading and context injection.

**Key Functions:**
- `cmd_load_role_context()` - Loads current role guide + referenced docs
- `cmd_show_role()` - Displays current role
- `cmd_set_role()` - Changes active role
- `cmd_list_roles()` - Shows available roles

### Agents

#### **agents/template-setup-assistant/**
Guides template initialization with organizational context detection.

**Workflow (v1.5.0):**
1. Analyze current directory
2. Load available templates
3. **Detect organizational context (NEW)** - Section 2.5
   - Check for parent `.claude` directories
   - Determine if root or sub-level setup
   - Validate organizational relationships
4. Select application mode (minimal/standard/complete)
5. Apply template with level-based filtering
6. Record configuration in preferences.json

**Parent Detection Logic:**
- If parent found: Shows parent level/name, asks if child or sibling
- If no parent: Asks if root or part of existing organization
- Validates parent-child relationships before setup

#### **agents/framework-validator/**
Validates plugin setup and hierarchy integrity.

#### **agents/role-guide-generator/**
Generates role guide templates.

### Commands

#### **/init-org-template**
Initialize organizational template structure.

**Flags (NEW in v1.5.0):**
- `--root` - Mark as top-level (no parent checking)
- `--parent <path>` - Explicitly specify parent .claude directory

**Example:**
```bash
# Initialize at root level
/init-org-template --root

# Initialize with auto-detected parent
/init-org-template

# Initialize with explicit parent
/init-org-template --parent ../../../.claude
```

#### **/set-org-level**
Set or update organizational level.

**Flags (NEW in v1.5.0):**
- `--parent <path>` - Set explicit parent .claude directory path
- `--root` - Mark as root level (no parent in hierarchy)
- `--update-parent` - Refresh parent directory references

**Extended Schema:**
```json
{
  "level": "project",
  "level_name": "my-project",
  "parent_claude_dir": "/path/to/parent/.claude",
  "parent_level": "product",
  "is_root": false,
  "hierarchy_path": ["company", "system", "product", "project"]
}
```

#### **/validate-setup**
Validate plugin configuration and hierarchy.

**New Checks (v1.5.0):**
- Hierarchy Validation
  - Verify parent_claude_dir path exists
  - Validate parent-child level relationship
  - Check is_root flag accuracy
  - Verify hierarchy_path construction
  - Detect invalid relationships
  - Detect broken parent links

**Flags:**
- `--migrate-hierarchy` - Migrate old format to extended schema
- `--skip-hierarchy` - Skip hierarchy checks

**Example Output:**
```
Hierarchy Validation:
  ✓ Parent .claude directory exists at /parent/.claude
  ✓ Parent level (product) is valid for current level (project)
  ✓ is_root flag correctly set to false
  ✓ hierarchy_path matches structure: company > system > product > project
```

#### **/load-role-context**
Manually load role context into session.

#### **/show-role** / **/set-role** / **/list-roles**
Role management commands.

## Configuration Files

### .claude/organizational-level.json

**Basic Format (backward compatible):**
```json
{
  "level": "project",
  "level_name": "my-project-name"
}
```

**Extended Format (v1.5.0):**
```json
{
  "level": "project",
  "level_name": "my-project-name",
  "parent_claude_dir": "/path/to/parent/.claude",
  "parent_level": "product",
  "is_root": false,
  "hierarchy_path": ["company", "product", "project"]
}
```

**Fields:**
- `level` - Organizational level (company/system/product/project)
- `level_name` - Human-readable name
- `parent_claude_dir` - Absolute path to parent .claude directory (null if root)
- `parent_level` - Parent's organizational level (null if root)
- `is_root` - Boolean indicating top-level organizational context
- `hierarchy_path` - Array showing full hierarchy from root to current

### .claude/preferences.json

Stores plugin preferences and current state.

```json
{
  "current_role": "software-engineer",
  "template_applied": "software-org",
  "template_mode": "standard",
  "preserved_claude_md": []
}
```

### .claude/role-references.json

Maps role guides to their referenced documents.

```json
{
  "software-engineer": [
    "docs/architecture.md",
    "docs/coding-standards.md"
  ]
}
```

### .claude/settings.json

Contains SessionStart hooks for automatic role loading.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "run": "bash",
        "args": ["-c", "~/.claude/plugins/role-context-manager/commands/validate-setup.sh"],
        "allowedPrompts": [{"tool": "Bash", "prompt": "validate plugin setup"}]
      },
      {
        "run": "bash",
        "args": ["-c", "~/.claude/plugins/role-context-manager/commands/load-role-context.sh"],
        "allowedPrompts": [{"tool": "Bash", "prompt": "load role context into session"}]
      }
    ]
  }
}
```

## Workflows

### Hierarchical Initialization

**Scenario: Set up project within existing product**

```bash
# 1. Navigate to product directory (already has .claude/)
cd /company/product

# 2. Create project subdirectory
mkdir my-project && cd my-project

# 3. Initialize with auto-detection
/init-org-template
```

**What happens:**
1. Plugin detects parent `.claude` at `/company/product/.claude`
2. Reads parent level: "product"
3. Prompts: "You're setting up a project under MyProduct (recommended)"
4. Creates `.claude/organizational-level.json` with parent references
5. Copies only project-level role guides (not product/system/company roles)
6. Records hierarchy_path: ["company", "product", "project"]

### Role Switching

```bash
# Show current role
/show-role
# Output: Current role: software-engineer

# List available roles
/list-roles
# Shows all role guides in .claude/role-guides/

# Switch role
/set-role qa-engineer
# Loads qa-engineer guide and referenced docs
```

### Hierarchy Validation

```bash
# Validate entire setup including hierarchy
/validate-setup

# Migrate old format to new hierarchy-aware format
/validate-setup --migrate-hierarchy

# Skip hierarchy checks (for standalone setups)
/validate-setup --skip-hierarchy
```

## Testing

### Unit Tests

**tests/test-hierarchy-detector.sh** (58 tests)
- Tests all hierarchy detection functions
- Validates parent-child relationships
- Tests invalid relationship rejection
- Tests edge cases and error handling

**Run:**
```bash
bash tests/test-hierarchy-detector.sh
```

### Integration Tests

**tests/test-hierarchical-initialization.sh** (73 tests)
- Tests complete initialization workflows
- Tests company → product → project sequences
- Validates organizational-level.json at each level
- Tests backward compatibility
- Tests error detection and validation

**Run:**
```bash
bash tests/test-hierarchical-initialization.sh
```

### Test Fixtures

**tests/fixtures/hierarchical/**
- Three-level hierarchy: company → product → project
- Invalid hierarchy: project → system (for error testing)
- Proper organizational-level.json at each level

## For Claude: Working with this Codebase

### Understanding User Context

When you start a session:
1. Check `.claude/preferences.json` for `current_role`
2. Read the corresponding role guide from `.claude/role-guides/`
3. Check `.claude/organizational-level.json` for hierarchy context
4. Understand the user's position in the organizational structure

### Respecting Organizational Boundaries

**Hierarchy-Aware Assistance:**
- Project-level users: Focus on implementation, code, testing
- Product-level users: Focus on coordination, roadmaps, features
- System-level users: Focus on architecture, platforms, infrastructure
- Company-level users: Focus on strategy, organization-wide decisions

**Role Guide Inheritance:**
- Users inherit role guides from parent levels
- Don't duplicate role guides that exist at parent levels
- Suggest appropriate level-specific roles based on hierarchy position

### Making Modifications

**When modifying hierarchy detection:**
- Update `scripts/hierarchy-detector.sh` for core logic
- Update `scripts/level-detector.sh` for user-facing prompts
- Update `scripts/template-manager.sh` for template application
- Update tests in `tests/test-hierarchy-detector.sh`
- Run both unit and integration tests

**When adding new organizational levels:**
- Update valid parent-child relationships in `is_valid_child_level()`
- Update role guide mapping in `get_role_guides_for_level()`
- Add test cases for new level
- Update documentation

**When modifying role guides:**
- Follow existing role guide patterns
- Update role-references.json if adding document references
- Test with /load-role-context

### Testing Changes

Always run tests after modifications:
```bash
# Unit tests
bash tests/test-hierarchy-detector.sh

# Integration tests
bash tests/test-hierarchical-initialization.sh

# Manual validation
/validate-setup
```

## Version History

### v1.6.0 (Current) - Selective Role Guide Initialization
- Interactive role guide selection during template setup
- Post-initialization role guide management (/add-role-guides command)
- Custom role guide placeholder generation
- Extended apply_template_with_mode() with 4th parameter for selection
- CUSTOM:name syntax for creating specialized role guides
- Comprehensive test suite with 23 tests for role guide selection
- Updated template-setup-assistant agent with Section 3.6
- Documentation updates across CHEATSHEET.md, init-org-template.md, CLAUDE.md

### v1.5.0 - Hierarchical Awareness
- Added hierarchy detection and validation
- Extended organizational-level.json schema with parent references
- Level-based role guide filtering
- Parent-aware initialization prompts
- Comprehensive hierarchy validation
- 131 tests (58 unit + 73 integration)

### v1.4.0 - Multi-Scope Configuration
- Project-level and global-level configuration support
- Scope-aware commands (--project, --global flags)

### v1.3.0 - Template System
- Organizational template structures
- Template application modes (minimal/standard/complete)
- Template-setup-assistant agent

### v1.2.0 - Role Management
- Role-based context loading
- Automatic SessionStart hooks
- Role switching and validation

### v1.1.0 - Initial Release
- Basic .claude directory structure
- Role guides
- Document references

## Migration Guide

### Upgrading to v1.5.0 (Hierarchical Awareness)

**Automatic Migration:**
- Old format organizational-level.json files continue to work
- New children automatically get extended format
- No manual intervention required for basic functionality

**Manual Migration (Recommended):**
```bash
# Migrate existing setups to extended format
/validate-setup --migrate-hierarchy
```

**What gets migrated:**
- Scans for parent `.claude` directories
- Adds parent_claude_dir, parent_level, is_root, hierarchy_path fields
- Validates parent-child relationships
- Creates backups before modification

## Support & Documentation

- **README.md**: Installation and quick start
- **CHEATSHEET.md**: Command reference
- **TEMPLATES.md**: Template guide
- **commands/*.md**: Individual command documentation

## License

Part of the role-context-manager plugin for Claude Code.
