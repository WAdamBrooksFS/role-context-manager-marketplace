# Role Context Manager Plugin - Architecture Documentation

## Overview

The **role-context-manager** is a Claude Code plugin that enables role-based context management with hierarchical organizational awareness and customizable directory structures. It provides a flexible, scalable system for managing documentation and context across complex organizational hierarchies while allowing full customization of directory naming conventions.

**Version:** 1.7.0
**Features:** Path Configuration System + Hierarchical Organizations (Integrated)

## Purpose

**For Users:**
- Automatically load relevant context based on their role (engineer, manager, designer, etc.)
- Navigate multi-level organizational structures (company → system → product → project)
- Inherit role guides and documentation from parent organizational levels
- Customize directory names to match organizational standards (`.myorg` instead of `.claude`)
- Maintain consistent context across team hierarchies
- Avoid conflicts with other tools through path customization

**For Claude:**
- Understand the user's current role and organizational context
- Access role-specific guides, templates, and documentation
- Respect organizational boundaries and hierarchies
- Provide role-appropriate assistance
- Work seamlessly with custom directory configurations

## Core Capabilities

### 1. Path Configuration System (v1.6.0)

Dynamic directory naming system allowing full customization of where configuration is stored.

**Customizable Directories:**
- **Claude Directory**: Default `.claude`, customizable to any name (`.myorg`, `.custom`, etc.)
- **Role Guides Directory**: Default `role-guides`, customizable to any name (`guides`, `roles`, etc.)

**Configuration Sources (Priority Order):**
1. **Environment Variables** (Highest)
   - `RCM_CLAUDE_DIR_NAME` - Override claude directory name
   - `RCM_ROLE_GUIDES_DIR` - Override role guides directory name
   - `RCM_PATHS_MANIFEST` - Custom manifest location
2. **Local Manifest** - `./<claude-dir>/paths.json` in current directory
3. **Global Manifest** - `$HOME/<claude-dir>/paths.json` user-wide config
4. **Default Values** (Lowest) - `.claude` and `role-guides`

**Security Constraints:**
- Alphanumeric characters, dots, hyphens, underscores only
- No path traversal sequences (`..`)
- No absolute paths
- No spaces or special characters
- Maximum length: 100 characters

**Use Cases:**
- **Organizational Branding**: Use `.myorg` to match internal tooling
- **Conflict Avoidance**: Separate multiple Claude-based tools
- **Naming Standards**: Comply with organizational directory requirements
- **Migration**: Rename existing directories without breaking functionality

### 2. Hierarchical Organizations (v1.5.0)

Multi-level organizational structure with parent-child relationships and inheritance.

**Organizational Levels:**
- **Company**: Top-level organization (executive roles: CTO, CPO, CISO, VPs)
- **System**: Major platforms/initiatives (management roles: Engineering Manager, Architect)
- **Product**: Feature groups (coordination roles: QA Manager, Designer, Product Manager)
- **Project**: Individual codebases (implementation roles: Software Engineer, DevOps, QA Engineer)

**Valid Parent-Child Relationships:**
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

**Key Features:**
- **Automatic Parent Detection**: Scans directory tree upward to find parent `.claude` (or custom) directories
- **Role Guide Inheritance**: Child levels inherit role guides from parents (avoids duplication)
- **Level-Based Filtering**: Templates apply only appropriate guides for current level
- **Parent-Child Validation**: Ensures valid organizational relationships

### 3. Combined System (v1.7.0 Integration)

Path configuration and hierarchical organizations work together seamlessly.

**Integration Points:**
- Hierarchy detection works with any configured directory names
- Parent detection uses path-config API to resolve directory names dynamically
- Role guide inheritance respects custom role-guides directory names
- Template application uses path-config for all file operations
- Validation checks both path configuration and hierarchy integrity

**Example: Hierarchy with Custom Paths**
```
/company-root/.myorg/           (company level, custom name)
  └─ organizational-level.json
  └─ guides/                     (custom role-guides name)
      └─ cto-guide.md

/company-root/product-a/.myorg/ (product level, custom name)
  └─ organizational-level.json  (records parent: /company-root/.myorg)
  └─ guides/
      └─ product-manager-guide.md
      # qa-manager inherited from parent

/company-root/product-a/project-x/.myorg/ (project level)
  └─ organizational-level.json  (records parent: ../product-a/.myorg)
  └─ guides/
      └─ software-engineer-guide.md
      # Inherits guides from parent and grandparent
```

## Architecture

### System Design

```
┌─────────────────────────────────────────────────────────────────┐
│                    Application Layer                            │
│  (Commands, Agents, User Interface)                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Orchestration Layer                           │
│  - role-manager.sh                                              │
│  - level-detector.sh                                            │
│  - template-manager.sh                                          │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌──────────────────────────┐   ┌──────────────────────────┐
│   Path Config System     │   │  Hierarchy System        │
│  (path-config.sh)        │   │ (hierarchy-detector.sh)  │
│                          │   │                          │
│  - Dynamic resolution    │   │  - Parent detection      │
│  - Config caching        │   │  - Level validation      │
│  - Security validation   │   │  - Inheritance logic     │
│  - API functions         │◄──┤  - Uses path-config API  │
└──────────────────────────┘   └──────────────────────────┘
              │                               │
              └───────────────┬───────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Storage Layer                                │
│  - Filesystem operations                                        │
│  - Configuration files (preferences.json, paths.json, etc.)    │
│  - Role guides and documents                                    │
└─────────────────────────────────────────────────────────────────┘
```

**Key Design Principles:**
1. **Single Source of Truth**: path-config.sh is the authority for directory resolution
2. **Dependency Flow**: hierarchy-detector.sh depends on and uses path-config.sh
3. **Dynamic Resolution**: All paths resolved at runtime, never hardcoded
4. **Backwards Compatible**: Default behavior identical to pre-v1.6.0 versions

### Core Scripts

#### **scripts/path-config.sh** (v1.6.0)

Foundation script providing path resolution API.

**Purpose:** Provide centralized, dynamic path resolution for all plugin components.

**Key Functions:**
```bash
# Primary API functions
get_claude_dir_name()          # Returns configured claude directory name
get_role_guides_dir()          # Returns configured role guides directory name
get_full_claude_path()         # Returns full path to claude directory
get_full_role_guides_path()    # Returns full path to role guides directory

# Configuration functions
load_path_config()             # Load and cache configuration
find_local_paths_manifest()    # Search for local paths.json
read_global_paths_manifest()   # Read global paths.json
resolve_path_config()          # Resolve from all sources

# Validation functions
validate_directory_name()      # Security and format validation
validate_paths_json()          # Validate paths.json file
```

**Configuration Resolution:**
```bash
# Priority order (highest to lowest):
1. RCM_CLAUDE_DIR_NAME environment variable
2. Local paths.json (current dir or parents)
3. Global paths.json ($HOME/.claude/paths.json)
4. Default value (".claude")
```

**Caching:**
- Configuration cached after first load for performance
- Cache invalidation on configuration change
- Cache shared across function calls within same script execution

**Security:**
- All directory names validated before use
- No path traversal allowed
- No spaces or special characters
- Alphanumeric + dot + hyphen + underscore only

**Performance:**
- Configuration load: <10ms
- Cached resolution: <1ms
- Minimal overhead in tight loops

#### **scripts/hierarchy-detector.sh** (v1.5.0, refactored v1.7.0)

Core hierarchy detection and validation engine, fully integrated with path-config.sh.

**Purpose:** Detect organizational hierarchies, validate relationships, manage inheritance.

**Key Refactoring (v1.7.0):**
- **CRITICAL**: All hardcoded `.claude` references replaced with `get_claude_dir_name()` calls
- **CRITICAL**: All hardcoded `role-guides` references replaced with `get_role_guides_dir()` calls
- Sources path-config.sh at initialization
- Uses path-config API for all directory operations

**Key Functions:**
```bash
# Parent detection (uses path-config)
find_parent_claude_dirs()      # Find all parent directories (any name)
get_nearest_parent()           # Get immediate parent
read_level_from_claude_dir()   # Read level from any named directory

# Hierarchy operations
build_hierarchy_path()         # Construct full hierarchy array
is_valid_child_level()         # Validate parent-child relationships
get_parent_level()             # Get parent's organizational level

# Role guide management
get_role_guides_for_level()    # Get appropriate guides for level
should_include_role_guide()    # Check if guide should be copied (inheritance filter)
filter_role_guides()           # Filter guides based on level and parent

# Persistence
save_level_with_hierarchy()    # Save organizational-level.json with parent info
```

**Integration Example:**
```bash
# Before refactoring (v1.5.0 - hardcoded):
if [[ -d "$dir/.claude" ]]; then
    parent_dirs+=("$dir/.claude")
fi

# After refactoring (v1.7.0 - dynamic):
source "$SCRIPT_DIR/path-config.sh"
load_path_config
local claude_dir_name
claude_dir_name="$(get_claude_dir_name)"
if [[ -d "$dir/$claude_dir_name" ]]; then
    parent_dirs+=("$dir/$claude_dir_name")
fi
```

**Inheritance Logic:**
```bash
# Company-level roles: CTO, CPO, CISO, VP-*
# System-level roles: Engineering Manager, Platform Engineer, Architects
# Product-level roles: QA Manager, Product Manager, Designers
# Project-level roles: Software Engineer, DevOps, QA Engineer, SRE

# When applying template at project level:
# - Includes only project-level guides
# - Skips product, system, company guides (inherited from parents)
# - Shows feedback: "Skipped: qa-manager-guide.md (inherited from parent)"
```

#### **scripts/role-manager.sh** (v1.7.0)

Role and context management with path-config integration.

**Purpose:** Manage user roles, load context, customize document references.

**Key Functions:**
```bash
# Role management (uses path-config)
cmd_set_role()                 # Set user role
cmd_show_role()                # Display current role
cmd_list_roles()               # List available roles
cmd_load_role_context()        # Load role guide + documents into session

# Document customization
cmd_update_role_docs()         # Add/remove document references
cmd_init_role_docs()           # Initialize from role guide defaults

# Hierarchy integration (NEW v1.5.0, refactored v1.7.0)
cmd_add_role_guides()          # Add guides with inheritance filtering
```

**Path-Config Integration:**
- All file operations use `get_full_role_guides_path()`
- Role guide discovery uses `get_role_guides_dir()`
- Configuration stored in `$(get_full_claude_path)/preferences.json`
- Works with any configured directory names

#### **scripts/level-detector.sh** (v1.7.0)

Organizational level detection with parent-aware prompting.

**Purpose:** Detect or prompt for organizational level with hierarchy context.

**Key Features:**
- Automatic detection via heuristics (directory structure, file presence)
- Parent-aware prompting: "Recommended: project (child of product)"
- Level validation against parent (uses hierarchy-detector.sh)
- Extended format writing via `save_level_with_hierarchy()`
- Uses path-config for all directory operations

**Detection Strategies:**
1. Check explicit marker (`organizational-level.json`)
2. Detect parent context (hierarchy-detector.sh)
3. Heuristic analysis (files, structure)
4. User prompt with recommendations

#### **scripts/template-manager.sh** (v1.7.0)

Template discovery, application, and synchronization with level-based filtering.

**Purpose:** Apply and manage organizational templates with hierarchy awareness.

**Key Functions:**
```bash
# Template operations (uses path-config)
apply_template()               # Apply template with level filtering
sync_template()                # Sync updates preserving customizations
validate_template()            # Validate template structure

# Hierarchy integration (NEW v1.5.0, refactored v1.7.0)
get_role_guides_for_level()    # Get guides for specific level
filter_role_guides_for_level() # Filter guides based on parent
should_include_role_guide()    # Inheritance check
```

**Level-Based Filtering:**
- Detects parent organizational level before template application
- Filters role guides to current level only
- Skips parent-level guides (inherited)
- Provides feedback: "Skipped: <guide> (inherited from parent <level>)"

### Agents

#### **agents/template-setup-assistant/**

Guides template initialization with organizational and path context detection.

**Workflow (v1.7.0):**
1. Analyze current directory structure
2. Load available templates
3. **Detect path configuration** - Check for custom paths
4. **Detect organizational context** - Check for parent directories
5. Present template options with recommendations
6. Select application mode (minimal/standard/complete)
7. Apply template with level-based filtering and path configuration
8. Record configuration in appropriate files

**Parent Detection Logic:**
- Uses path-config API to find parent directories (any name)
- If parent found: Shows parent level/name, validates relationship
- If no parent: Asks if root or part of existing organization
- Validates parent-child relationships before setup

#### **agents/framework-validator/**

Validates plugin setup, path configuration, and hierarchy integrity.

**Validation Checks (v1.7.0):**
- **Path Configuration**:
  - paths.json is valid JSON
  - Directory names follow security constraints
  - Configured directories exist
  - No path traversal attempts
- **Hierarchy Integrity**:
  - Parent paths are valid
  - Parent-child relationships are valid
  - Role guide inheritance is working
  - No orphaned configurations
- **Combined System**:
  - Path config and hierarchy work together
  - No conflicts between systems
  - All references resolve correctly

#### **agents/document-generator/**

Generates organizational documents from templates.

**Path Integration:** Uses path-config API to determine where to place generated documents.

#### **agents/role-guide-generator/**

Creates custom role guides following established patterns.

**Path Integration:** Uses path-config API to place guides in correct directory.

### Commands

#### **/init-org-template [--global|--project]**

Initialize organizational template structure.

**Path Configuration:**
- Automatically detects custom paths if configured
- Applies template to configured directory name
- Creates paths.json if custom paths specified

**Hierarchy Integration:**
- Auto-detects parent directories (any name)
- Validates parent-child relationships
- Applies level-based filtering

#### **/set-org-level [level]**

Set or update organizational level.

**Hierarchy Integration (v1.5.0):**
- Detects parent automatically (using path-config)
- Recommends level based on parent
- Validates against parent level
- Saves extended format with parent info

#### **/configure-paths [OPTIONS]**

Configure custom directory names.

**Options:**
- `--claude-dir=NAME` - Set claude directory name
- `--role-guides-dir=NAME` - Set role guides directory name
- `--global` - Create global configuration
- `--local` - Create local configuration (default)
- `--migrate OLD NEW` - Migrate directories (preserves hierarchy)
- `--dry-run` - Preview changes

**Hierarchy Preservation:**
When migrating directories, preserves parent references in organizational-level.json.

#### **/add-role-guides [guide1] [guide2] [CUSTOM:name]** (v1.5.0)

Add role guides with hierarchy-aware filtering.

**Features:**
- Uses path-config to determine target directory
- Detects parent level for inheritance filtering
- Skips guides inherited from parent
- Creates custom placeholder guides
- Reports filtering decisions

#### **/validate-setup [--quick|--fix|--silent|--quiet]**

Validate setup with combined system checks.

**Validation Coverage (v1.7.0):**
- Path configuration validity
- Directory structure integrity
- Hierarchy relationships
- Role guide inheritance
- Configuration consistency

### Configuration Files

#### **paths.json** (NEW v1.6.0)

Path configuration manifest.

**Location:** `./<claude-dir>/paths.json` or `$HOME/<claude-dir>/paths.json`

**Format:**
```json
{
  "version": "1.0",
  "claude_dir_name": ".myorg",
  "role_guides_dir": "guides"
}
```

**Fields:**
- `version` (optional): Schema version
- `claude_dir_name` (required): Claude directory name
- `role_guides_dir` (required): Role guides directory name

#### **organizational-level.json** (Enhanced v1.5.0)

Organizational level and hierarchy information.

**Extended Format (v1.5.0+):**
```json
{
  "level": "project",
  "level_name": "my-project",
  "parent_claude_dir": "/parent-product/.myorg",
  "parent_level": "product",
  "hierarchy_path": ["company", "system", "product", "project"]
}
```

**Fields:**
- `level` (required): Current organizational level
- `level_name` (optional): Display name
- `parent_claude_dir` (optional): Path to parent directory
- `parent_level` (optional): Parent's organizational level
- `hierarchy_path` (optional): Full hierarchy from root

#### **preferences.json**

User preferences and role configuration.

**Format:**
```json
{
  "user_role": "software-engineer",
  "auto_update_templates": true,
  "applied_template": {
    "id": "software-org",
    "version": "1.0.0",
    "applied_date": "2026-01-05"
  }
}
```

**Location:** Determined by path-config, typically `<claude-dir>/preferences.json`

#### **role-references.json**

Team-wide default document references per role.

**Location:** `<claude-dir>/role-references.json` (uses path-config)

#### **role-references.local.json**

User-specific document customizations (gitignored).

**Location:** `<claude-dir>/role-references.local.json` (uses path-config)

## Integration Workflows

### Workflow 1: Custom Paths with Hierarchy

Setup hierarchical organization with custom directory names:

```bash
# Step 1: Configure custom paths globally
/configure-paths --global --claude-dir=.myorg --role-guides-dir=guides

# Step 2: Initialize company level
cd /company-root
/init-org-template --project
# Creates: .myorg/ with guides/
/set-org-level company
/set-role cto

# Step 3: Initialize product level (child)
cd /company-root/product-a
/init-org-template
# Detects parent: /company-root/.myorg (company level)
# Inherits path configuration
# Creates: .myorg/ with guides/
/set-org-level product
/add-role-guides product-manager-guide.md
# Only adds product-level guides

# Step 4: Initialize project level (grandchild)
cd /company-root/product-a/project-x
/init-org-template
# Detects parent: ../product-a/.myorg (product level)
# Creates: .myorg/ with guides/
/set-org-level project
/add-role-guides software-engineer-guide.md
# Inherits guides from product and company levels
```

**Result:** Three-level hierarchy with consistent `.myorg` naming throughout.

### Workflow 2: Migrating Hierarchy to Custom Paths

Migrate existing hierarchy to new directory names:

```bash
# Step 1: Configure new paths
/configure-paths --global --claude-dir=.neworg

# Step 2: Migrate each level (top to bottom)
cd /company-root
/configure-paths --migrate .claude .neworg
# Migrates directory, updates internal references

cd /company-root/product-a
/configure-paths --migrate .claude .neworg
# Migrates directory, updates parent references to use new name

cd /company-root/product-a/project-x
/configure-paths --migrate .claude .neworg
# Migrates directory, maintains hierarchy chain with new names
```

**Result:** Entire hierarchy migrated with preserved relationships.

### Workflow 3: Mixed Path Configuration

Parent and child use different directory names:

```bash
# Parent with default paths
cd /parent-org
/init-org-template
# Creates: .claude/

# Child with custom paths
cd /parent-org/child-project
/configure-paths --local --claude-dir=.custom
/init-org-template
# Creates: .custom/
# Detects parent at: ../.claude (different name)
# Still maintains hierarchy relationship
```

**Result:** Hierarchy detection works across different directory names.

## Performance Characteristics

### Path Configuration Overhead

- **Configuration Load**: <10ms (first call)
- **Cached Resolution**: <1ms (subsequent calls)
- **Validation**: <5ms per directory name
- **Cache Memory**: <1KB

### Hierarchy Detection Overhead

- **Parent Scan**: <50ms per directory level
- **5-Level Hierarchy**: <100ms total (with path-config)
- **Validation**: <20ms per relationship check
- **Cache Effectiveness**: 90%+ hit rate in typical workflows

### Combined System Overhead

- **Total Overhead**: <200ms for full hierarchy detection with custom paths
- **Performance Target**: Met (requirement was <200ms)
- **Scalability**: Linear with hierarchy depth

## Security Considerations

### Path Configuration Security

**Constraints:**
- Only safe characters allowed (alphanumeric, dot, hyphen, underscore)
- No path traversal (`..` sequences blocked)
- No absolute paths allowed
- Maximum length: 100 characters
- All validation before any filesystem operations

**Threat Prevention:**
- **Path Traversal**: Blocked by character whitelist
- **Command Injection**: No shell expansion in directory names
- **Symlink Attacks**: Validated before following
- **Directory Escape**: Relative path only, validated against parent

### Hierarchy Security

**Validation:**
- Parent paths must exist before creating child
- Parent-child relationships validated before linking
- No circular references allowed
- No orphaned configurations

**Integrity:**
- Parent references stored as absolute paths (resolved safely)
- Validation on every hierarchy operation
- Graceful degradation if parent removed

## Backward Compatibility

### v1.6.0 Compatibility (Path Config)

**Default Behavior:**
- Without configuration, uses `.claude` and `role-guides`
- Identical behavior to pre-v1.6.0 versions
- No migration required for existing setups

**Migration:**
- Opt-in via `/configure-paths` command
- Can migrate incrementally
- No breaking changes

### v1.5.0 Compatibility (Hierarchy)

**Default Behavior:**
- Works as single-level setup if no parent detected
- No forced hierarchy adoption
- Existing setups unaffected

**Integration:**
- Parent detection is automatic but optional
- Hierarchy features activate only when parent found
- Backward compatible with single-level setups

### v1.7.0 Integration

**Combined Compatibility:**
- Both systems are optional, independent enhancements
- Can use path-config without hierarchy
- Can use hierarchy without custom paths
- Can use both together seamlessly
- Default behavior unchanged from v1.0.0

## Testing Strategy

### Unit Tests

- Path resolution functions
- Hierarchy detection functions
- Validation functions
- Configuration parsing

### Integration Tests

- Path-config + hierarchy detection
- Template application with custom paths
- Role guide inheritance with custom paths
- Migration with hierarchy preservation

### Performance Tests

- Path resolution benchmarks
- Hierarchy detection benchmarks
- Combined system overhead
- Cache effectiveness

### End-to-End Tests

- Full hierarchy setup with custom paths
- Migration scenarios
- Mixed configuration scenarios
- Backward compatibility validation

## Troubleshooting

### Common Issues

**Issue: Hierarchy not detected with custom paths**
- **Cause**: Parent directory has different name than configured
- **Solution**: Path-config should auto-detect. Run `/validate-setup` to check.

**Issue: Role guides duplicated across levels**
- **Cause**: Inheritance filtering not working
- **Solution**: Verify `organizational-level.json` has correct parent information.

**Issue: Migration broke hierarchy references**
- **Cause**: Parent paths not updated during migration
- **Solution**: Re-run migration or manually update `parent_claude_dir` in `organizational-level.json`.

**Issue: Custom paths not recognized**
- **Cause**: Configuration not loaded or cached incorrectly
- **Solution**: Verify `paths.json` syntax, restart session to clear cache.

### Diagnostic Commands

```bash
# Check path configuration
/show-paths --verbose

# Validate entire setup
/validate-setup

# Show organizational context
/show-role-context

# Test hierarchy detection
bash scripts/hierarchy-detector.sh find-parents

# Test path resolution
bash scripts/path-config.sh get-claude-dir-name
```

## Future Enhancements

### Planned Features

- **Multi-root support**: Multiple company-level organizations
- **Cross-hierarchy references**: Link related organizations
- **Dynamic path templates**: Rules for auto-generating directory names
- **Enhanced caching**: Persistent cache across sessions
- **Hierarchy visualization**: ASCII art hierarchy display

### Under Consideration

- **Remote configuration**: Cloud-synced path configurations
- **Namespace support**: Multiple isolated configurations
- **Audit logging**: Track configuration changes
- **Rollback support**: Undo configuration changes

## References

### Related Documentation

- [Path Configuration Guide](docs/PATH-CONFIGURATION.md)
- [Hierarchical Organizations Guide](docs/HIERARCHICAL-ORGANIZATIONS.md)
- [Combined Features Guide](docs/COMBINED-FEATURES.md)
- [Migration Guide](docs/MIGRATION-TO-PATH-CONFIG.md)

### Version History

- **v1.0.0**: Initial release - Basic role context management
- **v1.1.0**: Template system - Template discovery and agents
- **v1.2.0**: SessionStart hooks - Automatic validation
- **v1.3.0**: Multi-scope configuration - Global and project configs
- **v1.5.0**: Hierarchical organizations - Parent-child relationships (workflow-enhancements branch)
- **v1.6.0**: Path configuration - Customizable directory names (master branch)
- **v1.7.0**: Integrated release - Combined path-config + hierarchy systems

## Conclusion

The Role Context Manager v1.7.0 combines two powerful systems:

1. **Path Configuration System**: Full control over directory naming
2. **Hierarchical Organizations**: Multi-level organizational structures with inheritance

These systems work together seamlessly, providing maximum flexibility for organizing documentation and context across complex, real-world organizational structures. The integration maintains backward compatibility while adding significant new capabilities for advanced use cases.

**Key Benefits:**
- Flexible directory naming for organizational standards
- Multi-level organizational support
- Role guide inheritance to avoid duplication
- Automatic parent detection
- Security-first design
- Backward compatible with all previous versions
- Performance optimized (<200ms overhead)

---

**Plugin Version:** 1.7.0
**Generated:** 2026-02-06
**Status:** Integrated and Released
