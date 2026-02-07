# Hierarchical Organizations Guide

Complete guide to using multi-level organizational structures with Role Context Manager.

**Version:** 1.7.0
**Feature:** Hierarchical Organizations with Path Configuration Integration

---

## Table of Contents

- [Overview](#overview)
- [Organizational Levels](#organizational-levels)
- [Parent-Child Relationships](#parent-child-relationships)
- [Role Guide Inheritance](#role-guide-inheritance)
- [Setting Up Hierarchies](#setting-up-hierarchies)
- [Automatic Parent Detection](#automatic-parent-detection)
- [Using with Custom Paths](#using-with-custom-paths)
- [Template Application in Hierarchies](#template-application-in-hierarchies)
- [Validation and Troubleshooting](#validation-and-troubleshooting)
- [Advanced Scenarios](#advanced-scenarios)
- [Best Practices](#best-practices)
- [Technical Reference](#technical-reference)
- [FAQ](#faq)

---

## Overview

Hierarchical Organizations enable multi-level organizational structures where child organizations inherit role guides and context from their parents. This prevents duplication, ensures consistency, and scales from small startups to large enterprises.

### What Are Hierarchical Organizations?

A hierarchical organization structure is a parent-child relationship between organizational levels:

```
Company (Root Level)
├── System A (Child of Company)
│   ├── Product A1 (Child of System A)
│   │   └── Project A1a (Child of Product A1)
│   └── Product A2 (Child of System A)
├── System B (Child of Company)
└── Product B (Child of Company)
    └── Project B1 (Child of Product B)
```

**Key Concepts:**
- **Parent Organization**: Higher-level organization that provides inherited context
- **Child Organization**: Lower-level organization that inherits from parent
- **Inheritance**: Child automatically gains access to parent's role guides
- **Filtering**: Templates only copy guides appropriate for child's level

### Why Use Hierarchical Organizations?

**Benefits:**

1. **Avoid Duplication**: Role guides exist once at appropriate level, inherited by children
2. **Consistency**: All sub-organizations use same parent-level standards
3. **Scalability**: Add new projects/products without copying company-wide guides
4. **Maintainability**: Update parent guides, all children benefit immediately
5. **Clear Structure**: Organizational relationships explicit and validated

**When to Use:**

- Multiple teams/projects within one company
- Need for company-wide standards inherited by all projects
- Product-level coordination across multiple project teams
- System-level management across multiple products
- Growing organization that will add more projects over time

**When Not to Use:**

- Single standalone project
- All team members work at same level
- No organizational hierarchy in your company
- Prefer simplicity over hierarchy features

---

## Organizational Levels

Role Context Manager supports four organizational levels, each with characteristic roles and responsibilities.

### Company Level

**Purpose:** Top-level organizational entity

**Typical Roles:**
- CTO (Chief Technology Officer)
- CPO (Chief Product Officer)
- CISO (Chief Information Security Officer)
- VP Engineering
- VP Product
- Director of Quality Assurance
- Cloud Architect

**Typical Documents:**
- Company strategy and vision
- Company-wide OKRs
- Engineering standards (company-wide)
- Security policy
- Architecture principles
- Hiring standards

**When to Use:**
- Repository root for entire company
- Highest-level organizational configuration
- Standards that apply to all sub-organizations

### System Level

**Purpose:** Major platform or cross-product initiative

**Typical Roles:**
- Engineering Manager
- Platform Engineer
- Data Engineer
- Security Engineer
- Technical Product Manager
- Technical Program Manager

**Typical Documents:**
- System architecture
- System OKRs
- Platform documentation
- Cross-product decisions
- Integration patterns

**When to Use:**
- Large platforms spanning multiple products
- Shared infrastructure/services
- Cross-product coordination
- Major technical initiatives

### Product Level

**Purpose:** Feature groups or product lines

**Typical Roles:**
- Product Manager
- QA Manager
- UX Designer
- UI Designer
- Technical Writer

**Typical Documents:**
- Product roadmap
- PRDs (Product Requirements Documents)
- Product overview
- Release notes
- User documentation
- Feature specifications

**When to Use:**
- Distinct product offerings
- Feature groups requiring coordination
- Product-specific quality standards
- Products with multiple implementation projects

### Project Level

**Purpose:** Individual codebases and implementations

**Typical Roles:**
- Software Engineer
- Frontend Engineer
- Backend Engineer
- Full Stack Engineer
- DevOps Engineer
- SRE (Site Reliability Engineer)
- QA Engineer
- SDET
- Data Scientist
- Data Analyst
- Mobile Engineer
- Scrum Master

**Typical Documents:**
- Contributing guide
- Development setup
- API documentation
- Technical design documents
- Operational runbooks
- Project README
- Testing strategy

**When to Use:**
- Individual repositories/codebases
- Implementation-level work
- Most projects (default level)
- Team-specific practices

---

## Parent-Child Relationships

### Valid Relationships

Not all parent-child combinations are valid. These rules ensure logical organizational structure:

**Company Can Parent:**
- System (large platforms under company)
- Product (products directly under company)
- Project (small company with direct projects)

**System Can Parent:**
- Product (products within a system/platform)
- Project (projects directly in system)

**Product Can Parent:**
- Project (implementation projects for product)

**Project Cannot Parent:**
- Nothing (project is always a leaf node)

### Relationship Diagram

```
Level         Can Parent These Levels
--------      ------------------------
company   →   system, product, project
system    →   product, project
product   →   project
project   →   (none - leaf node)
```

### Validation

The plugin automatically validates parent-child relationships:

**Valid Examples:**
```bash
company → system      ✓ Valid
company → product     ✓ Valid
company → project     ✓ Valid
system → product      ✓ Valid
system → project      ✓ Valid
product → project     ✓ Valid
```

**Invalid Examples:**
```bash
project → product     ✗ Invalid (project cannot parent)
product → system      ✗ Invalid (cannot go up hierarchy)
system → company      ✗ Invalid (cannot go up hierarchy)
product → company     ✗ Invalid (cannot go up hierarchy)
```

### Relationship Enforcement

When you initialize a child organization or set an organizational level, the plugin:

1. **Detects parent** level from parent's `organizational-level.json`
2. **Validates** proposed child level against parent level
3. **Rejects** invalid relationships with explanation
4. **Suggests** valid alternatives
5. **Records** valid relationship in child's `organizational-level.json`

**Example of Invalid Relationship:**
```bash
# Parent is product level
cd /parent-product
cat .claude/organizational-level.json
# {"level": "product"}

# Try to create system child (invalid)
cd /parent-product/child-dir
/set-org-level system

# Error:
# ✗ Invalid parent-child relationship
#   Parent level: product
#   Proposed child level: system
#
#   This relationship is not valid. Products cannot parent systems.
#
#   Valid child levels for product parent:
#     - project (implementation projects for this product)
#
#   Did you mean to use 'project' level instead?
```

---

## Role Guide Inheritance

Child organizations inherit role guides from parent levels, avoiding duplication and ensuring consistency.

### How Inheritance Works

When you're in a child organization:

1. **Child's role guides** are read from child's `.claude/role-guides/` (or custom path)
2. **Parent's role guides** are accessible from parent's directory
3. **Grandparent's role guides** (if any) accessible through parent
4. **All levels combined** provide complete set of available roles

**Example:**
```
/company/.claude/role-guides/
  ├── cto-guide.md              ← Company level
  ├── cpo-guide.md              ← Company level
  └── vp-engineering-guide.md   ← Company level

/company/product-a/.claude/role-guides/
  ├── product-manager-guide.md  ← Product level
  └── qa-manager-guide.md       ← Product level
  # cto, cpo, vp-engineering inherited from parent

/company/product-a/project-x/.claude/role-guides/
  ├── software-engineer-guide.md    ← Project level
  ├── devops-engineer-guide.md      ← Project level
  └── qa-engineer-guide.md          ← Project level
  # product-manager, qa-manager inherited from parent
  # cto, cpo, vp-engineering inherited from grandparent
```

### Role Level Classification

Roles are classified by organizational level:

**Company-Level Roles:**
- cto, cpo, ciso
- vp-engineering, vp-product
- director-qa, cloud-architect

**System-Level Roles:**
- engineering-manager, platform-engineer
- data-engineer, security-engineer
- technical-product-manager, technical-program-manager

**Product-Level Roles:**
- product-manager, qa-manager
- ux-designer, ui-designer
- technical-writer

**Project-Level Roles:**
- software-engineer, frontend-engineer, backend-engineer
- full-stack-engineer, devops-engineer
- sre, qa-engineer, sdet
- data-scientist, data-analyst
- mobile-engineer, scrum-master

### Inheritance During Template Application

When applying a template to a child organization:

**What Happens:**
1. Plugin detects parent organizational level
2. Template is filtered to include only child-level roles
3. Parent-level roles are skipped with explanation
4. Child gets only roles appropriate for its level
5. Inheritance provides access to parent roles

**Example Output:**
```bash
cd /company/product-a/project-x
/init-org-template

# Applying software-org template...
# Parent detected: /company/product-a/.claude (product level)
# Filtering template for project level...
#
# Role Guides:
#   ✓ Copied: software-engineer-guide.md (project-level)
#   ✓ Copied: devops-engineer-guide.md (project-level)
#   ✓ Copied: qa-engineer-guide.md (project-level)
#   ✓ Copied: frontend-engineer-guide.md (project-level)
#   Skipped: product-manager-guide.md (inherited from parent product level)
#   Skipped: qa-manager-guide.md (inherited from parent product level)
#   Skipped: cto-guide.md (inherited from ancestor company level)
#
# Available roles after setup:
#   Local (4): software-engineer, devops-engineer, qa-engineer, frontend-engineer
#   Inherited (5): product-manager, qa-manager, cto, cpo, vp-engineering
#   Total: 9 roles available
```

### Adding Guides with Inheritance

The `/add-role-guides` command respects inheritance:

```bash
# At product level
cd /company/product-a
/add-role-guides product-manager-guide.md qa-manager-guide.md cto-guide.md

# Output:
#   ✓ Added: product-manager-guide.md (product-level role)
#   ✓ Added: qa-manager-guide.md (product-level role)
#   Skipped: cto-guide.md (company-level role, inherited from parent)

# At project level (child of product)
cd /company/product-a/project-x
/add-role-guides qa-engineer-guide.md qa-manager-guide.md

# Output:
#   ✓ Added: qa-engineer-guide.md (project-level role)
#   Skipped: qa-manager-guide.md (product-level role, inherited from parent)
```

### Benefits of Inheritance

1. **No Duplication**: Company guide exists once, used everywhere
2. **Consistency**: All projects use exact same company standards
3. **Easy Updates**: Update company guide, all children benefit
4. **Disk Efficiency**: Saves space (no copies in every project)
5. **Clear Ownership**: Role guide lives at appropriate level

---

## Setting Up Hierarchies

### Step-by-Step: Creating a Hierarchy

**Example: Company → Product → Project**

#### Step 1: Initialize Company Level

```bash
cd /company-root

# Initialize template
/init-org-template

# Agent prompts: "Is this your root organization?"
# Choose: Yes

# Set level
/set-org-level company

# Add company-level role guides
/add-role-guides cto-guide.md cpo-guide.md vp-engineering-guide.md

# Set your role
/set-role cto
```

**Result:**
```
/company-root/
  └── .claude/
      ├── organizational-level.json  ({"level": "company"})
      ├── preferences.json
      └── role-guides/
          ├── cto-guide.md
          ├── cpo-guide.md
          └── vp-engineering-guide.md
```

#### Step 2: Initialize Product Level (Child of Company)

```bash
cd /company-root/product-a

# Initialize template
/init-org-template

# Agent detects parent and prompts:
#   "Parent organization detected:
#    - Level: company
#    - Path: /company-root/.claude
#    - Recommended level: product or project
#
#    Initialize as child of company? (yes/no)"
# Choose: Yes

# Agent prompts: "What level? (product/project)"
# Choose: product

# Add product-level guides
/add-role-guides product-manager-guide.md qa-manager-guide.md

# Set your role
/set-role product-manager
```

**Result:**
```
/company-root/product-a/
  └── .claude/
      ├── organizational-level.json
      │   {
      │     "level": "product",
      │     "parent_claude_dir": "/company-root/.claude",
      │     "parent_level": "company"
      │   }
      ├── preferences.json
      └── role-guides/
          ├── product-manager-guide.md
          ├── qa-manager-guide.md
          # cto, cpo, vp-engineering inherited from parent
```

#### Step 3: Initialize Project Level (Child of Product)

```bash
cd /company-root/product-a/project-x

# Initialize template
/init-org-template

# Agent detects parent chain:
#   "Parent organization detected:
#    - Level: product
#    - Path: /company-root/product-a/.claude
#    - Grandparent: company level
#    - Recommended level: project
#
#    Initialize as project (child of product)? (yes/no)"
# Choose: Yes

# Add project-level guides
/add-role-guides software-engineer-guide.md devops-engineer-guide.md

# Set your role
/set-role software-engineer
```

**Result:**
```
/company-root/product-a/project-x/
  └── .claude/
      ├── organizational-level.json
      │   {
      │     "level": "project",
      │     "parent_claude_dir": "/company-root/product-a/.claude",
      │     "parent_level": "product",
      │     "hierarchy_path": ["company", "product", "project"]
      │   }
      ├── preferences.json
      └── role-guides/
          ├── software-engineer-guide.md
          ├── devops-engineer-guide.md
          # product-manager, qa-manager inherited from parent
          # cto, cpo, vp-engineering inherited from grandparent
```

### Alternative Hierarchies

**Company → System → Product → Project:**
```
/company-root/.claude/           (company)
  └── /platform-team/.claude/    (system, child of company)
      └── /api-product/.claude/  (product, child of system)
          └── /rest-api/.claude/ (project, child of product)
```

**Company → Product → Project:**
```
/company-root/.claude/              (company)
  └── /mobile-app/.claude/          (product, child of company)
      └── /ios-app/.claude/         (project, child of product)
      └── /android-app/.claude/     (project, child of product)
```

**Company → Project (Small Company):**
```
/company-root/.claude/           (company)
  └── /project-a/.claude/        (project, child of company)
  └── /project-b/.claude/        (project, child of company)
```

---

## Automatic Parent Detection

The plugin automatically detects parent organizations by scanning the directory tree.

### How Parent Detection Works

1. **Start at current directory**
2. **Walk up directory tree** (parent, grandparent, etc.)
3. **Check each directory** for `.claude` (or custom configured name)
4. **Read `organizational-level.json`** to get parent's level
5. **Stop at first parent found** (nearest parent)
6. **Validate** current-to-parent relationship
7. **Record parent info** in child's `organizational-level.json`

### Parent Detection Algorithm

```
current_dir = /company/product-a/project-x

Check: /company/product-a/project-x/.claude → Not found (current location)
Check: /company/product-a/.claude → Found! (parent)
  Read: organizational-level.json → level: "product"
  Validate: project → product relationship → Valid
  Record: parent_claude_dir: "/company/product-a/.claude"
          parent_level: "product"

Continue scanning for grandparent:
Check: /company/.claude → Found! (grandparent)
  Read: organizational-level.json → level: "company"
  Build hierarchy_path: ["company", "product", "project"]
```

### Detection with Custom Paths

Parent detection works with custom directory names:

```bash
export RCM_CLAUDE_DIR_NAME=".myorg"

# Directory structure:
# /company/.myorg/           (company level, custom name)
# /company/product/.myorg/   (product level, custom name)

cd /company/product/project
/init-org-template

# Detection process:
# 1. Loads path config: claude_dir_name = ".myorg"
# 2. Scans for .myorg directories (not .claude)
# 3. Finds: /company/product/.myorg (product level)
# 4. Finds: /company/.myorg (company level)
# 5. Records parent in child's organizational-level.json
```

### Mixed Path Detection

Parent and child can use different directory names:

```bash
# Parent uses .claude (default)
# /parent/.claude/

# Child uses custom path
cd /parent/child
export RCM_CLAUDE_DIR_NAME=".custom"
/init-org-template

# Detection:
# 1. First checks for .custom in parents (not found)
# 2. Falls back to checking .claude in parents (found!)
# 3. Detects: /parent/.claude as parent
# 4. Creates: .custom/ as child
# 5. Records parent path: "/parent/.claude"
```

### Manual Parent Specification

Override auto-detection if needed:

```bash
# Explicit parent path
/init-org-template --parent /path/to/parent/.claude

# Force root (no parent)
/init-org-template --root
```

---

## Using with Custom Paths

Hierarchical organizations work seamlessly with custom path configuration.

### Hierarchy with Consistent Custom Paths

Use same custom paths throughout hierarchy:

```bash
# Configure globally
/configure-paths --global --claude-dir=.myorg --role-guides-dir=guides

# Company level
cd /company-root
/init-org-template
# Creates: .myorg/guides/

# Product level (inherits path config)
cd /company-root/product-a
/init-org-template
# Creates: .myorg/guides/
# Detects parent: /company-root/.myorg

# Project level (inherits path config)
cd /company-root/product-a/project-x
/init-org-template
# Creates: .myorg/guides/
# Detects parent: /company-root/product-a/.myorg
```

**Result:** Consistent `.myorg` naming, full hierarchy detection.

### Hierarchy with Mixed Paths

Parent and child can use different names:

```bash
# Parent with defaults
cd /parent-org
/init-org-template
# Creates: .claude/role-guides/

# Child with custom paths
cd /parent-org/child-project
/configure-paths --local --claude-dir=.custom --role-guides-dir=guides
/init-org-template
# Creates: .custom/guides/
# Detects parent: /parent-org/.claude (different name)
# Hierarchy still works!
```

### Migrating Hierarchical Setup

Migrate entire hierarchy to new directory names:

```bash
# Configure new paths globally
/configure-paths --global --claude-dir=.myorg

# Migrate parent (top to bottom order recommended)
cd /company-root
/configure-paths --migrate .claude .myorg
# Renames: .claude → .myorg
# Updates: internal references

# Migrate children
cd /company-root/product-a
/configure-paths --migrate .claude .myorg
# Renames: .claude → .myorg
# Updates: parent_claude_dir to use new parent name

cd /company-root/product-a/project-x
/configure-paths --migrate .claude .myorg
# Renames: .claude → .myorg
# Updates: parent_claude_dir, maintains hierarchy
```

**Result:** Entire hierarchy uses `.myorg`, all relationships preserved.

### Path Configuration in organizational-level.json

Parent path is stored as absolute path, resolved at runtime:

```json
{
  "level": "project",
  "parent_claude_dir": "/company/product/.myorg",
  "parent_level": "product"
}
```

**Path Resolution:**
- Parent path is absolute: `/company/product/.myorg`
- Plugin reads custom paths: `.myorg`
- Hierarchy detection: Scans for `.myorg` directories
- Inheritance: Reads guides from `/company/product/.myorg/guides/`

---

## Template Application in Hierarchies

Templates intelligently filter content based on organizational level and hierarchy.

### Template Filtering Logic

When applying template in child organization:

1. **Detect parent** level (company/system/product)
2. **Determine current** level (system/product/project)
3. **Load template** content (all guides, documents)
4. **Filter role guides** by level classification
5. **Copy only child-level** guides to child directory
6. **Skip parent-level** guides with feedback
7. **Record application** in preferences.json

### Example: Template at Project Level

```bash
cd /company/product-a/project-x

# Parent: product level
# Current: project level

/init-org-template
# Select: software-org template

# Filtering process:
# 1. Load software-org template (40 role guides)
# 2. Classify each guide by level:
#    - Company: cto, cpo, ciso, vp-* (6 guides)
#    - System: engineering-manager, platform-engineer, etc. (8 guides)
#    - Product: product-manager, qa-manager, designers (6 guides)
#    - Project: software-engineer, devops, qa-engineer, etc. (20 guides)
# 3. Current level: project
# 4. Copy only project-level guides (20)
# 5. Skip company, system, product guides (26 skipped)

# Output:
# Role Guides (Project Level):
#   ✓ Copied: software-engineer-guide.md
#   ✓ Copied: frontend-engineer-guide.md
#   ✓ Copied: backend-engineer-guide.md
#   ✓ Copied: devops-engineer-guide.md
#   ✓ Copied: qa-engineer-guide.md
#   ... (15 more project guides)
#
#   Skipped (Inherited):
#   - product-manager-guide.md (inherited from parent product level)
#   - qa-manager-guide.md (inherited from parent product level)
#   - cto-guide.md (inherited from ancestor company level)
#   ... (23 more skipped)
#
# Summary:
#   Local guides: 20
#   Inherited guides: 26
#   Total available: 46 roles
```

### Template at Each Level

**Company Level (Root):**
```bash
cd /company-root
/init-org-template
# Copies: ALL guides (company + system + product + project)
# No filtering (no parent)
# Result: Complete template
```

**System Level (Child of Company):**
```bash
cd /company/system-a
/init-org-template
# Copies: system + product + project guides
# Skips: company guides (inherited)
# Result: 3 levels of guides
```

**Product Level (Child of System or Company):**
```bash
cd /company/product-a
/init-org-template
# Copies: product + project guides
# Skips: company, system guides (inherited)
# Result: 2 levels of guides
```

**Project Level (Child of Any):**
```bash
cd /company/product-a/project-x
/init-org-template
# Copies: project guides only
# Skips: company, system, product guides (inherited)
# Result: 1 level of guides
```

### Template Syncing in Hierarchies

When syncing template updates:

```bash
# At company level
cd /company-root
/sync-template

# Updates:
#   - Company-level guides
#   - All descendants benefit from updates

# At product level
cd /company/product-a
/sync-template

# Updates:
#   - Product-level guides
#   - Project-level guides
#   - Skips company guides (managed at parent)
```

---

## Validation and Troubleshooting

### Validating Hierarchies

Use `/validate-setup` to check hierarchy integrity:

```bash
/validate-setup

# Hierarchy Checks:
# ✓ Organizational level is valid: project
# ✓ Parent detected: /company/product-a/.claude
# ✓ Parent level is valid: product
# ✓ Parent-child relationship valid (project child of product)
# ✓ Parent directory accessible
# ✓ Parent organizational-level.json valid
# ✓ Hierarchy path: company → product → project
# ✓ Role guide inheritance working correctly
# ✓ No duplicate guides detected
```

### Common Issues and Solutions

#### Issue: Parent Not Detected

**Symptoms:**
```bash
/init-org-template
# No parent detected despite parent directory existing
```

**Possible Causes:**
1. Parent directory not named `.claude` (or custom configured name)
2. Parent missing `organizational-level.json`
3. Path configuration mismatch
4. Parent directory not in ancestor path

**Solutions:**
```bash
# Check parent directory name
ls -la /parent/

# Verify parent has organizational-level.json
cat /parent/.claude/organizational-level.json

# Check path configuration
/show-paths

# Manually specify parent if needed
/init-org-template --parent /path/to/parent/.claude
```

#### Issue: Invalid Relationship Error

**Symptoms:**
```bash
/set-org-level system
# Error: Invalid parent-child relationship
#        Parent: product, Proposed child: system
```

**Cause:** Trying to create invalid relationship (product cannot parent system)

**Solution:**
```bash
# Use valid child level
/set-org-level project  # Valid: product → project

# Or remove parent reference if hierarchy not needed
# Edit organizational-level.json, remove parent_claude_dir
```

#### Issue: Duplicate Role Guides

**Symptoms:**
```bash
/validate-setup
# Warning: Duplicate role guide detected
#          Local: ./claude/role-guides/product-manager-guide.md
#          Parent: /parent/.claude/role-guides/product-manager-guide.md
```

**Cause:** Guide copied to child when it should be inherited

**Solution:**
```bash
# Remove duplicate from child
rm ./.claude/role-guides/product-manager-guide.md

# Or if intentionally customized, rename to differentiate
mv product-manager-guide.md product-manager-custom-guide.md
```

#### Issue: Cannot Access Parent Guides

**Symptoms:**
```bash
# Child setup looks correct but roles not available
/list-roles
# Shows only local guides, not inherited ones
```

**Possible Causes:**
1. Parent directory permissions
2. Incorrect parent path
3. Parent guides missing

**Solutions:**
```bash
# Check parent path
cat .claude/organizational-level.json | grep parent_claude_dir

# Verify parent directory readable
ls -la /parent/.claude/role-guides/

# Check permissions
stat /parent/.claude/role-guides/

# Fix permissions if needed
chmod -R a+r /parent/.claude/role-guides/
```

#### Issue: Hierarchy Path Incorrect

**Symptoms:**
```bash
/validate-setup
# Warning: Hierarchy path incomplete or incorrect
```

**Solution:**
```bash
# Re-detect and save hierarchy
cd /current-dir
bash scripts/hierarchy-detector.sh build-hierarchy

# Or re-initialize level to rebuild
/set-org-level project
```

### Troubleshooting Commands

**Check parent detection:**
```bash
bash scripts/hierarchy-detector.sh find-parents
# Shows all parent directories found
```

**Validate relationship:**
```bash
bash scripts/hierarchy-detector.sh is-valid-child product project
# Returns: 0 (valid) or 1 (invalid)
```

**Show hierarchy path:**
```bash
bash scripts/hierarchy-detector.sh build-hierarchy
# Outputs: ["company", "product", "project"]
```

**List available roles (with inheritance):**
```bash
bash scripts/role-manager.sh list-roles
# Shows local + inherited roles
```

---

## Advanced Scenarios

### Scenario 1: Multi-Product Company

```
/company-root/.claude/                (company)
├── /product-api/.claude/             (product)
│   ├── /api-v1/.claude/              (project)
│   └── /api-v2/.claude/              (project)
├── /product-mobile/.claude/          (product)
│   ├── /ios-app/.claude/             (project)
│   └── /android-app/.claude/         (project)
└── /product-web/.claude/             (product)
    └── /web-app/.claude/             (project)
```

**Benefits:**
- Company standards inherited by all products and projects
- Each product has product-manager, shared across product's projects
- Each project has its own implementation guides

### Scenario 2: Platform-Centric Organization

```
/company-root/.claude/                    (company)
└── /platform/.claude/                    (system)
    ├── /auth-service/.claude/            (project)
    ├── /api-gateway/.claude/             (project)
    └── /data-platform/.claude/           (product)
        ├── /data-ingestion/.claude/      (project)
        └── /data-analytics/.claude/      (project)
```

**Benefits:**
- Platform team (system level) manages shared services
- Data platform (product under system) has sub-projects
- Clear separation between platform and data products

### Scenario 3: Matrix Organization

```
/company-root/.claude/                        (company)
├── /platform-infrastructure/.claude/        (system)
│   ├── /kubernetes-platform/.claude/        (project)
│   └── /ci-cd-platform/.claude/             (project)
├── /product-customer-portal/.claude/        (product)
│   └── /portal-backend/.claude/             (project)
└── /product-admin-dashboard/.claude/        (product)
    └── /dashboard-frontend/.claude/         (project)
```

**Benefits:**
- Platform team manages infrastructure as system
- Product teams manage features as products
- All inherit company-wide standards

### Scenario 4: Startup Growth Path

**Phase 1: Single Project**
```
/startup/.claude/  (project, standalone)
```

**Phase 2: Add Product Level**
```
/startup/.claude/                (company, level changed)
└── /mvp/.claude/                (product)
    └── /api/.claude/            (project, moved)
```

**Phase 3: Multiple Products**
```
/startup/.claude/                (company)
├── /product-core/.claude/       (product)
│   ├── /api/.claude/            (project)
│   └── /web/.claude/            (project)
└── /product-mobile/.claude/     (product)
    ├── /ios/.claude/            (project)
    └── /android/.claude/        (project)
```

**Migration Steps:**
1. Start simple (single project)
2. Add hierarchy as you grow
3. Migrate guides upward as standards emerge
4. Reorganize levels as org evolves

---

## Best Practices

### 1. Start at the Top

Initialize parent organizations before children:
- Company first
- Then systems/products
- Finally projects

**Why:** Children validate against parent during initialization.

### 2. Use Appropriate Levels

Match organizational levels to your actual structure:
- Don't create unnecessary hierarchy
- Skip levels that don't apply (e.g., company → project for small teams)
- Be realistic about your organization's complexity

### 3. Keep Parent Guides Generic

Parent-level guides should apply to all children:
- Company guides: Universal standards
- Product guides: Product-wide practices
- Project guides: Implementation specifics

### 4. Let Children Specialize

Children can add specialized guides:
- Add custom guides specific to child's domain
- Don't duplicate parent guides
- Trust inheritance for parent roles

### 5. Validate Regularly

Check hierarchy health:
```bash
# After setup changes
/validate-setup

# After adding guides
/validate-setup --quick

# Before committing to git
/validate-setup --summary
```

### 6. Document Hierarchy

Keep organizational structure documented:
- README at company level explaining structure
- Diagram of hierarchy
- Clear level definitions

### 7. Plan for Growth

Design hierarchy with growth in mind:
- Leave room for new products
- Consider future sub-projects
- Plan system level if you'll need it

### 8. Migrate Carefully

When restructuring hierarchy:
1. Plan new structure
2. Test in branch
3. Migrate top-down
4. Validate at each step
5. Update documentation

### 9. Use Consistent Paths

If using custom paths, be consistent:
- Same directory names throughout hierarchy
- Configure globally for consistency
- Document path choices

### 10. Monitor Inheritance

Verify inheritance is working:
- Check available roles in children
- Ensure parent guides accessible
- No unnecessary duplication

---

## Technical Reference

### Configuration Files

**organizational-level.json Format:**
```json
{
  "level": "project",
  "level_name": "my-project",
  "parent_claude_dir": "/parent/product/.claude",
  "parent_level": "product",
  "hierarchy_path": ["company", "product", "project"],
  "created_at": "2026-02-06T10:30:00Z"
}
```

**Fields:**
- `level` (required): Current organizational level
- `level_name` (optional): Display name
- `parent_claude_dir` (optional): Absolute path to parent directory
- `parent_level` (optional): Parent's organizational level
- `hierarchy_path` (optional): Array from root to current level
- `created_at` (optional): Timestamp

### API Functions

**hierarchy-detector.sh Functions:**
```bash
# Find all parent directories
find_parent_claude_dirs

# Get immediate parent
get_nearest_parent

# Read level from directory
read_level_from_claude_dir <path>

# Validate relationship
is_valid_child_level <parent_level> <child_level>

# Build hierarchy array
build_hierarchy_path

# Save with hierarchy info
save_level_with_hierarchy <level> [options]
```

### Role Level Mappings

```bash
# Defined in template-manager.sh
COMPANY_ROLES=("cto" "cpo" "ciso" "vp-engineering" "vp-product" "director-qa" "cloud-architect")
SYSTEM_ROLES=("engineering-manager" "platform-engineer" "data-engineer" "security-engineer" "technical-product-manager" "technical-program-manager")
PRODUCT_ROLES=("product-manager" "qa-manager" "ux-designer" "ui-designer" "technical-writer")
PROJECT_ROLES=("software-engineer" "frontend-engineer" "backend-engineer" "full-stack-engineer" "devops-engineer" "sre" "qa-engineer" "sdet" "data-scientist" "data-analyst" "mobile-engineer" "scrum-master")
```

### Performance Metrics

- **Parent detection**: <50ms per directory level
- **Hierarchy validation**: <20ms per relationship
- **5-level hierarchy**: <100ms total detection time
- **Role guide filtering**: <10ms per template application
- **Combined overhead**: <200ms (within target)

---

## FAQ

**Q: Can a project have multiple parents?**

A: No. Each organization has one parent (or none if root). Linear hierarchy only.

**Q: Can siblings share guides?**

A: No direct sharing. Use common parent for shared guides.

**Q: Can I change an organization's level after initialization?**

A: Yes, use `/set-org-level <new-level>`, but validate relationship with parent first.

**Q: What if I move a child directory?**

A: Parent path is absolute, so moving breaks the link. Re-run `/set-org-level` to re-detect parent.

**Q: Can I have multiple company-level roots?**

A: Yes, each company-level organization is independent. No hierarchy between companies.

**Q: How deep can hierarchy go?**

A: Maximum 4 levels: company → system → product → project. Most use 2-3 levels.

**Q: Can I use hierarchy without custom paths?**

A: Yes. Hierarchy works with default `.claude` directory names.

**Q: Can I use custom paths without hierarchy?**

A: Yes. Path customization is independent of hierarchy.

**Q: What happens if parent is deleted?**

A: Child loses inheritance. Validation will show warning. Child can become standalone or get new parent.

**Q: Can I have a product under one parent and project under different parent?**

A: Not directly. But you can have `company → product → project` and separately `company → different-product → different-project`.

**Q: How do I remove hierarchy from a child?**

A: Edit `organizational-level.json`, remove `parent_claude_dir` and `parent_level` fields. Child becomes standalone.

**Q: Can parent and child use different templates?**

A: Yes. Each level can use different templates. Inheritance still works for role guides.

---

## See Also

- [Path Configuration Guide](PATH-CONFIGURATION.md)
- [Combined Features Guide](COMBINED-FEATURES.md)
- [Architecture Documentation](../CLAUDE.md)
- [Cheatsheet](../CHEATSHEET.md)

---

**Version:** 1.7.0
**Feature:** Hierarchical Organizations with Path Configuration Integration
**Last Updated:** 2026-02-06
