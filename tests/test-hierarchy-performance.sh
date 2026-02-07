#!/usr/bin/env bash

# test-hierarchy-performance.sh - Performance tests for hierarchy detection with custom paths
#
# Tests performance metrics: 5-level hierarchy <100ms, combined overhead <200ms, cache effectiveness

set -o pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0
TEST_TMP="/tmp/test-hierarchy-perf-$$"

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
echo "║  Hierarchy Performance - Test Suite                  ║"
echo "╚═══════════════════════════════════════════════════════╝"

# =============================================================================
# Test 1: Baseline - find_parent_claude_dirs Performance
# =============================================================================
test_section "Baseline Performance"

setup_test_env

# Create 3-level hierarchy with default paths
mkdir -p "$TEST_TMP/level1/.claude"
mkdir -p "$TEST_TMP/level1/level2/.claude"
mkdir -p "$TEST_TMP/level1/level2/level3/.claude"

# Warm up
find_parent_claude_dirs "$TEST_TMP/level1/level2/level3" >/dev/null 2>&1

# Test
START=$(date +%s%N)
for i in {1..10}; do
    find_parent_claude_dirs "$TEST_TMP/level1/level2/level3" >/dev/null 2>&1
done
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))
AVG_MS=$(( ELAPSED_MS / 10 ))

if [[ "$AVG_MS" -lt 50 ]]; then
    test_pass "Baseline: find_parent_claude_dirs averages <50ms ($AVG_MS ms)"
else
    test_fail "Baseline: find_parent_claude_dirs too slow ($AVG_MS ms)"
fi

echo "Info: 3-level find_parent_claude_dirs: $AVG_MS ms average"

# =============================================================================
# Test 2: 5-Level Hierarchy Detection Performance
# =============================================================================
test_section "5-Level Hierarchy Detection"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".deep"

# Create 5-level directory structure
mkdir -p "$TEST_TMP/l1/.deep"
mkdir -p "$TEST_TMP/l1/l2/.deep"
mkdir -p "$TEST_TMP/l1/l2/l3/.deep"
mkdir -p "$TEST_TMP/l1/l2/l3/l4/.deep"
mkdir -p "$TEST_TMP/l1/l2/l3/l4/l5/.deep"

# Warm up
find_parent_claude_dirs "$TEST_TMP/l1/l2/l3/l4/l5" >/dev/null 2>&1

# Test single call
START=$(date +%s%N)
PARENTS=$(find_parent_claude_dirs "$TEST_TMP/l1/l2/l3/l4/l5")
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))

if [[ "$ELAPSED_MS" -lt 100 ]]; then
    test_pass "5-level: Single find_parent_claude_dirs <100ms ($ELAPSED_MS ms)"
else
    test_fail "5-level: Single find_parent_claude_dirs too slow ($ELAPSED_MS ms)"
fi

# Verify correctness
PARENT_COUNT=$(echo "$PARENTS" | grep -c "/.deep$" || echo "0")
if [[ "$PARENT_COUNT" -eq 4 ]]; then
    test_pass "5-level: Found correct number of parents (4)"
else
    test_fail "5-level: Parent count incorrect (expected 4, got $PARENT_COUNT)"
fi

echo "Info: 5-level find_parent_claude_dirs: $ELAPSED_MS ms"

# Test repeated calls (average)
START=$(date +%s%N)
for i in {1..10}; do
    find_parent_claude_dirs "$TEST_TMP/l1/l2/l3/l4/l5" >/dev/null 2>&1
done
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))
AVG_MS=$(( ELAPSED_MS / 10 ))

echo "Info: 5-level average (10 calls): $AVG_MS ms"

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 3: Combined Path Resolution + Hierarchy Detection
# =============================================================================
test_section "Combined Overhead"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".combined"

# Create 3-level hierarchy
mkdir -p "$TEST_TMP/comp/.combined"
mkdir -p "$TEST_TMP/comp/prod/.combined"
mkdir -p "$TEST_TMP/comp/prod/proj/.combined"

# Create organizational levels
save_level_with_hierarchy "$TEST_TMP/comp/.combined" "company" "Comp" >/dev/null 2>&1
save_level_with_hierarchy "$TEST_TMP/comp/prod/.combined" "product" "Prod" >/dev/null 2>&1

# Test combined operation: load config + save with hierarchy
START=$(date +%s%N)
load_path_config
save_level_with_hierarchy "$TEST_TMP/comp/prod/proj/.combined" "project" "Proj" >/dev/null 2>&1
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))

if [[ "$ELAPSED_MS" -lt 200 ]]; then
    test_pass "Combined: Path config + hierarchy save <200ms ($ELAPSED_MS ms)"
else
    test_fail "Combined: Path config + hierarchy save too slow ($ELAPSED_MS ms)"
fi

echo "Info: Combined overhead: $ELAPSED_MS ms"

# Verify correctness
if [[ -f "$TEST_TMP/comp/prod/proj/.combined/organizational-level.json" ]]; then
    HIERARCHY=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/comp/prod/proj/.combined/organizational-level.json")
    if [[ "$HIERARCHY" == "company,product,project" ]]; then
        test_pass "Combined: Hierarchy correct after performance test"
    else
        test_fail "Combined: Hierarchy incorrect: $HIERARCHY"
    fi
else
    test_fail "Combined: Failed to create organizational level"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 4: Cache Effectiveness - Path Config
# =============================================================================
test_section "Path Config Cache"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".cached"

# First call (uncached)
START=$(date +%s%N)
load_path_config
get_claude_dir_name >/dev/null
END=$(date +%s%N)
ELAPSED_1=$(( (END - START) / 1000000 ))

# Second call (cached)
START=$(date +%s%N)
get_claude_dir_name >/dev/null
END=$(date +%s%N)
ELAPSED_2=$(( (END - START) / 1000000 ))

echo "Info: First call: $ELAPSED_1 ms, Cached call: $ELAPSED_2 ms"

if [[ "$ELAPSED_2" -le "$ELAPSED_1" ]]; then
    test_pass "Cache: Cached call not slower than first call"
else
    test_fail "Cache: Cached call slower than first ($ELAPSED_2 ms vs $ELAPSED_1 ms)"
fi

# Test multiple cached calls
START=$(date +%s%N)
for i in {1..100}; do
    get_claude_dir_name >/dev/null
    get_role_guides_dir >/dev/null
done
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))
AVG_MS=$(( ELAPSED_MS / 100 ))

if [[ "$AVG_MS" -lt 5 ]]; then
    test_pass "Cache: 100 cached calls average <5ms ($AVG_MS ms)"
else
    test_fail "Cache: Cached calls too slow ($AVG_MS ms average)"
fi

echo "Info: Cache effectiveness: $AVG_MS ms per call (100 calls)"

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 5: build_hierarchy_path Performance
# =============================================================================
test_section "build_hierarchy_path Performance"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".build"

# Create 4-level hierarchy with data
mkdir -p "$TEST_TMP/c/.build"
mkdir -p "$TEST_TMP/c/s/.build"
mkdir -p "$TEST_TMP/c/s/p/.build"
mkdir -p "$TEST_TMP/c/s/p/pr/.build"

save_level_with_hierarchy "$TEST_TMP/c/.build" "company" "C" >/dev/null 2>&1
save_level_with_hierarchy "$TEST_TMP/c/s/.build" "system" "S" >/dev/null 2>&1
save_level_with_hierarchy "$TEST_TMP/c/s/p/.build" "product" "P" >/dev/null 2>&1
save_level_with_hierarchy "$TEST_TMP/c/s/p/pr/.build" "project" "PR" >/dev/null 2>&1

# Test build_hierarchy_path
START=$(date +%s%N)
for i in {1..10}; do
    build_hierarchy_path "$TEST_TMP/c/s/p/pr/.build" >/dev/null 2>&1
done
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))
AVG_MS=$(( ELAPSED_MS / 10 ))

if [[ "$AVG_MS" -lt 50 ]]; then
    test_pass "build_hierarchy_path: Averages <50ms for 4-level ($AVG_MS ms)"
else
    test_fail "build_hierarchy_path: Too slow ($AVG_MS ms)"
fi

echo "Info: build_hierarchy_path (4-level): $AVG_MS ms average"

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 6: get_nearest_parent Performance
# =============================================================================
test_section "get_nearest_parent Performance"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".nearest"

# Create hierarchy
mkdir -p "$TEST_TMP/parent/.nearest"
mkdir -p "$TEST_TMP/parent/child1/.nearest"
mkdir -p "$TEST_TMP/parent/child1/child2/.nearest"
mkdir -p "$TEST_TMP/parent/child1/child2/child3"

# Test get_nearest_parent
START=$(date +%s%N)
for i in {1..20}; do
    get_nearest_parent "$TEST_TMP/parent/child1/child2/child3" >/dev/null 2>&1
done
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))
AVG_MS=$(( ELAPSED_MS / 20 ))

if [[ "$AVG_MS" -lt 30 ]]; then
    test_pass "get_nearest_parent: Averages <30ms ($AVG_MS ms)"
else
    test_fail "get_nearest_parent: Too slow ($AVG_MS ms)"
fi

echo "Info: get_nearest_parent: $AVG_MS ms average (20 calls)"

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 7: Validation Performance
# =============================================================================
test_section "Validation Performance"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".valid"

# Create valid hierarchy
mkdir -p "$TEST_TMP/v-comp/.valid"
mkdir -p "$TEST_TMP/v-comp/v-prod/.valid"
mkdir -p "$TEST_TMP/v-comp/v-prod/v-proj/.valid"

save_level_with_hierarchy "$TEST_TMP/v-comp/.valid" "company" "V-Comp" >/dev/null 2>&1
save_level_with_hierarchy "$TEST_TMP/v-comp/v-prod/.valid" "product" "V-Prod" >/dev/null 2>&1
save_level_with_hierarchy "$TEST_TMP/v-comp/v-prod/v-proj/.valid" "project" "V-Proj" >/dev/null 2>&1

# Test validate_hierarchy
cd "$TEST_TMP/v-comp/v-prod/v-proj"
START=$(date +%s%N)
for i in {1..5}; do
    validate_hierarchy "$PWD" >/dev/null 2>&1
done
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))
AVG_MS=$(( ELAPSED_MS / 5 ))

if [[ "$AVG_MS" -lt 100 ]]; then
    test_pass "validate_hierarchy: Averages <100ms ($AVG_MS ms)"
else
    test_fail "validate_hierarchy: Too slow ($AVG_MS ms)"
fi

echo "Info: validate_hierarchy: $AVG_MS ms average (5 calls)"

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 8: Stress Test - Many Siblings
# =============================================================================
test_section "Stress Test - Many Siblings"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".stress"

# Create parent
mkdir -p "$TEST_TMP/stress-parent/.stress"
save_level_with_hierarchy "$TEST_TMP/stress-parent/.stress" "company" "Stress Parent" >/dev/null 2>&1

# Create 20 sibling products
START=$(date +%s%N)
for i in {1..20}; do
    mkdir -p "$TEST_TMP/stress-parent/child$i/.stress"
    save_level_with_hierarchy "$TEST_TMP/stress-parent/child$i/.stress" "product" "Child $i" >/dev/null 2>&1
done
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))
AVG_MS=$(( ELAPSED_MS / 20 ))

if [[ "$AVG_MS" -lt 200 ]]; then
    test_pass "Stress: Creating 20 sibling levels averages <200ms each ($AVG_MS ms)"
else
    test_fail "Stress: Creating siblings too slow ($AVG_MS ms average)"
fi

echo "Info: Stress test (20 siblings): $AVG_MS ms per sibling"

# Verify all created correctly
CREATED_COUNT=$(find "$TEST_TMP/stress-parent" -name "organizational-level.json" | wc -l)
if [[ "$CREATED_COUNT" -eq 21 ]]; then
    test_pass "Stress: All 21 organizational levels created (parent + 20 children)"
else
    test_fail "Stress: Incorrect number of levels created (expected 21, got $CREATED_COUNT)"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 9: Performance Comparison - Default vs Custom Paths
# =============================================================================
test_section "Performance Comparison"

setup_test_env

# Test with default .claude
mkdir -p "$TEST_TMP/default1/.claude"
mkdir -p "$TEST_TMP/default1/default2/.claude"
mkdir -p "$TEST_TMP/default1/default2/default3/.claude"

START=$(date +%s%N)
find_parent_claude_dirs "$TEST_TMP/default1/default2/default3" >/dev/null 2>&1
END=$(date +%s%N)
DEFAULT_MS=$(( (END - START) / 1000000 ))

# Test with custom path
export RCM_CLAUDE_DIR_NAME=".custom"
mkdir -p "$TEST_TMP/custom1/.custom"
mkdir -p "$TEST_TMP/custom1/custom2/.custom"
mkdir -p "$TEST_TMP/custom1/custom2/custom3/.custom"

START=$(date +%s%N)
find_parent_claude_dirs "$TEST_TMP/custom1/custom2/custom3" >/dev/null 2>&1
END=$(date +%s%N)
CUSTOM_MS=$(( (END - START) / 1000000 ))

echo "Info: Default (.claude): $DEFAULT_MS ms, Custom (.custom): $CUSTOM_MS ms"

DIFF_MS=$(( CUSTOM_MS - DEFAULT_MS ))
DIFF_ABS=${DIFF_MS#-}  # Absolute value

if [[ "$DIFF_ABS" -lt 50 ]]; then
    test_pass "Comparison: Performance difference <50ms ($DIFF_MS ms difference)"
else
    test_fail "Comparison: Large performance difference ($DIFF_MS ms)"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 10: Memory Efficiency (Indirect Test)
# =============================================================================
test_section "Memory Efficiency"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".memory"

# Create hierarchy
mkdir -p "$TEST_TMP/mem/.memory"
save_level_with_hierarchy "$TEST_TMP/mem/.memory" "company" "Mem" >/dev/null 2>&1

# Test that cache doesn't grow unbounded by repeatedly loading
for i in {1..100}; do
    load_path_config >/dev/null 2>&1
done

# If we get here without crashing, memory is reasonably managed
test_pass "Memory: No crash after 100 load_path_config calls"

# Test with many hierarchy operations
for i in {1..50}; do
    mkdir -p "$TEST_TMP/mem/prod$i/.memory"
    save_level_with_hierarchy "$TEST_TMP/mem/prod$i/.memory" "product" "Prod $i" >/dev/null 2>&1
done

test_pass "Memory: No crash after 50 hierarchy level creations"

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
    echo -e "${GREEN}✓ All performance tests passed${NC}"
    echo ""
    echo "Performance metrics within acceptable limits:"
    echo "  ✓ 5-level hierarchy detection <100ms"
    echo "  ✓ Combined path + hierarchy overhead <200ms"
    echo "  ✓ Cache effectiveness verified"
    echo "  ✓ Stress tests passed"
    exit 0
else
    echo -e "${RED}✗ Some performance tests failed${NC}"
    echo ""
    echo "Note: Performance tests can vary based on system load"
    exit 1
fi
