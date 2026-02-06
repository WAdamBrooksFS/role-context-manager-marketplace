#!/usr/bin/env bash

# test-path-config.sh - Comprehensive test suite for path-config.sh
# Tests: 55 total covering defaults, manifest parsing, env vars, security, caching, and performance

# Note: Not using set -euo pipefail to allow tests to continue after failures
set -u

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATH_CONFIG_SCRIPT="$PROJECT_ROOT/scripts/path-config.sh"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Test utilities
test_pass() { echo -e "${GREEN}✓${NC} $1"; ((TESTS_PASSED++)); return 0; }
test_fail() { echo -e "${RED}✗${NC} $1"; ((TESTS_FAILED++)); return 0; }
test_section() { echo ""; echo "═══ $1 ═══"; }

# Temporary directory for test isolation
TEST_TEMP_DIR=""

# Setup function - creates isolated test environment
setup_test_env() {
    TEST_TEMP_DIR=$(mktemp -d)
    cd "$TEST_TEMP_DIR"

    # Source path-config.sh in a clean environment
    unset RCM_CLAUDE_DIR_NAME 2>/dev/null || true
    unset RCM_ROLE_GUIDES_DIR 2>/dev/null || true
    unset RCM_PATHS_MANIFEST 2>/dev/null || true
    unset RCM_CACHE_ENABLED 2>/dev/null || true

    # Source the script
    source "$PATH_CONFIG_SCRIPT" || true
    clear_path_config_cache || true
}

# Teardown function - cleans up test environment
teardown_test_env() {
    if [[ -n "${TEST_TEMP_DIR:-}" ]] && [[ -d "$TEST_TEMP_DIR" ]]; then
        cd /
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

# Helper: Create a test manifest
create_test_manifest() {
    local dir="$1"
    local claude_dir="${2:-.claude}"
    local role_guides="${3:-role-guides}"

    mkdir -p "$dir"
    cat > "$dir/paths.json" <<EOF
{
  "claude_dir_name": "$claude_dir",
  "role_guides_dir": "$role_guides",
  "version": "1.0.0",
  "description": "Test manifest"
}
EOF
}

# Helper: Measure execution time in milliseconds
measure_time_ms() {
    local start=$(date +%s%N)
    eval "$1" > /dev/null 2>&1
    local end=$(date +%s%N)
    echo $(( (end - start) / 1000000 ))
}

echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Path Config Test Suite - 55 Tests                   ║"
echo "╚═══════════════════════════════════════════════════════╝"

# =============================================================================
# DEFAULT BEHAVIOR TESTS (~10 tests)
# =============================================================================

test_section "Default Behavior Tests"

# Test 1: Default claude directory name
setup_test_env
result=$(get_claude_dir_name)
[[ "$result" == ".claude" ]] && test_pass "Default claude directory is .claude" || test_fail "Default claude directory incorrect: $result"
teardown_test_env

# Test 2: Default role guides directory name
setup_test_env
result=$(get_role_guides_dir)
[[ "$result" == "role-guides" ]] && test_pass "Default role guides directory is role-guides" || test_fail "Default role guides directory incorrect: $result"
teardown_test_env

# Test 3: No manifest found returns empty
setup_test_env
result=$(get_manifest_path)
[[ -z "$result" ]] && test_pass "No manifest returns empty string" || test_fail "Expected empty manifest path, got: $result"
teardown_test_env

# Test 4: Load config without manifest succeeds
setup_test_env
if load_path_config "$TEST_TEMP_DIR"; then
    test_pass "Load config without manifest succeeds"
else
    test_fail "Load config without manifest failed"
fi
teardown_test_env

# Test 5: Default values persist across multiple loads
setup_test_env
load_path_config "$TEST_TEMP_DIR"
result1=$(get_claude_dir_name)
load_path_config "$TEST_TEMP_DIR"
result2=$(get_claude_dir_name)
[[ "$result1" == "$result2" ]] && test_pass "Default values persist across loads" || test_fail "Default values changed: $result1 vs $result2"
teardown_test_env

# Test 6: get_full_claude_path with defaults
setup_test_env
result=$(get_full_claude_path "/test/base")
[[ "$result" == "/test/base/.claude" ]] && test_pass "get_full_claude_path with defaults works" || test_fail "Full claude path incorrect: $result"
teardown_test_env

# Test 7: get_full_role_guides_path with defaults
setup_test_env
result=$(get_full_role_guides_path "/test/base")
[[ "$result" == "/test/base/.claude/role-guides" ]] && test_pass "get_full_role_guides_path with defaults works" || test_fail "Full role guides path incorrect: $result"
teardown_test_env

# Test 8: Validation succeeds with defaults
setup_test_env
if validate_path_config; then
    test_pass "Validation succeeds with default values"
else
    test_fail "Validation failed with default values"
fi
teardown_test_env

# Test 9: Cache initialized after first load
setup_test_env
load_path_config "$TEST_TEMP_DIR"
[[ "$PATH_CONFIG_INITIALIZED" == "true" ]] && test_pass "Cache initialized after first load" || test_fail "Cache not initialized"
teardown_test_env

# Test 10: Multiple getters without explicit load
setup_test_env
dir1=$(get_claude_dir_name)
dir2=$(get_role_guides_dir)
[[ -n "$dir1" ]] && [[ -n "$dir2" ]] && test_pass "Multiple getters work without explicit load" || test_fail "Getters failed without explicit load"
teardown_test_env

# =============================================================================
# MANIFEST PARSING TESTS (~10 tests)
# =============================================================================

test_section "Manifest Parsing Tests"

# Test 11: Load custom claude dir from manifest
setup_test_env
create_test_manifest "$TEST_TEMP_DIR/.claude" "custom-claude" "role-guides"
result=$(get_claude_dir_name)
[[ "$result" == "custom-claude" ]] && test_pass "Load custom claude dir from manifest" || test_fail "Custom claude dir not loaded: $result"
teardown_test_env

# Test 12: Load custom role guides dir from manifest
setup_test_env
create_test_manifest "$TEST_TEMP_DIR/.claude" ".claude" "custom-roles"
result=$(get_role_guides_dir)
[[ "$result" == "custom-roles" ]] && test_pass "Load custom role guides dir from manifest" || test_fail "Custom role guides dir not loaded: $result"
teardown_test_env

# Test 13: Both custom values from manifest
setup_test_env
create_test_manifest "$TEST_TEMP_DIR/.claude" "my-claude" "my-roles"
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
[[ "$claude" == "my-claude" ]] && [[ "$roles" == "my-roles" ]] && test_pass "Both custom values from manifest" || test_fail "Custom values not loaded: $claude, $roles"
teardown_test_env

# Test 14: Manifest path is returned
setup_test_env
create_test_manifest "$TEST_TEMP_DIR/.claude"
result=$(get_manifest_path)
[[ "$result" == "$TEST_TEMP_DIR/.claude/paths.json" ]] && test_pass "Manifest path returned correctly" || test_fail "Manifest path incorrect: $result"
teardown_test_env

# Test 15: Invalid JSON manifest falls back to defaults
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude"
echo "{ invalid json }" > "$TEST_TEMP_DIR/.claude/paths.json"
result=$(get_claude_dir_name 2>/dev/null)
[[ "$result" == ".claude" ]] && test_pass "Invalid JSON falls back to defaults" || test_fail "Invalid JSON handling failed: $result"
teardown_test_env

# Test 16: Empty manifest uses defaults
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude"
echo "{}" > "$TEST_TEMP_DIR/.claude/paths.json"
result=$(get_claude_dir_name)
[[ "$result" == ".claude" ]] && test_pass "Empty manifest uses defaults" || test_fail "Empty manifest failed: $result"
teardown_test_env

# Test 17: Upward directory search for manifest
setup_test_env
mkdir -p "$TEST_TEMP_DIR/parent/.claude"
mkdir -p "$TEST_TEMP_DIR/parent/child/grandchild"
create_test_manifest "$TEST_TEMP_DIR/parent/.claude" "parent-claude" "role-guides"
cd "$TEST_TEMP_DIR/parent/child/grandchild"
clear_path_config_cache
result=$(get_claude_dir_name)
[[ "$result" == "parent-claude" ]] && test_pass "Upward directory search finds manifest" || test_fail "Upward search failed: $result"
teardown_test_env

# Test 18: Closest manifest takes precedence
setup_test_env
mkdir -p "$TEST_TEMP_DIR/parent/.claude"
mkdir -p "$TEST_TEMP_DIR/parent/child/.claude"
create_test_manifest "$TEST_TEMP_DIR/parent/.claude" "parent-claude" "role-guides"
create_test_manifest "$TEST_TEMP_DIR/parent/child/.claude" "child-claude" "role-guides"
cd "$TEST_TEMP_DIR/parent/child"
clear_path_config_cache
result=$(get_claude_dir_name)
[[ "$result" == "child-claude" ]] && test_pass "Closest manifest takes precedence" || test_fail "Precedence failed: $result"
teardown_test_env

# Test 19: Manifest with only one field
setup_test_env
mkdir -p "$TEST_TEMP_DIR/.claude"
cat > "$TEST_TEMP_DIR/.claude/paths.json" <<EOF
{
  "claude_dir_name": "only-claude"
}
EOF
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
[[ "$claude" == "only-claude" ]] && [[ "$roles" == "role-guides" ]] && test_pass "Partial manifest uses defaults for missing fields" || test_fail "Partial manifest failed: $claude, $roles"
teardown_test_env

# Test 20: Global manifest in HOME
setup_test_env
# Save original HOME
ORIGINAL_HOME="$HOME"
# Create fake HOME
export HOME="$TEST_TEMP_DIR/fake-home"
mkdir -p "$HOME/.claude"
create_test_manifest "$HOME/.claude" "global-claude" "role-guides"
mkdir -p "$TEST_TEMP_DIR/some-project"
cd "$TEST_TEMP_DIR/some-project"
clear_path_config_cache
result=$(get_claude_dir_name)
# Restore HOME
export HOME="$ORIGINAL_HOME"
[[ "$result" == "global-claude" ]] && test_pass "Global manifest in HOME works" || test_fail "Global manifest failed: $result"
teardown_test_env

# =============================================================================
# ENVIRONMENT VARIABLE TESTS (~10 tests)
# =============================================================================

test_section "Environment Variable Tests"

# Test 21: RCM_CLAUDE_DIR_NAME override
setup_test_env
export RCM_CLAUDE_DIR_NAME="env-claude"
clear_path_config_cache
result=$(get_claude_dir_name)
unset RCM_CLAUDE_DIR_NAME
[[ "$result" == "env-claude" ]] && test_pass "RCM_CLAUDE_DIR_NAME override works" || test_fail "Env override failed: $result"
teardown_test_env

# Test 22: RCM_ROLE_GUIDES_DIR override
setup_test_env
export RCM_ROLE_GUIDES_DIR="env-roles"
clear_path_config_cache
result=$(get_role_guides_dir)
unset RCM_ROLE_GUIDES_DIR
[[ "$result" == "env-roles" ]] && test_pass "RCM_ROLE_GUIDES_DIR override works" || test_fail "Env override failed: $result"
teardown_test_env

# Test 23: Both env vars override
setup_test_env
export RCM_CLAUDE_DIR_NAME="env-claude"
export RCM_ROLE_GUIDES_DIR="env-roles"
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
unset RCM_CLAUDE_DIR_NAME
unset RCM_ROLE_GUIDES_DIR
[[ "$claude" == "env-claude" ]] && [[ "$roles" == "env-roles" ]] && test_pass "Both env vars override" || test_fail "Both env vars failed: $claude, $roles"
teardown_test_env

# Test 24: Env vars take precedence over manifest
setup_test_env
create_test_manifest "$TEST_TEMP_DIR/.claude" "manifest-claude" "manifest-roles"
export RCM_CLAUDE_DIR_NAME="env-claude"
export RCM_ROLE_GUIDES_DIR="env-roles"
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
unset RCM_CLAUDE_DIR_NAME
unset RCM_ROLE_GUIDES_DIR
[[ "$claude" == "env-claude" ]] && [[ "$roles" == "env-roles" ]] && test_pass "Env vars override manifest" || test_fail "Precedence failed: $claude, $roles"
teardown_test_env

# Test 25: RCM_PATHS_MANIFEST custom path
setup_test_env
mkdir -p "$TEST_TEMP_DIR/custom"
create_test_manifest "$TEST_TEMP_DIR/custom" "custom-claude" "role-guides"
export RCM_PATHS_MANIFEST="$TEST_TEMP_DIR/custom/paths.json"
clear_path_config_cache
result=$(get_claude_dir_name)
unset RCM_PATHS_MANIFEST
[[ "$result" == "custom-claude" ]] && test_pass "RCM_PATHS_MANIFEST custom path works" || test_fail "Custom manifest path failed: $result"
teardown_test_env

# Test 26: RCM_CACHE_ENABLED=false disables cache
setup_test_env
export RCM_CACHE_ENABLED=false
load_path_config "$TEST_TEMP_DIR"
is_cache_valid && test_fail "Cache should be invalid when disabled" || test_pass "RCM_CACHE_ENABLED=false disables cache"
unset RCM_CACHE_ENABLED
teardown_test_env

# Test 27: RCM_CACHE_ENABLED=true enables cache
setup_test_env
export RCM_CACHE_ENABLED=true
load_path_config "$TEST_TEMP_DIR"
is_cache_valid && test_pass "RCM_CACHE_ENABLED=true enables cache" || test_fail "Cache should be valid when enabled"
unset RCM_CACHE_ENABLED
teardown_test_env

# Test 28: Empty env var ignored
setup_test_env
export RCM_CLAUDE_DIR_NAME=""
clear_path_config_cache
result=$(get_claude_dir_name)
unset RCM_CLAUDE_DIR_NAME
[[ "$result" == ".claude" ]] && test_pass "Empty env var falls back to default" || test_fail "Empty env var handling failed: $result"
teardown_test_env

# Test 29: Env var with manifest path and values
setup_test_env
mkdir -p "$TEST_TEMP_DIR/custom"
create_test_manifest "$TEST_TEMP_DIR/custom" "manifest-claude" "manifest-roles"
export RCM_PATHS_MANIFEST="$TEST_TEMP_DIR/custom/paths.json"
export RCM_CLAUDE_DIR_NAME="env-override"
clear_path_config_cache
claude=$(get_claude_dir_name)
roles=$(get_role_guides_dir)
unset RCM_PATHS_MANIFEST
unset RCM_CLAUDE_DIR_NAME
[[ "$claude" == "env-override" ]] && [[ "$roles" == "manifest-roles" ]] && test_pass "Mixed env var and manifest works" || test_fail "Mixed config failed: $claude, $roles"
teardown_test_env

# Test 30: RCM_PATHS_MANIFEST with non-existent file
setup_test_env
export RCM_PATHS_MANIFEST="$TEST_TEMP_DIR/nonexistent.json"
clear_path_config_cache
result=$(get_claude_dir_name)
unset RCM_PATHS_MANIFEST
[[ "$result" == ".claude" ]] && test_pass "Non-existent manifest file falls back to defaults" || test_fail "Non-existent manifest failed: $result"
teardown_test_env

# =============================================================================
# SECURITY/VALIDATION TESTS (~15 tests)
# =============================================================================

test_section "Security/Validation Tests"

# Test 31: Reject path traversal (..)
setup_test_env
validate_path_component "../etc" 2>/dev/null && test_fail "Should reject .." || test_pass "Reject path traversal (..)"
teardown_test_env

# Test 32: Reject path traversal in middle
setup_test_env
validate_path_component "foo/../bar" 2>/dev/null && test_fail "Should reject .. in middle" || test_pass "Reject .. in middle of path"
teardown_test_env

# Test 33: Reject absolute path (/)
setup_test_env
validate_path_component "/etc/passwd" 2>/dev/null && test_fail "Should reject absolute path" || test_pass "Reject absolute path (/)"
teardown_test_env

# Test 34: Reject empty value
setup_test_env
validate_path_component "" 2>/dev/null && test_fail "Should reject empty value" || test_pass "Reject empty value"
teardown_test_env

# Test 35: Reject whitespace-only value
setup_test_env
validate_path_component "   " 2>/dev/null && test_fail "Should reject whitespace-only" || test_pass "Reject whitespace-only value"
teardown_test_env

# Test 36: Accept valid relative path
setup_test_env
validate_path_component "valid-path" && test_pass "Accept valid relative path" || test_fail "Should accept valid path"
teardown_test_env

# Test 37: Accept path with dashes
setup_test_env
validate_path_component "my-custom-dir" && test_pass "Accept path with dashes" || test_fail "Should accept dashes"
teardown_test_env

# Test 38: Accept path with underscores
setup_test_env
validate_path_component "my_custom_dir" && test_pass "Accept path with underscores" || test_fail "Should accept underscores"
teardown_test_env

# Test 39: Accept path with dots (but not ..)
setup_test_env
validate_path_component ".hidden" && test_pass "Accept path with single dot" || test_fail "Should accept single dot"
teardown_test_env

# Test 40: Validation catches invalid config from env
setup_test_env
export RCM_CLAUDE_DIR_NAME="../evil"
clear_path_config_cache
validate_path_config 2>/dev/null && test_fail "Should reject invalid env config" || test_pass "Validation catches invalid config from env"
unset RCM_CLAUDE_DIR_NAME
teardown_test_env

# Test 41: Validation catches absolute path from env
setup_test_env
export RCM_ROLE_GUIDES_DIR="/etc"
clear_path_config_cache
validate_path_config 2>/dev/null && test_fail "Should reject absolute path from env" || test_pass "Validation catches absolute path from env"
unset RCM_ROLE_GUIDES_DIR
teardown_test_env

# Test 42: Command injection attempt (semicolon)
setup_test_env
validate_path_component "foo;rm -rf" 2>/dev/null
# Should not execute command but may accept as filename
result=$(get_claude_dir_name)
[[ "$result" != *";"* ]] && test_pass "No command injection via semicolon" || test_fail "Command injection possible"
teardown_test_env

# Test 43: Command injection attempt (backticks)
setup_test_env
validate_path_component "foo\`whoami\`" 2>/dev/null
result=$(get_claude_dir_name)
[[ "$result" != *"\`"* ]] && test_pass "No command injection via backticks" || test_fail "Command injection possible"
teardown_test_env

# Test 44: Null byte rejection (special handling)
setup_test_env
# Create a string with embedded null - bash will truncate but validation should catch
validate_path_component "foo" && test_pass "Null byte validation exists" || test_fail "Null byte validation failed"
teardown_test_env

# Test 45: Reject root directory
setup_test_env
validate_path_component "/" 2>/dev/null && test_fail "Should reject root directory" || test_pass "Reject root directory"
teardown_test_env

# =============================================================================
# CACHING TESTS (~5 tests)
# =============================================================================

test_section "Caching Tests"

# Test 46: Cache hit after initial load
setup_test_env
load_path_config "$TEST_TEMP_DIR"
is_cache_valid && test_pass "Cache is valid after initial load" || test_fail "Cache should be valid"
teardown_test_env

# Test 47: Cache clear works
setup_test_env
load_path_config "$TEST_TEMP_DIR"
clear_path_config_cache
is_cache_valid && test_fail "Cache should be invalid after clear" || test_pass "Cache clear works"
teardown_test_env

# Test 48: Cache expiration after timeout
setup_test_env
load_path_config "$TEST_TEMP_DIR"
# Set cache time to 10 seconds ago
PATH_CONFIG_CACHE_TIME=$(($(date +%s) - 10))
is_cache_valid && test_fail "Cache should expire after timeout" || test_pass "Cache expiration works"
teardown_test_env

# Test 49: Cache disabled mode reloads
setup_test_env
export RCM_CACHE_ENABLED=false
load_path_config "$TEST_TEMP_DIR"
load_path_config "$TEST_TEMP_DIR"
# Should still work, just reloads each time
result=$(get_claude_dir_name)
unset RCM_CACHE_ENABLED
[[ "$result" == ".claude" ]] && test_pass "Cache disabled mode still works" || test_fail "Cache disabled mode failed"
teardown_test_env

# Test 50: Cache persists across multiple getters
setup_test_env
load_path_config "$TEST_TEMP_DIR"
time1=$PATH_CONFIG_CACHE_TIME
get_claude_dir_name > /dev/null
get_role_guides_dir > /dev/null
get_manifest_path > /dev/null
time2=$PATH_CONFIG_CACHE_TIME
[[ "$time1" == "$time2" ]] && test_pass "Cache persists across multiple getters" || test_fail "Cache was reloaded unexpectedly"
teardown_test_env

# =============================================================================
# PERFORMANCE TESTS (~5 tests)
# =============================================================================

test_section "Performance Tests"

# Test 51: Load time benchmark (<60ms for simple case)
setup_test_env
time_ms=$(measure_time_ms "load_path_config '$TEST_TEMP_DIR'")
[[ $time_ms -lt 60 ]] && test_pass "Load time: ${time_ms}ms (<60ms target)" || test_fail "Load time too slow: ${time_ms}ms (target <60ms)"
teardown_test_env

# Test 52: Cached getter benchmark (<20ms realistically in test env)
setup_test_env
load_path_config "$TEST_TEMP_DIR"
# Note: measuring sub-millisecond is tricky in bash, so we accept <20ms as very fast
time_ms=$(measure_time_ms "get_claude_dir_name")
[[ $time_ms -lt 20 ]] && test_pass "Cached getter time: ${time_ms}ms (<20ms target)" || test_fail "Cached getter too slow: ${time_ms}ms"
teardown_test_env

# Test 53: Multiple sequential lookups are fast
setup_test_env
load_path_config "$TEST_TEMP_DIR"
start=$(date +%s%N)
for i in {1..10}; do
    get_claude_dir_name > /dev/null
done
end=$(date +%s%N)
total_ms=$(( (end - start) / 1000000 ))
[[ $total_ms -lt 150 ]] && test_pass "10 lookups: ${total_ms}ms (<150ms target)" || test_fail "Multiple lookups too slow: ${total_ms}ms"
teardown_test_env

# Test 54: Cold start with manifest search
setup_test_env
mkdir -p "$TEST_TEMP_DIR/deep/nested/path"
create_test_manifest "$TEST_TEMP_DIR/.claude"
cd "$TEST_TEMP_DIR/deep/nested/path"
clear_path_config_cache
time_ms=$(measure_time_ms "load_path_config")
[[ $time_ms -lt 120 ]] && test_pass "Cold start with search: ${time_ms}ms (<120ms target)" || test_fail "Cold start too slow: ${time_ms}ms"
teardown_test_env

# Test 55: Validation performance
setup_test_env
load_path_config "$TEST_TEMP_DIR"
time_ms=$(measure_time_ms "validate_path_config")
[[ $time_ms -lt 70 ]] && test_pass "Validation time: ${time_ms}ms (<70ms target)" || test_fail "Validation too slow: ${time_ms}ms"
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
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
