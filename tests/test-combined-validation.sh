#!/usr/bin/env bash

# test-combined-validation.sh - Test combined validation of path-config + hierarchy features
#
# Tests validation when both custom paths and hierarchical organization features are active

set -o pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0
TEST_TMP="/tmp/test-combined-$$"

# Source scripts
HIERARCHY_DETECTOR="$PROJECT_ROOT/scripts/hierarchy-detector.sh"
PATH_CONFIG="$PROJECT_ROOT/scripts/path-config.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

test_pass() { echo -e "${GREEN}✓${NC} $1"; ((TESTS_PASSED++)); return 0; }
test_fail() { echo -e "${RED}✗${NC} $1"; ((TESTS_FAILED++)); return 0; }
test_section() { echo ""; echo "═══ $1 ═══"; }

# Cleanup function
cleanup() {
    rm -rf "$TEST_TMP"
    unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR
}
trap cleanup EXIT

# Setup test environment
setup_test_env() {
    rm -rf "$TEST_TMP"
    mkdir -p "$TEST_TMP"
    unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR
}

# Source the scripts
source "$PATH_CONFIG" 2>/dev/null || {
    echo "Error: Could not source $PATH_CONFIG" >&2
    exit 1
}

source "$HIERARCHY_DETECTOR" 2>/dev/null || {
    echo "Error: Could not source $HIERARCHY_DETECTOR" >&2
    exit 1
}

# Restore shell options after sourcing
set +e
set +u

echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Combined Validation - Test Suite                    ║"
echo "╚═══════════════════════════════════════════════════════╝"

# =============================================================================
# Test 1: Script Validation
# =============================================================================
test_section "Script Validation"

if [[ -f "$PATH_CONFIG" ]]; then
    test_pass "path-config.sh exists"
else
    test_fail "path-config.sh missing"
fi

if bash -n "$PATH_CONFIG" 2>/dev/null; then
    test_pass "path-config.sh syntax valid"
else
    test_fail "path-config.sh syntax error"
fi

if [[ -f "$HIERARCHY_DETECTOR" ]]; then
    test_pass "hierarchy-detector.sh exists"
else
    test_fail "hierarchy-detector.sh missing"
fi

if bash -n "$HIERARCHY_DETECTOR" 2>/dev/null; then
    test_pass "hierarchy-detector.sh syntax valid"
else
    test_fail "hierarchy-detector.sh syntax error"
fi

# =============================================================================
# Test 2: Combined Feature - Custom Path + Hierarchy
# =============================================================================
test_section "Combined Feature - Custom Path + Hierarchy"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".testorg"
export RCM_ROLE_GUIDES_DIR="guides"

# Load path config
load_path_config

# Get configured paths
CLAUDE_DIR=$(get_claude_dir_name)
GUIDES_DIR=$(get_role_guides_dir)

if [[ "$CLAUDE_DIR" == ".testorg" ]]; then
    test_pass "path-config returns custom claude directory name"
else
    test_fail "path-config did not return custom directory (got: $CLAUDE_DIR)"
fi

if [[ "$GUIDES_DIR" == "guides" ]]; then
    test_pass "path-config returns custom role guides directory"
else
    test_fail "path-config did not return custom guides dir (got: $GUIDES_DIR)"
fi

# Create company level with custom paths
mkdir -p "$TEST_TMP/company/.testorg"
save_level_with_hierarchy "$TEST_TMP/company/.testorg" "company" "Test Company" >/dev/null 2>&1

if [[ -f "$TEST_TMP/company/.testorg/organizational-level.json" ]]; then
    test_pass "Combined: Created company level with custom paths"
else
    test_fail "Combined: Failed to create company level"
fi

# Create product under company with custom paths
mkdir -p "$TEST_TMP/company/product/.testorg"
save_level_with_hierarchy "$TEST_TMP/company/product/.testorg" "product" "Test Product" >/dev/null 2>&1

if [[ -f "$TEST_TMP/company/product/.testorg/organizational-level.json" ]]; then
    test_pass "Combined: Created product level with custom paths"

    PARENT=$(jq -r '.parent_claude_dir' "$TEST_TMP/company/product/.testorg/organizational-level.json")
    if [[ "$PARENT" == "$TEST_TMP/company/.testorg" ]]; then
        test_pass "Combined: Product correctly references custom parent"
    else
        test_fail "Combined: Product parent reference incorrect: $PARENT"
    fi
else
    test_fail "Combined: Failed to create product level"
fi

unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR

# =============================================================================
# Test 3: Path Traversal Protection with Custom Paths
# =============================================================================
test_section "Path Traversal Protection"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".secure"

load_path_config

# Test that path traversal is detected in custom directory names
RESULT=$(validate_claude_dir_name "../.evil" 2>&1 || echo "FAILED")
if echo "$RESULT" | grep -q "FAILED\|traversal\|Invalid"; then
    test_pass "Security: Rejects path traversal in custom directory name"
else
    test_fail "Security: Did not reject path traversal"
fi

# Test that path traversal is detected in role guides directory
RESULT=$(validate_role_guides_dir "../evil-guides" 2>&1 || echo "FAILED")
if echo "$RESULT" | grep -q "FAILED\|traversal\|Invalid"; then
    test_pass "Security: Rejects path traversal in role guides directory"
else
    test_fail "Security: Did not reject path traversal in guides dir"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 4: Conflict Detection - Invalid Hierarchy with Custom Paths
# =============================================================================
test_section "Conflict Detection"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".conflict"

# Create project as root (invalid - project shouldn't be root typically)
mkdir -p "$TEST_TMP/invalid-project/.conflict"
save_level_with_hierarchy "$TEST_TMP/invalid-project/.conflict" "project" "Invalid Project" >/dev/null 2>&1

# Try to create product under project (invalid relationship)
mkdir -p "$TEST_TMP/invalid-project/invalid-product/.conflict"
RESULT=$(save_level_with_hierarchy "$TEST_TMP/invalid-project/invalid-product/.conflict" "product" "Invalid Product" 2>&1 || echo "ERROR")

if echo "$RESULT" | grep -q "Error.*Invalid hierarchy\|ERROR"; then
    test_pass "Conflict: Detects invalid hierarchy with custom paths"
else
    test_fail "Conflict: Did not detect invalid hierarchy: $RESULT"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 5: Backward Compatibility - Default Behavior
# =============================================================================
test_section "Backward Compatibility"

setup_test_env
# Don't set any custom environment variables

load_path_config

CLAUDE_DIR=$(get_claude_dir_name)
GUIDES_DIR=$(get_role_guides_dir)

if [[ "$CLAUDE_DIR" == ".claude" ]]; then
    test_pass "Backward compat: Defaults to .claude when no config"
else
    test_fail "Backward compat: Did not default to .claude (got: $CLAUDE_DIR)"
fi

if [[ "$GUIDES_DIR" == "role-guides" ]]; then
    test_pass "Backward compat: Defaults to role-guides when no config"
else
    test_fail "Backward compat: Did not default to role-guides (got: $GUIDES_DIR)"
fi

# Create standard hierarchy
mkdir -p "$TEST_TMP/standard-company/.claude"
save_level_with_hierarchy "$TEST_TMP/standard-company/.claude" "company" "Standard Company" >/dev/null 2>&1

if [[ -f "$TEST_TMP/standard-company/.claude/organizational-level.json" ]]; then
    test_pass "Backward compat: Standard hierarchy still works"
else
    test_fail "Backward compat: Standard hierarchy failed"
fi

# =============================================================================
# Test 6: Error Handling - Missing Configuration
# =============================================================================
test_section "Error Handling"

setup_test_env
export RCM_CLAUDE_DIR_NAME=""
export RCM_ROLE_GUIDES_DIR=""

load_path_config

# Empty strings should fall back to defaults
CLAUDE_DIR=$(get_claude_dir_name)
if [[ "$CLAUDE_DIR" == ".claude" ]]; then
    test_pass "Error handling: Empty config falls back to defaults"
else
    test_fail "Error handling: Empty config did not fall back (got: $CLAUDE_DIR)"
fi

unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR

# =============================================================================
# Test 7: Combined Validation - Deep Hierarchy with Custom Paths
# =============================================================================
test_section "Deep Hierarchy with Custom Paths"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".deep"

# Create 4-level hierarchy
mkdir -p "$TEST_TMP/comp/.deep"
save_level_with_hierarchy "$TEST_TMP/comp/.deep" "company" "comp" >/dev/null 2>&1

mkdir -p "$TEST_TMP/comp/sys/.deep"
save_level_with_hierarchy "$TEST_TMP/comp/sys/.deep" "system" "sys" >/dev/null 2>&1

mkdir -p "$TEST_TMP/comp/sys/prod/.deep"
save_level_with_hierarchy "$TEST_TMP/comp/sys/prod/.deep" "product" "prod" >/dev/null 2>&1

mkdir -p "$TEST_TMP/comp/sys/prod/proj/.deep"
save_level_with_hierarchy "$TEST_TMP/comp/sys/prod/proj/.deep" "project" "proj" >/dev/null 2>&1

# Verify complete hierarchy
HIERARCHY=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/comp/sys/prod/proj/.deep/organizational-level.json")
if [[ "$HIERARCHY" == "company,system,product,project" ]]; then
    test_pass "Deep hierarchy: 4-level hierarchy correct with custom paths"
else
    test_fail "Deep hierarchy: Hierarchy incorrect: $HIERARCHY"
fi

# Validate the hierarchy
cd "$TEST_TMP/comp/sys/prod/proj"
if validate_hierarchy "$PWD" >/dev/null 2>&1; then
    test_pass "Deep hierarchy: Validation passes for custom 4-level hierarchy"
else
    test_fail "Deep hierarchy: Validation failed"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 8: Performance - Combined Overhead
# =============================================================================
test_section "Performance - Combined Overhead"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".perf"

# Create 3-level hierarchy
mkdir -p "$TEST_TMP/perf-comp/.perf"
save_level_with_hierarchy "$TEST_TMP/perf-comp/.perf" "company" "perf-comp" >/dev/null 2>&1

mkdir -p "$TEST_TMP/perf-comp/perf-prod/.perf"
save_level_with_hierarchy "$TEST_TMP/perf-comp/perf-prod/.perf" "product" "perf-prod" >/dev/null 2>&1

mkdir -p "$TEST_TMP/perf-comp/perf-prod/perf-proj/.perf"

# Time the combined operation: load path config + save level with hierarchy
START=$(date +%s%N)
load_path_config
save_level_with_hierarchy "$TEST_TMP/perf-comp/perf-prod/perf-proj/.perf" "project" "perf-proj" >/dev/null 2>&1
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))

if [[ "$ELAPSED_MS" -lt 200 ]]; then
    test_pass "Performance: Combined overhead <200ms ($ELAPSED_MS ms)"
else
    test_fail "Performance: Combined overhead too high ($ELAPSED_MS ms)"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 9: Edge Case - Switching Custom Paths Mid-Session
# =============================================================================
test_section "Edge Case - Switching Custom Paths"

setup_test_env

# Start with default
load_path_config
CLAUDE_DIR_1=$(get_claude_dir_name)

# Switch to custom
export RCM_CLAUDE_DIR_NAME=".custom1"
load_path_config
CLAUDE_DIR_2=$(get_claude_dir_name)

# Switch again
export RCM_CLAUDE_DIR_NAME=".custom2"
load_path_config
CLAUDE_DIR_3=$(get_claude_dir_name)

if [[ "$CLAUDE_DIR_1" == ".claude" && "$CLAUDE_DIR_2" == ".custom1" && "$CLAUDE_DIR_3" == ".custom2" ]]; then
    test_pass "Edge case: Path config updates correctly when environment changes"
else
    test_fail "Edge case: Path config not updating (got: $CLAUDE_DIR_1, $CLAUDE_DIR_2, $CLAUDE_DIR_3)"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 10: Cache Behavior with Combined Features
# =============================================================================
test_section "Cache Behavior"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".cached"

# First call - uncached
START=$(date +%s%N)
load_path_config
CLAUDE_DIR_1=$(get_claude_dir_name)
END=$(date +%s%N)
ELAPSED_1=$(( (END - START) / 1000000 ))

# Second call - should be cached
START=$(date +%s%N)
CLAUDE_DIR_2=$(get_claude_dir_name)
END=$(date +%s%N)
ELAPSED_2=$(( (END - START) / 1000000 ))

if [[ "$CLAUDE_DIR_1" == "$CLAUDE_DIR_2" ]]; then
    test_pass "Cache: Returned same value on repeated calls"
else
    test_fail "Cache: Values differ ($CLAUDE_DIR_1 vs $CLAUDE_DIR_2)"
fi

if [[ "$ELAPSED_2" -le "$ELAPSED_1" ]]; then
    test_pass "Cache: Second call not slower than first ($ELAPSED_1 ms vs $ELAPSED_2 ms)"
else
    test_fail "Cache: Second call slower ($ELAPSED_1 ms vs $ELAPSED_2 ms)"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Test Results                                         ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All combined validation tests passed${NC}"
    echo ""
    echo "Combined features are working correctly:"
    echo "  ✓ Custom path configuration"
    echo "  ✓ Hierarchical organization"
    echo "  ✓ Security validation"
    echo "  ✓ Performance within limits"
    echo "  ✓ Backward compatibility maintained"
    exit 0
else
    echo -e "${RED}✗ Some combined validation tests failed${NC}"
    exit 1
fi
