# WEAVER_BLUEPRINT: Merge workflow-enhancements into master

**Version**: v1.7.0
**Generated From**: Plan at `/home/practice-adam-brooks/.claude/plans/purring-meandering-crescent.md`
**Feature**: Integrate Hierarchical Organizations with Path Configuration System
**Status**: Ready for Decomposition
**Estimated Timeline**: 7 days (40 hours)

---

## Executive Summary

Integrate the hierarchical organizational structure features from the `workflow-enhancements` branch with the path customization system in `master` to create v1.7.0. This merge combines two powerful features: dynamic path configuration (allowing custom directory names) and organizational hierarchy detection (company/system/product/project relationships).

**Challenge**: The branches have incompatible architectures - master uses dynamic path resolution via `path-config.sh` API, while workflow-enhancements has 30+ hardcoded `.claude` and `role-guides` references. This requires comprehensive refactoring, not a simple git merge.

**Value**: Users gain both custom directory naming AND hierarchical organization support in a single, unified system.

---

## Requirements

### Functional Requirements

**FR-1**: Hierarchy detection must work with custom directory names
- Parent/child detection across directories named `.myorg`, `.custom`, etc.
- Not just `.claude`

**FR-2**: Role guide inheritance must respect custom role-guides directory
- If configured as `guides`, hierarchy uses `guides` not `role-guides`

**FR-3**: /add-role-guides command must work with path-config
- Dynamic path resolution based on configuration

**FR-4**: Combined validation for both systems
- Path configuration validation (traversal checks, security)
- Hierarchy validation (parent-child relationships)

**FR-5**: 100% backward compatibility with v1.6.0
- Default behavior unchanged (.claude and role-guides)
- No forced migration

### Non-Functional Requirements

**NFR-1**: Performance - Combined overhead <200ms
- Path resolution + hierarchy detection together

**NFR-2**: Security - Path traversal protection maintained
- Existing security constraints apply

**NFR-3**: Code quality - All scripts pass shellcheck
- No regressions

**NFR-4**: Test coverage - Integration tests for combined features

---

## Architecture

### Component Integration

```
Application Scripts (role-manager, level-detector, etc.)
        │
        ├─────────> path-config.sh (dynamic paths, caching)
        │
        └─────────> hierarchy-detector.sh (parent/child detection)
                            │
                            └──> USES path-config.sh API
```

**Key Principle**: hierarchy-detector.sh MUST source and use path-config.sh functions.

### Refactoring Pattern

```bash
# BEFORE (workflow-enhancements - hardcoded)
if [[ -d "$dir/.claude" ]]; then
    parent_dirs+=("$dir/.claude")
fi

# AFTER (integrated - dynamic)
local claude_dir_name
claude_dir_name="$(get_claude_dir_name)"
if [[ -d "$dir/$claude_dir_name" ]]; then
    parent_dirs+=("$dir/$claude_dir_name")
fi
```

---

## Target Files

### Task 1: Refactor hierarchy-detector.sh (CRITICAL - Foundation)
**Action**: CREATE (from workflow-enhancements with refactoring)
**Size**: 541 lines
**Priority**: HIGHEST
**Modifications**: 30+ hardcoded paths to refactor
**Path**: `scripts/hierarchy-detector.sh`
**Purpose**: Detect parent-child organizational relationships with dynamic paths
**Dependencies**: Must source path-config.sh
**Estimate**: 6 hours

**Changes Required**:
```bash
# Add at top (after set -euo pipefail):
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/path-config.sh"
load_path_config

# Pattern to apply (30+ instances):
OLD: if [[ -d "$dir/.claude" ]]; then
NEW: local claude_dir_name="$(get_claude_dir_name)"
     if [[ -d "$dir/$claude_dir_name" ]]; then
```

**Constraints**:
- C1: Must source path-config.sh BEFORE using functions
- C2: All `.claude` strings become `get_claude_dir_name()` calls
- C3: All `role-guides` strings become `get_role_guides_dir()` calls
- C4: Function signatures must accept dynamic paths

**Validation**:
```bash
bash -n scripts/hierarchy-detector.sh
shellcheck scripts/hierarchy-detector.sh
# Test with custom paths
export RCM_CLAUDE_DIR_NAME=".test"
# Verify functions work
```

---

### Task 2: Integrate role-manager.sh changes
**Action**: MODIFY
**Base**: Master version (has path-config integration)
**Integrate**: `cmd_add_role_guides()` function from workflow-enhancements
**Path**: `scripts/role-manager.sh`
**Size**: Currently 40,019 bytes
**Changes**: Add ~150 lines, refactor for path-config
**Priority**: CRITICAL
**Estimate**: 3 hours

**Steps**:
1. Keep master's path-config infrastructure
2. Add `cmd_add_role_guides()` function
3. Refactor new function to use:
   - `get_claude_dir_name()` for `.claude` references
   - `get_role_guides_dir()` for `role-guides` references
   - `get_full_role_guides_path()` for full paths

**Constraints**:
- C5: Must preserve master's path-config sourcing
- C6: All path construction in new code uses path-config API
- C7: Line ~450: `".claude/role-guides"` → `get_full_role_guides_path()`

**Dependencies**: Task 1 (hierarchy-detector.sh) must be complete

**Validation**:
```bash
bash -n scripts/role-manager.sh
shellcheck scripts/role-manager.sh
```

---

### Task 3: Integrate level-detector.sh changes
**Action**: MODIFY
**Base**: Master version (has path-config)
**Integrate**: Hierarchy-aware prompt logic
**Path**: `scripts/level-detector.sh`
**Size**: Currently 8,395 bytes
**Priority**: CRITICAL
**Estimate**: 2 hours

**Steps**:
1. Keep master's path-config integration
2. Add `source hierarchy-detector.sh` (AFTER path-config.sh)
3. Integrate enhanced `prompt_user_for_level()` function
4. Update prompt to use both systems

**Constraints**:
- C8: Must source hierarchy-detector.sh AFTER path-config.sh
- C9: Prompt logic must use dynamic paths

**Dependencies**: Task 1

**Validation**:
```bash
bash -n scripts/level-detector.sh
shellcheck scripts/level-detector.sh
```

---

### Task 4: Integrate template-manager.sh changes
**Action**: MODIFY
**Base**: Master version (has path-config)
**Integrate**: Function moves from workflow-enhancements
**Path**: `scripts/template-manager.sh`
**Size**: Currently 20,736 bytes
**Priority**: HIGH
**Estimate**: 2 hours

**Steps**:
1. Keep master's path-config integration
2. Source hierarchy-detector.sh (AFTER path-config.sh)
3. Remove functions moved to hierarchy-detector.sh:
   - `get_role_guides_for_level()`
   - `filter_role_guides()`
4. Update calls to use hierarchy-detector versions

**Dependencies**: Task 1

**Validation**:
```bash
bash -n scripts/template-manager.sh
shellcheck scripts/template-manager.sh
```

---

### Task 5: Integrate post-install.sh changes
**Action**: MODIFY
**Base**: Master version (has path-config)
**Integrate**: Enhanced messaging
**Path**: `scripts/post-install.sh`
**Size**: Currently 4,950 bytes
**Priority**: MODERATE
**Estimate**: 1 hour

**Steps**:
1. Keep master's path-config infrastructure
2. Add improved error messages
3. Add enhanced validation checks
4. Ensure messages use `$CLAUDE_DIR_NAME` variable

**Validation**:
```bash
bash -n scripts/post-install.sh
shellcheck scripts/post-install.sh
```

---

### Task 6: Add add-role-guides command
**Action**: CREATE
**Source**: workflow-enhancements
**Paths**: `commands/add-role-guides.sh`, `commands/add-role-guides.md`
**Size**: ~200 lines (sh), ~250 lines (md)
**Priority**: HIGH
**Estimate**: 1.5 hours

**Steps**:
1. Copy add-role-guides.md as-is
2. Review add-role-guides.sh for hardcoded paths
3. Add path-config sourcing if needed
4. Make executable

**Dependencies**: Task 2 (refactored role-manager.sh)

**Validation**:
```bash
bash -n commands/add-role-guides.sh
shellcheck commands/add-role-guides.sh
chmod +x commands/add-role-guides.sh
```

---

### Task 7: Update existing hierarchy tests
**Action**: MODIFY (3 test files)
**Paths**:
- `tests/test-hierarchy-detector.sh`
- `tests/test-hierarchical-initialization.sh`
- `tests/test-role-guide-selection.sh`
**Priority**: HIGH
**Estimate**: 3 hours

**Changes**: Add custom path test scenarios to each

**Validation**:
```bash
./tests/test-hierarchy-detector.sh
./tests/test-hierarchical-initialization.sh
./tests/test-role-guide-selection.sh
```

---

### Task 8: Create integration test - hierarchy with custom paths
**Action**: CREATE
**Path**: `tests/test-hierarchy-with-custom-paths.sh`
**Size**: ~400 lines
**Priority**: CRITICAL
**Estimate**: 4 hours

**Test Cases**:
- Hierarchy detection with `.myorg` instead of `.claude`
- Parent-child relationships across custom directories
- Role guide inheritance with custom `guides` directory
- Mixed path scenarios (parent `.claude`, child `.myorg`)

**Validation**:
```bash
bash -n tests/test-hierarchy-with-custom-paths.sh
./tests/test-hierarchy-with-custom-paths.sh
```

---

### Task 9: Create integration test - add-role-guides with custom paths
**Action**: CREATE
**Path**: `tests/test-add-role-guides-custom-paths.sh`
**Size**: ~300 lines
**Priority**: HIGH
**Estimate**: 3 hours

**Test Cases**:
- /add-role-guides with custom paths
- Template resolution with custom directories
- Filtering with custom role-guides directory

**Validation**:
```bash
bash -n tests/test-add-role-guides-custom-paths.sh
./tests/test-add-role-guides-custom-paths.sh
```

---

### Task 10: Create integration test - combined validation
**Action**: CREATE
**Path**: `tests/test-combined-validation.sh`
**Size**: ~200 lines
**Priority**: HIGH
**Estimate**: 2 hours

**Test Cases**:
- validate-setup with both features enabled
- Conflict detection (invalid hierarchy + custom paths)
- Error handling and recovery

**Validation**:
```bash
bash -n tests/test-combined-validation.sh
./tests/test-combined-validation.sh
```

---

### Task 11: Create performance test
**Action**: CREATE
**Path**: `tests/test-hierarchy-performance.sh`
**Size**: ~300 lines
**Priority**: HIGH
**Estimate**: 3 hours

**Metrics**:
- 5-level hierarchy detection: <100ms
- Combined path+hierarchy overhead: <200ms
- Cache effectiveness

**Validation**:
```bash
./tests/test-hierarchy-performance.sh
```

---

### Task 12: Merge CHEATSHEET.md
**Action**: MODIFY
**Path**: `CHEATSHEET.md`
**Priority**: MODERATE
**Estimate**: 2 hours

**Sections**:
- Path Configuration Commands (from master)
- Organizational Commands (from workflow-enhancements)
- Combined Workflows section

**Validation**: Manual review

---

### Task 13: Merge CLAUDE.md
**Action**: MODIFY
**Path**: `CLAUDE.md`
**Priority**: MODERATE
**Estimate**: 2 hours

**Sections**:
- Path-config architecture
- Hierarchical architecture
- Combined system design

**Validation**: Manual review

---

### Task 14: Update command documentation
**Action**: MODIFY (2 files)
**Paths**:
- `commands/init-org-template.md`
- `commands/validate-setup.md`
**Priority**: MODERATE
**Estimate**: 3.5 hours

**Changes**:
- Add "Using with Custom Paths" sections
- Add "Hierarchical Organizations" sections
- Add combined examples

**Validation**: Manual review

---

### Task 15: Create HIERARCHICAL-ORGANIZATIONS.md
**Action**: CREATE
**Path**: `docs/HIERARCHICAL-ORGANIZATIONS.md`
**Size**: ~800 lines
**Priority**: MODERATE
**Estimate**: 4 hours

**Sections**:
- Company/system/product/project levels
- Parent-child relationships
- Role guide inheritance
- Using with custom paths
- Troubleshooting

**Validation**: Manual review

---

### Task 16: Create COMBINED-FEATURES.md
**Action**: CREATE
**Path**: `docs/COMBINED-FEATURES.md`
**Size**: ~600 lines
**Priority**: MODERATE
**Estimate**: 3 hours

**Sections**:
- Combined configuration examples
- Advanced workflows
- Edge cases and limitations
- Best practices

**Validation**: Manual review

---

### Task 17: Update README.md
**Action**: MODIFY
**Path**: `README.md`
**Priority**: MODERATE
**Estimate**: 1.5 hours

**Changes**:
- Add v1.7.0 features section
- Update feature list
- Add "What's New in v1.7.0"

**Validation**: Manual review

---

### Task 18: Update CHANGELOG.md
**Action**: MODIFY
**Path**: `CHANGELOG.md`
**Priority**: LOW
**Estimate**: 1 hour

**Changes**:
- Add complete v1.7.0 entry
- Document integrated features
- Note backward compatibility

**Validation**: Manual review

---

## Global Constraints

### C1: Path-Config API Usage (CRITICAL)
**Source**: `scripts/path-config.sh:7-10`
**Rule**: All path resolution MUST use path-config.sh functions
**Pattern**:
```bash
source "$SCRIPT_DIR/path-config.sh"
load_path_config
claude_dir="$(get_claude_dir_name)"
role_guides_dir="$(get_role_guides_dir)"
```
**Applies To**: Tasks 1-6

### C2: No Hardcoded Paths (CRITICAL)
**Rule**: Zero hardcoded `.claude` or `role-guides` strings in executable code
**Verification**: `git grep -n '\.claude\|role-guides' scripts/ commands/*.sh`
**Applies To**: Tasks 1-6

### C3: Source Order Dependency (HIGH)
**Rule**: Must source path-config.sh BEFORE hierarchy-detector.sh
**Pattern**:
```bash
source "$SCRIPT_DIR/path-config.sh"        # FIRST
load_path_config                            # SECOND
source "$SCRIPT_DIR/hierarchy-detector.sh" # THIRD
```
**Applies To**: Tasks 2-5

### C4: Backward Compatibility (CRITICAL)
**Rule**: Default behavior must be identical to v1.6.0
**Verification**: `./tests/test-backward-compatibility.sh` must pass
**Applies To**: All tasks

### C5: Shellcheck Compliance (HIGH)
**Rule**: All bash scripts must pass shellcheck
**Verification**: `shellcheck scripts/*.sh commands/*.sh`
**Applies To**: Tasks 1-6

### C6: Test Coverage (HIGH)
**Rule**: All new functionality must have test coverage
**Applies To**: Tasks 7-11

---

## Success Markers

### Validation Commands

**V1: Syntax Validation**
```bash
bash -n scripts/hierarchy-detector.sh
bash -n scripts/role-manager.sh
bash -n scripts/level-detector.sh
bash -n scripts/template-manager.sh
bash -n scripts/post-install.sh
bash -n commands/add-role-guides.sh
```
Expected: All pass (exit code 0)

**V2: Shellcheck Validation**
```bash
shellcheck scripts/hierarchy-detector.sh
shellcheck scripts/role-manager.sh
shellcheck scripts/level-detector.sh
shellcheck scripts/template-manager.sh
shellcheck scripts/post-install.sh
shellcheck commands/add-role-guides.sh
```
Expected: No errors (exit code 0)

**V3: Hardcoded Path Check**
```bash
git grep -n '\.claude\|role-guides' scripts/ commands/*.sh \
  | grep -v "^[^:]*:[^:]*:#" \
  | grep -v "get_claude_dir_name\|get_role_guides_dir"
```
Expected: No results

**V4: Path-Config Tests (No Regression)**
```bash
./tests/test-path-config.sh
./tests/test-custom-paths-integration.sh
./tests/test-backward-compatibility.sh
./tests/test-path-config-performance.sh
```
Expected: All pass

**V5: Hierarchy Tests (With Refactored Code)**
```bash
./tests/test-hierarchy-detector.sh
./tests/test-hierarchical-initialization.sh
./tests/test-role-guide-selection.sh
```
Expected: All pass

**V6: Integration Tests (New)**
```bash
./tests/test-hierarchy-with-custom-paths.sh
./tests/test-add-role-guides-custom-paths.sh
./tests/test-combined-validation.sh
```
Expected: All pass

**V7: Performance Tests**
```bash
./tests/test-path-config-performance.sh
./tests/test-hierarchy-performance.sh
```
Expected: All operations within thresholds

**V8: E2E Scenario 1 - Custom Paths + Hierarchy**
```bash
export RCM_CLAUDE_DIR_NAME=".testorg"
export RCM_ROLE_GUIDES_DIR="test-guides"
cd /tmp/test-e2e-1
./commands/init-org-template.sh software-org --level=company --no-git
test -d .testorg
test -f .testorg/organizational-level.json
mkdir child-system && cd child-system
./commands/init-org-template.sh software-org --level=system --no-git
test -d .testorg
grep -q "parent_claude_dir" .testorg/organizational-level.json
```
Expected: All assertions pass

**V9: E2E Scenario 2 - Backward Compatibility**
```bash
unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR
cd /tmp/test-e2e-2
./commands/init-org-template.sh startup-org --level=company --no-git
test -d .claude
test -d .claude/role-guides
mkdir child-product && cd child-product
./commands/init-org-template.sh startup-org --level=product --no-git
test -d .claude
grep -q "parent_claude_dir" .claude/organizational-level.json
```
Expected: Works like v1.6.0

**V10: /add-role-guides Command**
```bash
cd /tmp/test-add-guides
export RCM_CLAUDE_DIR_NAME=".custom"
export RCM_ROLE_GUIDES_DIR="guides"
./commands/init-org-template.sh software-org --level=company --no-git --no-role-guides
test -d .custom/guides
./commands/add-role-guides.sh software-engineer-guide.md
test -f .custom/guides/software-engineer-guide.md
```
Expected: Guide added to correct custom directory

---

## Test Strategy

### Test Pyramid
```
     E2E Tests (3 scenarios)
    Integration Tests (4 files, ~80 tests)
   Unit Tests (existing ~150 tests updated)
```

### Test Execution Order

**Phase 1: Individual Feature Tests**
- Run existing path-config tests (V4)
- Run updated hierarchy tests (V5)

**Phase 2: Integration Tests**
- Run new integration tests (V6)

**Phase 3: Performance Tests**
- Run performance tests (V7)

**Phase 4: End-to-End Scenarios**
- Run E2E scenarios (V8, V9, V10)

---

## Implementation Phases

### Phase 1: Core Refactoring (Days 1-3, 12 hours)
- Task 1: Refactor hierarchy-detector.sh (6 hours) ⚠️ CRITICAL
- Task 2: Integrate role-manager.sh (3 hours)
- Task 3: Integrate level-detector.sh (2 hours)
- Initial validation (1 hour)

### Phase 2: Secondary Refactoring (Day 4, 6 hours)
- Task 4: template-manager.sh (2 hours)
- Task 5: post-install.sh (1 hour)
- Task 6: add-role-guides command (1.5 hours)
- Testing (1.5 hours)

### Phase 3: Testing (Day 5, 8 hours)
- Task 7: Update existing tests (3 hours)
- Task 8-10: Create integration tests (9 hours)
- Task 11: Performance tests (3 hours)
- Full test suite run (2 hours)

### Phase 4: Documentation (Day 6, 6 hours)
- Task 12-14: Merge existing docs (7.5 hours)
- Task 15-16: Create new docs (7 hours)
- Task 17-18: Update README/CHANGELOG (2.5 hours)

### Phase 5: Final Validation (Day 7, 4 hours)
- All validation checks (1 hour)
- E2E scenarios (2 hours)
- Code review (1 hour)
- Merge to master (30 minutes)

---

## Risk Analysis

### High Risks

**Risk 1: Incomplete Path Refactoring** ⚠️
- Probability: MEDIUM
- Impact: HIGH
- Mitigation: Automated grep check (V3), test with non-standard paths
- Detection: Test with `RCM_CLAUDE_DIR_NAME=".nonstandard"`

**Risk 2: Hierarchy Detection Fails with Custom Paths** ⚠️
- Probability: MEDIUM
- Impact: HIGH
- Mitigation: Comprehensive integration tests (Task 8)
- Detection: V6, V8 tests

**Risk 3: Backward Compatibility Break** ⚠️
- Probability: LOW
- Impact: CRITICAL
- Mitigation: Existing test suite, V9 E2E scenario
- Detection: V4, V9 tests

**Risk 4: Performance Degradation**
- Probability: LOW
- Impact: MEDIUM
- Mitigation: Performance testing (Task 11)
- Detection: V7 tests

### Rollback Plan
```bash
# Immediate rollback
git checkout master              # Master unchanged
git branch -D integrate-workflow-enhancements
```

---

## Acceptance Criteria

### Must Have (Release Blockers)

1. ✅ All hardcoded paths refactored (V3 passes)
2. ✅ All tests pass (V4-V7 pass)
3. ✅ Hierarchy works with custom paths (V8 passes)
4. ✅ Backward compatibility maintained (V9 passes)
5. ✅ Performance within limits (V7 passes)
6. ✅ Documentation complete (Tasks 12-18)

### Should Have

7. ✅ Code quality maintained (V2 passes)
8. ✅ /add-role-guides works (V10 passes)
9. ✅ Combined validation works

---

## Timeline

**Total**: 40 hours (7 days sequential, 3-4 days with 2 developers)

- Day 1: Setup (4 hours)
- Days 2-3: Core refactoring (12 hours)
- Day 4: Secondary refactoring (6 hours)
- Day 5: Testing (8 hours)
- Day 6: Documentation (6 hours)
- Day 7: Validation & merge (4 hours)

---

## Approval

**Blueprint Status**: READY FOR DECOMPOSITION

**Approved by**: _______________
**Date**: _______________

---

**End of WEAVER_BLUEPRINT.md**
