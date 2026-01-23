# Implementation Plan: Automatic Role-Guide Loading on SessionStart

## Problem Statement

Currently, role-guides are stored in `.claude/role-guides/` but are NOT automatically loaded into the session context. Users must manually invoke commands to see role information. This plan adds automatic role-guide loading to the SessionStart hook so Claude immediately understands the user's role and its requirements.

## Solution Overview

Create a new `/load-role-context` command that reads the user's configured role guide and outputs it in a format that Claude processes as context. Add this command to the SessionStart hook configuration so it runs automatically when sessions begin.

## Critical Files

1. **NEW: `commands/load-role-context.md`** - Command definition with Claude instructions
2. **MODIFY: `scripts/role-manager.sh`** - Add `cmd_load_role_context()` function
3. **MODIFY: `scripts/post-install.sh`** - Update SessionStart hook to include new command
4. **MODIFY: `commands/setup-plugin-hooks.md`** - Update hook examples
5. **MODIFY: `README.md`** - Document the new automatic loading behavior

## Detailed Implementation

### 1. Create New Command: `/load-role-context`

**File:** `commands/load-role-context.md`

**Key behaviors:**
- **Respects multi-scope hierarchy**: Project role overrides global role
- **Graceful degradation**: Silently exits if no role set or role guide missing
- **Loads role guide + documents**: Loads both the role guide AND all documents referenced in the "Document References" section
- **Three output modes** (matching existing plugin patterns):
  - `--quiet`: One-line summary for SessionStart hook: `✓ Role context loaded: {role-name} ({doc-count} documents)`
  - Normal: Full role guide + documents with context injection wrapper
  - `--verbose`: Includes metadata (scope, path, section count, document list)

**Context injection format:**
```
=== ROLE CONTEXT LOADED ===

You are collaborating with a user in the role: {role-name}

The following role guide defines how you should assist this user:

---
{FULL ROLE GUIDE CONTENT}
---

## Referenced Documents

The following documents are part of this role's context:

[For each document in "Document References" section:]
### Document: {document-path}
---
{DOCUMENT CONTENT}
---

This context is automatically loaded for this session. Follow the
deterministic behaviors and leverage the agentic opportunities defined above.

=== END ROLE CONTEXT ===
```

**Edge case handling:**
- No .claude directory → Exit silently (validation catches this)
- No role set → Exit silently with code 0 (not an error)
- Role guide missing → Exit silently in silent mode; warn in normal mode
- Empty/malformed guide → Load anyway (best effort)

### 2. Add Function to role-manager.sh

**File:** `scripts/role-manager.sh`

**New function:** `cmd_load_role_context()`

**Logic flow:**
1. Parse mode argument (quiet/normal/verbose)
2. Determine effective config directory using existing `get_effective_config_dir()`
3. Get current role using existing `get_preference("user_role")`
4. Handle no-role case (exit silently with code 0)
5. Locate role guide using existing `get_role_guide_path()`
6. Handle missing-guide case (exit silently with code 0)
7. Read role guide content with `cat`
8. Extract document references using existing `extract_document_references()` function
9. Read each referenced document (with error handling for missing files)
10. Output based on mode (quiet: one-line summary, normal: full content, verbose: full + metadata)
11. Exit with code 0 (always success, no session blocking)

**Update main dispatcher:**
```bash
case "$command" in
    # ... existing commands ...
    load|load-role-context)
        cmd_load_role_context "$@"
        ;;
esac
```

### 3. Update SessionStart Hook Configuration

**File:** `scripts/post-install.sh`

**Change lines 95-98 to add third command:**
```bash
jq '.hooks.SessionStart = [
    "/validate-setup --quiet",
    "/sync-template --check-only",
    "/load-role-context --quiet"
]' "$SETTINGS_FILE" > "$temp_file"
```

**Hook execution order rationale:**
1. **Validate** - Ensures .claude directory exists and is valid (one-line output: `✓ Setup validated`)
2. **Sync** - Checks for template updates (one-line output if updates available)
3. **Load Role** - Injects role guide + documents into context (one-line output: `✓ Role context loaded: {role-name} ({count} documents)`)

**Output mode consistency:**
All three commands use `--quiet` mode for consistent one-line outputs that provide visibility without clutter. This maintains the existing plugin's visibility pattern.

**Update setup messages** to inform users about the new automatic loading behavior.

### 4. Update Hook Documentation

**File:** `commands/setup-plugin-hooks.md`

Update all example configurations to include the new command:

**Minimal configuration:**
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --quiet",
      "/load-role-context --quiet"
    ]
  }
}
```

**Standard configuration (recommended):**
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

**Verbose configuration:**
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup",
      "/sync-template",
      "/load-role-context --verbose"
    ]
  }
}
```

All configurations use `--quiet` mode in standard setup to maintain visibility with one-line outputs, matching the existing plugin pattern.

### 5. Update Main Documentation

**File:** `README.md`

**Updates needed:**
- SessionStart Hook section (~lines 95-187): Add description of role context loading
- Command list: Add `/load-role-context` command with usage examples
- Quick Start section: Mention automatic role loading after `/set-role`

**Key messages:**
- After setting a role with `/set-role`, it will automatically load on the next session
- Silent mode keeps startup clean while still providing context
- Manual invocation available for debugging or immediate loading

### 6. Update Cheatsheet

**File:** `CHEATSHEET.md`

Add entry for `/load-role-context` command in the Commands section with flags and use cases.

## Implementation Notes

### Multi-Scope Support

The implementation leverages existing multi-scope functions:
- `get_effective_config_dir()` - Finds project vs global config
- `get_preference()` - Reads role with hierarchy (project > global)
- `get_role_guide_path()` - Locates guide file with fallbacks

### No Blocking Behavior

**Critical requirement:** Never block session start
- All error conditions exit with code 0
- Silent mode suppresses warnings
- Missing role/guide is not an error condition

### User Experience

**First-time flow:**
1. User runs `/set-role software-engineer`
2. Command confirms: "Your role guide will automatically load on your next session"
3. Next session startup shows:
   ```
   ✓ Setup validated
   ✓ Role context loaded: software-engineer (5 documents)
   ```
4. Claude immediately understands the role context and has access to referenced documents

**Transparency:**
- Quiet mode outputs one line showing role and document count (matches existing plugin pattern)
- Normal mode shows full role guide + document content
- Verbose mode includes metadata (paths, scope, section counts)
- Maintains existing plugin's visibility while avoiding clutter

## Testing Strategy

### Unit Tests

1. No role set → Silent exit
2. Role set but guide missing → Silent exit (warn in normal mode)
3. Valid role with guide → Content loaded
4. Project role overrides global role
5. All three output modes work correctly

### Integration Tests

1. SessionStart hook executes all three commands in order
2. Role context appears in Claude's working memory
3. Claude can answer "What role am I in?" after startup
4. Migration from existing installations (re-run setup)

### Edge Case Tests

1. Empty .claude directory
2. Malformed role guide markdown
3. Permission denied reading guide
4. Very large role guide (performance)
5. Special characters in role guide content

## Migration Path

**For existing installations:**
1. Users run `/setup-plugin-hooks --force` to update hook configuration
2. Alternatively, automatic migration on next plugin update
3. Backwards compatible: Old hooks continue working, just without role loading

**For new installations:**
- `post-install.sh` automatically configures the complete hook

## Verification

After implementation, verify:

1. **Role loads automatically:**
   ```bash
   /set-role software-engineer
   # Start new session
   # Verify: ✓ Role context loaded: software-engineer (5 documents)
   ```

2. **Claude knows the role and has documents:**
   ```
   User: "What role am I in?"
   Claude: "You are in the software-engineer role. I have access to your engineering standards, quality standards, security policy, contributing guide, and development setup documentation."
   ```

3. **Manual invocation works:**
   ```bash
   /load-role-context --verbose
   # Verify: Full output with metadata
   ```

4. **Multi-scope hierarchy respected:**
   ```bash
   /set-role --global frontend-engineer
   cd project
   /set-role backend-engineer
   # Start session in project
   # Verify: backend-engineer loads (not frontend-engineer)
   ```

5. **Graceful handling of missing role:**
   ```bash
   # Clear role preference
   # Start new session
   # Verify: No errors, silent exit
   ```

## Future Enhancements

1. **Multiple roles**: Support primary + secondary roles
2. **Caching**: Cache loaded role within session to avoid re-reading
3. **Smart refresh**: Detect role guide changes and offer to reload
4. **Role switching**: `/switch-role` command to change role mid-session
5. **Selective document loading**: Allow users to customize which documents load

## Open Questions

None - the design is complete and ready for implementation.

## Summary

This implementation adds automatic role-guide and document loading to SessionStart by:
- Creating a new `/load-role-context` command with quiet/normal/verbose modes
- Loading both the role guide AND all documents from the "Document References" section
- Adding it to the SessionStart hook configuration (third command after validate and sync)
- Using `--quiet` mode to provide one-line output matching existing plugin visibility pattern
- Leveraging existing multi-scope infrastructure and `extract_document_references()` function
- Ensuring graceful degradation (no session blocking)

The result: Users set their role once with `/set-role`, and every subsequent session automatically loads that role's guide and referenced documents into context, enabling Claude to immediately understand role-specific requirements, workflows, and have access to relevant standards and documentation.
