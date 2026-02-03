#!/usr/bin/env bash

# test-hierarchical-initialization.sh - Integration tests for hierarchical initialization
#
# Tests end-to-end initialization workflows, validation, and backward compatibility

set -o pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0
TEST_TMP="/tmp/test-hierarchy-$$"

# Source the scripts we're testing
HIERARCHY_DETECTOR="$PROJECT_ROOT/scripts/hierarchy-detector.sh"
LEVEL_DETECTOR="$PROJECT_ROOT/scripts/level-detector.sh"

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

echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Hierarchical Initialization - Integration Tests     ║"
echo "╚═══════════════════════════════════════════════════════╝"

# =============================================================================
# Test 1: Script Existence and Syntax
# =============================================================================
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

if [[ -f "$LEVEL_DETECTOR" ]]; then
    test_pass "level-detector.sh exists"
else
    test_fail "level-detector.sh missing"
fi

# Source the scripts
source "$HIERARCHY_DETECTOR"
source "$LEVEL_DETECTOR"

# =============================================================================
# Test 2: Company Level Initialization (Root Level, No Parent)
# =============================================================================
test_section "Company Level Initialization (Root)"

setup_test_env
mkdir -p "$TEST_TMP/acme-corp/.claude"

# Initialize company level
save_level_with_hierarchy "$TEST_TMP/acme-corp/.claude" "company" "acme-corp" >/dev/null 2>&1

if [[ -f "$TEST_TMP/acme-corp/.claude/organizational-level.json" ]]; then
    test_pass "organizational-level.json created for company"

    # Verify fields
    LEVEL=$(jq -r '.level' "$TEST_TMP/acme-corp/.claude/organizational-level.json")
    if [[ "$LEVEL" == "company" ]]; then
        test_pass "Company level field correct"
    else
        test_fail "Company level field incorrect: $LEVEL"
    fi

    IS_ROOT=$(jq -r '.is_root' "$TEST_TMP/acme-corp/.claude/organizational-level.json")
    if [[ "$IS_ROOT" == "true" ]]; then
        test_pass "Company is_root flag correct"
    else
        test_fail "Company is_root flag incorrect: $IS_ROOT"
    fi

    PARENT=$(jq -r '.parent_claude_dir' "$TEST_TMP/acme-corp/.claude/organizational-level.json")
    if [[ "$PARENT" == "null" ]]; then
        test_pass "Company parent_claude_dir is null"
    else
        test_fail "Company parent_claude_dir should be null: $PARENT"
    fi

    HIERARCHY=$(jq -r '.hierarchy_path | length' "$TEST_TMP/acme-corp/.claude/organizational-level.json")
    if [[ "$HIERARCHY" -eq 1 ]]; then
        test_pass "Company hierarchy_path has 1 element"
    else
        test_fail "Company hierarchy_path length incorrect: $HIERARCHY"
    fi

    HIERARCHY_VALUE=$(jq -r '.hierarchy_path[0]' "$TEST_TMP/acme-corp/.claude/organizational-level.json")
    if [[ "$HIERARCHY_VALUE" == "company" ]]; then
        test_pass "Company hierarchy_path contains 'company'"
    else
        test_fail "Company hierarchy_path value incorrect: $HIERARCHY_VALUE"
    fi
else
    test_fail "organizational-level.json not created for company"
fi

# =============================================================================
# Test 3: Product Level Initialization (Under Company)
# =============================================================================
test_section "Product Level Initialization (Under Company)"

# Create product under company
mkdir -p "$TEST_TMP/acme-corp/widget-product/.claude"

save_level_with_hierarchy "$TEST_TMP/acme-corp/widget-product/.claude" "product" "widget-product" >/dev/null 2>&1

if [[ -f "$TEST_TMP/acme-corp/widget-product/.claude/organizational-level.json" ]]; then
    test_pass "organizational-level.json created for product"

    # Verify fields
    LEVEL=$(jq -r '.level' "$TEST_TMP/acme-corp/widget-product/.claude/organizational-level.json")
    if [[ "$LEVEL" == "product" ]]; then
        test_pass "Product level field correct"
    else
        test_fail "Product level field incorrect: $LEVEL"
    fi

    IS_ROOT=$(jq -r '.is_root' "$TEST_TMP/acme-corp/widget-product/.claude/organizational-level.json")
    if [[ "$IS_ROOT" == "false" ]]; then
        test_pass "Product is_root flag correct (false)"
    else
        test_fail "Product is_root flag incorrect: $IS_ROOT"
    fi

    PARENT=$(jq -r '.parent_claude_dir' "$TEST_TMP/acme-corp/widget-product/.claude/organizational-level.json")
    if [[ "$PARENT" == "$TEST_TMP/acme-corp/.claude" ]]; then
        test_pass "Product parent_claude_dir points to company"
    else
        test_fail "Product parent_claude_dir incorrect: $PARENT"
    fi

    PARENT_LEVEL=$(jq -r '.parent_level' "$TEST_TMP/acme-corp/widget-product/.claude/organizational-level.json")
    if [[ "$PARENT_LEVEL" == "company" ]]; then
        test_pass "Product parent_level is 'company'"
    else
        test_fail "Product parent_level incorrect: $PARENT_LEVEL"
    fi

    HIERARCHY=$(jq -r '.hierarchy_path | length' "$TEST_TMP/acme-corp/widget-product/.claude/organizational-level.json")
    if [[ "$HIERARCHY" -eq 2 ]]; then
        test_pass "Product hierarchy_path has 2 elements"
    else
        test_fail "Product hierarchy_path length incorrect: $HIERARCHY"
    fi

    HIERARCHY_STR=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/acme-corp/widget-product/.claude/organizational-level.json")
    if [[ "$HIERARCHY_STR" == "company,product" ]]; then
        test_pass "Product hierarchy_path is [company, product]"
    else
        test_fail "Product hierarchy_path incorrect: $HIERARCHY_STR"
    fi
else
    test_fail "organizational-level.json not created for product"
fi

# =============================================================================
# Test 4: Project Level Initialization (Under Product)
# =============================================================================
test_section "Project Level Initialization (Under Product)"

# Create project under product
mkdir -p "$TEST_TMP/acme-corp/widget-product/api-service/.claude"

save_level_with_hierarchy "$TEST_TMP/acme-corp/widget-product/api-service/.claude" "project" "api-service" >/dev/null 2>&1

if [[ -f "$TEST_TMP/acme-corp/widget-product/api-service/.claude/organizational-level.json" ]]; then
    test_pass "organizational-level.json created for project"

    # Verify fields
    LEVEL=$(jq -r '.level' "$TEST_TMP/acme-corp/widget-product/api-service/.claude/organizational-level.json")
    if [[ "$LEVEL" == "project" ]]; then
        test_pass "Project level field correct"
    else
        test_fail "Project level field incorrect: $LEVEL"
    fi

    IS_ROOT=$(jq -r '.is_root' "$TEST_TMP/acme-corp/widget-product/api-service/.claude/organizational-level.json")
    if [[ "$IS_ROOT" == "false" ]]; then
        test_pass "Project is_root flag correct (false)"
    else
        test_fail "Project is_root flag incorrect: $IS_ROOT"
    fi

    PARENT=$(jq -r '.parent_claude_dir' "$TEST_TMP/acme-corp/widget-product/api-service/.claude/organizational-level.json")
    if [[ "$PARENT" == "$TEST_TMP/acme-corp/widget-product/.claude" ]]; then
        test_pass "Project parent_claude_dir points to product"
    else
        test_fail "Project parent_claude_dir incorrect: $PARENT"
    fi

    PARENT_LEVEL=$(jq -r '.parent_level' "$TEST_TMP/acme-corp/widget-product/api-service/.claude/organizational-level.json")
    if [[ "$PARENT_LEVEL" == "product" ]]; then
        test_pass "Project parent_level is 'product'"
    else
        test_fail "Project parent_level incorrect: $PARENT_LEVEL"
    fi

    HIERARCHY=$(jq -r '.hierarchy_path | length' "$TEST_TMP/acme-corp/widget-product/api-service/.claude/organizational-level.json")
    if [[ "$HIERARCHY" -eq 3 ]]; then
        test_pass "Project hierarchy_path has 3 elements"
    else
        test_fail "Project hierarchy_path length incorrect: $HIERARCHY"
    fi

    HIERARCHY_STR=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/acme-corp/widget-product/api-service/.claude/organizational-level.json")
    if [[ "$HIERARCHY_STR" == "company,product,project" ]]; then
        test_pass "Project hierarchy_path is [company, product, project]"
    else
        test_fail "Project hierarchy_path incorrect: $HIERARCHY_STR"
    fi
else
    test_fail "organizational-level.json not created for project"
fi

# =============================================================================
# Test 5: System Level Under Company
# =============================================================================
test_section "System Level Initialization (Under Company)"

setup_test_env
mkdir -p "$TEST_TMP/tech-corp/.claude"
save_level_with_hierarchy "$TEST_TMP/tech-corp/.claude" "company" "tech-corp" >/dev/null 2>&1

# Create system under company
mkdir -p "$TEST_TMP/tech-corp/platform-system/.claude"
save_level_with_hierarchy "$TEST_TMP/tech-corp/platform-system/.claude" "system" "platform-system" >/dev/null 2>&1

if [[ -f "$TEST_TMP/tech-corp/platform-system/.claude/organizational-level.json" ]]; then
    test_pass "organizational-level.json created for system"

    PARENT_LEVEL=$(jq -r '.parent_level' "$TEST_TMP/tech-corp/platform-system/.claude/organizational-level.json")
    if [[ "$PARENT_LEVEL" == "company" ]]; then
        test_pass "System parent_level is 'company'"
    else
        test_fail "System parent_level incorrect: $PARENT_LEVEL"
    fi

    HIERARCHY_STR=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/tech-corp/platform-system/.claude/organizational-level.json")
    if [[ "$HIERARCHY_STR" == "company,system" ]]; then
        test_pass "System hierarchy_path is [company, system]"
    else
        test_fail "System hierarchy_path incorrect: $HIERARCHY_STR"
    fi
else
    test_fail "organizational-level.json not created for system"
fi

# =============================================================================
# Test 6: Project Directly Under Company (Skip Product)
# =============================================================================
test_section "Project Directly Under Company"

mkdir -p "$TEST_TMP/tech-corp/standalone-project/.claude"
save_level_with_hierarchy "$TEST_TMP/tech-corp/standalone-project/.claude" "project" "standalone-project" >/dev/null 2>&1

if [[ -f "$TEST_TMP/tech-corp/standalone-project/.claude/organizational-level.json" ]]; then
    test_pass "organizational-level.json created for project under company"

    PARENT_LEVEL=$(jq -r '.parent_level' "$TEST_TMP/tech-corp/standalone-project/.claude/organizational-level.json")
    if [[ "$PARENT_LEVEL" == "company" ]]; then
        test_pass "Project parent_level is 'company' (direct)"
    else
        test_fail "Project parent_level incorrect: $PARENT_LEVEL"
    fi

    HIERARCHY_STR=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/tech-corp/standalone-project/.claude/organizational-level.json")
    if [[ "$HIERARCHY_STR" == "company,project" ]]; then
        test_pass "Project hierarchy_path is [company, project]"
    else
        test_fail "Project hierarchy_path incorrect: $HIERARCHY_STR"
    fi
else
    test_fail "organizational-level.json not created for project under company"
fi

# =============================================================================
# Test 7: Invalid Parent-Child Relationships
# =============================================================================
test_section "Invalid Parent-Child Relationship Validation"

# Test 7a: Project cannot have children
setup_test_env
mkdir -p "$TEST_TMP/company-x/.claude"
save_level_with_hierarchy "$TEST_TMP/company-x/.claude" "company" "company-x" >/dev/null 2>&1

mkdir -p "$TEST_TMP/company-x/project-a/.claude"
save_level_with_hierarchy "$TEST_TMP/company-x/project-a/.claude" "project" "project-a" >/dev/null 2>&1

mkdir -p "$TEST_TMP/company-x/project-a/sub-project/.claude"
RESULT=$(save_level_with_hierarchy "$TEST_TMP/company-x/project-a/sub-project/.claude" "project" "sub-project" 2>&1 || echo "ERROR")

if echo "$RESULT" | grep -q "Error.*Invalid hierarchy"; then
    test_pass "Rejected project under project (invalid)"
else
    test_fail "Did not reject project under project: $RESULT"
fi

# Test 7b: Product cannot be parent of system
setup_test_env
mkdir -p "$TEST_TMP/company-y/.claude"
save_level_with_hierarchy "$TEST_TMP/company-y/.claude" "company" "company-y" >/dev/null 2>&1

mkdir -p "$TEST_TMP/company-y/product-b/.claude"
save_level_with_hierarchy "$TEST_TMP/company-y/product-b/.claude" "product" "product-b" >/dev/null 2>&1

mkdir -p "$TEST_TMP/company-y/product-b/system-invalid/.claude"
RESULT=$(save_level_with_hierarchy "$TEST_TMP/company-y/product-b/system-invalid/.claude" "system" "system-invalid" 2>&1 || echo "ERROR")

if echo "$RESULT" | grep -q "Error.*Invalid hierarchy"; then
    test_pass "Rejected system under product (invalid)"
else
    test_fail "Did not reject system under product: $RESULT"
fi

# Test 7c: System cannot be parent of company
setup_test_env
mkdir -p "$TEST_TMP/company-z/.claude"
save_level_with_hierarchy "$TEST_TMP/company-z/.claude" "company" "company-z" >/dev/null 2>&1

mkdir -p "$TEST_TMP/company-z/system-c/.claude"
save_level_with_hierarchy "$TEST_TMP/company-z/system-c/.claude" "system" "system-c" >/dev/null 2>&1

mkdir -p "$TEST_TMP/company-z/system-c/company-invalid/.claude"
RESULT=$(save_level_with_hierarchy "$TEST_TMP/company-z/system-c/company-invalid/.claude" "company" "company-invalid" 2>&1 || echo "ERROR")

if echo "$RESULT" | grep -q "Error.*Invalid hierarchy"; then
    test_pass "Rejected company under system (invalid)"
else
    test_fail "Did not reject company under system: $RESULT"
fi

# Test 7d: Same level cannot be child of itself
if is_valid_child_level "product" "product" 2>/dev/null; then
    test_fail "Should reject product under product"
else
    test_pass "Correctly rejected product under product (same level)"
fi

# =============================================================================
# Test 8: Valid Parent-Child Relationships
# =============================================================================
test_section "Valid Parent-Child Relationship Validation"

# Test valid relationships using is_valid_child_level function
if is_valid_child_level "company" "system"; then
    test_pass "company → system is valid"
else
    test_fail "company → system should be valid"
fi

if is_valid_child_level "company" "product"; then
    test_pass "company → product is valid"
else
    test_fail "company → product should be valid"
fi

if is_valid_child_level "company" "project"; then
    test_pass "company → project is valid"
else
    test_fail "company → project should be valid"
fi

if is_valid_child_level "system" "product"; then
    test_pass "system → product is valid"
else
    test_fail "system → product should be valid"
fi

if is_valid_child_level "system" "project"; then
    test_pass "system → project is valid"
else
    test_fail "system → project should be valid"
fi

if is_valid_child_level "product" "project"; then
    test_pass "product → project is valid"
else
    test_fail "product → project should be valid"
fi

# =============================================================================
# Test 9: Hierarchy Path Building
# =============================================================================
test_section "Hierarchy Path Building"

setup_test_env
mkdir -p "$TEST_TMP/mega-corp/.claude"
save_level_with_hierarchy "$TEST_TMP/mega-corp/.claude" "company" "mega-corp" >/dev/null 2>&1

mkdir -p "$TEST_TMP/mega-corp/cloud-system/.claude"
save_level_with_hierarchy "$TEST_TMP/mega-corp/cloud-system/.claude" "system" "cloud-system" >/dev/null 2>&1

mkdir -p "$TEST_TMP/mega-corp/cloud-system/data-product/.claude"
save_level_with_hierarchy "$TEST_TMP/mega-corp/cloud-system/data-product/.claude" "product" "data-product" >/dev/null 2>&1

mkdir -p "$TEST_TMP/mega-corp/cloud-system/data-product/etl-project/.claude"
save_level_with_hierarchy "$TEST_TMP/mega-corp/cloud-system/data-product/etl-project/.claude" "project" "etl-project" >/dev/null 2>&1

# Test build_hierarchy_path function
HIERARCHY=$(build_hierarchy_path "$TEST_TMP/mega-corp/cloud-system/data-product/etl-project/.claude")
HIERARCHY_STR=$(echo "$HIERARCHY" | jq -r 'join(",")')

if [[ "$HIERARCHY_STR" == "company,system,product,project" ]]; then
    test_pass "Built complete 4-level hierarchy path correctly"
else
    test_fail "Hierarchy path incorrect: $HIERARCHY_STR"
fi

# Verify it's recorded in the file
FILE_HIERARCHY=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/mega-corp/cloud-system/data-product/etl-project/.claude/organizational-level.json")
if [[ "$FILE_HIERARCHY" == "company,system,product,project" ]]; then
    test_pass "4-level hierarchy saved correctly in file"
else
    test_fail "Saved hierarchy incorrect: $FILE_HIERARCHY"
fi

# =============================================================================
# Test 10: Parent Directory Detection
# =============================================================================
test_section "Parent Directory Detection"

# Using the hierarchy we just created
cd "$TEST_TMP/mega-corp/cloud-system/data-product/etl-project"

PARENT=$(get_nearest_parent "$PWD")
if [[ "$PARENT" == "$TEST_TMP/mega-corp/cloud-system/data-product/.claude" ]]; then
    test_pass "Detected nearest parent correctly (product)"
else
    test_fail "Nearest parent detection failed: $PARENT"
fi

# Find all parents
PARENTS=$(find_parent_claude_dirs "$PWD")
PARENT_COUNT=$(echo "$PARENTS" | grep -c "/.claude" || echo "0")

if [[ "$PARENT_COUNT" -eq 3 ]]; then
    test_pass "Found all 3 parent .claude directories"
else
    test_fail "Parent count incorrect: $PARENT_COUNT (expected 3)"
fi

# =============================================================================
# Test 11: Validation Functions
# =============================================================================
test_section "Hierarchy Validation"

# Test valid hierarchy
cd "$TEST_TMP/mega-corp/cloud-system/data-product/etl-project"
if validate_hierarchy "$PWD" >/dev/null 2>&1; then
    test_pass "Validated correct hierarchy successfully"
else
    test_fail "Failed to validate correct hierarchy"
fi

# Test broken hierarchy - create project with wrong parent level in file
setup_test_env
mkdir -p "$TEST_TMP/broken-corp/.claude"
cat > "$TEST_TMP/broken-corp/.claude/organizational-level.json" <<EOF
{
  "level": "project",
  "level_name": "broken-corp",
  "parent_claude_dir": null,
  "parent_level": null,
  "is_root": true,
  "hierarchy_path": ["project"]
}
EOF

mkdir -p "$TEST_TMP/broken-corp/sub-product/.claude"
# Manually create invalid relationship - product under project
cat > "$TEST_TMP/broken-corp/sub-product/.claude/organizational-level.json" <<EOF
{
  "level": "product",
  "level_name": "sub-product",
  "parent_claude_dir": "$TEST_TMP/broken-corp/.claude",
  "parent_level": "project",
  "is_root": false,
  "hierarchy_path": ["project", "product"]
}
EOF

cd "$TEST_TMP/broken-corp/sub-product"
if validate_hierarchy "$PWD" >/dev/null 2>&1; then
    test_fail "Should have detected invalid hierarchy (product under project)"
else
    test_pass "Detected invalid hierarchy correctly"
fi

# =============================================================================
# Test 12: Backward Compatibility - Old Format
# =============================================================================
test_section "Backward Compatibility - Old Format"

setup_test_env
mkdir -p "$TEST_TMP/legacy-corp/.claude"

# Create old format organizational-level.json (without hierarchy fields)
cat > "$TEST_TMP/legacy-corp/.claude/organizational-level.json" <<EOF
{
  "level": "company",
  "level_name": "legacy-corp"
}
EOF

# Verify it can be read
LEVEL=$(get_level_value "$TEST_TMP/legacy-corp/.claude")
if [[ "$LEVEL" == "company" ]]; then
    test_pass "Old format level can be read"
else
    test_fail "Failed to read old format level: $LEVEL"
fi

# Read full level info
LEVEL_INFO=$(read_level_from_claude_dir "$TEST_TMP/legacy-corp/.claude")
if [[ "$LEVEL_INFO" != "{}" ]]; then
    test_pass "Old format organizational-level.json can be parsed"
else
    test_fail "Failed to parse old format file"
fi

# =============================================================================
# Test 13: Auto-Upgrade on Write
# =============================================================================
test_section "Auto-Upgrade Old Format on Write"

# Create product under legacy company (should auto-upgrade company)
mkdir -p "$TEST_TMP/legacy-corp/new-product/.claude"
save_level_with_hierarchy "$TEST_TMP/legacy-corp/new-product/.claude" "product" "new-product" >/dev/null 2>&1

# Check that new product has extended format
if jq -e '.hierarchy_path' "$TEST_TMP/legacy-corp/new-product/.claude/organizational-level.json" >/dev/null 2>&1; then
    test_pass "New product has extended format"
else
    test_fail "New product missing extended format fields"
fi

# Parent reference should work even though parent is old format
PARENT_LEVEL=$(jq -r '.parent_level' "$TEST_TMP/legacy-corp/new-product/.claude/organizational-level.json")
if [[ "$PARENT_LEVEL" == "company" ]]; then
    test_pass "Product correctly references legacy parent"
else
    test_fail "Product parent reference failed: $PARENT_LEVEL"
fi

# =============================================================================
# Test 14: Show Hierarchy Function
# =============================================================================
test_section "Show Hierarchy Information"

setup_test_env
mkdir -p "$TEST_TMP/show-corp/.claude"
save_level_with_hierarchy "$TEST_TMP/show-corp/.claude" "company" "show-corp" >/dev/null 2>&1

mkdir -p "$TEST_TMP/show-corp/show-product/.claude"
save_level_with_hierarchy "$TEST_TMP/show-corp/show-product/.claude" "product" "show-product" >/dev/null 2>&1

cd "$TEST_TMP/show-corp/show-product"
OUTPUT=$(show_hierarchy "$PWD" 2>&1)

if echo "$OUTPUT" | grep -q "Level: product"; then
    test_pass "show_hierarchy displays level"
else
    test_fail "show_hierarchy missing level display"
fi

if echo "$OUTPUT" | grep -q "Parent level: company"; then
    test_pass "show_hierarchy displays parent level"
else
    test_fail "show_hierarchy missing parent level display"
fi

if echo "$OUTPUT" | grep -q "Hierarchy:.*company.*product"; then
    test_pass "show_hierarchy displays hierarchy path"
else
    test_fail "show_hierarchy missing hierarchy path display"
fi

# =============================================================================
# Test 15: Missing Parent Directory Handling
# =============================================================================
test_section "Missing Parent Directory Handling"

setup_test_env
mkdir -p "$TEST_TMP/orphan-project/.claude"

# Try to create project with no parent
save_level_with_hierarchy "$TEST_TMP/orphan-project/.claude" "project" "orphan-project" >/dev/null 2>&1

# Should create root project (is_root: true)
IS_ROOT=$(jq -r '.is_root' "$TEST_TMP/orphan-project/.claude/organizational-level.json")
if [[ "$IS_ROOT" == "true" ]]; then
    test_pass "Orphan project created as root"
else
    test_fail "Orphan project is_root incorrect: $IS_ROOT"
fi

PARENT=$(jq -r '.parent_claude_dir' "$TEST_TMP/orphan-project/.claude/organizational-level.json")
if [[ "$PARENT" == "null" ]]; then
    test_pass "Orphan project has null parent"
else
    test_fail "Orphan project parent should be null: $PARENT"
fi

# =============================================================================
# Test 16: Multiple Siblings at Same Level
# =============================================================================
test_section "Multiple Siblings at Same Level"

setup_test_env
mkdir -p "$TEST_TMP/multi-corp/.claude"
save_level_with_hierarchy "$TEST_TMP/multi-corp/.claude" "company" "multi-corp" >/dev/null 2>&1

# Create multiple products under same company
mkdir -p "$TEST_TMP/multi-corp/product-1/.claude"
save_level_with_hierarchy "$TEST_TMP/multi-corp/product-1/.claude" "product" "product-1" >/dev/null 2>&1

mkdir -p "$TEST_TMP/multi-corp/product-2/.claude"
save_level_with_hierarchy "$TEST_TMP/multi-corp/product-2/.claude" "product" "product-2" >/dev/null 2>&1

mkdir -p "$TEST_TMP/multi-corp/product-3/.claude"
save_level_with_hierarchy "$TEST_TMP/multi-corp/product-3/.claude" "product" "product-3" >/dev/null 2>&1

# Verify all have same parent
PARENT_1=$(jq -r '.parent_claude_dir' "$TEST_TMP/multi-corp/product-1/.claude/organizational-level.json")
PARENT_2=$(jq -r '.parent_claude_dir' "$TEST_TMP/multi-corp/product-2/.claude/organizational-level.json")
PARENT_3=$(jq -r '.parent_claude_dir' "$TEST_TMP/multi-corp/product-3/.claude/organizational-level.json")

if [[ "$PARENT_1" == "$PARENT_2" && "$PARENT_2" == "$PARENT_3" ]]; then
    test_pass "All sibling products have same parent"
else
    test_fail "Sibling products have different parents"
fi

# Verify all have same hierarchy path
HIER_1=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/multi-corp/product-1/.claude/organizational-level.json")
HIER_2=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/multi-corp/product-2/.claude/organizational-level.json")
HIER_3=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/multi-corp/product-3/.claude/organizational-level.json")

if [[ "$HIER_1" == "company,product" && "$HIER_2" == "company,product" && "$HIER_3" == "company,product" ]]; then
    test_pass "All sibling products have correct hierarchy path"
else
    test_fail "Sibling products have incorrect hierarchy paths"
fi

# =============================================================================
# Test 17: Deep Nesting (4 Levels)
# =============================================================================
test_section "Deep Nesting (4 Levels)"

setup_test_env
mkdir -p "$TEST_TMP/deep/.claude"
save_level_with_hierarchy "$TEST_TMP/deep/.claude" "company" "deep" >/dev/null 2>&1

mkdir -p "$TEST_TMP/deep/sys/.claude"
save_level_with_hierarchy "$TEST_TMP/deep/sys/.claude" "system" "sys" >/dev/null 2>&1

mkdir -p "$TEST_TMP/deep/sys/prod/.claude"
save_level_with_hierarchy "$TEST_TMP/deep/sys/prod/.claude" "product" "prod" >/dev/null 2>&1

mkdir -p "$TEST_TMP/deep/sys/prod/proj/.claude"
save_level_with_hierarchy "$TEST_TMP/deep/sys/prod/proj/.claude" "project" "proj" >/dev/null 2>&1

HIERARCHY=$(jq -r '.hierarchy_path | join(",")' "$TEST_TMP/deep/sys/prod/proj/.claude/organizational-level.json")
if [[ "$HIERARCHY" == "company,system,product,project" ]]; then
    test_pass "4-level deep nesting works correctly"
else
    test_fail "4-level deep nesting hierarchy incorrect: $HIERARCHY"
fi

# Verify each level's parent is correct
PROJ_PARENT=$(jq -r '.parent_level' "$TEST_TMP/deep/sys/prod/proj/.claude/organizational-level.json")
PROD_PARENT=$(jq -r '.parent_level' "$TEST_TMP/deep/sys/prod/.claude/organizational-level.json")
SYS_PARENT=$(jq -r '.parent_level' "$TEST_TMP/deep/sys/.claude/organizational-level.json")

if [[ "$PROJ_PARENT" == "product" && "$PROD_PARENT" == "system" && "$SYS_PARENT" == "company" ]]; then
    test_pass "All parent references correct in 4-level hierarchy"
else
    test_fail "Parent references incorrect in 4-level hierarchy"
fi

# =============================================================================
# Test 18: Test Fixture Validation
# =============================================================================
test_section "Test Fixtures Validation"

# Company fixture
if [[ -f "$PROJECT_ROOT/tests/fixtures/hierarchical/company/.claude/organizational-level.json" ]]; then
    test_pass "Company test fixture exists"

    FIXTURE_LEVEL=$(jq -r '.level' "$PROJECT_ROOT/tests/fixtures/hierarchical/company/.claude/organizational-level.json")
    if [[ "$FIXTURE_LEVEL" == "company" ]]; then
        test_pass "Company fixture has correct level"
    else
        test_fail "Company fixture level incorrect: $FIXTURE_LEVEL"
    fi
else
    test_fail "Company test fixture missing"
fi

# Product fixture
if [[ -f "$PROJECT_ROOT/tests/fixtures/hierarchical/company/product/.claude/organizational-level.json" ]]; then
    test_pass "Product test fixture exists"

    FIXTURE_LEVEL=$(jq -r '.level' "$PROJECT_ROOT/tests/fixtures/hierarchical/company/product/.claude/organizational-level.json")
    if [[ "$FIXTURE_LEVEL" == "product" ]]; then
        test_pass "Product fixture has correct level"
    else
        test_fail "Product fixture level incorrect: $FIXTURE_LEVEL"
    fi
else
    test_fail "Product test fixture missing"
fi

# Project fixture
if [[ -f "$PROJECT_ROOT/tests/fixtures/hierarchical/company/product/project/.claude/organizational-level.json" ]]; then
    test_pass "Project test fixture exists"

    FIXTURE_LEVEL=$(jq -r '.level' "$PROJECT_ROOT/tests/fixtures/hierarchical/company/product/project/.claude/organizational-level.json")
    if [[ "$FIXTURE_LEVEL" == "project" ]]; then
        test_pass "Project fixture has correct level"
    else
        test_fail "Project fixture level incorrect: $FIXTURE_LEVEL"
    fi
else
    test_fail "Project test fixture missing"
fi

# Invalid fixture (project as root)
if [[ -f "$PROJECT_ROOT/tests/fixtures/hierarchical/invalid/project/.claude/organizational-level.json" ]]; then
    test_pass "Invalid test fixture exists"
else
    test_fail "Invalid test fixture missing"
fi

# =============================================================================
# Test 19: CLI Command Execution
# =============================================================================
test_section "CLI Command Execution"

setup_test_env
mkdir -p "$TEST_TMP/cli-test/.claude"

# Test save-level command
OUTPUT=$(bash "$HIERARCHY_DETECTOR" save-level "$TEST_TMP/cli-test/.claude" "company" "cli-test" 2>&1)

if [[ -f "$TEST_TMP/cli-test/.claude/organizational-level.json" ]]; then
    test_pass "CLI save-level command creates file"
else
    test_fail "CLI save-level command failed"
fi

# Test validate-child command
if bash "$HIERARCHY_DETECTOR" validate-child "company" "product" >/dev/null 2>&1; then
    test_pass "CLI validate-child accepts valid relationship"
else
    test_fail "CLI validate-child rejects valid relationship"
fi

if bash "$HIERARCHY_DETECTOR" validate-child "project" "product" >/dev/null 2>&1; then
    test_fail "CLI validate-child accepts invalid relationship"
else
    test_pass "CLI validate-child rejects invalid relationship"
fi

# Test get-parent command
mkdir -p "$TEST_TMP/cli-test/sub/.claude"
save_level_with_hierarchy "$TEST_TMP/cli-test/sub/.claude" "product" "sub" >/dev/null 2>&1

cd "$TEST_TMP/cli-test/sub"
PARENT_RESULT=$(bash "$HIERARCHY_DETECTOR" get-parent "$PWD" 2>/dev/null)

if [[ "$PARENT_RESULT" == "$TEST_TMP/cli-test/.claude" ]]; then
    test_pass "CLI get-parent returns correct parent"
else
    test_fail "CLI get-parent failed: $PARENT_RESULT"
fi

# =============================================================================
# Test 20: Edge Cases
# =============================================================================
test_section "Edge Cases"

# Test with spaces in directory names
setup_test_env
mkdir -p "$TEST_TMP/company with spaces/.claude"
save_level_with_hierarchy "$TEST_TMP/company with spaces/.claude" "company" "company with spaces" >/dev/null 2>&1

if [[ -f "$TEST_TMP/company with spaces/.claude/organizational-level.json" ]]; then
    test_pass "Handles directory names with spaces"
else
    test_fail "Failed to handle directory names with spaces"
fi

# Test with special characters in name
setup_test_env
mkdir -p "$TEST_TMP/comp-123/.claude"
save_level_with_hierarchy "$TEST_TMP/comp-123/.claude" "company" "comp-123" >/dev/null 2>&1

NAME=$(jq -r '.level_name' "$TEST_TMP/comp-123/.claude/organizational-level.json")
if [[ "$NAME" == "comp-123" ]]; then
    test_pass "Handles special characters in names"
else
    test_fail "Failed to handle special characters: $NAME"
fi

# Test empty level_name (should default to directory name)
setup_test_env
mkdir -p "$TEST_TMP/default-name/.claude"
save_level_with_hierarchy "$TEST_TMP/default-name/.claude" "company" "" >/dev/null 2>&1

NAME=$(jq -r '.level_name' "$TEST_TMP/default-name/.claude/organizational-level.json")
if [[ "$NAME" == "default-name" ]]; then
    test_pass "Defaults level_name to directory name"
else
    test_fail "Failed to default level_name: $NAME"
fi

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
    echo -e "${GREEN}✓ All integration tests passed${NC}"
    echo ""
    echo "Hierarchical initialization workflow is fully functional:"
    echo "  ✓ Company → Product → Project initialization"
    echo "  ✓ Parent-child relationship validation"
    echo "  ✓ Hierarchy path building and tracking"
    echo "  ✓ Backward compatibility with old format"
    echo "  ✓ Error detection and handling"
    exit 0
else
    echo -e "${RED}✗ Some integration tests failed${NC}"
    exit 1
fi
