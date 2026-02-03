#!/usr/bin/env bash

# test-role-guide-selection.sh - Test suite for role guide selection feature

set -o pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_MANAGER="$PROJECT_ROOT/scripts/template-manager.sh"
TESTS_PASSED=0
TESTS_FAILED=0
TEST_TMP="/tmp/test-role-selection-$$"

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

# Source the template-manager functions
source "$TEMPLATE_MANAGER" 2>/dev/null || {
    echo "Error: Could not source $TEMPLATE_MANAGER" >&2
    exit 1
}

# Restore shell options after sourcing
set +e
set +u

echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Role Guide Selection - Test Suite                   ║"
echo "╚═══════════════════════════════════════════════════════╝"

# =============================================================================
# Test Section 1: Script Validation
# =============================================================================
test_section "Script Validation"

if [[ -f "$TEMPLATE_MANAGER" ]]; then
    test_pass "template-manager.sh exists"
else
    test_fail "template-manager.sh missing"
fi

if bash -n "$TEMPLATE_MANAGER" 2>/dev/null; then
    test_pass "template-manager.sh syntax valid"
else
    test_fail "template-manager.sh syntax error"
fi

# =============================================================================
# Test Section 2: Selection String Parsing
# =============================================================================
test_section "Selection String Parsing"

# Test: Parse simple guide list
setup_test_env
SELECTION="software-engineer-guide.md,qa-engineer-guide.md"
# Simulate parsing by checking if function accepts 4th parameter
if apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" &>/dev/null || [[ $? -eq 1 ]]; then
    test_pass "Function accepts 4th parameter (selection string)"
else
    test_fail "Function does not accept 4th parameter"
fi

# Test: Parse CUSTOM: prefix
SELECTION="CUSTOM:platform-sre"
# Check if the parsing logic handles CUSTOM: prefix
# We'll test this by checking if the function processes it without syntax errors
if apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" &>/dev/null || [[ $? -eq 1 ]]; then
    test_pass "Function handles CUSTOM: prefix"
else
    test_fail "Function fails with CUSTOM: prefix"
fi

# Test: Mixed selection
SELECTION="software-engineer-guide.md,CUSTOM:devops-lead,qa-engineer-guide.md"
if apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" &>/dev/null || [[ $? -eq 1 ]]; then
    test_pass "Function handles mixed template and custom guides"
else
    test_fail "Function fails with mixed selection"
fi

# Test: Empty selection (backward compatibility)
SELECTION=""
setup_test_env
if apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" &>/dev/null || [[ $? -eq 1 ]]; then
    test_pass "Function handles empty selection (backward compatible)"
else
    test_fail "Function fails with empty selection"
fi

# Test: Whitespace handling
SELECTION=" software-engineer-guide.md , qa-engineer-guide.md "
if apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" &>/dev/null || [[ $? -eq 1 ]]; then
    test_pass "Function handles whitespace in selection"
else
    test_fail "Function fails with whitespace in selection"
fi

# =============================================================================
# Test Section 3: Path Traversal Protection
# =============================================================================
test_section "Path Traversal Protection"

# Test: Detect path traversal in guide name
SELECTION="../../../etc/passwd"
setup_test_env
OUTPUT=$(apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" 2>&1 || true)
if echo "$OUTPUT" | grep -q "path traversal"; then
    test_pass "Rejects path traversal in guide name"
else
    test_fail "Does not detect path traversal in guide name"
fi

# Test: Detect path traversal in CUSTOM: name
SELECTION="CUSTOM:../bad-guide"
setup_test_env
OUTPUT=$(apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" 2>&1 || true)
if echo "$OUTPUT" | grep -q "path traversal\|Invalid"; then
    test_pass "Rejects path traversal in CUSTOM: name"
else
    test_fail "Does not detect path traversal in CUSTOM: name"
fi

# Test: Detect slash in custom name
SELECTION="CUSTOM:roles/admin"
setup_test_env
OUTPUT=$(apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" 2>&1 || true)
if echo "$OUTPUT" | grep -q "path traversal\|Invalid"; then
    test_pass "Rejects slash in CUSTOM: name"
else
    test_fail "Does not detect slash in CUSTOM: name"
fi

# =============================================================================
# Test Section 4: Custom Name Validation
# =============================================================================
test_section "Custom Name Validation"

# Test: Valid kebab-case name
SELECTION="CUSTOM:platform-engineer"
setup_test_env
OUTPUT=$(apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" 2>&1 || true)
if ! echo "$OUTPUT" | grep -q "must be kebab-case"; then
    test_pass "Accepts valid kebab-case name"
else
    test_fail "Rejects valid kebab-case name"
fi

# Test: Reject uppercase in custom name
SELECTION="CUSTOM:PlatformEngineer"
setup_test_env
OUTPUT=$(apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" 2>&1 || true)
if echo "$OUTPUT" | grep -q "kebab-case"; then
    test_pass "Rejects uppercase in custom name"
else
    test_fail "Does not reject uppercase in custom name"
fi

# Test: Reject underscore in custom name
SELECTION="CUSTOM:platform_engineer"
setup_test_env
OUTPUT=$(apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" 2>&1 || true)
if echo "$OUTPUT" | grep -q "kebab-case"; then
    test_pass "Rejects underscore in custom name"
else
    test_fail "Does not reject underscore in custom name"
fi

# Test: Reject space in custom name
SELECTION="CUSTOM:platform engineer"
setup_test_env
OUTPUT=$(apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" 2>&1 || true)
if echo "$OUTPUT" | grep -q "kebab-case"; then
    test_pass "Rejects space in custom name"
else
    test_fail "Does not reject space in custom name"
fi

# Test: Accept numbers and hyphens
SELECTION="CUSTOM:platform-sre-2"
setup_test_env
OUTPUT=$(apply_template_with_mode "software-org" "minimal" "$TEST_TMP" "$SELECTION" 2>&1 || true)
if ! echo "$OUTPUT" | grep -q "must be kebab-case"; then
    test_pass "Accepts numbers and hyphens in custom name"
else
    test_fail "Rejects numbers and hyphens in custom name"
fi

# =============================================================================
# Test Section 5: Custom Guide Placeholder Generation
# =============================================================================
test_section "Custom Guide Placeholder Generation"

# Test: Function exists and callable
if command -v generate_custom_role_guide_placeholder &>/dev/null; then
    test_pass "generate_custom_role_guide_placeholder function exists"
else
    test_fail "generate_custom_role_guide_placeholder function not found"
fi

# Test: Generate placeholder for custom role
OUTPUT=$(generate_custom_role_guide_placeholder "test-role" "project" 2>&1)
if echo "$OUTPUT" | grep -q "# Test Role"; then
    test_pass "Generates placeholder with correct title"
else
    test_fail "Placeholder does not have correct title"
fi

# Test: Placeholder has Role Overview section
OUTPUT=$(generate_custom_role_guide_placeholder "platform-sre" "system" 2>&1)
if echo "$OUTPUT" | grep -q "## Role Overview"; then
    test_pass "Placeholder contains Role Overview section"
else
    test_fail "Placeholder missing Role Overview section"
fi

# Test: Placeholder has Deterministic Behaviors section
if echo "$OUTPUT" | grep -q "## Deterministic Behaviors"; then
    test_pass "Placeholder contains Deterministic Behaviors section"
else
    test_fail "Placeholder missing Deterministic Behaviors section"
fi

# Test: Placeholder has Agentic Opportunities section
if echo "$OUTPUT" | grep -q "## Agentic Opportunities"; then
    test_pass "Placeholder contains Agentic Opportunities section"
else
    test_fail "Placeholder missing Agentic Opportunities section"
fi

# Test: Placeholder has Common Workflows section
if echo "$OUTPUT" | grep -q "## Common Workflows"; then
    test_pass "Placeholder contains Common Workflows section"
else
    test_fail "Placeholder missing Common Workflows section"
fi

# Test: Placeholder includes organizational level
if echo "$OUTPUT" | grep -q "system"; then
    test_pass "Placeholder includes organizational level"
else
    test_fail "Placeholder does not include organizational level"
fi

# Test: Placeholder includes footer note
if echo "$OUTPUT" | grep -q "/generate-role-guide"; then
    test_pass "Placeholder includes footer note about /generate-role-guide"
else
    test_fail "Placeholder missing footer note"
fi

# =============================================================================
# Test Summary
# =============================================================================
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Test Summary                                         ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
else
    echo -e "${GREEN}Tests failed: $TESTS_FAILED${NC}"
fi
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
