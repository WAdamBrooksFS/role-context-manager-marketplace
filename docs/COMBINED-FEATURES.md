# Combined Features Guide

Complete guide to using Path Configuration and Hierarchical Organizations together.

**Version:** 1.7.0
**Features:** Path Configuration System + Hierarchical Organizations (Integrated)

---

## Table of Contents

- [Overview](#overview)
- [How the Systems Work Together](#how-the-systems-work-together)
- [Combined Configuration](#combined-configuration)
- [Advanced Workflows](#advanced-workflows)
- [Edge Cases and Limitations](#edge-cases-and-limitations)
- [Migration Strategies](#migration-strategies)
- [Performance Considerations](#performance-considerations)
- [Troubleshooting Combined Systems](#troubleshooting-combined-systems)
- [Best Practices](#best-practices)
- [Real-World Examples](#real-world-examples)

---

## Overview

Role Context Manager v1.7.0 combines two powerful features:

1. **Path Configuration System (v1.6.0)**: Customize directory names (`.claude` → `.myorg`)
2. **Hierarchical Organizations (v1.5.0)**: Multi-level structures with inheritance

These features were developed independently but integrated to work seamlessly together, providing maximum flexibility for organizing documentation across complex organizational structures.

### What This Guide Covers

This guide focuses on:
- Using both features simultaneously
- How they interact and integrate
- Advanced workflows combining both
- Edge cases when using together
- Best practices for combined usage

**For individual feature documentation, see:**
- [Path Configuration Guide](PATH-CONFIGURATION.md) - Path customization only
- [Hierarchical Organizations Guide](HIERARCHICAL-ORGANIZATIONS.md) - Hierarchy only

### When to Use Both Features

**Use Path Configuration When:**
- Organizational naming standards require specific directory names
- Need to avoid conflicts with other tools using `.claude`
- Migrating from existing system with different naming
- Want branded directory names (`.acme` instead of `.claude`)

**Use Hierarchical Organizations When:**
- Multiple teams/projects within one company
- Need role guide inheritance across levels
- Want to avoid duplicating company-wide standards
- Growing organization with sub-organizations

**Use Both Together When:**
- Need custom directory names AND organizational hierarchy
- Large enterprise with naming standards and complex structure
- Multiple products/projects requiring consistent branding
- Migration of hierarchical system to new directory names

---

## How the Systems Work Together

### Integration Architecture

```
Command Invocation
       ↓
Role Manager / Template Manager
       ↓
   ┌───────────────┴───────────────┐
   ↓                               ↓
Path Config System      Hierarchy Detector
(resolve directory      (find parents,
 names dynamically)      validate relationships)
       ↓                               ↓
   Uses path-config API ←──────────────┘
   (get_claude_dir_name, etc.)
       ↓
Filesystem Operations
(read/write with resolved paths)
```

**Key Integration Points:**

1. **Hierarchy Detector Uses Path Config**
   - Sources `path-config.sh` at initialization
   - Calls `get_claude_dir_name()` instead of hardcoded `.claude`
   - All parent detection uses resolved directory names

2. **Template Manager Uses Both**
   - Uses path config to determine target directories
   - Uses hierarchy detection to filter role guides
   - Applies templates to custom-named directories with level awareness

3. **Validation Checks Both**
   - Validates path configuration correctness
   - Validates hierarchy relationships
   - Ensures both systems work together without conflicts

### Integration Example

```bash
# Setup: Custom paths configured globally
export RCM_CLAUDE_DIR_NAME=".myorg"
export RCM_ROLE_GUIDES_DIR="guides"

# Company level
cd /company-root
/init-org-template
# 1. Path config resolves: ".myorg" (custom name)
# 2. Creates: .myorg/guides/ (custom paths)
# 3. Hierarchy detector: No parent found (root level)
# 4. Result: .myorg/ directory, no parent reference

# Product level (child)
cd /company-root/product-a
/init-org-template
# 1. Path config resolves: ".myorg" (from env/global config)
# 2. Hierarchy detector scans for: ".myorg" directories (not ".claude")
# 3. Finds parent: /company-root/.myorg
# 4. Reads parent level: "company"
# 5. Validates: product child of company (valid)
# 6. Creates: .myorg/guides/ with parent reference
# 7. Filters template: Only product+project guides copied
# 8. Result: .myorg/ with parent_claude_dir: "/company-root/.myorg"
```

**Result:** Hierarchical detection works seamlessly with custom directory names.

---

## Combined Configuration

### Scenario 1: Global Custom Paths + Hierarchy

Configure custom paths globally, use throughout hierarchy:

```bash
# Step 1: Configure custom paths globally
/configure-paths --global --claude-dir=.acme --role-guides-dir=guides

# Step 2: Initialize company level
cd /company-root
/init-org-template
# Creates: .acme/guides/
# Parent: None (root)
/set-org-level company

# Step 3: Initialize product level
cd /company-root/product-a
/init-org-template
# Path config: Uses .acme from global config
# Hierarchy: Detects parent at /company-root/.acme
# Creates: .acme/guides/
# Parent: /company-root/.acme
/set-org-level product

# Step 4: Initialize project level
cd /company-root/product-a/project-x
/init-org-template
# Path config: Uses .acme from global config
# Hierarchy: Detects parent at /company-root/product-a/.acme
# Creates: .acme/guides/
# Parent: /company-root/product-a/.acme
/set-org-level project
```

**Result:**
```
/company-root/
  └── .acme/                          (company, custom name)
      └── guides/                     (custom role-guides name)
          └── cto-guide.md
      └── paths.json                  (path config manifest)
      └── organizational-level.json   (level: company)

/company-root/product-a/
  └── .acme/                          (product, inherits custom name)
      └── guides/
          └── product-manager-guide.md
      └── organizational-level.json   (parent: /company-root/.acme)

/company-root/product-a/project-x/
  └── .acme/                          (project, inherits custom name)
      └── guides/
          └── software-engineer-guide.md
      └── organizational-level.json   (parent: ../product-a/.acme)
```

### Scenario 2: Local Custom Paths with Hierarchy

Each level has own path configuration:

```bash
# Company with defaults
cd /company-root
/init-org-template
# Creates: .claude/role-guides/
/set-org-level company

# Product with custom paths
cd /company-root/product-a
/configure-paths --local --claude-dir=.product --role-guides-dir=guides
/init-org-template
# Path config: Uses .product from local config
# Hierarchy: Detects parent at /company-root/.claude (different name)
# Creates: .product/guides/
# Parent: /company-root/.claude
/set-org-level product

# Project with different custom paths
cd /company-root/product-a/project-x
/configure-paths --local --claude-dir=.proj
/init-org-template
# Path config: Uses .proj from local config
# Hierarchy: Detects parent at /company-root/product-a/.product
# Creates: .proj/
# Parent: /company-root/product-a/.product
/set-org-level project
```

**Result:** Mixed path names, hierarchy detection still works across different names.

### Scenario 3: Environment Variables + Hierarchy

Use environment variables for temporary path overrides:

```bash
# Set environment variables
export RCM_CLAUDE_DIR_NAME=".env-override"
export RCM_ROLE_GUIDES_DIR="env-guides"

# All levels use environment config
cd /company-root
/init-org-template  # Uses .env-override/env-guides/

cd /company-root/product-a
/init-org-template  # Uses .env-override/env-guides/
                    # Detects parent: /company-root/.env-override

# Unset environment variables
unset RCM_CLAUDE_DIR_NAME RCM_ROLE_GUIDES_DIR

# Subsequent operations use defaults or manifests
cd /company-root/product-b
/init-org-template  # Uses .claude/ (default)
                    # Detects parent: /company-root/.env-override (still valid)
```

**Result:** Environment variables provide temporary overrides, hierarchy persists.

---

## Advanced Workflows

### Workflow 1: Migrating Hierarchy to Custom Paths

Migrate entire hierarchical structure to new directory names:

**Step 1: Plan Migration**
```bash
# Document current structure
tree -L 3 -d | grep .claude

# Choose new directory names
# Decision: .myorg and guides
```

**Step 2: Configure New Paths Globally**
```bash
/configure-paths --global --claude-dir=.myorg --role-guides-dir=guides
```

**Step 3: Migrate Top-Down (Critical Order)**
```bash
# IMPORTANT: Migrate parent before children

# 1. Migrate company level (root)
cd /company-root
/configure-paths --migrate .claude .myorg
# Renames: .claude → .myorg
# Updates: Internal references, creates paths.json

# 2. Migrate product level (child of company)
cd /company-root/product-a
/configure-paths --migrate .claude .myorg
# Renames: .claude → .myorg
# Updates: parent_claude_dir to "/company-root/.myorg"
# Maintains: Hierarchy relationship

# 3. Migrate project level (child of product)
cd /company-root/product-a/project-x
/configure-paths --migrate .claude .myorg
# Renames: .claude → .myorg
# Updates: parent_claude_dir to "/company-root/product-a/.myorg"
# Maintains: Hierarchy chain
```

**Step 4: Validate Migration**
```bash
# Validate each level
cd /company-root && /validate-setup
cd /company-root/product-a && /validate-setup
cd /company-root/product-a/project-x && /validate-setup

# All validations should pass with:
# ✓ Path configuration valid (.myorg/paths.json)
# ✓ Hierarchy relationship valid
# ✓ Parent path correct and accessible
```

### Workflow 2: Adding New Product to Existing Hierarchy

Add new product to company with custom paths:

```bash
# Existing: Company level with custom paths
# /company-root/.myorg/ (company level, custom name)

# Step 1: Navigate to new product location
cd /company-root/new-product

# Step 2: Inherit path configuration (automatic)
# Global config already set: .myorg

# Step 3: Initialize template
/init-org-template
# Detects parent: /company-root/.myorg (company level)
# Uses custom paths from global config
# Creates: .myorg/guides/
# Records parent: /company-root/.myorg

# Step 4: Set level
/set-org-level product

# Step 5: Add product-specific guides
/add-role-guides product-manager-guide.md
# Uses: .myorg/guides/ (custom paths)
# Filters: Skips company guides (inherited)
```

### Workflow 3: Reorganizing Hierarchy with Path Changes

Change both hierarchy structure and directory names:

**Before:**
```
/old-company/.claude/           (company)
  └── /project-a/.claude/       (project, direct child)
  └── /project-b/.claude/       (project, direct child)
```

**Goal:**
```
/new-company/.myorg/            (company, new name)
  └── /product-main/.myorg/     (product, new level)
      └── /project-a/.myorg/    (project, moved under product)
      └── /project-b/.myorg/    (project, moved under product)
```

**Steps:**
```bash
# 1. Configure new paths
/configure-paths --global --claude-dir=.myorg

# 2. Create new structure
mkdir -p /new-company/product-main
mv /old-company/project-a /new-company/product-main/
mv /old-company/project-b /new-company/product-main/

# 3. Migrate company level
cd /new-company
cp -r /old-company/.claude .claude-temp
/configure-paths --migrate .claude-temp .myorg
/set-org-level company

# 4. Initialize product level (new)
cd /new-company/product-main
/init-org-template
/set-org-level product
# Detects parent: /new-company/.myorg

# 5. Update projects
cd /new-company/product-main/project-a
/configure-paths --migrate .claude .myorg
/set-org-level project  # Re-detect parent (now product instead of company)

cd /new-company/product-main/project-b
/configure-paths --migrate .claude .myorg
/set-org-level project  # Re-detect parent
```

### Workflow 4: Branch-Based Path Testing

Test custom paths in feature branch:

```bash
# Main branch: Default paths with hierarchy
git checkout main
# Structure uses .claude/

# Create feature branch
git checkout -b test-custom-paths

# Configure custom paths (local only)
cd /company-root
/configure-paths --local --claude-dir=.test

# Migrate to test
/configure-paths --migrate .claude .test
# Now uses .test/ locally

# Initialize child with custom paths
cd /company-root/product-a
/configure-paths --migrate .claude .test
# Detects parent: /company-root/.test

# Test workflows
/add-role-guides software-engineer-guide.md
/validate-setup

# If satisfied, merge to main
git checkout main
# Apply same configuration to main branch
```

---

## Edge Cases and Limitations

### Edge Case 1: Parent and Child Different Path Configs

**Scenario:** Parent uses `.claude`, child uses `.myorg`

```bash
# Parent (default paths)
cd /parent
ls -la
# .claude/role-guides/

# Child (custom paths)
cd /parent/child
export RCM_CLAUDE_DIR_NAME=".myorg"
/init-org-template

# Question: Does hierarchy detection work?
# Answer: YES, hierarchy detector checks both configured name and common names
```

**How It Works:**
1. Child's path config: `.myorg`
2. Hierarchy detector first checks: `../.myorg` (not found)
3. Falls back to checking: `../.claude` (found!)
4. Reads parent level from: `../.claude/organizational-level.json`
5. Records parent: `parent_claude_dir: "/parent/.claude"`
6. Creates child: `.myorg/` with different name than parent

**Limitation:** Mixed path names are supported but not recommended for clarity.

### Edge Case 2: Migrating Parent Without Migrating Children

**Scenario:** Rename parent directory but leave children with old names

```bash
# Before:
# /company/.claude/ (company)
# /company/product/.claude/ (product, child)

# Migrate company
cd /company
/configure-paths --migrate .claude .myorg
# Now: /company/.myorg/

# Child still references old parent path
cd /company/product
cat .claude/organizational-level.json
# {"parent_claude_dir": "/company/.claude"}  # Now invalid!
```

**Problem:** Child's parent reference is broken.

**Solution:**
```bash
# Option 1: Re-detect parent
cd /company/product
/set-org-level product
# Re-scans and finds: /company/.myorg
# Updates: parent_claude_dir

# Option 2: Migrate child too
/configure-paths --migrate .claude .myorg
# Updates parent reference automatically
```

**Best Practice:** Migrate parent and all children together (top-down order).

### Edge Case 3: Path Configuration Conflicts

**Scenario:** Local and global configs conflict

```bash
# Global config
/configure-paths --global --claude-dir=.global

# Local config
cd /project
/configure-paths --local --claude-dir=.local

# Which is used?
# Answer: Local takes precedence (higher priority)

# Hierarchy detection
cd /project/subdir
/init-org-template
# Uses: .local (from parent's local config)
# Scans for: .local directories (not .global)
# May not find global-level parent if it uses .global
```

**Problem:** Hierarchy detection may fail across config boundaries.

**Solution:**
- Use consistent path configuration throughout hierarchy
- Or explicitly specify parent: `/init-org-template --parent /path/.global`

### Edge Case 4: Circular Directory Names

**Scenario:** Custom directory name matches actual directory name

```bash
# Configure claude dir to match actual directory
/configure-paths --claude-dir=myproject

# Directory structure:
# /myproject/       ← actual directory name
#   .claude/        ← config directory (not myproject/)

# Question: Does path config create /myproject/myproject/?
# Answer: NO, path config only affects config directory names
```

**Clarification:**
- `claude_dir_name` configures the name of the **configuration directory**
- It doesn't affect parent directory names
- Default `.claude` can be renamed, not `/myproject`

### Edge Case 5: Role Guide Name Collisions

**Scenario:** Custom guide at child has same name as inherited guide

```bash
# Parent
/company/.myorg/guides/engineer-guide.md  (company-level)

# Child creates custom guide with same name
cd /company/product/.myorg
echo "Custom content" > guides/engineer-guide.md

# Question: Which guide is used?
# Answer: Child's local copy takes precedence

# But validation warns:
/validate-setup
# ⚠ Warning: Duplicate guide detected
#   Local: engineer-guide.md
#   Parent: engineer-guide.md
#   Recommendation: Rename child to avoid confusion
```

**Solution:** Rename child guide to differentiate: `engineer-product-specific-guide.md`

### Limitation 1: Hierarchy Depth

**Maximum Depth:** 4 levels (company → system → product → project)

**Why:** Practical organizational structures rarely exceed 4 levels.

**Workaround:** Not recommended to increase depth. Restructure organization if needed.

### Limitation 2: Multiple Parents

**Limitation:** Each organization has exactly one parent (or none).

**Not Supported:**
```
# Child with two parents (not supported)
project-a inherits from:
  - product-team
  - platform-team
```

**Workaround:**
- Choose primary parent for hierarchy
- Use shared documents for secondary relationships
- Or flatten structure to single parent

### Limitation 3: Cross-Hierarchy References

**Limitation:** Organizations in different hierarchies cannot directly reference each other.

```
Hierarchy A:
  /company-a/.myorg/

Hierarchy B:
  /company-b/.myorg/

# company-b cannot inherit from company-a
```

**Workaround:**
- Use shared documentation repository
- Symlinks (with caution)
- Copy shared guides to both hierarchies

---

## Migration Strategies

### Strategy 1: Gradual Migration

Migrate hierarchy to custom paths gradually, level by level:

**Week 1: Plan and Test**
- Document current hierarchy
- Choose new directory names
- Test in feature branch

**Week 2: Migrate Top Level**
- Migrate company level only
- Test parent detection from children
- Validate everything still works

**Week 3: Migrate Second Level**
- Migrate system/product levels
- Verify hierarchy detection
- Validate role guide inheritance

**Week 4: Migrate Bottom Level**
- Migrate all projects
- Full validation
- Merge to main

### Strategy 2: Big Bang Migration

Migrate entire hierarchy at once (requires downtime):

```bash
#!/bin/bash
# migrate-all.sh

# Configure paths globally
/configure-paths --global --claude-dir=.myorg --role-guides-dir=guides

# Find all organizational directories
dirs=$(find /company-root -name ".claude" -type d | sort)

# Migrate each directory
for dir in $dirs; do
  parent=$(dirname "$dir")
  cd "$parent"
  /configure-paths --migrate .claude .myorg
  /validate-setup --quick
done

# Final validation
cd /company-root
/validate-setup
```

### Strategy 3: Parallel Hierarchies

Run old and new hierarchies side-by-side during migration:

```bash
# Keep old structure
/company-root/.claude/         (company, old)
/company-root/product/.claude/ (product, old)

# Create new structure alongside
/company-root/.myorg/          (company, new)
/company-root/product/.myorg/  (product, new)

# Gradually switch teams to new structure
# Delete old once everyone migrated
```

---

## Performance Considerations

### Combined Overhead

**Path Configuration:**
- Configuration load: <10ms (first call)
- Cached resolution: <1ms (subsequent)

**Hierarchy Detection:**
- Parent scan: <50ms per directory level
- 5-level hierarchy: <100ms total

**Combined:**
- Total overhead: <200ms (within target)
- Cache effectiveness: 90%+ hit rate

### Optimization Tips

1. **Use Global Path Config:** Reduces per-directory config lookups
2. **Limit Hierarchy Depth:** Keep to 2-3 levels when possible
3. **Cache Results:** Plugin caches both path config and parent detection
4. **Avoid Deep Nesting:** Shallow hierarchies perform better

### Performance Testing

```bash
# Test path resolution speed
time bash scripts/path-config.sh get-claude-dir-name

# Test hierarchy detection speed
time bash scripts/hierarchy-detector.sh find-parents

# Test combined operations
time /init-org-template --dry-run
```

---

## Troubleshooting Combined Systems

### Issue: Parent Not Found After Path Migration

**Symptoms:**
```bash
/init-org-template
# No parent detected (but parent exists)
```

**Diagnosis:**
```bash
# Check parent directory name
ls -la /parent/
# Verify: .myorg/ exists

# Check path configuration
/show-paths
# Verify: claude_dir_name matches parent directory name

# Check parent has organizational-level.json
cat /parent/.myorg/organizational-level.json
```

**Solutions:**
1. Verify path config is loaded
2. Check parent directory name matches config
3. Re-run `/set-org-level` to re-detect

### Issue: Duplicate Guides After Migration

**Symptoms:**
```bash
/validate-setup
# Warning: Duplicate role guides detected across hierarchy
```

**Cause:** Migration didn't clean up inherited guides

**Solution:**
```bash
# Identify duplicates
/validate-setup --verbose | grep "Duplicate"

# Remove child copies (keep parent copy)
cd /child/.myorg/guides
rm <duplicate-guide>.md

# Re-validate
/validate-setup
```

### Issue: Mixed Path Names Breaking Inheritance

**Symptoms:**
```bash
# Parent uses .myorg, child uses .custom
# Guides not inherited correctly
```

**Solution:**
```bash
# Standardize on one directory name
# Migrate child to match parent
cd /child
/configure-paths --migrate .custom .myorg

# Or migrate parent to match child
cd /parent
/configure-paths --migrate .myorg .custom
```

### Issue: Validation Fails After Combined Setup

**Symptoms:**
```bash
/validate-setup
# Multiple errors related to paths and hierarchy
```

**Debug Steps:**
```bash
# 1. Check path configuration
/show-paths --verbose

# 2. Check hierarchy detection
bash scripts/hierarchy-detector.sh find-parents

# 3. Check organizational-level.json files
find . -name "organizational-level.json" -exec cat {} \;

# 4. Validate individual components
/validate-setup --quick  # Fast check
```

---

## Best Practices

### 1. Plan Before Implementing

- Document current structure
- Choose directory names carefully
- Test in branch before main
- Validate at each step

### 2. Use Consistent Path Configuration

- Configure globally for entire hierarchy
- Avoid mixing different directory names
- Document path choices

### 3. Migrate Top-Down

- Always migrate parent before children
- Validate each level before proceeding
- Keep backups during migration

### 4. Validate Frequently

```bash
# After every significant change
/validate-setup

# Before committing
/validate-setup --summary

# In CI/CD
/validate-setup --quick
```

### 5. Document Combined Setup

Create hierarchy documentation:
```markdown
# Organization Structure

## Directory Names
- Configuration: `.myorg`
- Role Guides: `guides`

## Hierarchy
- Company: /company-root/.myorg
  - Product A: /company-root/product-a/.myorg
    - Project X: /company-root/product-a/project-x/.myorg
  - Product B: /company-root/product-b/.myorg
```

### 6. Use Git Effectively

```bash
# Track configuration files
git add .myorg/paths.json
git add .myorg/organizational-level.json

# Ignore local customizations
echo ".myorg/role-references.local.json" >> .gitignore
```

### 7. Train Team Members

- Explain custom path choices
- Document hierarchy relationships
- Provide migration guides
- Share troubleshooting tips

### 8. Monitor Performance

```bash
# Test combined operations
time /init-org-template
time /add-role-guides <guides>

# Should be <200ms for most operations
```

### 9. Plan for Growth

- Leave room for new products
- Design extensible hierarchy
- Choose generic path names
- Document expansion strategy

### 10. Automate Where Possible

```bash
# Automated validation
#!/bin/bash
# validate-all-levels.sh
dirs=$(find /company-root -name ".myorg" -type d)
for dir in $dirs; do
  cd "$(dirname "$dir")"
  /validate-setup --quiet || echo "Failed: $dir"
done
```

---

## Real-World Examples

### Example 1: Enterprise Software Company

**Company:** Acme Software Inc.
**Size:** 500 engineers, 10 products, 50 projects
**Custom Paths:** `.acme-ai` and `role-definitions`

**Structure:**
```
/acme-software/
  └── .acme-ai/role-definitions/        (company: 5 guides)
      ├── /platform-services/
      │   └── .acme-ai/role-definitions/ (system: 8 guides)
      │       ├── /auth-service/
      │       │   └── .acme-ai/role-definitions/ (project: 12 guides)
      │       └── /api-gateway/
      │           └── .acme-ai/role-definitions/ (project: 12 guides)
      ├── /product-crm/
      │   └── .acme-ai/role-definitions/ (product: 6 guides)
      │       ├── /crm-backend/
      │       │   └── .acme-ai/role-definitions/ (project: 15 guides)
      │       └── /crm-frontend/
      │           └── .acme-ai/role-definitions/ (project: 10 guides)
      └── /product-analytics/
          └── .acme-ai/role-definitions/ (product: 6 guides)
              ├── /analytics-engine/
              │   └── .acme-ai/role-definitions/ (project: 15 guides)
              └── /analytics-ui/
                  └── .acme-ai/role-definitions/ (project: 10 guides)
```

**Benefits:**
- Branded directory name matches internal tools
- Clear hierarchy: company → (system/product) → project
- Role guides inherited efficiently: ~100 total guides, no duplication
- Consistent structure across all 50 projects

### Example 2: Startup Growth Journey

**Company:** FastGrowth Startup
**Initial Size:** 3 engineers
**Growth:** → 50 engineers over 2 years

**Evolution:**

**Phase 1: Single Project (Month 0)**
```
/fastgrowth/.fg/           (project, standalone)
```

**Phase 2: Add Company Level (Month 6, 10 engineers)**
```
/fastgrowth/.fg/           (company, upgraded from project)
  └── /mvp-app/.fg/        (project, original project moved)
```

**Phase 3: Add Products (Month 12, 25 engineers)**
```
/fastgrowth/.fg/                  (company)
  ├── /product-core/.fg/          (product)
  │   ├── /backend/.fg/           (project)
  │   └── /web-app/.fg/           (project)
  └── /product-mobile/.fg/        (product)
      ├── /ios-app/.fg/           (project)
      └── /android-app/.fg/       (project)
```

**Phase 4: Add Platform Team (Month 24, 50 engineers)**
```
/fastgrowth/.fg/                     (company)
  ├── /platform/.fg/                 (system)
  │   ├── /auth-service/.fg/         (project)
  │   └── /data-pipeline/.fg/        (project)
  ├── /product-core/.fg/             (product)
  │   ├── /backend/.fg/              (project)
  │   └── /web-app/.fg/              (project)
  └── /product-mobile/.fg/           (product)
      ├── /ios-app/.fg/              (project)
      └── /android-app/.fg/          (project)
```

**Key Decisions:**
- Early branding: `.fg` from start (avoided migration pain)
- Incremental hierarchy: Added levels as team grew
- Minimal disruption: Each reorganization ~2 hours
- Clear ownership: Each level has dedicated role guides

---

## See Also

- [Path Configuration Guide](PATH-CONFIGURATION.md) - Complete path customization guide
- [Hierarchical Organizations Guide](HIERARCHICAL-ORGANIZATIONS.md) - Complete hierarchy guide
- [Architecture Documentation](../CLAUDE.md) - Technical architecture details
- [Migration Guide](MIGRATION-TO-PATH-CONFIG.md) - Path configuration migration

---

**Version:** 1.7.0
**Features:** Path Configuration + Hierarchical Organizations (Integrated)
**Last Updated:** 2026-02-06
