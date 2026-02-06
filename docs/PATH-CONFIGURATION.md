# Path Configuration Guide

Complete guide to customizing directory structure in Role Context Manager.

## Table of Contents

- [Overview](#overview)
- [Configuration Hierarchy](#configuration-hierarchy)
- [Quick Start](#quick-start)
- [Environment Variables](#environment-variables)
- [Manifest Files](#manifest-files)
- [Configuration Scenarios](#configuration-scenarios)
- [Commands](#commands)
- [Migration Guide](#migration-guide)
- [Troubleshooting](#troubleshooting)
- [Technical Reference](#technical-reference)
- [Best Practices](#best-practices)
- [FAQ](#faq)

---

## Overview

Role Context Manager uses customizable directory names for its configuration storage. By default, it uses:

- `.claude` - Main configuration directory
- `role-guides` - Role guide storage (inside `.claude`)

### Why Customize Paths?

**Organization Branding**: Use `.myorg` instead of `.claude` to match internal tooling conventions.

**Avoiding Conflicts**: Separate multiple AI systems with different directory names (`.claude-rcm`, `.other-ai`).

**Naming Standards**: Comply with organizational directory naming requirements.

**Multi-System Support**: Run different Claude-based tools with isolated configurations.

### When to Use Custom Paths

- Your organization has branded directory naming conventions
- You're migrating from an existing setup with different names
- You need to avoid conflicts with other tools using `.claude`
- You want project-specific vs. global configurations

---

## Configuration Hierarchy

Path configuration uses a priority hierarchy, with higher priority sources overriding lower ones:

### Priority Order (Highest to Lowest)

1. **Environment Variables** (Highest Priority)
   - `RCM_CLAUDE_DIR_NAME` - Claude directory name
   - `RCM_ROLE_GUIDES_DIR` - Role guides directory name
   - `RCM_PATHS_MANIFEST` - Custom manifest location

2. **Local Manifest**
   - `./<claude-dir>/paths.json` in current directory or parents
   - Project-specific configuration

3. **Global Manifest**
   - `$HOME/<claude-dir>/paths.json`
   - User-wide configuration

4. **Default Values** (Lowest Priority)
   - `claude_dir_name`: `.claude`
   - `role_guides_dir`: `role-guides`

### How Resolution Works

```
User runs command
    ↓
Check environment variables (RCM_CLAUDE_DIR_NAME, etc.)
    ↓ (if not set)
Search for local paths.json (current dir → root)
    ↓ (if not found)
Check global paths.json ($HOME/.claude/paths.json)
    ↓ (if not found)
Use default values (.claude, role-guides)
```

### Example Priority

```bash
# Environment variable (highest priority)
export RCM_CLAUDE_DIR_NAME=".env-override"

# Local manifest (medium priority)
# ./.custom/paths.json contains: "claude_dir_name": ".custom"

# Global manifest (low priority)
# $HOME/.claude/paths.json contains: "claude_dir_name": ".global"

# Result: Uses ".env-override" from environment variable
```

---

## Quick Start

### Basic Usage

```bash
# Interactive configuration
/configure-paths

# Set custom directory names directly
/configure-paths --claude-dir=.myorg --role-guides-dir=guides

# Create global configuration
/configure-paths --global --claude-dir=.myorg

# Preview without applying
/configure-paths --dry-run --claude-dir=.custom
```

### Verify Configuration

```bash
# Show current paths
/show-paths

# Validate setup
/validate-setup
```

### Quick Migration

```bash
# Migrate existing .claude directories
/configure-paths --migrate .claude .myorg-rcm
```

---

## Environment Variables

### Available Variables

**`RCM_CLAUDE_DIR_NAME`**

Override the claude directory name.

```bash
export RCM_CLAUDE_DIR_NAME=".myorg"
```

**`RCM_ROLE_GUIDES_DIR`**

Override the role guides directory name.

```bash
export RCM_ROLE_GUIDES_DIR="guides"
```

**`RCM_PATHS_MANIFEST`**

Specify custom manifest file location.

```bash
export RCM_PATHS_MANIFEST="/path/to/custom/paths.json"
```

**`RCM_CACHE_ENABLED`**

Enable/disable configuration caching (default: true).

```bash
export RCM_CACHE_ENABLED="false"
```

### Usage Examples

**Temporary Override**:
```bash
# Use custom name for one command
RCM_CLAUDE_DIR_NAME=".temp" /validate-setup
```

**Session Override**:
```bash
# Set for entire session
export RCM_CLAUDE_DIR_NAME=".myorg"
/validate-setup
/set-role engineer
```

**Permanent Override**:
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export RCM_CLAUDE_DIR_NAME=".myorg"' >> ~/.bashrc
```

---

## Manifest Files

### File Format

Path configuration is stored in `paths.json` using JSON format:

```json
{
  "claude_dir_name": ".myorg-rcm",
  "role_guides_dir": "role-guides",
  "version": "1.0.0",
  "description": "Path configuration for Role Context Manager"
}
```

### Schema

**Required Fields**: None (all fields are optional with defaults)

**Optional Fields**:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `claude_dir_name` | string | `.claude` | Claude directory name |
| `role_guides_dir` | string | `role-guides` | Role guides directory |
| `version` | string | - | Schema version (semver) |
| `description` | string | - | Configuration description |
| `project_root` | string | - | Project root identifier |
| `additional_config_dirs` | array | - | Additional config directories |

### Validation Rules

All directory names must:
- Be 1-255 characters long
- Match pattern: `^[a-zA-Z0-9._-]+$`
- Not contain `..` (path traversal)
- Not contain `/` or `\` (path separators)
- Not contain null bytes
- Not be whitespace-only

### File Locations

**Local Configuration**:
```
./
└── .claude/
    └── paths.json
```

**Global Configuration**:
```
$HOME/
└── .claude/
    └── paths.json
```

### Creating Manually

```bash
# Create local manifest
mkdir -p ./.myorg
cat > ./.myorg/paths.json << 'EOF'
{
  "claude_dir_name": ".myorg",
  "role_guides_dir": "guides",
  "version": "1.0.0",
  "description": "Custom organization configuration"
}
EOF
```

---

## Configuration Scenarios

### Scenario A: Default Configuration

Use defaults with no customization.

**Setup**: None required

**Configuration**:
- Claude directory: `.claude`
- Role guides: `role-guides`
- No manifest file needed

**Usage**:
```bash
# All commands use defaults
/validate-setup
/set-role engineer
/load-role-context
```

**Directory Structure**:
```
project/
└── .claude/
    ├── config.json
    └── role-guides/
        └── engineer-guide.md
```

---

### Scenario B: Environment Variable Override

Temporary override using environment variables.

**Setup**:
```bash
export RCM_CLAUDE_DIR_NAME=".myorg"
export RCM_ROLE_GUIDES_DIR="guides"
```

**Configuration**:
- Source: Environment variables
- Scope: Current shell session
- Priority: Highest

**Usage**:
```bash
# All commands use environment variable values
/validate-setup    # Uses .myorg/
/set-role engineer # Updates .myorg/config.json
```

**When to Use**:
- Testing different configurations
- Temporary overrides for specific tasks
- CI/CD pipelines with dynamic naming

---

### Scenario C: Manifest File Configuration

Persistent configuration using manifest files.

**Setup**:
```bash
# Create local configuration
/configure-paths --local --claude-dir=.custom --role-guides-dir=my-guides

# Or create global configuration
/configure-paths --global --claude-dir=.custom --role-guides-dir=my-guides
```

**Configuration**:
- Source: `paths.json` manifest
- Scope: Local (project) or Global (user)
- Priority: Medium (local) or Low (global)

**Result**:
```json
{
  "claude_dir_name": ".custom",
  "role_guides_dir": "my-guides",
  "version": "1.0.0"
}
```

**When to Use**:
- Permanent project-specific naming
- Organizational standards
- Shared team configurations

---

### Scenario D: Hybrid Configuration

Combine environment variables with manifest files.

**Setup**:
```bash
# Create global manifest
/configure-paths --global --claude-dir=.myorg --role-guides-dir=guides

# Override claude dir with environment variable
export RCM_CLAUDE_DIR_NAME=".dev"
# (role-guides-dir still uses value from manifest)
```

**Configuration**:
- `claude_dir_name`: `.dev` (from environment)
- `role_guides_dir`: `guides` (from manifest)

**Usage**:
```bash
# Validates .dev/config.json
# Uses guides/ for role guides
/validate-setup
```

**When to Use**:
- Development vs. production environments
- Override specific settings without changing manifest
- Testing alternate configurations

---

### Scenario E: Hierarchical Configuration

Local configuration overrides global configuration.

**Setup**:
```bash
# Create global configuration (applies everywhere)
/configure-paths --global --claude-dir=.global-org

# Create local configuration in specific project (overrides global)
cd /path/to/project
/configure-paths --local --claude-dir=.project-custom
```

**Configuration**:
```
$HOME/.global-org/paths.json (global)
/path/to/project/.project-custom/paths.json (local)
```

**Usage**:
```bash
# In /path/to/project - uses .project-custom
/validate-setup

# In other projects - uses .global-org
cd ~/other-project
/validate-setup
```

**When to Use**:
- Organization-wide defaults with project exceptions
- Different naming for legacy vs. new projects
- Team vs. personal preferences

---

### Scenario F: Migration from Existing Setup

Migrate existing `.claude` directories to new naming.

**Setup**:
```bash
# Preview migration
/configure-paths --dry-run --migrate .claude .myorg-rcm

# Execute migration
/configure-paths --migrate .claude .myorg-rcm
```

**Migration Process**:
1. Validates old and new names
2. Finds all directories matching old name
3. Shows preview of changes
4. Renames directories
5. Creates/updates paths.json manifest

**Example Output**:
```
Searching for directories named '.claude'...
Found 2 directories to migrate:
  - ./.claude -> ./.myorg-rcm
  - ./project/.claude -> ./project/.myorg-rcm

Proceed with migration? (y/n): y
Renamed: ./.claude -> ./.myorg-rcm
Renamed: ./project/.claude -> ./project/.myorg-rcm

Created manifest: ./.myorg-rcm/paths.json
Migration complete!
```

**When to Use**:
- Changing organizational standards
- Rebranding internal tools
- Consolidating multiple configurations

---

## Commands

### /configure-paths

Configure custom directory names and migrate installations.

**Syntax**:
```bash
/configure-paths [OPTIONS]
```

**Options**:
- `--help` - Show help message
- `--dry-run` - Preview changes without applying
- `--global` - Create configuration in $HOME
- `--local` - Create configuration in current directory (default)
- `--claude-dir=NAME` - Set claude directory name
- `--role-guides-dir=NAME` - Set role guides directory name
- `--migrate OLD NEW` - Migrate directories from OLD to NEW name

**Examples**:
```bash
# Interactive mode
/configure-paths

# Direct configuration
/configure-paths --claude-dir=.myorg --role-guides-dir=guides

# Global configuration
/configure-paths --global --claude-dir=.myorg

# Preview changes
/configure-paths --dry-run --claude-dir=.test

# Migrate directories
/configure-paths --migrate .claude .myorg
```

### /show-paths

Display current path configuration.

**Syntax**:
```bash
/show-paths [OPTIONS]
```

**Options**:
- `--verbose` - Show detailed configuration including source
- `--json` - Output in JSON format

**Example Output**:
```
Path Configuration:
  Claude directory: .myorg
  Role guides directory: guides
  Source: Local manifest (./.myorg/paths.json)
```

---

## Migration Guide

### Pre-Migration Checklist

- [ ] Backup current configuration and role guides
- [ ] Test migration with `--dry-run` first
- [ ] Communicate changes to team members
- [ ] Update documentation and scripts referencing old paths
- [ ] Verify all projects are committed to version control

### Step-by-Step Migration

**Step 1: Test Migration**
```bash
# Preview what will change
/configure-paths --dry-run --migrate .claude .myorg
```

**Step 2: Execute Migration**
```bash
# Perform the migration
/configure-paths --migrate .claude .myorg
```

**Step 3: Verify Migration**
```bash
# Check new directory exists
ls -la .myorg/

# Verify configuration
/show-paths

# Test commands work
/validate-setup
/load-role-context --verbose
```

**Step 4: Update Team**
```bash
# Share configuration with team (if using version control)
git add .myorg/paths.json
git commit -m "Migrate to .myorg directory structure"
git push

# Or document the change
echo "RCM now uses .myorg directory" >> MIGRATION-NOTES.md
```

### Rollback Plan

If migration causes issues:

```bash
# Rename directories back
mv .myorg .claude

# Remove new manifest
rm .claude/paths.json

# Clear cache
export RCM_CACHE_ENABLED="false"

# Verify rollback
/validate-setup
```

### Migration Best Practices

1. **Use Dry Run**: Always test with `--dry-run` first
2. **Migrate Incrementally**: Start with one project, then expand
3. **Version Control**: Commit changes immediately after migration
4. **Document Changes**: Update README and team documentation
5. **Keep Backups**: Backup before migration, keep for 30 days

---

## Troubleshooting

### Common Issues

**Issue: Command can't find configuration**

```
Error: Configuration file not found: ./.claude/config.json
```

**Solution**:
```bash
# Check current paths
/show-paths

# Verify directory exists
ls -la .claude/  # or whatever name is shown

# Recreate directory if needed
mkdir -p .claude
/validate-setup --fix
```

---

**Issue: Wrong directory being used**

Commands using unexpected directory name.

**Solution**:
```bash
# Check configuration hierarchy
/show-paths --verbose

# Check for environment variable overrides
env | grep RCM_

# Clear environment variables if unwanted
unset RCM_CLAUDE_DIR_NAME
unset RCM_ROLE_GUIDES_DIR
```

---

**Issue: Migration fails with "target already exists"**

```
Error: Target directory already exists: ./.myorg
```

**Solution**:
```bash
# Check if target is from previous failed migration
ls -la .myorg/

# Remove if empty or backup and remove
mv .myorg .myorg.backup

# Retry migration
/configure-paths --migrate .claude .myorg
```

---

**Issue: Invalid path component error**

```
Error: Path component contains '..' (path traversal attempt)
```

**Solution**: Use valid directory names only:
```bash
# Invalid (security risks)
/configure-paths --claude-dir=../unsafe  # ❌ Path traversal
/configure-paths --claude-dir=/etc/evil  # ❌ Absolute path

# Valid
/configure-paths --claude-dir=.myorg     # ✅ Relative
/configure-paths --claude-dir=claude-ai  # ✅ Simple name
```

---

**Issue: Cache not updating**

Configuration changes not taking effect immediately.

**Solution**:
```bash
# Disable cache temporarily
export RCM_CACHE_ENABLED="false"

# Run command
/validate-setup

# Or wait 5 seconds for cache to expire
```

---

### Debugging Tips

**Enable Verbose Output**:
```bash
# For most commands
/validate-setup --verbose
/load-role-context --verbose

# For path configuration
/show-paths --verbose
```

**Check Configuration Sources**:
```bash
# Show all environment variables
env | grep RCM_

# Check local manifest
cat ./.claude/paths.json 2>/dev/null || echo "No local manifest"

# Check global manifest
cat $HOME/.claude/paths.json 2>/dev/null || echo "No global manifest"
```

**Validate Configuration**:
```bash
# Use schema validation
jq -e . ./.claude/paths.json  # Check JSON syntax

# Validate paths
/configure-paths --dry-run --claude-dir=.test
```

**Test Path Resolution**:
```bash
# Trace path resolution
bash -x /path/to/configure-paths --help 2>&1 | grep -i "path"
```

---

## Technical Reference

### Schema Version

Current schema version: `1.0.0`

**Format**: Semantic versioning (major.minor.patch)

**Compatibility**: All fields optional for backward compatibility

### Security Constraints

Directory names are validated to prevent:
- **Path Traversal**: No `..` sequences
- **Absolute Paths**: Must be relative names
- **Injection Attacks**: Alphanumeric, dots, hyphens, underscores only
- **Null Bytes**: Prevented at validation layer

**Validation Pattern**: `^[a-zA-Z0-9._-]+$`

**Examples**:
```bash
# Secure (passes validation)
.claude         ✅
.myorg-ai       ✅
claude_config   ✅
ai.workspace    ✅

# Insecure (fails validation)
../etc          ❌ Path traversal
/etc/config     ❌ Absolute path
my dir          ❌ Contains space
config;rm -rf   ❌ Shell metacharacter
```

### Cache Behavior

**Cache Duration**: 5 seconds

**Cache Invalidation**: Automatic after timeout

**Disable Caching**:
```bash
export RCM_CACHE_ENABLED="false"
```

**Cache Storage**: In-memory associative array (Bash 4.0+)

### File Operations

**Configuration Creation**:
- Creates directory: `<target>/<claude-dir>/`
- Creates file: `<target>/<claude-dir>/paths.json`
- Sets permissions: Inherits from parent directory

**Configuration Update**:
- Backs up existing: `paths.json.bak`
- Writes new manifest
- Validates before replacing

**Migration**:
- Renames directories atomically
- Updates manifest after rename
- Skips if target exists

### Dependencies

**Required**:
- Bash 4.0+ (associative arrays)
- Standard Unix utilities (mkdir, mv, cat)

**Optional**:
- `jq` (prettier JSON formatting)
- Falls back to basic JSON if unavailable

### Exit Codes

| Code | Meaning | Examples |
|------|---------|----------|
| 0 | Success | Configuration created, migration complete |
| 1 | Validation error | Invalid name, user cancelled |
| 2 | System error | Missing dependencies, permission denied |

---

## Best Practices

### Choosing Directory Names

**Use Descriptive Names**: `.myorg-rcm` instead of `.x`

**Follow Conventions**: Dot-prefix for hidden (`.myorg`) or no prefix for visible (`myorg-ai`)

**Keep It Short**: Shorter names easier to type and display

**Use Consistent Naming**: Same pattern across all projects

**Examples**:
```bash
# Good
.myorg-ai        # Clear, branded, concise
.acme-rcm        # Organization branded
claude-workspace # Visible, descriptive

# Avoid
.x               # Too short, unclear
.my-org-really-long-name  # Too long
.ClAuDe          # Mixed case inconsistent
```

### Configuration Scope

**Use Global For**: Organization-wide standards, personal defaults

**Use Local For**: Project-specific needs, legacy migrations, team conventions

**Use Environment For**: Temporary overrides, CI/CD, testing

### Version Control

**Do Commit**:
- `paths.json` manifests
- Documentation of path configuration

**Don't Commit**:
- Actual `.claude/` directory contents (usually)
- Environment variable configurations

**Example .gitignore**:
```gitignore
# Commit the manifest
!.myorg/paths.json

# Ignore other contents
.myorg/*
!.myorg/paths.json
```

### Team Collaboration

**Document Decisions**: Explain why custom paths were chosen

**Consistent Configuration**: Use same names across team projects

**Migration Communication**: Notify team before directory changes

**Version Control**: Share paths.json via repository

### Testing

**Always Dry Run**: Test with `--dry-run` before applying

**Validate After Changes**: Run `/validate-setup` after configuration

**Test Commands**: Verify all commands work with new paths

```bash
# Test workflow
/configure-paths --dry-run --claude-dir=.test
/configure-paths --claude-dir=.test
/validate-setup
/set-role engineer
/load-role-context
```

---

## FAQ

### Can I use spaces in directory names?

No. Directory names must match `^[a-zA-Z0-9._-]+$`. Use hyphens or underscores instead:
```bash
# Invalid
--claude-dir="my config"  ❌

# Valid
--claude-dir=my-config    ✅
--claude-dir=my_config    ✅
```

### What happens if I delete paths.json?

The system falls back to defaults (`.claude` and `role-guides`). Recreate with `/configure-paths` if needed.

### Can I have different paths per project?

Yes. Use local manifests:
```bash
cd project-a
/configure-paths --local --claude-dir=.project-a

cd ../project-b
/configure-paths --local --claude-dir=.project-b
```

### How do I share configuration with my team?

Commit `paths.json` to version control:
```bash
git add .myorg/paths.json
git commit -m "Add path configuration"
git push
```

Team members automatically use the configuration when they pull.

### Can I rename the paths.json file?

Yes, using `RCM_PATHS_MANIFEST`:
```bash
export RCM_PATHS_MANIFEST="/path/to/custom-config.json"
```

### Does this affect all RCM commands?

Yes. All commands use `path-config.sh` library and automatically respect configuration.

### Can I use absolute paths?

No. Security validation prevents absolute paths. Use relative directory names only.

### What if migration finds no directories?

Migration requires at least one directory to rename. Create the directory first:
```bash
mkdir .claude
/configure-paths --migrate .claude .myorg
```

### How do I revert to defaults?

Remove manifests and environment variables:
```bash
# Remove manifests
rm ./.claude/paths.json
rm $HOME/.claude/paths.json

# Clear environment variables
unset RCM_CLAUDE_DIR_NAME
unset RCM_ROLE_GUIDES_DIR
unset RCM_PATHS_MANIFEST
```

### Can I use this in CI/CD?

Yes. Use environment variables for dynamic configuration:
```bash
# In CI/CD pipeline
export RCM_CLAUDE_DIR_NAME=".ci-claude"
/configure-paths --global --claude-dir=.ci-claude
/validate-setup
```

### Is configuration backwards compatible?

Yes. All manifest fields are optional. Existing setups continue working with defaults.

### What's the performance impact of caching?

Minimal. Cache is in-memory and expires after 5 seconds. Disable if needed:
```bash
export RCM_CACHE_ENABLED="false"
```

---

## See Also

- `/configure-paths` - Configure paths command reference
- `/validate-setup` - Validate Role Context Manager setup
- `/load-role-context` - Load role-specific context
- `scripts/path-config.sh` - Path configuration library source
- `schemas/paths-v1.schema.json` - JSON schema definition
