# Multi-Scope Implementation Test Plan

## Overview

This test plan validates the multi-scope functionality added in v1.3.0, which allows the plugin to work at both global (`~/.claude/`) and project (`./.claude/`) levels with proper configuration hierarchy and fallback behavior.

## Test Environment Setup

### Prerequisites

- Claude Code CLI installed
- role-context-manager plugin installed (v1.3.0+)
- `jq` command-line tool installed
- Test projects with and without `.claude/` directories

### Test Directories

Create the following test structure:

```bash
# Test directory structure
~/test-multi-scope/
├── test-project-a/          # Will have project config
│   └── .claude/
├── test-project-b/          # Will have project config
│   └── .claude/
├── test-project-c/          # No .claude (will use global)
└── test-no-project/         # Outside any project
```

Setup commands:
```bash
mkdir -p ~/test-multi-scope/{test-project-a,test-project-b,test-project-c,test-no-project}
mkdir -p ~/test-multi-scope/test-project-a/.claude
mkdir -p ~/test-multi-scope/test-project-b/.claude
```

## Test Categories

### 1. Global Configuration Tests
### 2. Project Configuration Tests
### 3. Configuration Hierarchy Tests
### 4. Command Scope Parameter Tests
### 5. Hook Configuration Tests
### 6. Template Management Tests
### 7. Validation Tests
### 8. Migration Tests

---

## Test Case 1: Global Installation Only

**Objective**: Verify plugin works when installed globally with no project configs.

### Test 1.1: Initialize Global Template

**Steps:**
```bash
cd ~/test-multi-scope/test-no-project
/init-org-template --global
```

**Expected Results:**
- [ ] Template selection dialog appears
- [ ] Template applied to `~/.claude/`
- [ ] `~/.claude/role-guides/` contains role guides
- [ ] `~/.claude/preferences.json` created
- [ ] Message indicates global scope

**Validation:**
```bash
ls -la ~/.claude/
ls -la ~/.claude/role-guides/
cat ~/.claude/preferences.json | jq '.applied_template'
```

### Test 1.2: Set Global Role

**Steps:**
```bash
cd ~/test-multi-scope/test-no-project
/set-role software-engineer --global
```

**Expected Results:**
- [ ] Role set in `~/.claude/preferences.json`
- [ ] Message indicates "global scope"
- [ ] Document list displayed
- [ ] No project config created

**Validation:**
```bash
cat ~/.claude/preferences.json | jq '.user_role'
# Should show: "software-engineer"
test ! -d ./.claude && echo "✓ No project config created"
```

### Test 1.3: Show Role Context (Global Only)

**Steps:**
```bash
cd ~/test-multi-scope/test-no-project
/show-role-context
```

**Expected Results:**
- [ ] Shows "Configuration Hierarchy"
- [ ] Shows "Global config: ~/.claude/"
- [ ] Shows "Project config: none"
- [ ] Shows effective configuration
- [ ] Role displayed: software-engineer

**Validation:**
```bash
# Output should include:
# - Global config section
# - Project config: none
# - Effective Configuration section
```

### Test 1.4: Update Global Role Docs

**Steps:**
```bash
cd ~/test-multi-scope/test-no-project
/update-role-docs +custom-doc.md --global
```

**Expected Results:**
- [ ] Document added to `~/.claude/role-references.local.json`
- [ ] Message indicates global scope
- [ ] No project files modified

**Validation:**
```bash
cat ~/.claude/role-references.local.json | jq '.custom_additions'
```

---

## Test Case 2: Project Configuration Only

**Objective**: Verify plugin works with project-specific configs.

### Test 2.1: Initialize Project Template

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a
/init-org-template --project
```

**Expected Results:**
- [ ] Template selection dialog appears
- [ ] Template applied to `./.claude/`
- [ ] `.claude/role-guides/` contains role guides
- [ ] `.claude/preferences.json` created
- [ ] Message indicates project scope
- [ ] Global config unaffected

**Validation:**
```bash
ls -la ./.claude/
ls -la ./.claude/role-guides/
cat ./.claude/preferences.json | jq '.applied_template'
```

### Test 2.2: Set Project Role

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a
/set-role qa-engineer --project
```

**Expected Results:**
- [ ] Role set in `./.claude/preferences.json`
- [ ] Message indicates "project scope"
- [ ] Document list displayed
- [ ] Global config unaffected

**Validation:**
```bash
cat ./.claude/preferences.json | jq '.user_role'
# Should show: "qa-engineer"
cat ~/.claude/preferences.json | jq '.user_role'
# Should show: "software-engineer" (unchanged from Test 1.2)
```

### Test 2.3: Show Role Context (Project Only)

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a
/show-role-context
```

**Expected Results:**
- [ ] Shows "Configuration Hierarchy"
- [ ] Shows "Global config: ~/.claude/" (if exists)
- [ ] Shows "Project config: .../test-project-a/.claude/"
- [ ] Shows effective configuration
- [ ] Role displayed: qa-engineer (project overrides global)

---

## Test Case 3: Configuration Hierarchy

**Objective**: Verify project configs override global configs correctly.

### Test 3.1: Global + Project with Different Roles

**Setup:**
```bash
# Global role already set to software-engineer (from Test 1.2)
# Project A role already set to qa-engineer (from Test 2.2)
cd ~/test-multi-scope/test-project-b
```

**Steps:**
```bash
# Initialize project with different role
/init-org-template --project
/set-role devops-engineer --project
/show-role-context
```

**Expected Results:**
- [ ] Shows both global and project configs
- [ ] Global role: software-engineer
- [ ] Project role: devops-engineer
- [ ] Effective role: devops-engineer (project wins)
- [ ] Clear indication of override

**Validation:**
```bash
cat ~/.claude/preferences.json | jq '.user_role'
# "software-engineer"
cat ./.claude/preferences.json | jq '.user_role'
# "devops-engineer"
```

### Test 3.2: Project Uses Global When No Override

**Steps:**
```bash
cd ~/test-multi-scope/test-project-c
# This project has no .claude directory
/show-role-context
```

**Expected Results:**
- [ ] Shows global config only
- [ ] Shows "Project config: none"
- [ ] Effective role: software-engineer (from global)
- [ ] Message: "Using global config"

### Test 3.3: Document References Hierarchy

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a
# Add doc to global
cd ~/test-multi-scope/test-no-project
/update-role-docs +global-doc.md --global

# Add doc to project
cd ~/test-multi-scope/test-project-a
/update-role-docs +project-doc.md --project

# Show combined context
/show-role-context
```

**Expected Results:**
- [ ] Shows documents from global config
- [ ] Shows documents from project config
- [ ] Clear indication of source (global vs project)
- [ ] Combined document list in effective configuration

---

## Test Case 4: Command Scope Parameters

**Objective**: Verify all commands respect scope parameters.

### Test 4.1: Set Role with Different Scopes

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a

# Set global role
/set-role backend-engineer --global

# Set project role
/set-role frontend-engineer --project

# Show context
/show-role-context
```

**Expected Results:**
- [ ] Global role: backend-engineer
- [ ] Project role: frontend-engineer
- [ ] Both configs updated independently
- [ ] Messages indicate correct scope

**Validation:**
```bash
cat ~/.claude/preferences.json | jq '.user_role'
# "backend-engineer"
cat ./.claude/preferences.json | jq '.user_role'
# "frontend-engineer"
```

### Test 4.2: Auto Scope Detection

**Steps:**
```bash
# In project - should use project scope
cd ~/test-multi-scope/test-project-a
/set-role data-scientist
cat ./.claude/preferences.json | jq '.user_role'
# Should be "data-scientist"

# Outside project - should use global scope
cd ~/test-multi-scope/test-no-project
/set-role product-manager
cat ~/.claude/preferences.json | jq '.user_role'
# Should be "product-manager"
```

**Expected Results:**
- [ ] Auto mode chooses project when in project
- [ ] Auto mode chooses global when outside project
- [ ] Appropriate config files updated
- [ ] Messages indicate detected scope

### Test 4.3: Validate Setup Scope Parameters

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a

# Validate global only
/validate-setup --global

# Validate project only
/validate-setup --project

# Validate both
/validate-setup
```

**Expected Results:**
- [ ] `--global` validates only `~/.claude/`
- [ ] `--project` validates only `./.claude/`
- [ ] No flag validates both scopes
- [ ] Clear separation in output

### Test 4.4: Sync Template Scope Parameters

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a

# Check global template
/sync-template --check-only --global

# Check project template
/sync-template --check-only --project

# Check both
/sync-template --check-only
```

**Expected Results:**
- [ ] `--global` checks only global template
- [ ] `--project` checks only project template
- [ ] No flag checks both templates
- [ ] Appropriate update notifications

---

## Test Case 5: Hook Configuration

**Objective**: Verify hooks work at both scopes.

### Test 5.1: Setup Global Hooks

**Steps:**
```bash
cd ~/test-multi-scope/test-no-project
/setup-plugin-hooks --global
```

**Expected Results:**
- [ ] Hook configured in `~/.claude/settings.json`
- [ ] Marker file: `~/.claude/.role-context-manager-setup-complete`
- [ ] Message indicates global scope
- [ ] Mentions "runs for all projects"

**Validation:**
```bash
cat ~/.claude/settings.json | jq '.hooks.SessionStart'
# Should show validation and sync commands
test -f ~/.claude/.role-context-manager-setup-complete && echo "✓ Marker exists"
```

### Test 5.2: Setup Project Hooks

**Steps:**
```bash
cd ~/test-multi-scope/test-project-b
/setup-plugin-hooks --project
```

**Expected Results:**
- [ ] Hook configured in `./.claude/settings.json`
- [ ] Marker file: `./.claude/.role-context-manager-setup-complete`
- [ ] Message indicates project scope
- [ ] Mentions "runs for this project only"

**Validation:**
```bash
cat ./.claude/settings.json | jq '.hooks.SessionStart'
test -f ./.claude/.role-context-manager-setup-complete && echo "✓ Marker exists"
```

### Test 5.3: Hook Precedence

**Setup:**
```bash
# Global hook already configured (Test 5.1)
# Project B hook already configured (Test 5.2)
```

**Test:**
- Start new Claude Code session in test-project-b
- Observe which hooks run

**Expected Results:**
- [ ] Project hooks take precedence
- [ ] Global hooks do NOT run in this project
- [ ] Validation runs against project config
- [ ] Clear indication of active scope

### Test 5.4: Hook Validation Behavior

**Steps:**
```bash
# In project with global hooks only
cd ~/test-multi-scope/test-project-a
# Start new session
```

**Expected Results:**
- [ ] Global hooks run (no project hook override)
- [ ] Validates both global and project configs
- [ ] Shows status for both scopes
- [ ] Appropriate scope indicators

---

## Test Case 6: Template Management

**Objective**: Verify template operations work at both scopes.

### Test 6.1: Apply Different Templates to Different Scopes

**Steps:**
```bash
# Apply startup-org to global
cd ~/test-multi-scope/test-no-project
/init-org-template --global
# Select "startup-org"

# Apply software-org to project
cd ~/test-multi-scope/test-project-a
/init-org-template --project
# Select "software-org"
```

**Expected Results:**
- [ ] Different templates applied to different scopes
- [ ] Each scope has appropriate role guides
- [ ] Preferences show different `applied_template`
- [ ] No conflicts or mixing

**Validation:**
```bash
cat ~/.claude/preferences.json | jq '.applied_template.id'
# "startup-org"
cat ~/test-multi-scope/test-project-a/.claude/preferences.json | jq '.applied_template.id'
# "software-org"
```

### Test 6.2: Sync Template at Different Scopes

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a

# Sync global template
/sync-template --global --preview

# Sync project template
/sync-template --project --preview

# Sync both
/sync-template --preview
```

**Expected Results:**
- [ ] Each scope syncs independently
- [ ] Preview shows changes for appropriate scope
- [ ] No cross-contamination
- [ ] Clear scope indicators

---

## Test Case 7: Validation

**Objective**: Verify validation works correctly across scopes.

### Test 7.1: Validate Both Scopes Independently

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a

# Break global config
echo "invalid json" > ~/.claude/preferences.json

# Validate global
/validate-setup --global

# Fix global, break project
cat > ./.claude/preferences.json <<EOF
{"user_role": "invalid-role"}
EOF

# Validate project
/validate-setup --project
```

**Expected Results:**
- [ ] Global validation catches global issues only
- [ ] Project validation catches project issues only
- [ ] Clear indication of which scope has issues
- [ ] Appropriate error messages

### Test 7.2: Validate Both Scopes Together

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a

# Fix both configs
# Re-initialize if needed

# Validate both
/validate-setup
```

**Expected Results:**
- [ ] Validates both scopes
- [ ] Shows separate results for each
- [ ] Clear hierarchy display
- [ ] Combined pass/fail status

### Test 7.3: Validation with Auto-Fix

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a

# Introduce fixable issue in global
# (e.g., trailing comma in JSON)

# Run validation with fix
/validate-setup --global --fix
```

**Expected Results:**
- [ ] Identifies issues in correct scope
- [ ] Offers fixes
- [ ] Fixes applied to correct config
- [ ] Other scope unaffected

---

## Test Case 8: Migration Scenarios

**Objective**: Verify smooth migration from project-only to multi-scope.

### Test 8.1: Existing Project-Only Installation

**Setup:**
```bash
# Simulate existing project-only setup
mkdir -p ~/test-multi-scope/existing-project/.claude
cd ~/test-multi-scope/existing-project
# Create old-style config
cat > ./.claude/preferences.json <<EOF
{
  "user_role": "software-engineer",
  "auto_update_templates": true
}
EOF
```

**Steps:**
```bash
cd ~/test-multi-scope/existing-project
/show-role-context
```

**Expected Results:**
- [ ] Plugin recognizes existing config
- [ ] Works without migration
- [ ] Shows project config
- [ ] No global config required

### Test 8.2: Add Global Config to Existing Project Setup

**Steps:**
```bash
# User has existing project setup from 8.1
cd ~/test-multi-scope/existing-project

# Now add global config
/set-role product-manager --global
/show-role-context
```

**Expected Results:**
- [ ] Global config created
- [ ] Existing project config preserved
- [ ] Hierarchy correctly displayed
- [ ] Project config still takes precedence

---

## Test Case 9: Edge Cases

**Objective**: Test unusual or edge case scenarios.

### Test 9.1: Set Project Scope Outside Project

**Steps:**
```bash
cd ~/test-multi-scope/test-no-project
/set-role software-engineer --project
```

**Expected Results:**
- [ ] Error message displayed
- [ ] "Not in a project context"
- [ ] Suggests using `--global` instead
- [ ] No config files modified

### Test 9.2: Empty Global Config

**Steps:**
```bash
# Remove global config entirely
rm -rf ~/.claude

cd ~/test-multi-scope/test-no-project
/set-role software-engineer --global
```

**Expected Results:**
- [ ] Global config auto-created
- [ ] Message: "✓ Created global config directory"
- [ ] Preferences initialized
- [ ] Role set successfully

### Test 9.3: Conflicting Scopes

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a

# Try to use both global and project flags
/set-role software-engineer --global --project
```

**Expected Results:**
- [ ] Error or warning
- [ ] Clear message about conflicting flags
- [ ] Suggests using one flag only
- [ ] No config modified

### Test 9.4: Nested Project Directories

**Setup:**
```bash
mkdir -p ~/test-multi-scope/parent-project/.claude
mkdir -p ~/test-multi-scope/parent-project/sub-dir/nested-project/.claude
```

**Steps:**
```bash
cd ~/test-multi-scope/parent-project/sub-dir/nested-project
/show-role-context
```

**Expected Results:**
- [ ] Uses nearest `.claude` directory (nested-project)
- [ ] Does not use parent project config
- [ ] Clear indication of which config is active

---

## Test Case 10: Performance & Reliability

**Objective**: Ensure multi-scope doesn't introduce performance issues.

### Test 10.1: Command Response Time

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a

# Time various commands
time /show-role-context
time /validate-setup
time /set-role software-engineer
```

**Expected Results:**
- [ ] Commands complete in under 2 seconds
- [ ] No noticeable slowdown from single-scope
- [ ] File I/O is minimal

### Test 10.2: Concurrent Access

**Steps:**
```bash
# Open multiple terminals
# Terminal 1:
cd ~/test-multi-scope/test-project-a
/set-role software-engineer --project

# Terminal 2 (simultaneously):
cd ~/test-multi-scope/test-project-b
/set-role qa-engineer --project
```

**Expected Results:**
- [ ] No file corruption
- [ ] Both commands complete successfully
- [ ] Appropriate configs updated
- [ ] No lock file conflicts

---

## Test Case 11: Documentation & Help

**Objective**: Verify documentation reflects multi-scope changes.

### Test 11.1: Command Help Text

**Steps:**
```bash
/set-role --help
```

**Expected Results:**
- [ ] Help mentions `--global` flag
- [ ] Help mentions `--project` flag
- [ ] Help mentions `--scope` parameter
- [ ] Examples show scope usage

### Test 11.2: Show Role Context Output

**Steps:**
```bash
cd ~/test-multi-scope/test-project-a
/show-role-context
```

**Expected Results:**
- [ ] Output shows "Configuration Hierarchy"
- [ ] Clear separation of global vs project
- [ ] Effective configuration clearly marked
- [ ] Source indicators (from global/from project)

---

## Success Criteria

### Critical (Must Pass)

- [ ] All commands work with `--global` flag
- [ ] All commands work with `--project` flag
- [ ] Auto scope detection works correctly
- [ ] Project configs override global configs
- [ ] Global configs used when no project config
- [ ] No regression in existing project-only functionality
- [ ] Hooks work at both scopes
- [ ] Validation works at both scopes
- [ ] No data corruption or loss

### Important (Should Pass)

- [ ] All scope flags documented in command help
- [ ] Clear error messages for invalid scope usage
- [ ] Performance is acceptable (< 2s for most commands)
- [ ] Migration from project-only is seamless
- [ ] Edge cases handled gracefully

### Nice to Have (Could Pass)

- [ ] Helpful tips about scope in command output
- [ ] Visual indicators of active scope
- [ ] Suggestions for optimal scope usage

---

## Test Execution Tracking

### Test Run 1: Initial Implementation

**Date**: _____________
**Tester**: _____________
**Version**: v1.3.0

| Test Case | Status | Notes |
|-----------|--------|-------|
| 1.1 - Initialize Global Template | ⬜ | |
| 1.2 - Set Global Role | ⬜ | |
| 1.3 - Show Role Context (Global) | ⬜ | |
| 1.4 - Update Global Role Docs | ⬜ | |
| 2.1 - Initialize Project Template | ⬜ | |
| 2.2 - Set Project Role | ⬜ | |
| 2.3 - Show Role Context (Project) | ⬜ | |
| 3.1 - Different Roles | ⬜ | |
| 3.2 - Project Uses Global | ⬜ | |
| 3.3 - Document References Hierarchy | ⬜ | |
| 4.1 - Set Role Different Scopes | ⬜ | |
| 4.2 - Auto Scope Detection | ⬜ | |
| 4.3 - Validate Setup Scopes | ⬜ | |
| 4.4 - Sync Template Scopes | ⬜ | |
| 5.1 - Setup Global Hooks | ⬜ | |
| 5.2 - Setup Project Hooks | ⬜ | |
| 5.3 - Hook Precedence | ⬜ | |
| 5.4 - Hook Validation | ⬜ | |
| 6.1 - Different Templates | ⬜ | |
| 6.2 - Sync Different Scopes | ⬜ | |
| 7.1 - Validate Independent | ⬜ | |
| 7.2 - Validate Together | ⬜ | |
| 7.3 - Validation Auto-Fix | ⬜ | |
| 8.1 - Existing Project-Only | ⬜ | |
| 8.2 - Add Global to Existing | ⬜ | |
| 9.1 - Project Scope Outside Project | ⬜ | |
| 9.2 - Empty Global Config | ⬜ | |
| 9.3 - Conflicting Scopes | ⬜ | |
| 9.4 - Nested Projects | ⬜ | |
| 10.1 - Response Time | ⬜ | |
| 10.2 - Concurrent Access | ⬜ | |
| 11.1 - Command Help | ⬜ | |
| 11.2 - Show Context Output | ⬜ | |

**Legend**: ⬜ Not Run | ✅ Pass | ❌ Fail | ⚠️ Issues

---

## Bug Tracking Template

### Bug Report Format

**Test Case**: _____________
**Expected**: _____________
**Actual**: _____________
**Severity**: Critical | High | Medium | Low
**Steps to Reproduce**:
1.
2.
3.

**Environment**:
- OS: _____________
- Claude Code Version: _____________
- Plugin Version: _____________

**Additional Notes**: _____________

---

## Regression Testing

After bug fixes or changes, re-run:
- [ ] All failed test cases
- [ ] Related test cases
- [ ] Full test suite (before release)

---

## Cleanup After Testing

```bash
# Remove test directories
rm -rf ~/test-multi-scope

# Optional: Reset global config
rm -rf ~/.claude
```

---

## Notes for Testers

1. **Take screenshots** of output for documentation
2. **Save logs** if commands fail
3. **Note unexpected behavior** even if tests pass
4. **Test on multiple OS** (Linux, macOS, Windows WSL)
5. **Test with different terminals** (bash, zsh, fish)
6. **Verify git status** doesn't show unexpected changes
7. **Check file permissions** are correct

---

## Automated Testing (Future)

Consider creating automated tests for:
- Core scope detection functions
- Config file creation and merging
- Path resolution logic
- JSON parsing and validation
- Hook installation
- Template application

Potential frameworks:
- `bats` (Bash Automated Testing System)
- `shunit2`
- Custom bash test scripts
