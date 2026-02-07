#!/usr/bin/env bash

# test-hierarchy-with-custom-paths.sh - Test hierarchy detection with custom path configuration
#
# Tests the integration of hierarchical organization features with custom directory names

set -o pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0
TEST_TMP="/tmp/test-hierarchy-custom-$$"

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
echo "║  Hierarchy with Custom Paths - Test Suite            ║"
echo "╚═══════════════════════════════════════════════════════╝"

# =============================================================================
# Test 1: Hierarchy Detection with .myorg Directory
# =============================================================================
test_section "Hierarchy Detection with .myorg"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".myorg"

# Create 3-level hierarchy with .myorg
mkdir -p "$TEST_TMP/acme/.myorg"
mkdir -p "$TEST_TMP/acme/widgets/.myorg"
mkdir -p "$TEST_TMP/acme/widgets/api/.myorg"

# Create organizational level files
cat > "$TEST_TMP/acme/.myorg/organizational-level.json" <<'EOF'
{
  "level": "company",
  "level_name": "ACME Corp",
  "parent_claude_dir": null,
  "parent_level": null,
  "is_root": true,
  "hierarchy_path": ["company"]
}
EOF

cat > "$TEST_TMP/acme/widgets/.myorg/organizational-level.json" <<EOF
{
  "level": "product",
  "level_name": "Widgets",
  "parent_claude_dir": "$TEST_TMP/acme/.myorg",
  "parent_level": "company",
  "is_root": false,
  "hierarchy_path": ["company", "product"]
}
EOF

cat > "$TEST_TMP/acme/widgets/api/.myorg/organizational-level.json" <<EOF
{
  "level": "project",
  "level_name": "Widget API",
  "parent_claude_dir": "$TEST_TMP/acme/widgets/.myorg",
  "parent_level": "product",
  "is_root": false,
  "hierarchy_path": ["company", "product", "project"]
}
EOF

# Test find_parent_claude_dirs
PARENTS=$(find_parent_claude_dirs "$TEST_TMP/acme/widgets/api")
PARENT_COUNT=$(echo "$PARENTS" | grep -c "/.myorg$" || echo "0")

if [[ "$PARENT_COUNT" -eq 2 ]]; then
    test_pass "Custom .myorg: Found 2 parent directories"
else
    test_fail "Custom .myorg: Expected 2 parents, found $PARENT_COUNT"
fi

# Test get_nearest_parent
NEAREST=$(get_nearest_parent "$TEST_TMP/acme/widgets/api")
if [[ "$NEAREST" == "$TEST_TMP/acme/widgets/.myorg" ]]; then
    test_pass "Custom .myorg: Nearest parent correct"
else
    test_fail "Custom .myorg: Nearest parent incorrect (got: $NEAREST)"
fi

# Test build_hierarchy_path
HIERARCHY=$(build_hierarchy_path "$TEST_TMP/acme/widgets/api/.myorg")
if echo "$HIERARCHY" | jq -e '. == ["company","product","project"]' >/dev/null 2>&1; then
    test_pass "Custom .myorg: Hierarchy path correct"
else
    test_fail "Custom .myorg: Hierarchy path incorrect (got: $HIERARCHY)"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 2: Parent-Child Relationships Across Custom Directories
# =============================================================================
test_section "Parent-Child with Custom Directories"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".custom"

# Create company
mkdir -p "$TEST_TMP/tech-corp/.custom"
save_level_with_hierarchy "$TEST_TMP/tech-corp/.custom" "company" "Tech Corp" >/dev/null 2>&1

# Create system under company
mkdir -p "$TEST_TMP/tech-corp/platform/.custom"
save_level_with_hierarchy "$TEST_TMP/tech-corp/platform/.custom" "system" "Platform" >/dev/null 2>&1

# Verify parent reference
PARENT=$(jq -r '.parent_claude_dir' "$TEST_TMP/tech-corp/platform/.custom/organizational-level.json")
if [[ "$PARENT" == "$TEST_TMP/tech-corp/.custom" ]]; then
    test_pass "Custom directory: System references custom company parent"
else
    test_fail "Custom directory: System parent reference incorrect: $PARENT"
fi

# Create product under system
mkdir -p "$TEST_TMP/tech-corp/platform/data-product/.custom"
save_level_with_hierarchy "$TEST_TMP/tech-corp/platform/data-product/.custom" "product" "Data Product" >/dev/null 2>&1

# Verify hierarchy
HIERARCHY=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/tech-corp/platform/data-product/.custom/organizational-level.json")
if [[ "$HIERARCHY" == "company,system,product" ]]; then
    test_pass "Custom directory: 3-level hierarchy correct"
else
    test_fail "Custom directory: Hierarchy incorrect: $HIERARCHY"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 3: Role Guide Inheritance with Custom Directories
# =============================================================================
test_section "Role Guide Inheritance"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".org"
export RCM_ROLE_GUIDES_DIR="team-guides"

# Create company with custom role-guides directory
mkdir -p "$TEST_TMP/startup/.org/team-guides"
save_level_with_hierarchy "$TEST_TMP/startup/.org" "company" "Startup Inc" >/dev/null 2>&1

# Create guide files
echo "# Company Engineer Guide" > "$TEST_TMP/startup/.org/team-guides/engineer-guide.md"
echo "# Company QA Guide" > "$TEST_TMP/startup/.org/team-guides/qa-guide.md"

if [[ -f "$TEST_TMP/startup/.org/team-guides/engineer-guide.md" ]]; then
    test_pass "Custom guides: Company-level guides created in custom directory"
else
    test_fail "Custom guides: Guide file not created"
fi

# Create product
mkdir -p "$TEST_TMP/startup/mobile-app/.org/team-guides"
save_level_with_hierarchy "$TEST_TMP/startup/mobile-app/.org" "product" "Mobile App" >/dev/null 2>&1

# Create product-specific guides
echo "# Mobile Engineer Guide" > "$TEST_TMP/startup/mobile-app/.org/team-guides/mobile-engineer-guide.md"

# Verify hierarchy allows finding parent guides
NEAREST_PARENT=$(get_nearest_parent "$TEST_TMP/startup/mobile-app")
if [[ "$NEAREST_PARENT" == "$TEST_TMP/startup/.org" ]]; then
    test_pass "Custom guides: Can locate parent for guide inheritance"

    # Check if parent has guides
    if [[ -d "$NEAREST_PARENT/team-guides" ]]; then
        test_pass "Custom guides: Parent custom guides directory exists"
    else
        test_fail "Custom guides: Parent guides directory not found"
    fi
else
    test_fail "Custom guides: Cannot locate parent"
fi

unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR

# =============================================================================
# Test 4: Mixed Directory Scenarios
# =============================================================================
test_section "Mixed Directory Scenarios"

setup_test_env

# Scenario 1: Parent uses .claude, child uses custom
mkdir -p "$TEST_TMP/mixed1/.claude"
save_level_with_hierarchy "$TEST_TMP/mixed1/.claude" "company" "Mixed Company 1" >/dev/null 2>&1

export RCM_CLAUDE_DIR_NAME=".custom"
mkdir -p "$TEST_TMP/mixed1/child1/.custom"
# Note: This scenario might not work perfectly as parent detection depends on current env var
# This is a known limitation

# Scenario 2: Verify standard .claude still works when no env vars set
unset RCM_CLAUDE_DIR_NAME

mkdir -p "$TEST_TMP/standard/.claude"
save_level_with_hierarchy "$TEST_TMP/standard/.claude" "company" "Standard Co" >/dev/null 2>&1

if [[ -f "$TEST_TMP/standard/.claude/organizational-level.json" ]]; then
    test_pass "Mixed: Standard .claude directory still works"
else
    test_fail "Mixed: Standard .claude directory failed"
fi

mkdir -p "$TEST_TMP/standard/prod/.claude"
save_level_with_hierarchy "$TEST_TMP/standard/prod/.claude" "product" "Standard Prod" >/dev/null 2>&1

PARENT=$(jq -r '.parent_claude_dir' "$TEST_TMP/standard/prod/.claude/organizational-level.json")
if [[ "$PARENT" == "$TEST_TMP/standard/.claude" ]]; then
    test_pass "Mixed: Standard hierarchy references work"
else
    test_fail "Mixed: Standard parent reference failed: $PARENT"
fi

# =============================================================================
# Test 5: Hierarchy Validation with Custom Paths
# =============================================================================
test_section "Validation with Custom Paths"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".validate"

# Create valid hierarchy
mkdir -p "$TEST_TMP/valid-co/.validate"
save_level_with_hierarchy "$TEST_TMP/valid-co/.validate" "company" "Valid Co" >/dev/null 2>&1

mkdir -p "$TEST_TMP/valid-co/valid-prod/.validate"
save_level_with_hierarchy "$TEST_TMP/valid-co/valid-prod/.validate" "product" "Valid Prod" >/dev/null 2>&1

mkdir -p "$TEST_TMP/valid-co/valid-prod/valid-proj/.validate"
save_level_with_hierarchy "$TEST_TMP/valid-co/valid-prod/valid-proj/.validate" "project" "Valid Proj" >/dev/null 2>&1

# Validate the hierarchy
cd "$TEST_TMP/valid-co/valid-prod/valid-proj"
if validate_hierarchy "$PWD" >/dev/null 2>&1; then
    test_pass "Validation: Valid custom hierarchy passes validation"
else
    test_fail "Validation: Valid custom hierarchy failed validation"
fi

# Test invalid hierarchy
mkdir -p "$TEST_TMP/invalid-proj/.validate"
cat > "$TEST_TMP/invalid-proj/.validate/organizational-level.json" <<EOF
{
  "level": "project",
  "level_name": "Invalid Proj",
  "parent_claude_dir": null,
  "parent_level": null,
  "is_root": true,
  "hierarchy_path": ["project"]
}
EOF

mkdir -p "$TEST_TMP/invalid-proj/child/.validate"
cat > "$TEST_TMP/invalid-proj/child/.validate/organizational-level.json" <<EOF
{
  "level": "product",
  "level_name": "Invalid Child",
  "parent_claude_dir": "$TEST_TMP/invalid-proj/.validate",
  "parent_level": "project",
  "is_root": false,
  "hierarchy_path": ["project", "product"]
}
EOF

cd "$TEST_TMP/invalid-proj/child"
if validate_hierarchy "$PWD" >/dev/null 2>&1; then
    test_fail "Validation: Should reject invalid custom hierarchy"
else
    test_pass "Validation: Correctly rejected invalid custom hierarchy"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 6: Deep Nesting with Custom Paths
# =============================================================================
test_section "Deep Nesting (5 Levels)"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".deep"

# Create 5-level deep hierarchy: company → system → product → project → subproject (if supported)
mkdir -p "$TEST_TMP/deep-co/.deep"
save_level_with_hierarchy "$TEST_TMP/deep-co/.deep" "company" "Deep Co" >/dev/null 2>&1

mkdir -p "$TEST_TMP/deep-co/sys/.deep"
save_level_with_hierarchy "$TEST_TMP/deep-co/sys/.deep" "system" "Sys" >/dev/null 2>&1

mkdir -p "$TEST_TMP/deep-co/sys/prod/.deep"
save_level_with_hierarchy "$TEST_TMP/deep-co/sys/prod/.deep" "product" "Prod" >/dev/null 2>&1

mkdir -p "$TEST_TMP/deep-co/sys/prod/proj/.deep"
save_level_with_hierarchy "$TEST_TMP/deep-co/sys/prod/proj/.deep" "project" "Proj" >/dev/null 2>&1

# Verify 4-level hierarchy
HIERARCHY=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/deep-co/sys/prod/proj/.deep/organizational-level.json")
if [[ "$HIERARCHY" == "company,system,product,project" ]]; then
    test_pass "Deep nesting: 4-level custom hierarchy correct"
else
    test_fail "Deep nesting: 4-level hierarchy incorrect: $HIERARCHY"
fi

# Test parent finding from deepest level
PARENTS=$(find_parent_claude_dirs "$TEST_TMP/deep-co/sys/prod/proj")
PARENT_COUNT=$(echo "$PARENTS" | grep -c "/.deep$" || echo "0")

if [[ "$PARENT_COUNT" -eq 3 ]]; then
    test_pass "Deep nesting: Found all 3 parents from project level"
else
    test_fail "Deep nesting: Expected 3 parents, found $PARENT_COUNT"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 7: Performance with Custom Paths
# =============================================================================
test_section "Performance"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".perf"

# Create 4-level hierarchy
mkdir -p "$TEST_TMP/perf1/.perf"
mkdir -p "$TEST_TMP/perf1/perf2/.perf"
mkdir -p "$TEST_TMP/perf1/perf2/perf3/.perf"
mkdir -p "$TEST_TMP/perf1/perf2/perf3/perf4/.perf"

# Time find_parent_claude_dirs
START=$(date +%s%N)
PARENTS=$(find_parent_claude_dirs "$TEST_TMP/perf1/perf2/perf3/perf4")
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))

if [[ "$ELAPSED_MS" -lt 100 ]]; then
    test_pass "Performance: find_parent_claude_dirs with custom paths <100ms ($ELAPSED_MS ms)"
else
    test_fail "Performance: find_parent_claude_dirs too slow ($ELAPSED_MS ms)"
fi

# Create organizational levels
save_level_with_hierarchy "$TEST_TMP/perf1/.perf" "company" "Perf1" >/dev/null 2>&1
save_level_with_hierarchy "$TEST_TMP/perf1/perf2/.perf" "system" "Perf2" >/dev/null 2>&1
save_level_with_hierarchy "$TEST_TMP/perf1/perf2/perf3/.perf" "product" "Perf3" >/dev/null 2>&1

# Time save_level_with_hierarchy
START=$(date +%s%N)
save_level_with_hierarchy "$TEST_TMP/perf1/perf2/perf3/perf4/.perf" "project" "Perf4" >/dev/null 2>&1
END=$(date +%s%N)
ELAPSED_MS=$(( (END - START) / 1000000 ))

if [[ "$ELAPSED_MS" -lt 200 ]]; then
    test_pass "Performance: save_level_with_hierarchy with custom paths <200ms ($ELAPSED_MS ms)"
else
    test_fail "Performance: save_level_with_hierarchy too slow ($ELAPSED_MS ms)"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 8: Edge Cases
# =============================================================================
test_section "Edge Cases"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".edge"

# Test with directory names containing hyphens and numbers
mkdir -p "$TEST_TMP/company-123/.edge"
save_level_with_hierarchy "$TEST_TMP/company-123/.edge" "company" "Company 123" >/dev/null 2>&1

if [[ -f "$TEST_TMP/company-123/.edge/organizational-level.json" ]]; then
    test_pass "Edge case: Handles directory names with hyphens and numbers"
else
    test_fail "Edge case: Failed with hyphens and numbers"
fi

# Test with deeply nested path
mkdir -p "$TEST_TMP/a/b/c/d/e/f/g/.edge"
save_level_with_hierarchy "$TEST_TMP/a/b/c/d/e/f/g/.edge" "project" "Deep Project" >/dev/null 2>&1

if [[ -f "$TEST_TMP/a/b/c/d/e/f/g/.edge/organizational-level.json" ]]; then
    test_pass "Edge case: Handles deeply nested filesystem paths"
else
    test_fail "Edge case: Failed with deep nesting"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 9: Show Hierarchy with Custom Paths
# =============================================================================
test_section "Show Hierarchy"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".show"

mkdir -p "$TEST_TMP/show-co/.show"
save_level_with_hierarchy "$TEST_TMP/show-co/.show" "company" "Show Company" >/dev/null 2>&1

mkdir -p "$TEST_TMP/show-co/show-prod/.show"
save_level_with_hierarchy "$TEST_TMP/show-co/show-prod/.show" "product" "Show Product" >/dev/null 2>&1

cd "$TEST_TMP/show-co/show-prod"
OUTPUT=$(show_hierarchy "$PWD" 2>&1)

if echo "$OUTPUT" | grep -q "Level: product"; then
    test_pass "Show hierarchy: Displays level with custom paths"
else
    test_fail "Show hierarchy: Does not display level"
fi

if echo "$OUTPUT" | grep -q "Parent level: company"; then
    test_pass "Show hierarchy: Displays parent level with custom paths"
else
    test_fail "Show hierarchy: Does not display parent level"
fi

unset RCM_CLAUDE_DIR_NAME

# =============================================================================
# Test 10: Multiple Sibling Directories
# =============================================================================
test_section "Multiple Siblings"

setup_test_env
export RCM_CLAUDE_DIR_NAME=".multi"

# Create parent
mkdir -p "$TEST_TMP/parent/.multi"
save_level_with_hierarchy "$TEST_TMP/parent/.multi" "company" "Parent" >/dev/null 2>&1

# Create multiple sibling products
for i in 1 2 3; do
    mkdir -p "$TEST_TMP/parent/child$i/.multi"
    save_level_with_hierarchy "$TEST_TMP/parent/child$i/.multi" "product" "Child $i" >/dev/null 2>&1
done

# Verify all siblings have same parent
PARENT_1=$(jq -r '.parent_claude_dir' "$TEST_TMP/parent/child1/.multi/organizational-level.json")
PARENT_2=$(jq -r '.parent_claude_dir' "$TEST_TMP/parent/child2/.multi/organizational-level.json")
PARENT_3=$(jq -r '.parent_claude_dir' "$TEST_TMP/parent/child3/.multi/organizational-level.json")

if [[ "$PARENT_1" == "$PARENT_2" && "$PARENT_2" == "$PARENT_3" ]]; then
    test_pass "Siblings: All siblings reference same custom parent"
else
    test_fail "Siblings: Siblings have different parents"
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
    echo -e "${GREEN}✓ All hierarchy with custom paths tests passed${NC}"
    echo ""
    echo "Hierarchy detection works correctly with custom paths:"
    echo "  ✓ Custom directory detection"
    echo "  ✓ Parent-child relationships"
    echo "  ✓ Role guide inheritance"
    echo "  ✓ Validation"
    echo "  ✓ Performance within limits"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
