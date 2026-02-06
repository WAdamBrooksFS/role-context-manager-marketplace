# /load-role-context

Loads the current user's role guide and all referenced documents into the session context.

## Purpose

This command automatically injects role-specific context into Claude's working memory, including:
- The complete role guide for the user's configured role
- All documents referenced in the role guide's "Document References" section

This enables Claude to immediately understand the user's role requirements, workflows, and standards without manual prompting.

## Usage

```bash
/load-role-context [OPTIONS]
```

### Options

- `--quiet`: Output a single-line summary (designed for SessionStart hooks)
- `--verbose`: Include detailed metadata (scope, paths, section count, document list)
- No flag: Output full role guide and document content with context wrapper

### Examples

```bash
# Load role context with full output
/load-role-context

# Load with minimal output (for hooks)
/load-role-context --quiet

# Load with detailed metadata
/load-role-context --verbose
```

## Behavior

### Multi-Scope Hierarchy

The command respects the configuration hierarchy:
1. **Project role** (`.claude/config.json` in current directory) takes precedence
2. **Global role** (`~/.claude/config.json`) is used if no project role exists

Note: If custom paths are configured (via `paths.json` or environment variables), the command uses the configured directory names instead of `.claude`. For example, if configured to use `.myorg`, it reads from `.myorg/config.json`.

### Graceful Degradation

The command never blocks or fails:
- If no role is set: Exits silently (code 0)
- If role guide is missing: Exits silently in quiet mode; warns in normal mode
- If referenced documents are missing: Loads available documents, skips missing ones

### Output Modes

**Quiet mode** (`--quiet`):
```
✓ Role context loaded: software-engineer (5 documents)
```

**Normal mode** (default):
```
=== ROLE CONTEXT LOADED ===

You are collaborating with a user in the role: software-engineer

The following role guide defines how you should assist this user:

---
[FULL ROLE GUIDE CONTENT]
---

## Referenced Documents

The following documents are part of this role's context:

### Document: docs/engineering-standards.md
---
[DOCUMENT CONTENT]
---

[... additional documents ...]

This context is automatically loaded for this session. Follow the
deterministic behaviors and leverage the agentic opportunities defined above.

=== END ROLE CONTEXT ===
```

**Verbose mode** (`--verbose`):
Includes all normal mode output plus:
- Configuration scope (project or global)
- Role guide file path
- Number of sections in role guide
- List of loaded documents with paths

## SessionStart Hook Integration

This command is designed to run automatically on session start:

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

The `--quiet` flag ensures clean startup output while still providing visibility into what was loaded.

## Manual Invocation

While typically run automatically, you can invoke manually:
- **After changing roles**: Load the new role immediately without restarting
- **For debugging**: Use `--verbose` to see exactly what's being loaded
- **For verification**: Confirm which role and documents are active

## Document Loading

The command automatically loads all documents listed in the role guide's "Document References" section. For example, if your role guide contains:

```markdown
## Document References

- docs/engineering-standards.md
- docs/quality-standards.md
- docs/security-policy.md
```

All three documents will be loaded and injected into the context along with the role guide.

### Path Configuration Support

The command respects custom path configuration:

**Default paths**:
```bash
# Loads from .claude/role-guides/engineer-guide.md
/load-role-context
```

**Custom paths** (via paths.json or environment):
```bash
# If configured to use .myorg and guides/
# Loads from .myorg/guides/engineer-guide.md
export RCM_CLAUDE_DIR_NAME=".myorg"
export RCM_ROLE_GUIDES_DIR="guides"
/load-role-context
```

The command automatically detects and uses the configured paths. See [Path Configuration](../docs/PATH-CONFIGURATION.md) for details.

## Claude Instructions

When you execute this command, Claude will:

1. **Acknowledge the role context**: Understand that it's working with a user in a specific role
2. **Internalize the role guide**: Follow all deterministic behaviors and leverage agentic opportunities defined in the guide
3. **Access referenced documents**: Have immediate access to standards, policies, and guidelines without needing to read files
4. **Maintain context**: Keep this role context active throughout the session

The loaded context shapes how Claude assists you, ensuring consistency with your role's requirements and workflows.

## Implementation Details

This command invokes a bash script to load role context. Follow these steps:

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
   SCRIPT_PATH="$PLUGIN_DIR/scripts/role-manager.sh"
   if [ ! -f "$SCRIPT_PATH" ]; then
       echo "Error: role-manager.sh not found at $SCRIPT_PATH" >&2
       exit 2
   fi
   ```

3. **Invoke the script with arguments:**
   ```bash
   bash "$PLUGIN_DIR/scripts/role-manager.sh" load-role-context "$@"
   ```

   The script will:
   - Parse command-line flags (`--quiet`, `--verbose`)
   - Determine configuration scope (project vs global)
   - Load current role from preferences
   - Read role guide file
   - Extract document references
   - Output formatted content based on flags

4. **Pass through all command arguments:**
   - `--quiet` → Single-line summary for hooks
   - `--verbose` → Detailed metadata output
   - No flags → Full role guide and document content

### Exit Codes

- `0`: Success (even if no role set or guide missing - graceful degradation)
- `2`: System error (script not found, permissions issue)

**Critical:** This command never fails to avoid blocking SessionStart hooks. If there's an issue, it exits with code 0 and logs a warning.

### Example Invocation

When user runs `/load-role-context --quiet`, execute:
```bash
bash "$CLAUDE_PLUGIN_DIR/scripts/role-manager.sh" load-role-context --quiet
```
