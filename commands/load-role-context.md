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

## Claude Instructions

When you execute this command, Claude will:

1. **Acknowledge the role context**: Understand that it's working with a user in a specific role
2. **Internalize the role guide**: Follow all deterministic behaviors and leverage agentic opportunities defined in the guide
3. **Access referenced documents**: Have immediate access to standards, policies, and guidelines without needing to read files
4. **Maintain context**: Keep this role context active throughout the session

The loaded context shapes how Claude assists you, ensuring consistency with your role's requirements and workflows.

## Implementation Details

**Delegates to:** `scripts/role-manager.sh load-role-context`

**Exit codes:**
- `0`: Success (even if no role set or guide missing - graceful degradation)

**No errors:** This command never fails to avoid blocking SessionStart hooks.
