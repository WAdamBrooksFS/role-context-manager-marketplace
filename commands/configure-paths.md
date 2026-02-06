# /configure-paths

Configure custom directory names for Role Context Manager and migrate existing installations.

## Purpose

This command allows you to customize the directory structure used by the Role Context Manager system. By default, the system uses `.claude` as the main directory name and `role-guides` for storing role guide files. Organizations may need to:

- Use branded directory names (e.g., `.myorg-rcm` instead of `.claude`)
- Follow internal naming conventions
- Migrate existing installations to new naming standards
- Support multiple Claude-based systems with different directory names

The command provides both interactive and direct configuration modes, along with safe directory migration capabilities.

## Usage

```bash
/configure-paths [OPTIONS]
/configure-paths --claude-dir=NAME --role-guides-dir=NAME
/configure-paths --migrate OLD NEW
```

### Options

- `--help`: Show help message and exit
- `--dry-run`: Preview changes without applying them
- `--global`: Create configuration in `$HOME/.claude/paths.json` (or custom name)
- `--local`: Create configuration in `./.claude/paths.json` (default)
- `--claude-dir=NAME`: Set the claude directory name (e.g., `.myorg`, `.custom-rcm`)
- `--role-guides-dir=NAME`: Set the role guides directory name (e.g., `guides`, `role-docs`)
- `--migrate OLD NEW`: Migrate existing directories from OLD name to NEW name

### Examples

```bash
# Interactive mode - prompts for all configuration
/configure-paths

# Set custom directory names directly
/configure-paths --claude-dir=.myorg --role-guides-dir=my-guides

# Create global configuration (in $HOME)
/configure-paths --global --claude-dir=.myorg-rcm

# Preview changes without applying (dry run)
/configure-paths --dry-run --claude-dir=.custom

# Set only claude directory (uses default for role-guides)
/configure-paths --claude-dir=.myorg

# Migrate existing .claude directories to new name
/configure-paths --migrate .claude .myorg-rcm

# Preview migration without executing
/configure-paths --dry-run --migrate .claude .myorg-rcm

# Migrate and use global configuration
/configure-paths --global --migrate .claude .myorg
```

## Behavior

### Configuration Scope

The command supports two configuration scopes:

**Local Configuration** (default):
- Creates `.claude/paths.json` (or custom name) in current directory
- Takes precedence over global configuration
- Used for project-specific naming conventions

**Global Configuration** (`--global` flag):
- Creates `$HOME/.claude/paths.json` (or custom name)
- Used across all projects without local configuration
- Ideal for user-wide or organization-wide standards

### Interactive Mode

When run without configuration arguments, the command enters interactive mode:

1. Prompts for claude directory name (default: `.claude`)
2. Prompts for role guides directory name (default: `role-guides`)
3. Asks whether to create global or local configuration
4. Shows preview of configuration
5. Requests confirmation before applying

Interactive mode is user-friendly and provides clear explanations at each step.

### Direct Configuration Mode

When `--claude-dir` is provided, the command operates in direct mode:

- No interactive prompts
- Validates inputs immediately
- Shows configuration preview
- Creates or updates `paths.json` manifest

This mode is ideal for scripting and automation.

### Migration Mode

The `--migrate` option safely renames existing directories:

**Migration Process:**

1. **Validation**: Validates both old and new directory names
2. **Discovery**: Searches for all directories matching the old name
3. **Preview**: Shows all directories that will be renamed
4. **Confirmation**: Prompts for confirmation (unless `--dry-run`)
5. **Execution**: Renames each directory
6. **Configuration**: Creates or updates `paths.json` with new name

**Safety Features:**

- Validates directory names before any changes
- Shows preview of all changes before execution
- Skips directories if target already exists
- Supports `--dry-run` to preview without executing
- Creates backups of manifest files before updating

**Example Migration Output:**

```
Searching for directories named '.claude'...
Found 3 directories to migrate:
  - ./.claude -> ./.myorg-rcm
  - ./projects/api/.claude -> ./projects/api/.myorg-rcm
  - ./projects/web/.claude -> ./projects/web/.myorg-rcm

Proceed with migration? (y/n): y
Renamed: ./.claude -> ./.myorg-rcm
Renamed: ./projects/api/.claude -> ./projects/api/.myorg-rcm
Renamed: ./projects/web/.claude -> ./projects/web/.myorg-rcm

Updating configuration...
Created manifest: ./.myorg-rcm/paths.json
Configuration:
  claude_dir_name: .myorg-rcm
  role_guides_dir: role-guides

Migration complete!
```

### Dry Run Mode

The `--dry-run` flag previews changes without applying them:

```bash
/configure-paths --dry-run --claude-dir=.custom
```

Output:
```
=== Configuration Preview ===
Claude directory: .custom
Role guides directory: role-guides
Scope: Local (./.custom/paths.json)

[DRY RUN] Would create directory: ./.custom
[DRY RUN] Would create manifest: ./.custom/paths.json
[DRY RUN] Configuration:
  claude_dir_name: .custom
  role_guides_dir: role-guides
```

Dry run mode works with both configuration and migration operations.

## Validation

The command validates all directory names before making changes:

**Validation Rules:**

- Cannot be empty
- Cannot contain path traversal (`..`)
- Cannot start with `/` (must be relative)
- Cannot be whitespace-only
- Cannot contain null bytes

**Invalid Examples:**

```bash
# Will fail - contains path traversal
/configure-paths --claude-dir=../myorg

# Will fail - absolute path
/configure-paths --claude-dir=/etc/myorg

# Will fail - empty name
/configure-paths --claude-dir=

# Will fail - whitespace only
/configure-paths --claude-dir="   "
```

**Valid Examples:**

```bash
# All valid directory names
/configure-paths --claude-dir=.myorg
/configure-paths --claude-dir=.custom-rcm
/configure-paths --claude-dir=rcm
/configure-paths --claude-dir=.ai-config
```

## Configuration File Format

The command creates a `paths.json` manifest file with this structure:

```json
{
  "claude_dir_name": ".myorg-rcm",
  "role_guides_dir": "role-guides",
  "version": "1.0.0",
  "description": "Path configuration for Role Context Manager"
}
```

This manifest is automatically read by all Role Context Manager commands through the `path-config.sh` library.

## Error Handling

The command handles errors gracefully:

**Validation Errors** (exit code 1):
- Invalid directory names
- Missing required arguments
- User cancellation

**System Errors** (exit code 2):
- Missing dependencies
- Permission issues
- File system errors

**Example Error Messages:**

```
Error: Path component contains '..' (path traversal attempt)
Error: --claude-dir is required in non-interactive mode
Error: Invalid role guides directory name: /absolute/path
```

## Use Cases

### Use Case 1: Organization Branding

Your organization uses `.myorg` for all internal tools:

```bash
# Configure organization-wide naming
/configure-paths --global --claude-dir=.myorg

# All projects will now use .myorg instead of .claude
```

### Use Case 2: Project-Specific Configuration

A specific project needs custom naming:

```bash
cd /path/to/project

# Configure project-specific naming
/configure-paths --local --claude-dir=.project-ai --role-guides-dir=guides

# Only this project uses these names
```

### Use Case 3: Migrating Existing Installation

Migrate all existing `.claude` directories to `.myorg-rcm`:

```bash
# Preview migration
/configure-paths --dry-run --migrate .claude .myorg-rcm

# Execute migration
/configure-paths --migrate .claude .myorg-rcm
```

### Use Case 4: Supporting Multiple AI Systems

You have both Claude and another AI system with conflicting directory names:

```bash
# Rename Claude directories to avoid conflicts
/configure-paths --migrate .claude .claude-rcm

# Now you can have both .claude-rcm and .other-ai directories
```

## Integration with Other Commands

After configuring custom paths, all Role Context Manager commands automatically use the new names:

```bash
# Configure custom paths
/configure-paths --claude-dir=.myorg

# All commands now use .myorg instead of .claude
/validate-setup        # Checks .myorg/config.json
/set-role engineer     # Updates .myorg/config.json
/load-role-context     # Loads from .myorg/role-guides/
/sync-template         # Syncs template to .myorg/role-guides/
```

No additional configuration is needed - the path configuration is automatically applied system-wide through the `path-config.sh` library.

## Configuration Precedence

The system determines directory names in this order:

1. **Environment variables** (highest priority):
   - `RCM_CLAUDE_DIR_NAME` - Override claude directory name
   - `RCM_ROLE_GUIDES_DIR` - Override role guides directory name
   - `RCM_PATHS_MANIFEST` - Override manifest file location

2. **Local manifest** (project-specific):
   - `./<claude-dir>/paths.json` in current directory or parent directories

3. **Global manifest** (user-wide):
   - `$HOME/<claude-dir>/paths.json`

4. **Default values** (lowest priority):
   - Claude directory: `.claude`
   - Role guides directory: `role-guides`

This hierarchy allows for flexible configuration at different levels.

## Implementation Details

This command is implemented as a bash script that uses the `path-config.sh` library for core functionality.

### Dependencies

**Required:**
- Bash 4.0+ (for associative arrays)
- `scripts/path-config.sh` (path configuration library)

**Optional:**
- `jq` (for cleaner JSON formatting)
- Falls back to basic JSON formatting if `jq` is not available

### Exit Codes

- `0`: Success (configuration created or migration completed)
- `1`: Validation error or user cancellation
- `2`: System error (missing dependencies, permissions)

### File Operations

The command performs these file operations:

**Configuration Creation:**
- Creates directory: `<target>/<claude-dir>/`
- Creates file: `<target>/<claude-dir>/paths.json`

**Configuration Update:**
- Backs up existing manifest: `paths.json.bak`
- Updates manifest with new values

**Migration:**
- Renames directories: `old-name` → `new-name`
- Updates or creates manifest in renamed directory

All operations respect the `--dry-run` flag and show preview output without modifying files.

## Examples by Scenario

### Scenario 1: First-Time Setup with Custom Names

```bash
# Interactive setup with custom names
/configure-paths
# Prompts:
#   Claude directory name [default: .claude]: .myorg
#   Role guides directory name [default: role-guides]: guides
#   Create global configuration in $HOME? (y/n): y
# Result: Creates $HOME/.myorg/paths.json
```

### Scenario 2: Migrating Existing Project

```bash
# You have a project with .claude directory
ls -la
# Output: .claude/ (contains config.json, role-guides/, etc.)

# Migrate to organizational naming
/configure-paths --migrate .claude .myorg-rcm

# Result: Directory renamed, paths.json created
ls -la
# Output: .myorg-rcm/ (contains all previous content + paths.json)
```

### Scenario 3: Testing Configuration Changes

```bash
# Preview configuration without applying
/configure-paths --dry-run --claude-dir=.test --role-guides-dir=test-guides

# Output shows what would happen
# No files are created or modified
```

### Scenario 4: Scripted Deployment

```bash
#!/bin/bash
# Deploy with custom configuration

# Set custom paths
/configure-paths --global --claude-dir=.myorg-ai --role-guides-dir=guides

# Validate setup
/validate-setup

# Set role for user
/set-role software-engineer

# Load role context
/load-role-context
```

## Next Steps

After running `/configure-paths`, you typically want to:

1. **Validate the configuration**:
   ```bash
   /validate-setup
   ```

2. **Create role guides** in the configured directory:
   ```bash
   mkdir -p ./<claude-dir>/<role-guides-dir>/
   ```

3. **Set your role**:
   ```bash
   /set-role <role-name>
   ```

4. **Test the setup**:
   ```bash
   /load-role-context --verbose
   ```

## See Also

- `scripts/path-config.sh` - Path configuration library documentation
- `/validate-setup` - Validate Role Context Manager setup
- `/load-role-context` - Load role-specific context
- `/set-role` - Set current user role
