#!/usr/bin/env bash

# test-hierarchy-detector.sh - Test suite for hierarchy-detector.sh

set -o pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HIERARCHY_DETECTOR="$PROJECT_ROOT/scripts/hierarchy-detector.sh"
TESTS_PASSED=0
TESTS_FAILED=0
TEST_TMP="/tmp/test-hierarchy-$$"

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
}
trap cleanup EXIT

# Setup test environment
setup_test_env() {
    rm -rf "$TEST_TMP"
    mkdir -p "$TEST_TMP"
}

# Source the hierarchy-detector functions
# Note: We don't use set -e because we manually check test results
source "$HIERARCHY_DETECTOR" 2>/dev/null || true

# Restore shell options after sourcing (hierarchy-detector.sh sets -euo pipefail)
set +e
set +u

echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Hierarchy Detector - Test Suite                     ║"
echo "╚═══════════════════════════════════════════════════════╝"

# Test 1: Script existence and syntax
test_section "Script Validation"
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

if [[ -x "$HIERARCHY_DETECTOR" ]]; then
    test_pass "hierarchy-detector.sh is executable"
else
    test_fail "hierarchy-detector.sh not executable"
fi

# Test 2: find_parent_claude_dirs - Basic detection
test_section "find_parent_claude_dirs - Basic Detection"
setup_test_env

# Create three-level hierarchy
mkdir -p "$TEST_TMP/level1/.claude"
mkdir -p "$TEST_TMP/level1/level2/.claude"
mkdir -p "$TEST_TMP/level1/level2/level3"

# Find parents from deepest level
RESULT=$(find_parent_claude_dirs "$TEST_TMP/level1/level2/level3")
COUNT=$(echo "$RESULT" | wc -l)

if [[ "$COUNT" -eq 2 ]]; then
    test_pass "Found correct number of parent directories (2)"
else
    test_fail "Found incorrect number of parent directories (expected: 2, got: $COUNT)"
fi

# Verify nearest parent is first
FIRST_PARENT=$(echo "$RESULT" | head -n1)
if [[ "$FIRST_PARENT" == "$TEST_TMP/level1/level2/.claude" ]]; then
    test_pass "Nearest parent is first in list"
else
    test_fail "Nearest parent not first (got: $FIRST_PARENT)"
fi

# Test 3: find_parent_claude_dirs - No parents
test_section "find_parent_claude_dirs - No Parents"
setup_test_env
mkdir -p "$TEST_TMP/isolated"

RESULT=$(find_parent_claude_dirs "$TEST_TMP/isolated" || true)
if [[ -z "$RESULT" ]]; then
    test_pass "No parents found for isolated directory"
else
    test_fail "Found parents when none should exist"
fi

# Test 4: get_nearest_parent - Basic detection
test_section "get_nearest_parent - Basic Detection"
setup_test_env

mkdir -p "$TEST_TMP/level1/.claude"
mkdir -p "$TEST_TMP/level1/level2/.claude"
mkdir -p "$TEST_TMP/level1/level2/level3"

RESULT=$(get_nearest_parent "$TEST_TMP/level1/level2/level3")
if [[ "$RESULT" == "$TEST_TMP/level1/level2/.claude" ]]; then
    test_pass "get_nearest_parent returns correct parent"
else
    test_fail "get_nearest_parent returned wrong parent (got: $RESULT)"
fi

# Test 5: get_nearest_parent - Skip current directory
test_section "get_nearest_parent - Skip Current Directory"
setup_test_env

mkdir -p "$TEST_TMP/level1/.claude"
mkdir -p "$TEST_TMP/level1/level2/.claude"

# From level2, should skip its own .claude and return level1
RESULT=$(get_nearest_parent "$TEST_TMP/level1/level2")
if [[ "$RESULT" == "$TEST_TMP/level1/.claude" ]]; then
    test_pass "get_nearest_parent correctly skips current directory"
else
    test_fail "get_nearest_parent did not skip current directory (got: $RESULT)"
fi

# Test 6: get_nearest_parent - No parent found
test_section "get_nearest_parent - No Parent"
setup_test_env
mkdir -p "$TEST_TMP/isolated"

RESULT=$(get_nearest_parent "$TEST_TMP/isolated" 2>/dev/null || true)
if [[ -z "$RESULT" ]]; then
    test_pass "get_nearest_parent returns empty for no parent"
else
    test_fail "get_nearest_parent should return empty (got: $RESULT)"
fi

# Test 7: read_level_from_claude_dir - Valid file
test_section "read_level_from_claude_dir - Valid File"
setup_test_env
mkdir -p "$TEST_TMP/test/.claude"

cat > "$TEST_TMP/test/.claude/organizational-level.json" <<'EOF'
{
  "level": "company",
  "level_name": "Test Company",
  "is_root": true
}
EOF

RESULT=$(read_level_from_claude_dir "$TEST_TMP/test/.claude")
if echo "$RESULT" | jq -e '.level == "company"' >/dev/null 2>&1; then
    test_pass "read_level_from_claude_dir reads valid file"
else
    test_fail "read_level_from_claude_dir failed to read valid file"
fi

# Test 8: read_level_from_claude_dir - Missing file
test_section "read_level_from_claude_dir - Missing File"
setup_test_env
mkdir -p "$TEST_TMP/empty/.claude"

RESULT=$(read_level_from_claude_dir "$TEST_TMP/empty/.claude" 2>/dev/null)
if [[ "$RESULT" == "{}" ]]; then
    test_pass "read_level_from_claude_dir returns {} for missing file"
else
    test_fail "read_level_from_claude_dir did not return {} for missing file (got: '$RESULT')"
fi

# Test 9: get_level_value - Extract level
test_section "get_level_value - Extract Level"
setup_test_env
mkdir -p "$TEST_TMP/test/.claude"

cat > "$TEST_TMP/test/.claude/organizational-level.json" <<'EOF'
{
  "level": "product",
  "level_name": "Test Product"
}
EOF

RESULT=$(get_level_value "$TEST_TMP/test/.claude")
if [[ "$RESULT" == "product" ]]; then
    test_pass "get_level_value extracts level correctly"
else
    test_fail "get_level_value extraction failed (got: $RESULT)"
fi

# Test 10: get_level_value - Missing level field
test_section "get_level_value - Missing Level Field"
setup_test_env
mkdir -p "$TEST_TMP/test/.claude"

cat > "$TEST_TMP/test/.claude/organizational-level.json" <<'EOF'
{
  "level_name": "Test"
}
EOF

RESULT=$(get_level_value "$TEST_TMP/test/.claude" 2>/dev/null || echo "")
if [[ -z "$RESULT" ]]; then
    test_pass "get_level_value returns empty for missing level field"
else
    test_fail "get_level_value should return empty (got: $RESULT)"
fi

# Test 11: build_hierarchy_path - Three-level hierarchy
test_section "build_hierarchy_path - Three-Level Hierarchy"
setup_test_env

mkdir -p "$TEST_TMP/company/.claude"
mkdir -p "$TEST_TMP/company/product/.claude"
mkdir -p "$TEST_TMP/company/product/project/.claude"

cat > "$TEST_TMP/company/.claude/organizational-level.json" <<'EOF'
{"level": "company"}
EOF

cat > "$TEST_TMP/company/product/.claude/organizational-level.json" <<'EOF'
{"level": "product"}
EOF

cat > "$TEST_TMP/company/product/project/.claude/organizational-level.json" <<'EOF'
{"level": "project"}
EOF

RESULT=$(build_hierarchy_path "$TEST_TMP/company/product/project/.claude")
EXPECTED='["company","product","project"]'

if [[ "$RESULT" == "$EXPECTED" ]]; then
    test_pass "build_hierarchy_path builds correct three-level hierarchy"
else
    test_fail "build_hierarchy_path incorrect (expected: $EXPECTED, got: $RESULT)"
fi

# Test 12: build_hierarchy_path - Single level (root)
test_section "build_hierarchy_path - Single Level (Root)"
setup_test_env
mkdir -p "$TEST_TMP/company/.claude"

cat > "$TEST_TMP/company/.claude/organizational-level.json" <<'EOF'
{"level": "company"}
EOF

RESULT=$(build_hierarchy_path "$TEST_TMP/company/.claude")
EXPECTED='["company"]'

if [[ "$RESULT" == "$EXPECTED" ]]; then
    test_pass "build_hierarchy_path builds correct single-level hierarchy"
else
    test_fail "build_hierarchy_path incorrect (expected: $EXPECTED, got: $RESULT)"
fi

# Test 13: is_valid_child_level - Valid relationships
test_section "is_valid_child_level - Valid Relationships"

if is_valid_child_level "company" "system" 2>/dev/null; then
    test_pass "company → system is valid"
else
    test_fail "company → system should be valid"
fi

if is_valid_child_level "company" "product" 2>/dev/null; then
    test_pass "company → product is valid"
else
    test_fail "company → product should be valid"
fi

if is_valid_child_level "company" "project" 2>/dev/null; then
    test_pass "company → project is valid"
else
    test_fail "company → project should be valid"
fi

if is_valid_child_level "system" "product" 2>/dev/null; then
    test_pass "system → product is valid"
else
    test_fail "system → product should be valid"
fi

if is_valid_child_level "system" "project" 2>/dev/null; then
    test_pass "system → project is valid"
else
    test_fail "system → project should be valid"
fi

if is_valid_child_level "product" "project" 2>/dev/null; then
    test_pass "product → project is valid"
else
    test_fail "product → project should be valid"
fi

# Test 14: is_valid_child_level - Invalid relationships
test_section "is_valid_child_level - Invalid Relationships"

if ! is_valid_child_level "project" "company" 2>/dev/null; then
    test_pass "project → company is invalid (reverse hierarchy)"
else
    test_fail "project → company should be invalid"
fi

if ! is_valid_child_level "product" "company" 2>/dev/null; then
    test_pass "product → company is invalid (reverse hierarchy)"
else
    test_fail "product → company should be invalid"
fi

if ! is_valid_child_level "project" "system" 2>/dev/null; then
    test_pass "project → system is invalid"
else
    test_fail "project → system should be invalid"
fi

if ! is_valid_child_level "product" "system" 2>/dev/null; then
    test_pass "product → system is invalid"
else
    test_fail "product → system should be invalid"
fi

if ! is_valid_child_level "project" "project" 2>/dev/null; then
    test_pass "project → project is invalid (same level)"
else
    test_fail "project → project should be invalid"
fi

# Test 15: is_valid_child_level - Project has no children
test_section "is_valid_child_level - Project Has No Children"

if ! is_valid_child_level "project" "product" 2>/dev/null; then
    test_pass "project cannot have product children"
else
    test_fail "project should not have product children"
fi

if ! is_valid_child_level "project" "system" 2>/dev/null; then
    test_pass "project cannot have system children"
else
    test_fail "project should not have system children"
fi

if ! is_valid_child_level "project" "company" 2>/dev/null; then
    test_pass "project cannot have company children"
else
    test_fail "project should not have company children"
fi

# Test 16: is_valid_child_level - Invalid level names
test_section "is_valid_child_level - Invalid Level Names"

if ! is_valid_child_level "invalid" "project" 2>/dev/null; then
    test_pass "Invalid parent level rejected"
else
    test_fail "Invalid parent level should be rejected"
fi

if ! is_valid_child_level "company" "invalid" 2>/dev/null; then
    test_pass "Invalid child level rejected"
else
    test_fail "Invalid child level should be rejected"
fi

# Test 17: save_level_with_hierarchy - Root level (is_root = true)
test_section "save_level_with_hierarchy - Root Level"
setup_test_env
mkdir -p "$TEST_TMP/company/.claude"

save_level_with_hierarchy "$TEST_TMP/company/.claude" "company" "Test Company" >/dev/null 2>&1

if [[ -f "$TEST_TMP/company/.claude/organizational-level.json" ]]; then
    test_pass "save_level_with_hierarchy creates file"

    RESULT=$(cat "$TEST_TMP/company/.claude/organizational-level.json")

    if echo "$RESULT" | jq -e '.level == "company"' >/dev/null 2>&1; then
        test_pass "Saved level is correct"
    else
        test_fail "Saved level is incorrect"
    fi

    if echo "$RESULT" | jq -e '.is_root == true' >/dev/null 2>&1; then
        test_pass "is_root is true for root level"
    else
        test_fail "is_root should be true for root level"
    fi

    if echo "$RESULT" | jq -e '.parent_claude_dir == null' >/dev/null 2>&1; then
        test_pass "parent_claude_dir is null for root level"
    else
        test_fail "parent_claude_dir should be null for root level"
    fi
else
    test_fail "save_level_with_hierarchy did not create file"
fi

# Test 18: save_level_with_hierarchy - Child level (is_root = false)
test_section "save_level_with_hierarchy - Child Level"
setup_test_env

mkdir -p "$TEST_TMP/company/.claude"
mkdir -p "$TEST_TMP/company/product/.claude"

# Create parent level first
cat > "$TEST_TMP/company/.claude/organizational-level.json" <<'EOF'
{"level": "company", "is_root": true}
EOF

save_level_with_hierarchy "$TEST_TMP/company/product/.claude" "product" "Test Product" >/dev/null 2>&1

if [[ -f "$TEST_TMP/company/product/.claude/organizational-level.json" ]]; then
    RESULT=$(cat "$TEST_TMP/company/product/.claude/organizational-level.json")

    if echo "$RESULT" | jq -e '.is_root == false' >/dev/null 2>&1; then
        test_pass "is_root is false for child level"
    else
        test_fail "is_root should be false for child level"
    fi

    if echo "$RESULT" | jq -e '.parent_level == "company"' >/dev/null 2>&1; then
        test_pass "parent_level is correct"
    else
        test_fail "parent_level is incorrect"
    fi

    if echo "$RESULT" | jq -e '.hierarchy_path == ["company","product"]' >/dev/null 2>&1; then
        test_pass "hierarchy_path is correct"
    else
        test_fail "hierarchy_path is incorrect"
    fi
else
    test_fail "save_level_with_hierarchy did not create child file"
fi

# Test 19: save_level_with_hierarchy - Invalid parent-child relationship
test_section "save_level_with_hierarchy - Invalid Relationship"
setup_test_env

mkdir -p "$TEST_TMP/project/.claude"
mkdir -p "$TEST_TMP/project/invalid/.claude"

# Create parent as project (cannot have children)
cat > "$TEST_TMP/project/.claude/organizational-level.json" <<'EOF'
{"level": "project", "is_root": true}
EOF

# Try to create invalid child
if ! save_level_with_hierarchy "$TEST_TMP/project/invalid/.claude" "product" "Invalid Product" 2>/dev/null; then
    test_pass "save_level_with_hierarchy rejects invalid parent-child relationship"
else
    test_fail "save_level_with_hierarchy should reject invalid parent-child relationship"
fi

# Test 20: save_level_with_hierarchy - Invalid level name
test_section "save_level_with_hierarchy - Invalid Level Name"
setup_test_env
mkdir -p "$TEST_TMP/test/.claude"

if ! save_level_with_hierarchy "$TEST_TMP/test/.claude" "invalid-level" "Test" 2>/dev/null; then
    test_pass "save_level_with_hierarchy rejects invalid level name"
else
    test_fail "save_level_with_hierarchy should reject invalid level name"
fi

# Test 21: save_level_with_hierarchy - Auto-generate level_name
test_section "save_level_with_hierarchy - Auto-Generate level_name"
setup_test_env
mkdir -p "$TEST_TMP/my-company/.claude"

save_level_with_hierarchy "$TEST_TMP/my-company/.claude" "company" "" >/dev/null 2>&1

if [[ -f "$TEST_TMP/my-company/.claude/organizational-level.json" ]]; then
    RESULT=$(cat "$TEST_TMP/my-company/.claude/organizational-level.json")

    if echo "$RESULT" | jq -e '.level_name == "my-company"' >/dev/null 2>&1; then
        test_pass "level_name auto-generated from directory name"
    else
        LEVEL_NAME=$(echo "$RESULT" | jq -r '.level_name')
        test_fail "level_name not auto-generated correctly (got: $LEVEL_NAME)"
    fi
else
    test_fail "save_level_with_hierarchy did not create file"
fi

# Test 22: Test fixtures validation
test_section "Test Fixtures Validation"

FIXTURE_BASE="$PROJECT_ROOT/tests/fixtures/hierarchical"

if [[ -f "$FIXTURE_BASE/company/.claude/organizational-level.json" ]]; then
    test_pass "Company level fixture exists"

    if jq empty "$FIXTURE_BASE/company/.claude/organizational-level.json" 2>/dev/null; then
        test_pass "Company level fixture is valid JSON"

        LEVEL=$(jq -r '.level' "$FIXTURE_BASE/company/.claude/organizational-level.json")
        if [[ "$LEVEL" == "company" ]]; then
            test_pass "Company level fixture has correct level"
        else
            test_fail "Company level fixture has wrong level: $LEVEL"
        fi

        IS_ROOT=$(jq -r '.is_root' "$FIXTURE_BASE/company/.claude/organizational-level.json")
        if [[ "$IS_ROOT" == "true" ]]; then
            test_pass "Company level fixture is marked as root"
        else
            test_fail "Company level fixture should be marked as root"
        fi
    else
        test_fail "Company level fixture is invalid JSON"
    fi
else
    test_fail "Company level fixture missing"
fi

if [[ -f "$FIXTURE_BASE/company/product/.claude/organizational-level.json" ]]; then
    test_pass "Product level fixture exists"

    if jq empty "$FIXTURE_BASE/company/product/.claude/organizational-level.json" 2>/dev/null; then
        test_pass "Product level fixture is valid JSON"

        LEVEL=$(jq -r '.level' "$FIXTURE_BASE/company/product/.claude/organizational-level.json")
        if [[ "$LEVEL" == "product" ]]; then
            test_pass "Product level fixture has correct level"
        else
            test_fail "Product level fixture has wrong level: $LEVEL"
        fi

        PARENT_LEVEL=$(jq -r '.parent_level' "$FIXTURE_BASE/company/product/.claude/organizational-level.json")
        if [[ "$PARENT_LEVEL" == "company" ]]; then
            test_pass "Product level fixture has correct parent_level"
        else
            test_fail "Product level fixture has wrong parent_level: $PARENT_LEVEL"
        fi
    else
        test_fail "Product level fixture is invalid JSON"
    fi
else
    test_fail "Product level fixture missing"
fi

if [[ -f "$FIXTURE_BASE/company/product/project/.claude/organizational-level.json" ]]; then
    test_pass "Project level fixture exists"

    if jq empty "$FIXTURE_BASE/company/product/project/.claude/organizational-level.json" 2>/dev/null; then
        test_pass "Project level fixture is valid JSON"

        HIERARCHY=$(jq -r '.hierarchy_path | join(",")' "$FIXTURE_BASE/company/product/project/.claude/organizational-level.json")
        if [[ "$HIERARCHY" == "company,product,project" ]]; then
            test_pass "Project level fixture has correct hierarchy_path"
        else
            test_fail "Project level fixture has wrong hierarchy_path: $HIERARCHY"
        fi
    else
        test_fail "Project level fixture is invalid JSON"
    fi
else
    test_fail "Project level fixture missing"
fi

if [[ -f "$FIXTURE_BASE/invalid/project/.claude/organizational-level.json" ]]; then
    test_pass "Invalid hierarchy fixture exists"
else
    test_fail "Invalid hierarchy fixture missing"
fi

# Test 23: Integration test with fixtures
test_section "Integration Test - Fixture Hierarchy Detection"

PROJECT_DIR="$FIXTURE_BASE/company/product/project"
PARENTS=$(find_parent_claude_dirs "$PROJECT_DIR")
PARENT_COUNT=$(echo "$PARENTS" | wc -l)

# Note: This may find more than 2 parents if there are .claude dirs outside the fixtures
if [[ "$PARENT_COUNT" -ge 2 ]]; then
    test_pass "Fixture hierarchy: found at least 2 parents from project level ($PARENT_COUNT total)"

    # Check that fixture parents are included
    if echo "$PARENTS" | grep -q "$FIXTURE_BASE/company/product/.claude"; then
        test_pass "Fixture hierarchy: product level parent found"
    else
        test_fail "Fixture hierarchy: product level parent missing"
    fi

    if echo "$PARENTS" | grep -q "$FIXTURE_BASE/company/.claude"; then
        test_pass "Fixture hierarchy: company level parent found"
    else
        test_fail "Fixture hierarchy: company level parent missing"
    fi
else
    test_fail "Fixture hierarchy: expected at least 2 parents, found $PARENT_COUNT"
fi

NEAREST=$(get_nearest_parent "$PROJECT_DIR")
if [[ "$NEAREST" == "$FIXTURE_BASE/company/product/.claude" ]]; then
    test_pass "Fixture hierarchy: nearest parent is product level"
else
    test_fail "Fixture hierarchy: nearest parent incorrect (got: $NEAREST)"
fi

# Test 24: Integration test - Build hierarchy from fixture
test_section "Integration Test - Build Hierarchy from Fixture"

HIERARCHY=$(build_hierarchy_path "$FIXTURE_BASE/company/product/project/.claude")
EXPECTED='["company","product","project"]'

if [[ "$HIERARCHY" == "$EXPECTED" ]]; then
    test_pass "Fixture hierarchy builds correct path"
else
    test_fail "Fixture hierarchy path incorrect (expected: $EXPECTED, got: $HIERARCHY)"
fi

# Summary
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Test Results                                         ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
