# Init Org Template Command

Initialize your organizational framework from a template.

## Purpose

This command helps users who don't yet have a `.claude` directory structure to select and apply an appropriate organizational template. It's the starting point for setting up role-based context management.

## When to Use

- You don't have a `.claude` directory yet (either globally or in project)
- Your `.claude/role-guides/` directory is empty
- You want to switch to a different organizational template
- You're setting up the plugin for the first time
- You want to set up global default templates (use --global)
- You want to set up project-specific templates (use --project)

## Arguments

- `--global`: Initialize template in global config (~/.claude/)
- `--project`: Initialize template in project config (./.claude/)
- `--scope <auto|global|project>`: Explicitly specify scope (default: auto)

Note: If custom paths are configured via `paths.json` or environment variables, the template will be initialized in the customized directory (e.g., `.myorg` instead of `.claude`).

## Instructions for Claude

When this command is executed, you should invoke the **template-setup-assistant agent** to guide the user through template selection and setup.

**PRE-FLIGHT: Configure SessionStart Hook (First-Time Setup)**

**This check runs before anything else - only on first use of any plugin command:**

1. **Check if SessionStart hook is configured**:
   ```bash
   # Check for marker file indicating hook setup is complete
   if [ ! -f .claude/.role-context-manager-setup-complete ]; then
     # Hook not configured yet - this is first-time use
   fi
   ```

2. **If hook not configured** (marker file missing):
   - Inform user: "First-time setup: Configuring SessionStart hook..."
   - Run post-install script:
     ```bash
     bash ~/.claude/plugins/role-context-manager/scripts/post-install.sh
     ```
   - Check exit code:
     - If exit code 0: Continue with command
     - If exit code 1: Show error message and suggest running `/setup-plugin-hooks` manually
   - Display: "✓ SessionStart hook configured. Validation will run automatically on future sessions."

3. **If hook already configured** (marker file exists):
   - Skip this check silently and proceed to main command logic

**Implementation**:

1. **Parse scope arguments**:
   - Extract scope flags (--global, --project, --scope)
   - Determine scope value:
     - If `--global` present: scope = "global" (initialize in ~/.claude/)
     - If `--project` present: scope = "project" (initialize in ./.claude/)
     - If `--scope <value>` present: scope = value
     - Otherwise: scope = "auto" (project if in project context, else global)

2. **Invoke the agent with scope**:
   ```
   Use the Task tool with:
   - subagent_type: 'template-setup-assistant'
   - description: 'Initialize organizational template'
   - prompt: 'Help the user select and apply an appropriate organizational template to [scope] config. Analyze their current directory structure, present available templates, guide template selection, and apply the chosen template to the appropriate scope (global ~/.claude/ or project ./.claude/).'
   ```

3. **The agent will**:
   - Determine target directory based on scope (~/.claude/ or ./.claude/)
   - Check if target `.claude` directory already exists
   - Analyze the current directory to understand the context
   - Load available templates from the plugin's `templates/` directory
   - Present template options with descriptions and recommendations
   - Ask clarifying questions to determine the best fit
   - Get user approval before applying template
   - Copy template files to appropriate `.claude/` directory (global or project)
   - Set up initial configuration in appropriate scope
   - Record applied template in appropriate preferences file
   - Guide user to next steps (/set-role with appropriate scope)

4. **After agent completes**:
   - Summarize what was set up
   - Show available roles from the applied template
   - Suggest running `/set-role` to complete setup

## Example Usage

```bash
# Initialize template (auto-detects scope)
/init-org-template

# Initialize global template (applies to ~/.claude/)
/init-org-template --global

# Initialize project template (applies to ./.claude/)
/init-org-template --project

# Agent will present options like:
# "Based on your project structure, I recommend the Startup Organization template.
#  This is ideal for teams of 0-10 people focused on speed and iteration.
#
#  Would you like to:
#  1. Use Startup Organization template (Recommended)
#  2. Use Full Software Organization template
#  3. Learn more about templates
#
#  Which option?"

# After global template applied:
# "✓ Startup Organization template applied successfully to global config!
#  Location: ~/.claude/
#
#  This template will be used across all projects unless overridden.
#
#  Next steps:
#  1. Set your global role: /set-role founder-ceo --global
#  2. View your context: /show-role-context
#  3. Customize if needed: /update-role-docs --global
#
#  Available roles: founder-ceo, technical-cofounder, founding-engineer"

# After project template applied:
# "✓ Startup Organization template applied successfully to project!
#  Location: ./.claude/
#
#  Next steps:
#  1. Set your role: /set-role founder-ceo
#  2. View your context: /show-role-context
#  3. Customize if needed: /update-role-docs
#
#  Available roles: founder-ceo, technical-cofounder, founding-engineer"
```

## Error Handling

**If .claude already exists and is complete**:
- Agent will detect this and ask if user wants to switch templates or cancel
- Offer to back up existing setup before switching

**If plugin templates can't be found**:
- Agent will report the error
- Suggest checking plugin installation
- Provide manual setup instructions as fallback

**If user cancels during setup**:
- Don't create partial `.claude` structure
- Leave project in original state
- User can run command again when ready

## Path Customization During Initialization

Templates can include custom path configuration in their `paths.json` file. When applying a template:

**If template includes paths.json**:
- Agent asks if you want to use template's directory names
- You can accept template paths or use defaults
- Example: Template specifies `.myorg` instead of `.claude`

**If you've already configured custom paths**:
- Template is applied to your configured directories
- Template's paths.json is ignored in favor of existing configuration
- Example: Your `.custom` directory receives the template

**Customizing paths after initialization**:
```bash
# Initialize template first
/init-org-template

# Then customize paths if needed
/configure-paths --claude-dir=.myorg --role-guides-dir=guides
```

**Example with custom paths**:
```bash
# Configure custom paths first
/configure-paths --claude-dir=.myorg

# Initialize template (uses .myorg directory)
/init-org-template

# Output:
# ✓ Template applied to: .myorg/
# ✓ Using custom path configuration from paths.json
```

See [Path Configuration](../docs/PATH-CONFIGURATION.md) for complete details on customizing directory names.

## Using with Hierarchical Organizations (v1.7.0)

The plugin supports multi-level organizational structures with parent-child relationships. When initializing a template in a hierarchical organization, automatic parent detection and role guide inheritance activate.

### Organizational Levels

Four organizational levels are supported:

- **Company** (root): Executive roles (CTO, CPO, CISO, VPs)
- **System**: Management roles (Engineering Manager, Architect, Platform Engineer)
- **Product**: Coordination roles (Product Manager, QA Manager, Designers)
- **Project**: Implementation roles (Software Engineer, DevOps, QA Engineer, SRE)

### Valid Parent-Child Relationships

```
company → system, product, or project
system → product or project
product → project
project → (no children - leaf node)
```

### Automatic Parent Detection

When you run `/init-org-template` in a directory with a parent `.claude` (or custom configured) directory:

1. **Scans upward** for parent organizational directories
2. **Detects parent level** from `organizational-level.json`
3. **Shows parent context** during initialization
4. **Validates relationship** before allowing setup
5. **Records parent path** in child's `organizational-level.json`
6. **Filters role guides** - Only copies guides appropriate for child level

**Example with Auto-Detection:**

```bash
# Parent: Company level
cd /company-root
/init-org-template
# Agent presents: "No parent detected. Is this your root organization? (yes/no)"
# User confirms yes
# Creates: .claude/ at company level
/set-org-level company
/set-role cto

# Child: Product level
cd /company-root/product-a
/init-org-template
# Agent presents: "Parent organization detected:"
#   - Level: company
#   - Path: /company-root/.claude
#   - Recommended level for child: product
#
# "Would you like to initialize as a product (child of company)? (yes/no)"
# User confirms yes
# Creates: .claude/ at product level
# Records parent path in organizational-level.json
# Skips company-level role guides (inherited)
/set-org-level product
/set-role product-manager
```

### Role Guide Inheritance

Child organizations automatically inherit role guides from parent levels, avoiding duplication:

**Example Hierarchy:**
```
/company-root/.claude/role-guides/
  ├── cto-guide.md                    (company-level role)
  ├── cpo-guide.md                    (company-level role)
  └── vp-engineering-guide.md         (company-level role)

/company-root/product-a/.claude/role-guides/
  ├── product-manager-guide.md        (product-level role)
  └── qa-manager-guide.md             (product-level role)
  # cto, cpo, vp-engineering inherited from parent

/company-root/product-a/project-x/.claude/role-guides/
  ├── software-engineer-guide.md      (project-level role)
  ├── devops-engineer-guide.md        (project-level role)
  └── qa-engineer-guide.md            (project-level role)
  # product-manager, qa-manager inherited from parent
  # cto, cpo, vp-engineering inherited from grandparent
```

### Template Application with Hierarchy

When applying a template in a child organization:

1. **Detects parent** organizational level
2. **Filters template** to include only child-level guides
3. **Skips parent guides** with feedback
4. **Shows inheritance** information during setup

**Agent Output Example:**
```
Applying software-org template to product level...

Role Guides:
  ✓ Copied: product-manager-guide.md (product-level)
  ✓ Copied: qa-manager-guide.md (product-level)
  ✓ Copied: ux-designer-guide.md (product-level)
  Skipped: cto-guide.md (inherited from parent company level)
  Skipped: cpo-guide.md (inherited from parent company level)
  Skipped: vp-engineering-guide.md (inherited from parent company level)

Organizational Documents:
  ✓ Copied: product-overview.md
  ✓ Copied: roadmap.md
  ✓ Copied: release-notes.md

Template applied successfully!
Parent: /company-root/.claude (company level)
```

### Hierarchical Organizations with Custom Paths

Hierarchy detection and custom paths work together seamlessly:

```bash
# Configure custom paths globally
/configure-paths --global --claude-dir=.myorg --role-guides-dir=guides

# Initialize company level with custom paths
cd /company-root
/init-org-template
# Creates: .myorg/ and .myorg/guides/
/set-org-level company

# Initialize product level (child) with inherited custom paths
cd /company-root/product-a
/init-org-template
# Detects parent: /company-root/.myorg (company level)
# Creates: .myorg/ and .myorg/guides/
# Hierarchy detection works with custom directory names
/set-org-level product
```

**Result:** Hierarchical structure with consistent `.myorg` naming throughout.

### Mixed Path Hierarchies

Parent and child can use different directory names:

```bash
# Parent with default paths
cd /parent-org
/init-org-template
# Creates: .claude/

# Child with custom paths
cd /parent-org/child-project
/configure-paths --local --claude-dir=.custom
/init-org-template
# Detects parent at: ../.claude (different name)
# Creates: .custom/
# Hierarchy still works across different names
```

### Validation in Hierarchies

Use `/validate-setup` to check hierarchy integrity:

```bash
/validate-setup

# Validates:
# ✓ Organizational level is valid
# ✓ Parent organizational level detected
# ✓ Parent path exists: /parent/.claude
# ✓ Hierarchy relationship is valid (project child of product)
# ✓ Role guide inheritance working correctly
# ✓ No duplicate guides (proper inheritance)
```

### When to Use Hierarchical Organizations

**Use hierarchical organizations when:**
- You have multiple teams/projects within one company
- Different organizational levels have different roles
- You want to avoid duplicating role guides
- You need consistent standards across sub-organizations
- You want parent-level policies inherited by children

**Use single-level setup when:**
- You have a standalone project
- You don't need organizational hierarchy
- All team members work at same level
- You prefer simplicity over hierarchy features

### Troubleshooting Hierarchies

**Parent not detected:**
- Verify parent `.claude` (or custom name) directory exists
- Check `organizational-level.json` exists in parent
- Run `/show-paths` to verify path configuration

**Wrong level recommended:**
- Override with `/set-org-level <level>` after initialization
- Validation will check if level is valid for parent

**Duplicate role guides:**
- Verify `parent_claude_dir` in `organizational-level.json`
- Run `/validate-setup` to check inheritance
- Re-initialize child level if needed

**Hierarchy relationship invalid:**
- Check valid relationships: company → system/product/project, system → product/project, product → project
- Parent must be initialized before child
- Use `/set-org-level` to fix incorrect levels

See [Hierarchical Organizations Guide](../docs/HIERARCHICAL-ORGANIZATIONS.md) for complete documentation.

## Notes

- This command is designed to be safe and non-destructive
- Agent always gets user approval before making changes
- Existing customizations are preserved when possible
- Template can be changed later by running command again
- Path configuration can be customized before or after template initialization
