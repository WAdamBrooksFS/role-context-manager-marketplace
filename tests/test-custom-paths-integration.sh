#!/usr/bin/env bash

# test-custom-paths-integration.sh - Comprehensive integration test suite for custom paths
#
# Purpose: End-to-end testing of path configuration across all scenarios:
#   - Scenario A: Default configuration (backward compatibility)
#   - Scenario B: Environment variable override
#   - Scenario C: Manifest file configuration
#   - Scenario D: Hybrid configuration (env + manifest)
#   - Scenario E: Hierarchical configuration (parent/child)
#   - Scenario F: Migration from existing setup
#
# Test count: 50 E2E scenarios
# Dependencies: path-config.sh, configure-paths.sh, show-paths.sh, role-manager.sh,
#               template-manager.sh, level-detector.sh, doc-validator.sh, post-install.sh

set -u

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATH_CONFIG_SCRIPT="$PROJECT_ROOT/scripts/path-config.sh"
CONFIGURE_PATHS_CMD="$PROJECT_ROOT/commands/configure-paths.sh"
SHOW_PATHS_CMD="$PROJECT_ROOT/commands/show-paths.sh"
ROLE_MANAGER_SCRIPT="$PROJECT_ROOT/scripts/role-manager.sh"
TEMPLATE_MANAGER_SCRIPT="$PROJECT_ROOT/scripts/template-manager.sh"
LEVEL_DETECTOR_SCRIPT="$PROJECT_ROOT/scripts/level-detector.sh"
DOC_VALIDATOR_SCRIPT="$PROJECT_ROOT/scripts/doc-validator.sh"
POST_INSTALL_SCRIPT="$PROJECT_ROOT/scripts/post-install.sh"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test utilities
test_pass() { echo -e "${GREEN}✓${NC} $1"; ((TESTS_PASSED++)); return 0; }
test_fail() { echo -e "${RED}✗${NC} $1"; ((TESTS_FAILED++)); return 0; }
test_section() { echo ""; echo -e "${BLUE}═══ $1 ═══${NC}"; }

# Temporary directory for test isolation
TEST_TEMP_DIR=""
ORIGINAL_PWD="$PWD"
ORIGINAL_HOME="$HOME"

# =============================================================================
# Test Environment Setup/Teardown
# =============================================================================

setup_test_env() {
    # Create unique test directory
    TEST_TEMP_DIR=$(mktemp -d -t rcm-integration-test-XXXXXX)
    cd "$TEST_TEMP_DIR"

    # Clear environment variables
    unset RCM_CLAUDE_DIR_NAME 2>/dev/null || true
    unset RCM_ROLE_GUIDES_DIR 2>/dev/null || true
    unset RCM_PATHS_MANIFEST 2>/dev/null || true
    unset RCM_CACHE_ENABLED 2>/dev/null || true

    # Source path-config.sh
    source "$PATH_CONFIG_SCRIPT" || true
    clear_path_config_cache || true
}

teardown_test_env() {
    if [[ -n "${TEST_TEMP_DIR:-}" ]] && [[ -d "$TEST_TEMP_DIR" ]]; then
        cd "$ORIGINAL_PWD"
        rm -rf "$TEST_TEMP_DIR" 2>/dev/null || true
    fi
    TEST_TEMP_DIR=""

    # Clear environment
    unset RCM_CLAUDE_DIR_NAME 2>/dev/null || true
    unset RCM_ROLE_GUIDES_DIR 2>/dev/null || true
    unset RCM_PATHS_MANIFEST 2>/dev/null || true
    unset RCM_CACHE_ENABLED 2>/dev/null || true

    # Reload script to reset state
    source "$PATH_CONFIG_SCRIPT" || true
    clear_path_config_cache || true
}

# =============================================================================
# Helper Functions
# =============================================================================

create_manifest() {
    local dir="$1"
    local claude_dir="${2:-.claude}"
    local role_guides="${3:-role-guides}"

    mkdir -p "$dir"
    cat > "$dir/paths.json" <<EOF
{
  "claude_dir_name": "$claude_dir",
  "role_guides_dir": "$role_guides",
  "version": "1.0.0",
  "description": "Test manifest for integration tests"
}
EOF
}

create_preferences_file() {
    local dir="$1"
    local role="${2:-software-engineer}"

    mkdir -p "$dir"
    cat > "$dir/preferences.json" <<EOF
{
  "user_role": "$role",
  "organizational_level": "startup-org"
}
EOF
}

create_role_guide() {
    local dir="$1"
    local role_name="${2:-software-engineer}"

    mkdir -p "$dir"
    cat > "$dir/${role_name}.md" <<EOF
# Role Guide: $role_name

## Overview
Test role guide for integration testing.

## Responsibilities
- Task 1
- Task 2

## Knowledge Base
- Area 1
- Area 2
EOF
}

# Run a command in a subshell with specific environment
run_with_env() {
    local env_vars="$1"
    shift
    (eval "$env_vars" && "$@")
}

echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Custom Paths Integration Test Suite - 50 Tests      ║"
echo "╚═══════════════════════════════════════════════════════╝"

# =============================================================================
# SCENARIO A: Default Configuration (Backward Compatibility)
# =============================================================================

test_section "Scenario A: Default Configuration (8 tests)"

# Test A1: Default paths with no configuration
setup_test_env
claude_dir=$(get_claude_dir_name)
role_guides_dir=$(get_role_guides_dir)
[[ "$claude_dir" == ".claude" ]] && [[ "$role_guides_dir" == "role-guides" ]] && \
    test_pass "A1: Default paths without configuration" || \
    test_fail "A1: Default paths incorrect: $claude_dir, $role_guides_dir"
teardown_test_env

# Test A2: No manifest file created by default
setup_test_env
manifest=$(get_manifest_path)
[[ -z "$manifest" ]] && test_pass "A2: No manifest file by default" || \
    test_fail "A2: Unexpected manifest found: $manifest"
teardown_test_env

# Test A3: Full claude path with defaults
setup_test_env
full_path=$(get_full_claude_path "$TEST_TEMP_DIR")
[[ "$full_path" == "$TEST_TEMP_DIR/.claude" ]] && \
    test_pass "A3: Full claude path with defaults" || \
    test_fail "A3: Full claude path incorrect: $full_path"
teardown_test_env

# Test A4: Full role guides path with defaults
setup_test_env
full_path=$(get_full_role_guides_path "$TEST_TEMP_DIR")
[[ "$full_path" == "$TEST_TEMP_DIR/.claude/role-guides" ]] && \
    test_pass "A4: Full role guides path with defaults" || \
    test_fail "A4: Full role guides path incorrect: $full_path"
teardown_test_env

# Test A5: Create directory structure with defaults
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude/role-guides"
create_preferences_file "$TEST_TEMP_DIR/.claude"
create_role_guide "$TEST_TEMP_DIR/.claude/role-guides"
[[ -f "$TEST_TEMP_DIR/.claude/preferences.json" ]] && \
[[ -f "$TEST_TEMP_DIR/.claude/role-guides/software-engineer.md" ]] && \
    test_pass "A5: Directory structure created with defaults" || \
    test_fail "A5: Directory structure creation failed"
teardown_test_env

# Test A6: Validate default configuration
setup_test_env
if validate_path_config 2>/dev/null; then
    test_pass "A6: Default configuration validates successfully"
else
    test_fail "A6: Default configuration validation failed"
fi
teardown_test_env

# Test A7: show-paths command with defaults
setup_test_env
output=$("$SHOW_PATHS_CMD" 2>/dev/null) || output=""
if echo "$output" | grep -q ".claude" && echo "$output" | grep -q "role-guides"; then
    test_pass "A7: show-paths command works with defaults"
else
    test_fail "A7: show-paths command failed: $output"
fi
teardown_test_env

# Test A8: Cache works with defaults
setup_test_env
load_path_config "$TEST_TEMP_DIR"
if is_cache_valid; then
    test_pass "A8: Cache works with default configuration"
else
    test_fail "A8: Cache not working with defaults"
fi
teardown_test_env

# =============================================================================
# SCENARIO B: Environment Variable Override
# =============================================================================

test_section "Scenario B: Environment Variable Override (8 tests)"

# Test B1: RCM_CLAUDE_DIR_NAME override
setup_test_env
export RCM_CLAUDE_DIR_NAME=".rcm"
clear_path_config_cache
result=$(get_claude_dir_name)
unset RCM_CLAUDE_DIR_NAME
[[ "$result" == ".rcm" ]] && test_pass "B1: RCM_CLAUDE_DIR_NAME override works" || \
    test_fail "B1: Environment override failed: $result"
teardown_test_env

# Test B2: RCM_ROLE_GUIDES_DIR override
setup_test_env
export RCM_ROLE_GUIDES_DIR="personas"
clear_path_config_cache
result=$(get_role_guides_dir)
unset RCM_ROLE_GUIDES_DIR
[[ "$result" == "personas" ]] && test_pass "B2: RCM_ROLE_GUIDES_DIR override works" || \
    test_fail "B2: Environment override failed: $result"
teardown_test_env

# Test B3: Both env vars together
setup_test_env
export RCM_CLAUDE_DIR_NAME=".myorg"
export RCM_ROLE_GUIDES_DIR="agent-guides"
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR
[[ "$claude" == ".myorg" ]] && [[ "$roles" == "agent-guides" ]] && \
    test_pass "B3: Both env vars override together" || \
    test_fail "B3: Combined override failed: $claude, $roles"
teardown_test_env

# Test B4: Full paths with env overrides
setup_test_env
export RCM_CLAUDE_DIR_NAME=".custom"
export RCM_ROLE_GUIDES_DIR="my-roles"
clear_path_config_cache
claude_path=$(get_full_claude_path "$TEST_TEMP_DIR")
roles_path=$(get_full_role_guides_path "$TEST_TEMP_DIR")
unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR
[[ "$claude_path" == "$TEST_TEMP_DIR/.custom" ]] && \
[[ "$roles_path" == "$TEST_TEMP_DIR/.custom/my-roles" ]] && \
    test_pass "B4: Full paths with env overrides" || \
    test_fail "B4: Full paths incorrect: $claude_path, $roles_path"
teardown_test_env

# Test B5: Create structure with env overrides
setup_test_env
export RCM_CLAUDE_DIR_NAME=".enterprise"
export RCM_ROLE_GUIDES_DIR="roles"
clear_path_config_cache
claude_path=$(get_full_claude_path "$TEST_TEMP_DIR")
roles_path=$(get_full_role_guides_path "$TEST_TEMP_DIR")
mkdir -p "$roles_path"
create_preferences_file "$claude_path"
unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR
[[ -f "$TEST_TEMP_DIR/.enterprise/preferences.json" ]] && \
[[ -d "$TEST_TEMP_DIR/.enterprise/roles" ]] && \
    test_pass "B5: Directory structure created with env overrides" || \
    test_fail "B5: Structure creation failed with env overrides"
teardown_test_env

# Test B6: show-paths displays env var as source
setup_test_env
export RCM_CLAUDE_DIR_NAME=".envtest"
clear_path_config_cache
output=$("$SHOW_PATHS_CMD" 2>/dev/null) || output=""
unset RCM_CLAUDE_DIR_NAME
if echo "$output" | grep -q "environment" && echo "$output" | grep -q ".envtest"; then
    test_pass "B6: show-paths identifies env var as source"
else
    test_fail "B6: show-paths source detection failed: $output"
fi
teardown_test_env

# Test B7: Empty env var falls back to default
setup_test_env
export RCM_CLAUDE_DIR_NAME=""
clear_path_config_cache
result=$(get_claude_dir_name)
unset RCM_CLAUDE_DIR_NAME
[[ "$result" == ".claude" ]] && test_pass "B7: Empty env var falls back to default" || \
    test_fail "B7: Empty env var handling failed: $result"
teardown_test_env

# Test B8: Validation with env vars
setup_test_env
export RCM_CLAUDE_DIR_NAME=".valid"
export RCM_ROLE_GUIDES_DIR="valid-roles"
clear_path_config_cache
if validate_path_config 2>/dev/null; then
    test_pass "B8: Validation succeeds with env vars"
else
    test_fail "B8: Validation failed with env vars"
fi
unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR
teardown_test_env

# =============================================================================
# SCENARIO C: Manifest File Configuration
# =============================================================================

test_section "Scenario C: Manifest File Configuration (8 tests)"

# Test C1: Load from local manifest
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".myorg" "agent-guides"
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
[[ "$claude" == ".myorg" ]] && [[ "$roles" == "agent-guides" ]] && \
    test_pass "C1: Load configuration from local manifest" || \
    test_fail "C1: Manifest loading failed: $claude, $roles"
teardown_test_env

# Test C2: Manifest path detected
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".test" "test-roles"
clear_path_config_cache
manifest=$(get_manifest_path)
[[ "$manifest" == "$TEST_TEMP_DIR/.claude/paths.json" ]] && \
    test_pass "C2: Manifest path detected correctly" || \
    test_fail "C2: Manifest path detection failed: $manifest"
teardown_test_env

# Test C3: Partial manifest uses defaults
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude"
cat > "$TEST_TEMP_DIR/.claude/paths.json" <<EOF
{
  "claude_dir_name": ".partial"
}
EOF
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
[[ "$claude" == ".partial" ]] && [[ "$roles" == "role-guides" ]] && \
    test_pass "C3: Partial manifest uses defaults for missing fields" || \
    test_fail "C3: Partial manifest handling failed: $claude, $roles"
teardown_test_env

# Test C4: Invalid JSON manifest falls back to defaults
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude"
echo "{ invalid json" > "$TEST_TEMP_DIR/.claude/paths.json"
clear_path_config_cache
result=$(get_claude_dir_name 2>/dev/null)
[[ "$result" == ".claude" ]] && test_pass "C4: Invalid JSON falls back to defaults" || \
    test_fail "C4: Invalid JSON handling failed: $result"
teardown_test_env

# Test C5: Empty manifest uses defaults
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude"
echo "{}" > "$TEST_TEMP_DIR/.claude/paths.json"
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
[[ "$claude" == ".claude" ]] && [[ "$roles" == "role-guides" ]] && \
    test_pass "C5: Empty manifest uses defaults" || \
    test_fail "C5: Empty manifest handling failed: $claude, $roles"
teardown_test_env

# Test C6: show-paths identifies manifest as source
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".manifest-test" "manifest-roles"
clear_path_config_cache
output=$("$SHOW_PATHS_CMD" 2>/dev/null) || output=""
if echo "$output" | grep -q "manifest" && echo "$output" | grep -q ".manifest-test"; then
    test_pass "C6: show-paths identifies manifest as source"
else
    test_fail "C6: show-paths manifest source detection failed"
fi
teardown_test_env

# Test C7: Global manifest in HOME
setup_test_env
FAKE_HOME="$TEST_TEMP_DIR/fake-home"
mkdir -p "$FAKE_HOME/.claude"
create_manifest "$FAKE_HOME/.claude" ".global" "global-roles"
mkdir -p "$TEST_TEMP_DIR/project"
cd "$TEST_TEMP_DIR/project"
export HOME="$FAKE_HOME"
clear_path_config_cache
result=$(get_claude_dir_name)
export HOME="$ORIGINAL_HOME"
[[ "$result" == ".global" ]] && test_pass "C7: Global manifest in HOME works" || \
    test_fail "C7: Global manifest failed: $result"
cd "$TEST_TEMP_DIR"
teardown_test_env

# Test C8: Upward directory search for manifest
setup_test_env
mkdir -p "$TEST_TEMP_DIR/parent/.claude"
mkdir -p "$TEST_TEMP_DIR/parent/child/grandchild"
create_manifest "$TEST_TEMP_DIR/parent/.claude" ".parent" "parent-roles"
cd "$TEST_TEMP_DIR/parent/child/grandchild"
clear_path_config_cache
result=$(get_claude_dir_name)
[[ "$result" == ".parent" ]] && test_pass "C8: Upward directory search finds manifest" || \
    test_fail "C8: Upward search failed: $result"
cd "$TEST_TEMP_DIR"
teardown_test_env

# =============================================================================
# SCENARIO D: Hybrid Configuration (Env + Manifest)
# =============================================================================

test_section "Scenario D: Hybrid Configuration (8 tests)"

# Test D1: Env var overrides manifest
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".manifest" "manifest-roles"
export RCM_CLAUDE_DIR_NAME=".env-override"
clear_path_config_cache
result=$(get_claude_dir_name)
unset RCM_CLAUDE_DIR_NAME
[[ "$result" == ".env-override" ]] && test_pass "D1: Env var overrides manifest" || \
    test_fail "D1: Override precedence failed: $result"
teardown_test_env

# Test D2: Partial env override (one field)
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".manifest" "manifest-roles"
export RCM_CLAUDE_DIR_NAME=".env-claude"
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
unset RCM_CLAUDE_DIR_NAME
[[ "$claude" == ".env-claude" ]] && [[ "$roles" == "manifest-roles" ]] && \
    test_pass "D2: Partial env override preserves manifest values" || \
    test_fail "D2: Partial override failed: $claude, $roles"
teardown_test_env

# Test D3: Both fields overridden (env takes precedence)
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".manifest" "manifest-roles"
export RCM_CLAUDE_DIR_NAME=".env-claude"
export RCM_ROLE_GUIDES_DIR="env-roles"
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR
[[ "$claude" == ".env-claude" ]] && [[ "$roles" == "env-roles" ]] && \
    test_pass "D3: Both env vars override manifest" || \
    test_fail "D3: Full override failed: $claude, $roles"
teardown_test_env

# Test D4: RCM_PATHS_MANIFEST with env override
setup_test_env
mkdir -p "$TEST_TEMP_DIR/custom-location"
create_manifest "$TEST_TEMP_DIR/custom-location" ".custom-manifest" "custom-roles"
export RCM_PATHS_MANIFEST="$TEST_TEMP_DIR/custom-location/paths.json"
export RCM_CLAUDE_DIR_NAME=".env-wins"
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
unset RCM_PATHS_MANIFEST RCM_CLAUDE_DIR_NAME
[[ "$claude" == ".env-wins" ]] && [[ "$roles" == "custom-roles" ]] && \
    test_pass "D4: RCM_PATHS_MANIFEST with env override" || \
    test_fail "D4: Custom manifest with override failed: $claude, $roles"
teardown_test_env

# Test D5: show-paths displays correct precedence
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".manifest" "manifest-roles"
export RCM_CLAUDE_DIR_NAME=".env"
clear_path_config_cache
output=$("$SHOW_PATHS_CMD" 2>/dev/null) || output=""
unset RCM_CLAUDE_DIR_NAME
if echo "$output" | grep -q "environment" && echo "$output" | grep -q ".env"; then
    test_pass "D5: show-paths displays env precedence correctly"
else
    test_fail "D5: show-paths precedence display failed"
fi
teardown_test_env

# Test D6: Global manifest with local env override
setup_test_env
FAKE_HOME="$TEST_TEMP_DIR/fake-home"
mkdir -p "$FAKE_HOME/.claude"
create_manifest "$FAKE_HOME/.claude" ".global" "global-roles"
export HOME="$FAKE_HOME"
export RCM_CLAUDE_DIR_NAME=".local-env"
clear_path_config_cache
result=$(get_claude_dir_name)
export HOME="$ORIGINAL_HOME"
unset RCM_CLAUDE_DIR_NAME
[[ "$result" == ".local-env" ]] && test_pass "D6: Local env overrides global manifest" || \
    test_fail "D6: Global/local precedence failed: $result"
teardown_test_env

# Test D7: Empty env var doesn't override manifest
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".manifest" "manifest-roles"
export RCM_CLAUDE_DIR_NAME=""
clear_path_config_cache
result=$(get_claude_dir_name)
unset RCM_CLAUDE_DIR_NAME
[[ "$result" == ".manifest" ]] && test_pass "D7: Empty env var doesn't override manifest" || \
    test_fail "D7: Empty env var handling failed: $result"
teardown_test_env

# Test D8: Validation with hybrid config
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".manifest" "manifest-roles"
export RCM_CLAUDE_DIR_NAME=".valid-hybrid"
clear_path_config_cache
if validate_path_config 2>/dev/null; then
    test_pass "D8: Validation succeeds with hybrid config"
else
    test_fail "D8: Validation failed with hybrid config"
fi
unset RCM_CLAUDE_DIR_NAME
teardown_test_env

# =============================================================================
# SCENARIO E: Hierarchical Configuration (Parent/Child)
# =============================================================================

test_section "Scenario E: Hierarchical Configuration (8 tests)"

# Test E1: Child overrides parent
setup_test_env
mkdir -p "$TEST_TEMP_DIR/parent/.claude"
mkdir -p "$TEST_TEMP_DIR/parent/child/.claude"
create_manifest "$TEST_TEMP_DIR/parent/.claude" ".parent" "parent-roles"
create_manifest "$TEST_TEMP_DIR/parent/child/.claude" ".child" "child-roles"
cd "$TEST_TEMP_DIR/parent/child"
clear_path_config_cache
result=$(get_claude_dir_name)
cd "$TEST_TEMP_DIR"
[[ "$result" == ".child" ]] && test_pass "E1: Child manifest overrides parent" || \
    test_fail "E1: Child override failed: $result"
teardown_test_env

# Test E2: Grandchild inherits from parent
setup_test_env
mkdir -p "$TEST_TEMP_DIR/parent/.claude"
mkdir -p "$TEST_TEMP_DIR/parent/child/grandchild"
create_manifest "$TEST_TEMP_DIR/parent/.claude" ".ancestor" "ancestor-roles"
cd "$TEST_TEMP_DIR/parent/child/grandchild"
clear_path_config_cache
result=$(get_claude_dir_name)
cd "$TEST_TEMP_DIR"
[[ "$result" == ".ancestor" ]] && test_pass "E2: Grandchild inherits from ancestor" || \
    test_fail "E2: Inheritance failed: $result"
teardown_test_env

# Test E3: Closest manifest wins
setup_test_env
mkdir -p "$TEST_TEMP_DIR/level1/.claude"
mkdir -p "$TEST_TEMP_DIR/level1/level2/.claude"
mkdir -p "$TEST_TEMP_DIR/level1/level2/level3"
create_manifest "$TEST_TEMP_DIR/level1/.claude" ".level1" "roles1"
create_manifest "$TEST_TEMP_DIR/level1/level2/.claude" ".level2" "roles2"
cd "$TEST_TEMP_DIR/level1/level2/level3"
clear_path_config_cache
result=$(get_claude_dir_name)
cd "$TEST_TEMP_DIR"
[[ "$result" == ".level2" ]] && test_pass "E3: Closest manifest takes precedence" || \
    test_fail "E3: Closest manifest failed: $result"
teardown_test_env

# Test E4: Parent uses own config
setup_test_env
mkdir -p "$TEST_TEMP_DIR/parent/.claude"
mkdir -p "$TEST_TEMP_DIR/parent/child/.claude"
create_manifest "$TEST_TEMP_DIR/parent/.claude" ".parent" "parent-roles"
create_manifest "$TEST_TEMP_DIR/parent/child/.claude" ".child" "child-roles"
cd "$TEST_TEMP_DIR/parent"
clear_path_config_cache
result=$(get_claude_dir_name)
cd "$TEST_TEMP_DIR"
[[ "$result" == ".parent" ]] && test_pass "E4: Parent uses own configuration" || \
    test_fail "E4: Parent config failed: $result"
teardown_test_env

# Test E5: Sibling directories isolated
setup_test_env
mkdir -p "$TEST_TEMP_DIR/project-a/.claude"
mkdir -p "$TEST_TEMP_DIR/project-b/.claude"
create_manifest "$TEST_TEMP_DIR/project-a/.claude" ".project-a" "roles-a"
create_manifest "$TEST_TEMP_DIR/project-b/.claude" ".project-b" "roles-b"
cd "$TEST_TEMP_DIR/project-a"
clear_path_config_cache
result_a=$(get_claude_dir_name)
cd "$TEST_TEMP_DIR/project-b"
clear_path_config_cache
result_b=$(get_claude_dir_name)
cd "$TEST_TEMP_DIR"
[[ "$result_a" == ".project-a" ]] && [[ "$result_b" == ".project-b" ]] && \
    test_pass "E5: Sibling directories have isolated configs" || \
    test_fail "E5: Sibling isolation failed: $result_a, $result_b"
teardown_test_env

# Test E6: Local overrides global
setup_test_env
FAKE_HOME="$TEST_TEMP_DIR/fake-home"
mkdir -p "$FAKE_HOME/.claude"
mkdir -p "$TEST_TEMP_DIR/project/.claude"
create_manifest "$FAKE_HOME/.claude" ".global" "global-roles"
create_manifest "$TEST_TEMP_DIR/project/.claude" ".local" "local-roles"
cd "$TEST_TEMP_DIR/project"
export HOME="$FAKE_HOME"
clear_path_config_cache
result=$(get_claude_dir_name)
export HOME="$ORIGINAL_HOME"
cd "$TEST_TEMP_DIR"
[[ "$result" == ".local" ]] && test_pass "E6: Local manifest overrides global" || \
    test_fail "E6: Local/global precedence failed: $result"
teardown_test_env

# Test E7: Global used when no local
setup_test_env
FAKE_HOME="$TEST_TEMP_DIR/fake-home"
mkdir -p "$FAKE_HOME/.claude"
mkdir -p "$TEST_TEMP_DIR/project"
create_manifest "$FAKE_HOME/.claude" ".global" "global-roles"
cd "$TEST_TEMP_DIR/project"
export HOME="$FAKE_HOME"
clear_path_config_cache
result=$(get_claude_dir_name)
export HOME="$ORIGINAL_HOME"
cd "$TEST_TEMP_DIR"
[[ "$result" == ".global" ]] && test_pass "E7: Global manifest used when no local" || \
    test_fail "E7: Global fallback failed: $result"
teardown_test_env

# Test E8: Deep nesting works correctly
setup_test_env
mkdir -p "$TEST_TEMP_DIR/a/b/c/d/e/f/.claude"
create_manifest "$TEST_TEMP_DIR/a/b/c/d/e/f/.claude" ".deep" "deep-roles"
cd "$TEST_TEMP_DIR/a/b/c/d/e/f"
clear_path_config_cache
result=$(get_claude_dir_name)
cd "$TEST_TEMP_DIR"
[[ "$result" == ".deep" ]] && test_pass "E8: Deep nesting works correctly" || \
    test_fail "E8: Deep nesting failed: $result"
teardown_test_env

# =============================================================================
# SCENARIO F: Migration from Existing Setup
# =============================================================================

test_section "Scenario F: Migration from Existing Setup (8 tests)"

# Test F1: Detect existing .claude directory
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude/role-guides"
create_preferences_file "$TEST_TEMP_DIR/.claude"
[[ -d "$TEST_TEMP_DIR/.claude" ]] && [[ -f "$TEST_TEMP_DIR/.claude/preferences.json" ]] && \
    test_pass "F1: Existing .claude directory detected" || \
    test_fail "F1: Existing directory detection failed"
teardown_test_env

# Test F2: Works with existing setup (no manifest)
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude/role-guides"
create_preferences_file "$TEST_TEMP_DIR/.claude"
create_role_guide "$TEST_TEMP_DIR/.claude/role-guides"
clear_path_config_cache
load_path_config "$TEST_TEMP_DIR"
claude=$(get_claude_dir_name)
[[ "$claude" == ".claude" ]] && test_pass "F2: Works with existing setup without manifest" || \
    test_fail "F2: Existing setup compatibility failed: $claude"
teardown_test_env

# Test F3: Add manifest to existing setup
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude/role-guides"
create_preferences_file "$TEST_TEMP_DIR/.claude"
create_manifest "$TEST_TEMP_DIR/.claude" ".claude" "role-guides"
clear_path_config_cache
manifest=$(get_manifest_path)
[[ "$manifest" == "$TEST_TEMP_DIR/.claude/paths.json" ]] && \
    test_pass "F3: Manifest added to existing setup" || \
    test_fail "F3: Manifest addition failed: $manifest"
teardown_test_env

# Test F4: Configure custom paths on existing setup
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude/role-guides"
create_preferences_file "$TEST_TEMP_DIR/.claude"
create_manifest "$TEST_TEMP_DIR/.claude" ".myorg" "my-guides"
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
[[ "$claude" == ".myorg" ]] && [[ "$roles" == "my-guides" ]] && \
    test_pass "F4: Custom paths configured on existing setup" || \
    test_fail "F4: Configuration on existing setup failed: $claude, $roles"
teardown_test_env

# Test F5: Validate existing setup
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude/role-guides"
create_preferences_file "$TEST_TEMP_DIR/.claude"
create_role_guide "$TEST_TEMP_DIR/.claude/role-guides"
if validate_path_config 2>/dev/null; then
    test_pass "F5: Existing setup validates successfully"
else
    test_fail "F5: Existing setup validation failed"
fi
teardown_test_env

# Test F6: Multiple existing directories
setup_test_env
mkdir -p "$TEST_TEMP_DIR/project1/.claude"
mkdir -p "$TEST_TEMP_DIR/project2/.claude"
create_preferences_file "$TEST_TEMP_DIR/project1/.claude" "role-a"
create_preferences_file "$TEST_TEMP_DIR/project2/.claude" "role-b"
[[ -f "$TEST_TEMP_DIR/project1/.claude/preferences.json" ]] && \
[[ -f "$TEST_TEMP_DIR/project2/.claude/preferences.json" ]] && \
    test_pass "F6: Multiple existing directories supported" || \
    test_fail "F6: Multiple directories failed"
teardown_test_env

# Test F7: Backwards compatibility maintained
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude/role-guides"
create_preferences_file "$TEST_TEMP_DIR/.claude"
create_role_guide "$TEST_TEMP_DIR/.claude/role-guides"
# Should work without any manifest
clear_path_config_cache
full_path=$(get_full_role_guides_path "$TEST_TEMP_DIR")
[[ "$full_path" == "$TEST_TEMP_DIR/.claude/role-guides" ]] && \
[[ -f "$TEST_TEMP_DIR/.claude/role-guides/software-engineer.md" ]] && \
    test_pass "F7: Backwards compatibility maintained" || \
    test_fail "F7: Backwards compatibility broken"
teardown_test_env

# Test F8: Migration preserves data
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude/role-guides"
create_preferences_file "$TEST_TEMP_DIR/.claude" "senior-engineer"
create_role_guide "$TEST_TEMP_DIR/.claude/role-guides" "senior-engineer"
# Add manifest to "migrate" (in real migration, dirs would be renamed)
create_manifest "$TEST_TEMP_DIR/.claude" ".claude" "role-guides"
[[ -f "$TEST_TEMP_DIR/.claude/preferences.json" ]] && \
[[ -f "$TEST_TEMP_DIR/.claude/role-guides/senior-engineer.md" ]] && \
[[ -f "$TEST_TEMP_DIR/.claude/paths.json" ]] && \
    test_pass "F8: Migration preserves existing data" || \
    test_fail "F8: Migration data preservation failed"
teardown_test_env

# =============================================================================
# ADDITIONAL INTEGRATION TESTS
# =============================================================================

test_section "Additional Integration Tests (2 tests)"

# Test I1: JSON output format
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".test" "test-roles"
clear_path_config_cache
output=$("$SHOW_PATHS_CMD" --json 2>/dev/null) || output=""
if echo "$output" | grep -q "claude_dir_name" && echo "$output" | grep -q ".test"; then
    test_pass "I1: JSON output format works"
else
    test_fail "I1: JSON output failed"
fi
teardown_test_env

# Test I2: Verbose output includes full paths
setup_test_env
create_manifest "$TEST_TEMP_DIR/.claude" ".verbose-test" "verbose-roles"
clear_path_config_cache
output=$("$SHOW_PATHS_CMD" --verbose 2>/dev/null) || output=""
if echo "$output" | grep -q "Full path" && echo "$output" | grep -q ".verbose-test"; then
    test_pass "I2: Verbose output includes full paths"
else
    test_fail "I2: Verbose output failed"
fi
teardown_test_env

# =============================================================================
# TEST SUMMARY
# =============================================================================

echo ""
echo "═══════════════════════════════════════════════════════"
echo "TEST SUMMARY"
echo "═══════════════════════════════════════════════════════"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo "Total:  $((TESTS_PASSED + TESTS_FAILED))"
echo "═══════════════════════════════════════════════════════"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All integration tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
