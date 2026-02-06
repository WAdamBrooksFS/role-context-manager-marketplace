# WEAVER_BLUEPRINT: Path Configuration Manifest System

**Version**: 1.7.0
**Generated From**: Plan at `/home/practice-adam-brooks/.claude/plans/shimmering-petting-hammock.md`
**Feature**: Comprehensive Path Configuration with Hybrid Manifest + Environment Variables
**Status**: Ready for Decomposition
**Estimated Timeline**: 6 weeks

## Executive Summary

Implement a hybrid path configuration system enabling enterprise/multi-tenant deployments where all directory names, file locations, and organizational conventions are fully customizable. Users can configure paths via manifest files (`.claude/paths.json`) for persistent config or environment variables for runtime overrides.

**Key Value Proposition**: Eliminates hardcoded `.claude` directory assumptions (40+ occurrences), enabling multiple isolated instances, organizational naming compliance, and collision-free multi-tool ecosystems.

## Requirements

### User Goals
- **Primary**: Support multi-tenant/enterprise deployments with custom naming conventions
- **Secondary**: Allow flexible configuration without breaking existing setups (100% backward compatible)
- **Tertiary**: Enable per-project and per-user path customization with clear precedence

### Current Pain Points
1. `.claude` directory name hardcoded in 40+ locations → name collisions with other tools
2. `role-guides/` subdirectory hardcoded → can't match org conventions (`personas/`, `agents/`)
3. Config filenames hardcoded (`preferences.json`, etc.) → difficult to run multiple instances
4. Backup/cache locations hardcoded → compliance requirements unmet

### Success Criteria
- [ ] 100% backward compatible with v1.6.0 (zero migration required)
- [ ] Environment variables override all other config sources
- [ ] Manifest files configure persistent project settings
- [ ] Hierarchical setups work with custom directory names
- [ ] Performance overhead <10ms per command invocation
- [ ] All 125+ comprehensive tests pass
- [ ] Security: Rejects path traversal, validates all inputs

## Architecture

### Configuration Hierarchy (Precedence Order)

```
1. Environment Variables     RCM_CLAUDE_DIR_NAME, RCM_ROLE_GUIDES_DIR, etc.
   ↓ (highest priority)
2. Project Manifest          .claude/paths.json or $PWD/.custom/paths.json
   ↓
3. Global Manifest           ~/.config/role-context-manager/paths.json
   ↓
4. Hardcoded Defaults        Backward compatible with v1.6.0
   (lowest priority)
```

### Configuration Schema

**Manifest Location**: `.claude/paths.json` (or custom if already configured)

```json
{
  "$schema": "https://role-context-manager/schemas/paths-v1.json",
  "version": "1.0.0",
  "directories": {
    "claude_dir_name": ".claude",
    "role_guides_dir": "role-guides",
    "backups_dir": ".backups",
    "cache_dir": ".cache",
    "document_guides_dir": "document-guides"
  },
  "files": {
    "preferences": "preferences.json",
    "organizational_level": "organizational-level.json",
    "role_references": "role-references.json",
    "role_references_local": "role-references.local.json",
    "settings": "settings.json",
    "settings_local": "settings.local.json"
  },
  "global": {
    "home_config_dir": "~/.claude",
    "system_config_dir": "~/.config/role-context-manager"
  },
  "plugin": {
    "templates_dir": "templates",
    "scripts_dir": "scripts",
    "commands_dir": "commands",
    "agents_dir": "agents"
  }
}
```

### Environment Variables (15 Total)

All optional, override manifest and defaults:

```bash
# Directory names (5 vars)
RCM_CLAUDE_DIR_NAME=".myorg-claude"
RCM_ROLE_GUIDES_DIR="personas"
RCM_BACKUPS_DIR=".rcm-backups"
RCM_CACHE_DIR=".cache"
RCM_DOCUMENT_GUIDES_DIR="document-guides"

# Config filenames (6 vars)
RCM_PREFERENCES_FILE="config.json"
RCM_ORG_LEVEL_FILE="org-structure.json"
RCM_ROLE_REF_FILE="role-documents.json"
RCM_ROLE_REF_LOCAL_FILE="role-documents.local.json"
RCM_SETTINGS_FILE="settings.json"
RCM_SETTINGS_LOCAL_FILE="settings.local.json"

# Global locations (2 vars)
RCM_HOME_CONFIG_DIR="~/.myorg/rcm"
RCM_SYSTEM_CONFIG_DIR="~/.config/myorg-rcm"

# Plugin structure (2 vars - rare, for relocated installations)
RCM_TEMPLATES_DIR="/opt/rcm-templates"
RCM_SCRIPTS_DIR="/opt/rcm/scripts"
```

## Critical Files

### Files to CREATE (13 new files)
- `scripts/path-config.sh` - Core configuration library (~350 lines)
- `schemas/paths-v1.schema.json` - JSON Schema for validation (~200 lines)
- `commands/configure-paths.sh` - Configuration command wrapper (~200 lines)
- `commands/configure-paths.md` - Configuration command docs (~400 lines)
- `commands/show-paths.sh` - Path display command (~100 lines)
- `commands/show-paths.md` - Path display docs (~150 lines)
- `docs/PATH-CONFIGURATION.md` - Comprehensive guide (~1000 lines)
- `docs/MIGRATION-TO-PATH-CONFIG.md` - Migration guide (~300 lines)
- `tests/test-path-config.sh` - Unit tests (~600 lines, 55 tests)
- `tests/test-custom-paths-integration.sh` - Integration tests (~800 lines, 50 tests)
- `tests/test-backward-compatibility.sh` - Compatibility tests (~400 lines, 20 tests)
- `templates/core/software-org/.claude/paths.json` - Default manifest (~50 lines)
- `templates/core/startup-org/.claude/paths.json` - Default manifest (~50 lines)

### Files to MODIFY (15 existing files)
- `scripts/role-manager.sh` - Refactor 34+ path references (~150 lines modified)
- `scripts/template-manager.sh` - Refactor 4+ path references (~40 lines modified)
- `scripts/level-detector.sh` - Refactor find_claude_dir + 4 refs (~30 lines modified)
- `scripts/hierarchy-detector.sh` - Update parent discovery (~20 lines modified)
- `scripts/doc-validator.sh` - Update document resolution (~15 lines modified)
- `scripts/post-install.sh` - Update hook installation (~10 lines modified)
- `commands/validate-setup.md` - Add path validation section (~100 lines added)
- `CLAUDE.md` - Add path configuration section (~150 lines added)
- `README.md` - Add quick start for custom paths (~50 lines added)
- `CHEATSHEET.md` - Add new commands (~80 lines added)
- `TEMPLATES.md` - Document paths.json (~60 lines added)
- `commands/init-org-template.md` - Document path customization (~40 lines added)
- `commands/load-role-context.md` - Update example paths (~20 lines modified)
- `commands/set-role.md` - Update example paths (~20 lines modified)
- All `agents/*/agent.md` (6 files) - Update example paths (~10 lines each)

## Key Implementation Constraints

### Backward Compatibility (CRITICAL - Blocking)
- **Constraint**: Zero breaking changes for v1.6.0 users
- **Source**: Plan requirement "100% backward compatible"
- **Verification**: All existing tests pass, defaults match exactly, no forced migration
- **Example**: User with existing `.claude/` setup must continue working without any changes

### Performance Requirements (High Priority)
- **Constraint**: path-config loading <5ms, total overhead <10ms per command
- **Source**: Enterprise requirement for fast command execution
- **Verification**: `time` measurements, performance test suite
- **Example**: `time (source scripts/path-config.sh && load_path_config)` must be <5ms

### Security Requirements (Critical)
- **Constraint**: Reject path traversal (`..`, `/`), null bytes, command injection
- **Source**: User-provided configuration is untrusted input
- **Verification**: Security test suite with malicious inputs
- **Example**: `RCM_CLAUDE_DIR_NAME="../etc"` must be rejected with error

### Code Quality Standards
- **Constraint**: All scripts pass `bash -n` and `shellcheck`, comprehensive comments
- **Source**: Existing codebase standards
- **Verification**: CI checks, manual review
- **Example**: Every function must have usage comment: `# Usage: function_name arg1 arg2`

## Verification Strategy

### End-to-End Test Scenarios

#### Scenario A: Default Behavior (Backward Compatibility)
```bash
# Setup: Clean system, no custom config
cd /tmp/test-default
/init-org-template
/set-role software-engineer
/load-role-context

# Verification Commands:
test -d .claude
test -d .claude/role-guides
test -f .claude/preferences.json
grep -q "software-engineer" .claude/preferences.json

# Expected Result:
# - .claude directory created (not any other name)
# - role-guides/ subdirectory exists (not any other name)
# - preferences.json created (not any other filename)
# - All commands work identically to v1.6.0
# - NO paths.json created (not required for defaults)
```

#### Scenario B: Environment Variable Override
```bash
# Setup: Set environment variables before any operations
export RCM_CLAUDE_DIR_NAME=".rcm"
export RCM_ROLE_GUIDES_DIR="personas"

cd /tmp/test-custom-env
/init-org-template
/set-role software-engineer
/load-role-context
/show-paths

# Verification Commands:
test -d .rcm
test -d .rcm/personas
test -f .rcm/preferences.json
test ! -d .claude  # Old name must NOT be created
/show-paths | grep 'claude_dir_name: ".rcm" (from: environment variable)'

# Expected Result:
# - .rcm directory created (not .claude)
# - .rcm/personas/ exists (not role-guides)
# - preferences.json in .rcm/
# - Role context loads from .rcm/personas/
# - /show-paths correctly identifies env var as source
```

#### Scenario C: Manifest Configuration
```bash
# Setup: Create manifest before init
cd /tmp/test-manifest
mkdir .claude
cat > .claude/paths.json <<'EOF'
{
  "version": "1.0.0",
  "directories": {
    "claude_dir_name": ".mycompany-rcm",
    "role_guides_dir": "agent-guides"
  }
}
EOF

/init-org-template
/show-paths

# Verification Commands:
test -d .mycompany-rcm
test -d .mycompany-rcm/agent-guides
/show-paths | grep 'claude_dir_name: ".mycompany-rcm" (from: project manifest)'

# Expected Result:
# - .mycompany-rcm directory created
# - agent-guides subdirectory exists
# - Manifest config honored over defaults
# - /show-paths identifies manifest as source
```

#### Scenario D: Hybrid - Manifest + Env Var Override
```bash
# Setup: Global manifest + env var override
mkdir -p ~/.config/role-context-manager
echo '{"directories":{"claude_dir_name":".rcm"}}' > ~/.config/role-context-manager/paths.json
export RCM_CLAUDE_DIR_NAME=".custom"

cd /tmp/test-hybrid
/init-org-template
/show-paths

# Verification Commands:
test -d .custom  # Env var wins
test ! -d .rcm   # Manifest value not used
/show-paths | grep 'claude_dir_name: ".custom" (from: environment variable)'

# Expected Result:
# - .custom directory created (env var precedence)
# - .rcm NOT created (manifest overridden)
# - /show-paths shows env var as source, not manifest
# - Precedence order respected: env > project > global > default
```

#### Scenario E: Hierarchical Multi-Tenant Setup
```bash
# Setup: Parent and child with different configs
cd /tmp/enterprise
mkdir parent-project child-project

cd parent-project
export RCM_CLAUDE_DIR_NAME=".parent-rcm"
/init-org-template --root

cd ../child-project
export RCM_CLAUDE_DIR_NAME=".child-rcm"
/init-org-template

# Verification Commands:
test -d ../parent-project/.parent-rcm
test -d .child-rcm
grep -q "parent_claude_dir" .child-rcm/organizational-level.json

# Expected Result:
# - Hierarchy detection works with custom names
# - Parent filtering respects custom directory names
# - Both configs isolated and functional
# - Child detects parent even with non-default name
```

#### Scenario F: Migration of Existing Setup
```bash
# Setup: Existing .claude setup from v1.6.0
cd /tmp/existing-setup
mkdir -p .claude/role-guides
echo '{"user_role":"software-engineer"}' > .claude/preferences.json
echo 'Test content' > .claude/role-guides/software-engineer-guide.md

/configure-paths --migrate .claude .myorg-rcm

# Verification Commands:
test -d .myorg-rcm
test -d .myorg-rcm/role-guides
test -f .myorg-rcm/preferences.json
test -f .myorg-rcm/paths.json
test ! -d .claude  # Old directory removed
grep -q '"claude_dir_name": ".myorg-rcm"' .myorg-rcm/paths.json
/set-role software-engineer  # Must still work

# Expected Result:
# - .myorg-rcm/ exists with all files
# - .claude/ directory removed
# - paths.json created with new name
# - preferences.json migrated intact
# - /set-role, /load-role-context work with new location
# - No data loss during migration
```

### Security Verification

```bash
# Test 1: Reject path traversal with dots
echo '{"directories":{"claude_dir_name":"../etc"}}' > .claude/paths.json
/validate-setup 2>&1 | grep -q "path traversal"
# Expected: Error detected

# Test 2: Reject path traversal with slash
export RCM_CLAUDE_DIR_NAME="/etc/passwd"
/init-org-template 2>&1 | grep -q "invalid"
# Expected: Error or sanitization

# Test 3: Reject null byte injection
export RCM_CLAUDE_DIR_NAME=$'.claude\x00/etc/passwd'
/init-org-template 2>&1 | grep -q "invalid"
# Expected: Error about invalid characters

# Test 4: Reject slash in directory name
export RCM_CLAUDE_DIR_NAME=".claude/../../etc"
/init-org-template 2>&1 | grep -q "invalid"
# Expected: Error about invalid characters

# Test 5: Accept valid names
export RCM_CLAUDE_DIR_NAME=".my-org_claude.v2"
/init-org-template
test -d .my-org_claude.v2
# Expected: Success, directory created
```

### Performance Benchmarks

```bash
# Benchmark 1: path-config load time
time bash -c '
for i in {1..100}; do
  (source scripts/path-config.sh && load_path_config) > /dev/null
done
'
# Expected: Total <500ms (avg <5ms per iteration)

# Benchmark 2: Command overhead
time bash -c 'for i in {1..50}; do /show-role-context > /dev/null; done'
# Expected: <10ms additional overhead per command vs v1.6.0

# Benchmark 3: Cached getter performance
bash -c '
source scripts/path-config.sh
load_path_config
time for i in {1..1000}; do get_claude_dir_name > /dev/null; done
'
# Expected: <100ms total (cached, no file I/O)
```

## Test Matrix

| Test Category | Test Count | File | Purpose |
|---------------|------------|------|---------|
| Unit - Path Config | 55 | test-path-config.sh | Default loading, manifest parsing, env vars, validation, performance |
| Integration - Custom Paths | 50 | test-custom-paths-integration.sh | E2E workflows with custom names in various scenarios |
| Backward Compatibility | 20 | test-backward-compatibility.sh | Ensure v1.6.0 setups work unchanged |
| Security | 10 | test-path-config.sh | Path traversal, injection, sanitization |
| Performance | 5 | test-path-config-performance.sh | Load time, caching, overhead |
| **TOTAL** | **140** | | |

## Dependencies

### External Tools
- `bash` 4.0+ (associative arrays, parameter expansion)
- `jq` 1.5+ (JSON parsing - optional but recommended)
- `jsonschema` CLI (optional, for schema validation)

### Internal Dependencies (Load Order)
1. `scripts/path-config.sh` - MUST be created first, no dependencies
2. `schemas/paths-v1.schema.json` - For validation, referenced by path-config.sh
3. All other scripts - Source path-config.sh, call load_path_config

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing setups | High without testing | Critical | 20 backward compat tests, phased rollout |
| Path traversal vuln | Medium (user config) | High | Strict validation, whitelist patterns only |
| Performance degradation | Low | Low | Benchmarking required, caching implemented |
| Complexity creep | Medium | Medium | Centralize in path-config.sh, clear docs |
| Incomplete refactoring | Medium | High | Grep audit (40+ occurrences), test coverage |

## Timeline

- **Week 1**: Core library (path-config.sh, schema, unit tests)
- **Week 2-3**: Refactor all scripts (role-manager, template-manager, level-detector, hierarchy-detector)
- **Week 3**: User commands (/configure-paths, /show-paths, /validate-setup updates)
- **Week 4**: Templates (add paths.json) + Documentation (PATH-CONFIGURATION.md)
- **Week 5-6**: Integration tests, backward compat tests, E2E testing, bug fixes

**Total**: 6 weeks from start to verified release

---

**Status**: READY FOR DECOMPOSITION
**Next Command**: `/workflow-weaver:decompose` to generate `tasks.json`
