# Validate Setup Command

Validate `.claude` directory structure and configuration for completeness and correctness.

## Purpose

This command performs comprehensive checks on your `.claude` directory, identifies issues, explains problems with context, and offers automated fixes. It's your troubleshooting assistant for maintaining a healthy role-context-manager setup.

## When to Use

- You're experiencing issues with role-context loading
- You manually edited configuration files and want to verify correctness
- You're onboarding new team members and want to validate their setup
- After template sync or updates to ensure everything still works
- Periodically as a health check for your `.claude` directory

## Usage

```bash
# Run full validation (validates both global and project scopes)
/validate-setup

# Quick validation (essential checks only)
/validate-setup --quick

# Validation with auto-fix (fixes issues automatically with confirmation)
/validate-setup --fix

# Silent mode (no output unless issues found) - for SessionStart hook
/validate-setup --silent

# Quiet mode (one-line summary) - for SessionStart hook
/validate-setup --quiet

# Summary mode (brief checklist of results)
/validate-setup --summary

# Validate only global config
/validate-setup --global

# Validate only project config
/validate-setup --project

# Validate specific scope
/validate-setup --scope global
```

## Instructions for Claude

When this command is executed, invoke the **framework-validator agent** to perform validation.

**Implementation**:

**CRITICAL: First-Run Detection (Highest Priority)**

**This check runs before anything else when invoked with `--quiet` or `--silent` flags:**

1. **Check if `.claude` directory exists**:
   ```bash
   if [ ! -d .claude ]; then
     # This is first run - no .claude directory exists yet
   fi
   ```

2. **If `.claude` directory does NOT exist (first run)**:
   - **Skip all other validation steps**
   - Display welcome message:
     ```
     👋 Welcome to role-context-manager!

     This plugin helps you organize documentation and maintain
     role-based context for Claude Code sessions.

     To get started, you need to initialize your organizational framework.
     ```

   - **Use AskUserQuestion tool** to ask:
     - Question: "Would you like to initialize your organizational framework now?"
     - Options:
       1. "Yes, initialize now" → Invoke template-setup-assistant agent
       2. "No, I'll do it later" → Show manual instructions
       3. "What does this plugin do?" → Show brief explanation, ask again

   - **If user chooses "Yes"**:
     - Use Task tool to invoke template-setup-assistant agent
     - Agent will guide through template selection and setup
     - After completion: Show success and next steps

   - **If user chooses "No"**:
     - Display: "No problem! Run /init-org-template when you're ready."
     - Exit with code 0 (don't show validation errors for missing .claude)

   - **If user chooses "What does this plugin do?"**:
     - Explain: "This plugin manages role-based documentation context. It helps Claude understand your role and automatically load relevant documents for better assistance."
     - Ask the initialization question again

3. **If `.claude` directory EXISTS**:
   - Skip first-run mode
   - Proceed to normal validation (step 4 below)

**Standard Validation (after first-run check passes)**:

4. **Parse command arguments**:
   - Check for `--quick` flag (run essential checks only)
   - Check for `--fix` flag (offer automated fixes)
   - Check for `--silent` flag (no output unless issues found)
   - Check for `--quiet` flag (one-line summary only)
   - Check for `--summary` flag (brief checklist of results)
   - Check for `--global` flag (validate only global config)
   - Check for `--project` flag (validate only project config)
   - Check for `--scope <value>` (validate specific scope)
   - Extract any other parameters

   Determine scope:
   - If `--global` present: scope = "global" (validate only ~/.claude/)
   - If `--project` present: scope = "project" (validate only ./.claude/)
   - If `--scope <value>` present: scope = value
   - Otherwise: scope = "both" (validate both global and project if they exist)

5. **Invoke the agent**:
   ```
   Use the Task tool with:
   - subagent_type: 'framework-validator'
   - description: 'Validate .claude directory setup'
   - prompt: 'Perform validation of the .claude directory structure and configuration at [scope] scope (both, global, or project). If scope is "both", validate both ~/.claude/ (global) and ./.claude/ (project) independently and show results for each. Check directory structure, validate JSON files, verify role guides exist and are properly formatted, validate reference integrity, check template tracking, and cross-reference documents. For each issue found, explain what's wrong, why it matters, how to fix it, and the likely root cause. Generate a validation report with appropriate verbosity based on flags provided. When validating both scopes, clearly indicate which config has issues.'
   ```

   **Add to prompt based on flags**:

   If `--silent` flag present:
   - Add: 'SILENT MODE: Run all validation checks but produce NO OUTPUT unless validation fails. If issues found, show only critical errors with actionable suggestions. If all checks pass, produce no output at all.'

   If `--quiet` flag present:
   - Add: 'QUIET MODE: Run all validation checks but output only a concise one-line summary. Examples: "✓ Setup valid" or "⚠ 3 issues found (run /validate-setup for details)". Include severity indicator and brief action item.'

   If `--summary` flag present:
   - Add: 'SUMMARY MODE: Show brief checklist of validation results. Format: "✓ Check name" for passed, "✗ Check name" for failed. Include 5-8 most important checks. Examples: "✓ .claude directory exists", "✓ Role guides present (6 files)", "✗ User role not set (run /set-role)"'

   If `--quick` flag present:
   - Add: 'Run only critical checks (directory structure, JSON validity, basic reference integrity). Skip detailed content validation and cross-referencing.'

   If `--fix` flag present:
   - Add: 'After identifying issues, offer automated fixes for fixable problems. Get user approval before applying fixes.'

6. **The agent will**:
   - Determine which configs to validate based on scope parameter
   - For each config (global and/or project):
     * Check directory structure (`.claude/`, `role-guides/`, `document-guides/`)
     * Validate all JSON configuration files
     * Verify role guides exist and are populated
     * Check reference integrity (roles, documents, templates)
     * Validate cross-references between files
     * Check template tracking if applied
   - If validating both scopes:
     * Validate global config (~/.claude/)
     * Validate project config (./.claude/)
     * Check configuration hierarchy and overrides
     * Ensure consistency between scopes
   - Generate validation report (verbosity depends on flags)
   - Categorize issues by severity (Critical, Warning, Info)
   - Explain each issue with context (unless --silent or --quiet)
   - Indicate which scope has issues (global vs project)
   - Offer automated fixes where possible (if --fix flag present)

7. **After agent completes**:
   - Display validation summary (verbosity based on flags)
   - Show critical issues first (unless --silent mode passes)
   - Provide next steps if issues found
   - Confirm setup is healthy if all checks pass

8. **Exit codes** (for SessionStart hook integration):
   - Exit code 0: Validation passed, no issues
   - Exit code 1: Warnings found, setup works but should review
   - Exit code 2: Critical errors found, setup broken

## Example Usage

### Full Validation

```bash
/validate-setup

# Agent performs comprehensive checks and reports:
#
# ═══════════════════════════════════════════════════
# .claude Directory Validation Report
# Generated: 2026-01-05 14:30:22
# ═══════════════════════════════════════════════════
#
# SUMMARY
# ✓ 15 checks passed
# ✗ 2 issues found
# ⚠ 1 warning
#
# CRITICAL ISSUES (Must Fix)
#
# ✗ Issue 1: role-references.json contains invalid JSON
#
#   What's wrong:
#     Trailing comma on line 8 in role-references.json
#
#   Why it matters:
#     File can't be parsed, breaking role document loading.
#     Users won't see their role's document references.
#
#   How to fix:
#     Option 1 (Automated): Remove trailing comma
#     Option 2 (Manual): Edit .claude/role-references.json line 8
#
#   Root cause:
#     Manual edit added trailing comma (JSON doesn't allow this)
#
# ✗ Issue 2: Missing role guide for set role
#
#   What's wrong:
#     preferences.json has user_role set to "data-engineer"
#     but no .claude/role-guides/data-engineer-guide.md exists
#
#   Why it matters:
#     AI doesn't have guidance for assisting data-engineers.
#     Role-specific behaviors won't be applied.
#
#   How to fix:
#     Option 1 (Automated): Generate role guide using /create-role-guide
#     Option 2 (Manual): Create data-engineer-guide.md yourself
#     Option 3: Change role to existing guide with /set-role
#
#   Root cause:
#     Role was added to preferences without creating guide first
#
# WARNINGS (Should Review)
#
# ⚠ Warning: Template version outdated
#
#   Current: software-org v1.0.0
#   Available: software-org v1.1.0
#
#   Recommendation:
#     Run /sync-template to update to latest version
#     New version includes 3 new role guides and bug fixes
#
# PASSED CHECKS
# ✓ .claude directory exists
# ✓ role-guides directory exists and populated (6 guides)
# ✓ preferences.json exists and is valid JSON
# ✓ organizational-level.json exists and is valid JSON
# ✓ Organizational level is valid value ("project")
# ✓ Applied template tracking is properly formatted
# ✓ All roles in role-references.json have corresponding guides
# ✓ Directory permissions are correct
# ... (more passed checks)
#
# NEXT STEPS
# 1. Fix invalid JSON in role-references.json
# 2. Create or change role to resolve missing guide
# 3. Consider updating template to v1.1.0
#
# Would you like me to attempt automated fixes? (yes/no)
```

### With Auto-Fix

```bash
/validate-setup --fix

# Agent finds issues and offers fixes:
#
# Found 2 fixable issues:
#
# Fix 1: Remove trailing comma in role-references.json
#   Will modify: .claude/role-references.json line 8
#   Backup: Create .claude/role-references.json.backup first
#
# Fix 2: Generate missing data-engineer role guide
#   Will create: .claude/role-guides/data-engineer-guide.md
#   Based on: Existing role guide patterns
#
# Apply fixes? (yes / select specific / cancel)
# > yes
#
# Applying fixes...
# ✓ Backed up role-references.json
# ✓ Fixed JSON syntax error
# ✓ Generated data-engineer-guide.md
#
# Re-validating...
# ✓ All checks passed!
#
# Your .claude directory is now properly configured.
```

### Quick Validation

```bash
/validate-setup --quick

# Agent runs essential checks only:
#
# Quick Validation Results
# ✓ .claude directory structure valid
# ✓ All JSON files valid
# ✓ Role guides directory populated
# ✓ Current role has corresponding guide
# ✓ Essential configuration present
#
# Setup appears healthy. Run full validation for detailed analysis.
```

## Validation Checks

### Critical Checks (Must Pass)
- `.claude/` directory exists with proper permissions (or custom configured directory)
- `.claude/role-guides/` directory exists (or custom configured path)
- At least one role guide file present
- `preferences.json` exists and is valid JSON
- `role-references.json` exists and is valid JSON
- `organizational-level.json` exists and is valid JSON
- JSON structure matches expected schema
- `paths.json` (if present) is valid and follows schema

### Important Checks (Should Pass)
- Multiple role guides exist (3+ for most templates)
- All roles in `role-references.json` have corresponding guide files
- Current `user_role` (if set) exists in `role-references.json`
- Organizational level is valid value (company/system/product/project)
- Applied template (if set) has valid structure (id, version, applied_date)
- Role guide files follow naming convention (`[role]-guide.md`)

### Quality Checks (Nice to Have)
- Document guides directory exists and is populated
- Referenced documents in role guides exist or are marked optional
- No broken cross-references between documents
- Template version is current (if template tracking enabled)
- File permissions are appropriate (readable, writable where needed)
- Role guides contain required sections
- Configuration values are sensible

### Path Configuration Validation

When `paths.json` is present, validation includes:

**Path Configuration Checks**:
- `paths.json` file is valid JSON
- Directory names follow security constraints (alphanumeric, dots, hyphens, underscores only)
- No path traversal attempts (`..` sequences)
- No absolute paths in configuration
- Configured directories actually exist
- Schema version is valid (if specified)

**Configuration Consistency**:
- Actual directory structure matches `paths.json` configuration
- Environment variables (if set) are consistent with manifest
- Global and local path configurations don't conflict

**Validation Example**:
```bash
# Validate with custom paths
/validate-setup

# Agent checks:
# ✓ Path configuration valid (.myorg/paths.json)
# ✓ Claude directory exists: .myorg/
# ✓ Role guides directory exists: .myorg/guides/
# ✓ Directory names follow security constraints
# ✓ No path traversal attempts detected
```

**Common Path Issues Detected**:
- Invalid directory names (spaces, special characters)
- Mismatched configuration (paths.json says `.myorg` but directory is `.claude`)
- Path traversal attempts in configuration
- Missing directories specified in paths.json
- Conflicting environment variables

**Auto-Fix Capabilities**:
- Create missing directories specified in paths.json
- Update paths.json to match actual directory structure
- Remove invalid path configuration entries
- Standardize directory name format

See [Path Configuration](../docs/PATH-CONFIGURATION.md) for complete path customization details.

## Issue Severity Levels

**Critical** (✗ Red):
- Blocks core functionality
- Causes errors or failures
- Must be fixed for system to work
- Examples: Missing directories, invalid JSON, broken references

**Warning** (⚠ Yellow):
- Functionality works but not optimal
- Potential issues or inconsistencies
- Should be addressed soon
- Examples: Outdated template, missing optional files, quality issues

**Info** (ℹ Blue):
- Informational only
- No functional impact
- Nice-to-have improvements
- Examples: Style inconsistencies, optimization suggestions

## Automated Fixes

The agent can automatically fix:

**JSON Issues**:
- Remove trailing commas
- Fix quote mismatches
- Repair common syntax errors
- Recreate malformed files

**Missing Files**:
- Create missing configuration files with defaults
- Create missing directories
- Generate missing role guides (with user input)

**Reference Issues**:
- Remove broken references
- Fix incorrect paths
- Update outdated references

**Configuration Issues**:
- Set valid default values
- Fix invalid enum values
- Correct data types

**Always with user approval** - agent never makes changes without confirmation.

## Validation Report Format

The report includes:

1. **Summary**: Overview of results
2. **Critical Issues**: Must-fix problems with detailed explanations
3. **Warnings**: Should-review items
4. **Passed Checks**: What's working correctly
5. **Configuration Details**: Current setup information
6. **Recommendations**: Specific suggestions based on findings
7. **Next Steps**: Actionable steps to resolve issues

## Integration with Other Commands

**After template operations**:
- After `/init-org-template` - verify template applied correctly
- After `/sync-template` - ensure merge was successful
- After `/create-role-guide` - verify new guide is properly integrated

**Before critical operations**:
- Before committing `.claude` to git - ensure it's valid
- Before sharing setup with team - verify it's complete
- Before running other plugin commands - check health

**Troubleshooting**:
- When `/set-role` fails - validate to find issue
- When `/show-role-context` shows errors - check what's wrong
- When context isn't loading - identify root cause

## Error Handling

**If validation itself fails**:
- Report what checks succeeded before failure
- Explain what prevented completion
- Provide manual validation steps
- Suggest recovery actions

**If automated fix fails**:
- Explain what went wrong
- Revert any partial changes
- Provide manual fix instructions
- Offer alternative approaches

**If structure is severely broken**:
- Assess if recovery is possible
- Suggest backup and fresh template application
- Provide step-by-step recovery plan
- Offer migration assistance

## Notes

- Validation is non-destructive - only reads, doesn't modify (unless --fix used)
- Safe to run frequently as a health check
- Generates detailed reports you can share with team
- Helps with troubleshooting and debugging
- Complements manual validation with automated checks

## Best Practices

**Run validation**:
- After manual edits to `.claude` files
- After template updates or syncs
- Before sharing setup with teammates
- Periodically (monthly) as maintenance
- When experiencing unexplained issues

**Use --fix cautiously**:
- Review proposed fixes before accepting
- Understand what will be changed
- Back up important customizations
- Test after fixes applied

**Share validation reports**:
- Include in troubleshooting discussions
- Attach to bug reports if needed
- Use to verify team member setups
- Document setup requirements
