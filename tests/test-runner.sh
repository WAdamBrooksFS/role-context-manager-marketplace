#!/usr/bin/env bash

# test-runner.sh - Test suite for role-context-manager plugin

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

test_pass() { echo -e "${GREEN}✓${NC} $1"; ((TESTS_PASSED++)); return 0; }
test_fail() { echo -e "${RED}✗${NC} $1"; ((TESTS_FAILED++)); return 0; }
test_section() { echo ""; echo "═══ $1 ═══"; }

echo "╔═══════════════════════════════════════════════════════╗"
echo "║  Role Context Manager - Test Suite                   ║"
echo "╚═══════════════════════════════════════════════════════╝"

# Test 1: Bash script syntax validation
test_section "Bash Script Syntax"
bash -n "$PROJECT_ROOT/scripts/doc-validator.sh" 2>/dev/null && test_pass "doc-validator.sh syntax valid" || test_fail "doc-validator.sh syntax error"
bash -n "$PROJECT_ROOT/scripts/level-detector.sh" 2>/dev/null && test_pass "level-detector.sh syntax valid" || test_fail "level-detector.sh syntax error"
bash -n "$PROJECT_ROOT/scripts/role-manager.sh" 2>/dev/null && test_pass "role-manager.sh syntax valid" || test_fail "role-manager.sh syntax error"

# Test 2: Script executability
test_section "Script Executability"
[[ -x "$PROJECT_ROOT/scripts/doc-validator.sh" ]] && test_pass "doc-validator.sh is executable" || test_fail "doc-validator.sh not executable"
[[ -x "$PROJECT_ROOT/scripts/level-detector.sh" ]] && test_pass "level-detector.sh is executable" || test_fail "level-detector.sh not executable"
[[ -x "$PROJECT_ROOT/scripts/role-manager.sh" ]] && test_pass "role-manager.sh is executable" || test_fail "role-manager.sh not executable"

# Test 3: JSON validation
test_section "JSON Validation"
if command -v jq &>/dev/null; then
    jq empty "$PROJECT_ROOT/plugin.json" 2>/dev/null && test_pass "plugin.json valid" || test_fail "plugin.json invalid"
    jq empty "$PROJECT_ROOT/templates/role-references.json" 2>/dev/null && test_pass "role-references.json template valid" || test_fail "role-references.json template invalid"
else
    test_fail "jq not installed (required)"
fi

# Test 4: Plugin manifest fields
test_section "Plugin Manifest"
jq -e '.name' "$PROJECT_ROOT/plugin.json" &>/dev/null && test_pass "plugin.json has 'name' field" || test_fail "plugin.json missing 'name' field"
jq -e '.version' "$PROJECT_ROOT/plugin.json" &>/dev/null && test_pass "plugin.json has 'version' field" || test_fail "plugin.json missing 'version' field"
COMMAND_COUNT=$(jq '.commands | length' "$PROJECT_ROOT/plugin.json" 2>/dev/null || echo "0")
[[ $COMMAND_COUNT -gt 0 ]] && test_pass "plugin.json has $COMMAND_COUNT commands" || test_fail "plugin.json has no commands"

# Test 5: Command files exist
test_section "Command Files"
[[ -f "$PROJECT_ROOT/commands/set-role.md" ]] && test_pass "set-role.md exists" || test_fail "set-role.md missing"
[[ -f "$PROJECT_ROOT/commands/show-role-context.md" ]] && test_pass "show-role-context.md exists" || test_fail "show-role-context.md missing"
[[ -f "$PROJECT_ROOT/commands/update-role-docs.md" ]] && test_pass "update-role-docs.md exists" || test_fail "update-role-docs.md missing"
[[ -f "$PROJECT_ROOT/commands/init-role-docs.md" ]] && test_pass "init-role-docs.md exists" || test_fail "init-role-docs.md missing"
[[ -f "$PROJECT_ROOT/commands/set-org-level.md" ]] && test_pass "set-org-level.md exists" || test_fail "set-org-level.md missing"

# Test 6: Script files exist
test_section "Script Files"
[[ -f "$PROJECT_ROOT/scripts/role-manager.sh" ]] && test_pass "role-manager.sh exists" || test_fail "role-manager.sh missing"
[[ -f "$PROJECT_ROOT/scripts/doc-validator.sh" ]] && test_pass "doc-validator.sh exists" || test_fail "doc-validator.sh missing"
[[ -f "$PROJECT_ROOT/scripts/level-detector.sh" ]] && test_pass "level-detector.sh exists" || test_fail "level-detector.sh missing"

# Test 7: Documentation sections
test_section "Documentation"
[[ -f "$PROJECT_ROOT/README.md" ]] && test_pass "README.md exists" || test_fail "README.md missing"
grep -q "## Installation" "$PROJECT_ROOT/README.md" 2>/dev/null && test_pass "README has 'Installation' section" || test_fail "README missing 'Installation' section"
grep -q "## Quick Start" "$PROJECT_ROOT/README.md" 2>/dev/null && test_pass "README has 'Quick Start' section" || test_fail "README missing 'Quick Start' section"
grep -q "## Commands Reference" "$PROJECT_ROOT/README.md" 2>/dev/null && test_pass "README has 'Commands Reference' section" || test_fail "README missing 'Commands Reference' section"

# Test 8: Repository configuration
test_section "Repository Config"
[[ -f "$PROJECT_ROOT/.gitignore" ]] && test_pass ".gitignore exists" || test_fail ".gitignore missing"
grep -q "role-references.local.json" "$PROJECT_ROOT/.gitignore" 2>/dev/null && test_pass ".gitignore has local overrides pattern" || test_fail ".gitignore missing local overrides pattern"
[[ -d "$PROJECT_ROOT/.git" ]] && test_pass "Git repository initialized" || test_fail "Not a git repository"

# Test 9: Dependencies
test_section "Dependencies"
if command -v jq &>/dev/null; then
    JQ_VERSION=$(jq --version 2>/dev/null | grep -oP '\d+\.\d+' | head -1)
    test_pass "jq installed (version $JQ_VERSION)"
else
    test_fail "jq not installed"
fi
if command -v bash &>/dev/null; then
    BASH_VERSION=$(bash --version | head -1 | grep -oP '\d+\.\d+' | head -1)
    test_pass "bash installed (version $BASH_VERSION)"
else
    test_fail "bash not installed"
fi

# Test 10: Repository URL
test_section "Repository URL"
REPO_URL=$(jq -r '.repository' "$PROJECT_ROOT/plugin.json" 2>/dev/null)
[[ "$REPO_URL" != *"your-org"* ]] && test_pass "Repository URL updated" || test_fail "Repository URL still has placeholder"

# Summary
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
