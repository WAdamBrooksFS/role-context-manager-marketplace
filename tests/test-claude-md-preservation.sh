#!/usr/bin/env bash

# test-claude-md-preservation.sh - Test suite for CLAUDE.md preservation feature

set -o pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0
TEST_TMP="/tmp/test-claude-md-$$"

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
echo "║  CLAUDE.md Preservation - Test Suite                 ║"
echo "╚═══════════════════════════════════════════════════════╝"

# Test 1: Script existence and syntax
test_section "Script Validation"
if [[ -f "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" ]]; then
    test_pass "claude-md-analyzer.sh exists"
else
    test_fail "claude-md-analyzer.sh missing"
fi

if bash -n "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" 2>/dev/null; then
    test_pass "claude-md-analyzer.sh syntax valid"
else
    test_fail "claude-md-analyzer.sh syntax error"
fi

if [[ -x "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" ]]; then
    test_pass "claude-md-analyzer.sh is executable"
else
    test_fail "claude-md-analyzer.sh not executable"
fi

# Test 2: Detection - Case Insensitive
test_section "Case-Insensitive Detection"
setup_test_env

# Create test files with different case variations
echo "# Test" > "$TEST_TMP/CLAUDE.md"
echo "# Test" > "$TEST_TMP/claude.md"
echo "# Test" > "$TEST_TMP/Claude.md"
echo "# Test" > "$TEST_TMP/ClAuDe.Md"

RESULT=$(bash "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" --scan "$TEST_TMP" 2>/dev/null | jq '.files | length' 2>/dev/null || echo "0")

if [[ "$RESULT" -eq 4 ]]; then
    test_pass "Detected all 4 case variations"
else
    test_fail "Detection missed some case variations (found: $RESULT, expected: 4)"
fi

# Test 3: Detection - Hierarchical
test_section "Hierarchical Detection"
setup_test_env
mkdir -p "$TEST_TMP/level1/level2/level3/level4"
echo "# Root" > "$TEST_TMP/CLAUDE.md"
echo "# L1" > "$TEST_TMP/level1/CLAUDE.md"
echo "# L2" > "$TEST_TMP/level1/level2/CLAUDE.md"
echo "# L3" > "$TEST_TMP/level1/level2/level3/CLAUDE.md"
echo "# L4" > "$TEST_TMP/level1/level2/level3/level4/CLAUDE.md"

# Should find files up to 4 levels deep (root + 4 levels = 5 total, but limited to 4 depth)
RESULT=$(bash "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" --scan "$TEST_TMP" 2>/dev/null | jq '.files | length' 2>/dev/null || echo "0")

if [[ "$RESULT" -ge 4 ]]; then
    test_pass "Detected files in hierarchical structure (found: $RESULT)"
else
    test_fail "Hierarchical detection incomplete (found: $RESULT, expected: ≥4)"
fi

# Test 4: Analysis - Content Detection
test_section "Content Analysis"
setup_test_env
cat > "$TEST_TMP/CLAUDE.md" <<'EOF'
# Test File

## Mission
Test mission

## Capabilities
Test capabilities

## Guidelines
Test guidelines
EOF

RESULT=$(bash "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" --analyze "$TEST_TMP/CLAUDE.md" 2>/dev/null)

if echo "$RESULT" | jq -e '.has_standard_sections.mission == true' >/dev/null 2>&1; then
    test_pass "Detected mission section"
else
    test_fail "Failed to detect mission section"
fi

if echo "$RESULT" | jq -e '.has_standard_sections.capabilities == true' >/dev/null 2>&1; then
    test_pass "Detected capabilities section"
else
    test_fail "Failed to detect capabilities section"
fi

if echo "$RESULT" | jq -e '.has_standard_sections.guidelines == true' >/dev/null 2>&1; then
    test_pass "Detected guidelines section"
else
    test_fail "Failed to detect guidelines section"
fi

# Test 5: Analysis - Line Counting
test_section "Line Counting"
setup_test_env

# Create small file
echo -e "# Small\n\nContent\n" > "$TEST_TMP/small.md"
RESULT=$(bash "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" --analyze "$TEST_TMP/small.md" 2>/dev/null | jq '.line_count' 2>/dev/null || echo "0")
if [[ "$RESULT" -le 10 ]]; then
    test_pass "Small file line count correct ($RESULT lines)"
else
    test_fail "Small file line count incorrect ($RESULT lines)"
fi

# Create large file (>100 lines)
{
    echo "# Large File"
    for i in {1..110}; do
        echo "Line $i"
    done
} > "$TEST_TMP/large.md"

RESULT=$(bash "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" --analyze "$TEST_TMP/large.md" 2>/dev/null | jq '.line_count' 2>/dev/null || echo "0")
if [[ "$RESULT" -ge 100 ]]; then
    test_pass "Large file line count correct ($RESULT lines)"
else
    test_fail "Large file line count incorrect ($RESULT lines)"
fi

# Test 6: Suggestions - Adaptive Generation
test_section "Adaptive Suggestion Generation"
setup_test_env

# Small file should get 2-3 suggestions
echo "# Small" > "$TEST_TMP/small.md"
SMALL_RESULT=$(bash "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" --suggest "$TEST_TMP/small.md" software-org 2>/dev/null | jq '.enhancements | length' 2>/dev/null || echo "0")

if [[ "$SMALL_RESULT" -ge 1 && "$SMALL_RESULT" -le 5 ]]; then
    test_pass "Small file suggestions count appropriate ($SMALL_RESULT suggestions)"
else
    test_fail "Small file suggestions count out of range ($SMALL_RESULT suggestions)"
fi

# Large file should get 5-7+ suggestions
{
    echo "# Large File"
    for i in {1..110}; do
        echo "Content line $i"
    done
} > "$TEST_TMP/large.md"

LARGE_RESULT=$(bash "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" --suggest "$TEST_TMP/large.md" software-org 2>/dev/null | jq '.enhancements | length' 2>/dev/null || echo "0")

if [[ "$LARGE_RESULT" -ge 3 ]]; then
    test_pass "Large file suggestions count appropriate ($LARGE_RESULT suggestions)"
else
    test_fail "Large file suggestions count too low ($LARGE_RESULT suggestions)"
fi

# Test 7: Suggestions - JSON Schema
test_section "Suggestion JSON Schema"
setup_test_env
echo "# Test" > "$TEST_TMP/test.md"

RESULT=$(bash "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" --suggest "$TEST_TMP/test.md" software-org 2>/dev/null)

if echo "$RESULT" | jq -e '.file' >/dev/null 2>&1; then
    test_pass "Suggestions include 'file' field"
else
    test_fail "Suggestions missing 'file' field"
fi

if echo "$RESULT" | jq -e '.enhancements' >/dev/null 2>&1; then
    test_pass "Suggestions include 'enhancements' array"
else
    test_fail "Suggestions missing 'enhancements' array"
fi

if echo "$RESULT" | jq -e '.enhancements[0].priority' >/dev/null 2>&1; then
    test_pass "Enhancements include 'priority' field"
else
    test_fail "Enhancements missing 'priority' field"
fi

# Test 8: Template Preservation
test_section "Template Manager Preservation"
setup_test_env

# Create existing CLAUDE.md
echo "# Existing CLAUDE.md" > "$TEST_TMP/CLAUDE.md"
echo "This should be preserved." >> "$TEST_TMP/CLAUDE.md"

# Apply template
cd "$TEST_TMP"
OUTPUT=$(bash "$PROJECT_ROOT/scripts/template-manager.sh" apply-mode software-org standard . 2>&1 || true)

# Check if original content is preserved
if grep -q "This should be preserved" "$TEST_TMP/CLAUDE.md" 2>/dev/null; then
    test_pass "Original CLAUDE.md content preserved"
else
    test_fail "Original CLAUDE.md content was overwritten"
fi

# Check if preservation was recorded
if [[ -f "$TEST_TMP/.claude/preferences.json" ]]; then
    if jq -e '.preserved_claude_md' "$TEST_TMP/.claude/preferences.json" >/dev/null 2>&1; then
        test_pass "Preservation recorded in preferences.json"
    else
        test_fail "Preservation not recorded in preferences.json"
    fi
else
    test_fail "preferences.json not created"
fi

# Test 9: Suggestion File Creation
test_section "Suggestion File Creation"
setup_test_env
mkdir -p "$TEST_TMP/.claude"
cd "$TEST_TMP"

echo "# Test" > "$TEST_TMP/CLAUDE.md"
bash "$PROJECT_ROOT/scripts/claude-md-analyzer.sh" --suggest "$TEST_TMP/CLAUDE.md" software-org >/dev/null 2>&1

if [[ -f "$TEST_TMP/.claude/claude-md-suggestions.json" ]]; then
    test_pass "Suggestions file created in .claude/"
    if jq empty "$TEST_TMP/.claude/claude-md-suggestions.json" 2>/dev/null; then
        test_pass "Suggestions file is valid JSON"
    else
        test_fail "Suggestions file is invalid JSON"
    fi
else
    test_fail "Suggestions file not created"
fi

# Test 10: Test Fixtures Validation
test_section "Test Fixtures"

if [[ -f "$PROJECT_ROOT/tests/fixtures/small-claude.md" ]]; then
    LINE_COUNT=$(wc -l < "$PROJECT_ROOT/tests/fixtures/small-claude.md")
    if [[ "$LINE_COUNT" -lt 100 ]]; then
        test_pass "small-claude.md fixture exists and is small ($LINE_COUNT lines)"
    else
        test_fail "small-claude.md fixture is too large ($LINE_COUNT lines)"
    fi
else
    test_fail "small-claude.md fixture missing"
fi

if [[ -f "$PROJECT_ROOT/tests/fixtures/large-claude.md" ]]; then
    LINE_COUNT=$(wc -l < "$PROJECT_ROOT/tests/fixtures/large-claude.md")
    if [[ "$LINE_COUNT" -ge 100 ]]; then
        test_pass "large-claude.md fixture exists and is large ($LINE_COUNT lines)"
    else
        test_fail "large-claude.md fixture is too small ($LINE_COUNT lines)"
    fi
else
    test_fail "large-claude.md fixture missing"
fi

if [[ -f "$PROJECT_ROOT/tests/fixtures/hierarchical/CLAUDE.md" ]]; then
    test_pass "hierarchical/CLAUDE.md fixture exists"
else
    test_fail "hierarchical/CLAUDE.md fixture missing"
fi

# Test 11: Agent Documentation
test_section "Agent Documentation"

if [[ -f "$PROJECT_ROOT/agents/claude-md-enhancer/agent.md" ]]; then
    test_pass "claude-md-enhancer agent exists"
    if grep -q "## Your Mission" "$PROJECT_ROOT/agents/claude-md-enhancer/agent.md" 2>/dev/null; then
        test_pass "Agent has mission section"
    else
        test_fail "Agent missing mission section"
    fi
else
    test_fail "claude-md-enhancer agent missing"
fi

if [[ -f "$PROJECT_ROOT/commands/enhance-claude-md.md" ]]; then
    test_pass "enhance-claude-md command documentation exists"
    if grep -q -- "--list" "$PROJECT_ROOT/commands/enhance-claude-md.md" 2>/dev/null; then
        test_pass "Command documents --list flag"
    else
        test_fail "Command missing --list flag documentation"
    fi
    if grep -q -- "--plan" "$PROJECT_ROOT/commands/enhance-claude-md.md" 2>/dev/null; then
        test_pass "Command documents --plan flag"
    else
        test_fail "Command missing --plan flag documentation"
    fi
else
    test_fail "enhance-claude-md command documentation missing"
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
