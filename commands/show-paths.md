# /show-paths

Displays the current path configuration with source attribution for each value.

## Purpose

This command helps users understand and debug their path configuration by showing:
- Current values for all path configuration settings
- Where each value comes from (environment variable, manifest file, or default)
- Full paths when requested (verbose mode)

This is essential for troubleshooting configuration issues and understanding how the Role Context Manager resolves paths.

## Usage

```bash
/show-paths [OPTIONS]
```

### Options

- `--help`: Show help message with detailed usage information
- `--json`: Output in JSON format for machine-readable consumption
- `--verbose`: Include full paths, cache status, and environment variable details

### Examples

```bash
# Show current configuration (default human-readable format)
/show-paths

# Show configuration in JSON format
/show-paths --json

# Show configuration with verbose details
/show-paths --verbose
```

## Output Formats

### Default Output (Human-Readable)

```
Current Path Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  claude_dir_name:    .claude
    Source: default

  role_guides_dir:    role-guides
    Source: default

  manifest_path:      (none)
    Source: not found

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

When values are configured via environment variables or manifest:

```
Current Path Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  claude_dir_name:    .rcm
    Source: environment variable (RCM_CLAUDE_DIR_NAME)

  role_guides_dir:    roles
    Source: manifest (/home/user/project/.claude/paths.json)

  manifest_path:      /home/user/project/.claude/paths.json
    Source: auto-discovered

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### JSON Output (--json)

```json
{
  "claude_dir_name": {
    "value": ".claude",
    "source": "default"
  },
  "role_guides_dir": {
    "value": "role-guides",
    "source": "default"
  },
  "manifest_path": {
    "value": null,
    "source": "not_found"
  }
}
```

With configured values:

```json
{
  "claude_dir_name": {
    "value": ".rcm",
    "source": "environment"
  },
  "role_guides_dir": {
    "value": "roles",
    "source": "manifest"
  },
  "manifest_path": {
    "value": "/home/user/project/.claude/paths.json",
    "source": "found"
  }
}
```

### Verbose Output (--verbose)

Includes all default output plus additional details:

```
Current Path Configuration:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  claude_dir_name:    .claude
    Source: default
    Full path: /home/user/project/.claude

  role_guides_dir:    role-guides
    Source: default
    Full path: /home/user/project/.claude/role-guides

  manifest_path:      (none)
    Source: not found

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Additional Details:
  Working directory:  /home/user/project
  Cache enabled:      true
  Cache age:          2s

Environment Variables:
  RCM_CLAUDE_DIR_NAME:  (not set)
  RCM_ROLE_GUIDES_DIR:  (not set)
  RCM_PATHS_MANIFEST:   (not set)
```

## Configuration Sources

The command shows which source provides each configuration value, using this priority order:

### 1. Environment Variables (Highest Priority)

- `RCM_CLAUDE_DIR_NAME`: Override for claude directory name
- `RCM_ROLE_GUIDES_DIR`: Override for role guides directory name
- `RCM_PATHS_MANIFEST`: Override for manifest file location

When set, environment variables take precedence over all other sources.

### 2. Manifest File (Medium Priority)

The manifest file (`paths.json`) is searched in:
1. `.claude/paths.json` in current directory (and upward)
2. `~/.claude/paths.json` for global configuration

When found, manifest values are used unless overridden by environment variables.

### 3. Defaults (Lowest Priority)

If no environment variable or manifest value exists:
- `claude_dir_name`: `.claude`
- `role_guides_dir`: `role-guides`

## Use Cases

### Debugging Configuration Issues

When commands aren't finding expected paths:

```bash
/show-paths --verbose
```

This reveals:
- Which configuration source is active
- Full resolved paths
- Whether manifest file was found
- Current environment variable values

### Verifying Custom Configuration

After setting up custom paths:

```bash
# Set custom paths
export RCM_CLAUDE_DIR_NAME=".rcm"

# Verify they're being used
/show-paths
```

### Scripting and Automation

Use JSON output for programmatic access:

```bash
# Get configuration as JSON
/show-paths --json > config.json

# Parse with jq
/show-paths --json | jq -r '.claude_dir_name.value'
```

### Understanding Path Resolution

When working in different directories:

```bash
# Check configuration in project directory
cd ~/projects/myproject
/show-paths

# Compare with home directory
cd ~
/show-paths
```

This shows how manifest file discovery affects configuration.

## Implementation Details

This command invokes a bash script that uses the path-config library.

### Script Invocation Instructions

1. **Determine plugin directory path:**
   ```bash
   # Check if CLAUDE_PLUGIN_DIR is set (Claude Code sets this)
   if [ -n "$CLAUDE_PLUGIN_DIR" ]; then
       PLUGIN_DIR="$CLAUDE_PLUGIN_DIR"
   else
       # Fallback: Common installation location
       PLUGIN_DIR="$HOME/.claude/plugins/role-context-manager"
   fi
   ```

2. **Verify script exists:**
   ```bash
   SCRIPT_PATH="$PLUGIN_DIR/commands/show-paths.sh"
   if [ ! -f "$SCRIPT_PATH" ]; then
       echo "Error: show-paths.sh not found at $SCRIPT_PATH" >&2
       exit 2
   fi
   ```

3. **Invoke the script with arguments:**
   ```bash
   bash "$PLUGIN_DIR/commands/show-paths.sh" "$@"
   ```

   The script will:
   - Load path configuration using the path-config library
   - Detect the source for each configuration value
   - Format output based on provided flags
   - Return appropriate exit code

4. **Pass through all command arguments:**
   - `--help` → Display help message
   - `--json` → Output in JSON format
   - `--verbose` → Include additional details
   - No flags → Human-readable default format

### Exit Codes

- `0`: Success (configuration displayed)
- `1`: Invalid arguments (unknown option)
- `2`: System error (script not found, permissions issue)

### Example Invocation

When user runs `/show-paths --verbose`, execute:
```bash
bash "$CLAUDE_PLUGIN_DIR/commands/show-paths.sh" --verbose
```

## Related Commands

- `/load-role-context`: Uses path configuration to locate role guides
- `/validate-setup`: Verifies that path configuration is valid
- `/sync-template`: May use path configuration for template location

## Technical Notes

### Cache Awareness

The command respects the path configuration cache (default 5-second timeout). The verbose mode shows cache age to help understand if configuration is stale.

### Manifest Discovery

The command uses the same manifest discovery logic as other commands:
1. Check `RCM_PATHS_MANIFEST` environment variable
2. Search upward from current directory for `.claude/paths.json`
3. Check `~/.claude/paths.json` as fallback

### JSON Output Format

The JSON output is designed for machine parsing and includes:
- `value`: The actual configuration value (string or null)
- `source`: The source type (environment, manifest, default, found, not_found)

This format allows scripts to both use the values and make decisions based on the source.
