# Templates Guide - Role Context Manager

This guide explains how to use, customize, and create organizational templates for the role-context-manager plugin.

## Table of Contents

- [What Are Templates?](#what-are-templates)
- [Bundled Templates](#bundled-templates)
- [Using Templates](#using-templates)
- [Template Structure](#template-structure)
- [Creating Custom Templates](#creating-custom-templates)
- [Template Versioning](#template-versioning)
- [Auto-Update System](#auto-update-system)
- [Template Sync & Merging](#template-sync--merging)

---

## What Are Templates?

Templates are pre-configured organizational frameworks that include:
- **Role guides** - Guidance for Claude Code to assist specific roles
- **Document guides** - Templates for generating organizational documents
- **Organizational documents** - Standards, policies, strategies, OKRs
- **Configuration** - Organizational level, role references, preferences

Templates help teams get started quickly with best practices and consistent structures.

### Why Use Templates?

**For new teams**:
- Start with proven organizational patterns
- Skip the setup complexity
- Get role guides and document templates immediately

**For established teams**:
- Maintain consistency across projects
- Share organizational standards automatically
- Keep documentation up-to-date via template sync

**For organizations**:
- Push standards updates to all teams
- Ensure compliance with organizational policies
- Evolve frameworks as the company grows

---

## Bundled Templates

The plugin includes two templates covering different organizational stages:

### Software Organization Template (`software-org`)

**Version**: 1.0.0
**Target Audience**: Established software companies with 50+ people, multiple teams, and formal processes

**When to use**:
- Company has 50+ employees
- Multiple systems, products, or business units
- Need for formal processes and governance
- SOC2, compliance, or enterprise customer requirements
- Management layers (Directors, VPs, executives)
- Established engineering practices

**What's included**:
- **6 role guides**: CTO/VP Engineering, CISO, Cloud Architect, CPO/VP Product, Director QA, Product Manager
- **3 document guides**: Architecture Decision Records, OKRs, Product Requirements Documents
- **14 organizational documents**:
  - `CLAUDE.md` - Claude Code guidance
  - `FRAMEWORK-SUMMARY.md` - Framework overview
  - `README.md` - Repository introduction
  - `agile-practices.md` - Agile methodology standards
  - `data-governance.md` - Data handling policies
  - `engineering-standards.md` - Code quality, style, conventions
  - `infrastructure-standards.md` - Infrastructure and deployment standards
  - `objectives-and-key-results.md` - Company OKRs
  - `product-vision.md` - Product strategy and vision
  - `quality-standards.md` - Testing and QA expectations
  - `roadmap.md` - Product and engineering roadmap
  - `roles-and-responsibilities.md` - Organizational structure
  - `security-policy.md` - Security requirements
  - `strategy.md` - Company strategy

**Organizational structure**: Hierarchical (company → system → product → project)

**Tone**: Formal, comprehensive, enterprise-grade

### Startup Organization Template (`startup-org`)

**Version**: 1.0.0
**Target Audience**: Pre-seed to seed stage startups (0-10 people), fast iteration focus

**When to use**:
- Pre-seed or seed stage (0-10 people)
- Founders still searching for product-market fit
- Team wears multiple hats
- Limited resources (time, money, people)
- Fundraising or preparing to fundraise
- Need speed and fast iteration over formal processes

**What's included**:
- **Role guides directory** - Ready for custom roles as needed
- **4 organizational documents**:
  - `CLAUDE.md` - Claude Code guidance for startups
  - `FRAMEWORK-SUMMARY.md` - Lean framework overview
  - `IMPLEMENTATION-STATUS.md` - Setup tracking
  - `README.md` - Startup-specific introduction
- **Organizational structure** (directories):
  - `strategic/` - Vision, OKRs, strategy, roadmap
  - `fundraising/` - Pitch deck, investor updates
  - `product/` - Feature specs, user research
  - `engineering/` - Standards, tech stack, setup
  - `operations/` - Security, handbook, metrics
  - `docs/templates/` - Reusable document templates

**Organizational structure**: Flat (no hierarchy, single company level)

**Tone**: Informal, conversational, scrappy, ~50% shorter than enterprise

**Graduation path**: Move to `software-org` template when you reach 50+ people, Series B+ funding, or need formal processes

---

## Using Templates

### First-Time Setup

If you don't have a `.claude` directory yet:

```bash
/init-org-template
```

The **template-setup-assistant agent** will:
1. Analyze your directory structure
2. Infer organization type (startup vs established)
3. Present template options with recommendations
4. Ask clarifying questions about your team
5. Show template preview (roles, documents included)
6. Apply selected template with user confirmation
7. Guide you to set your role

### Example Flow

```
You: /init-org-template

Agent: I'll help you initialize your organizational framework.

Analyzing your directory...
✓ Found package.json (Node.js project)
✓ Small codebase (~3k LOC)
✓ No existing organizational documents

Based on your project, I recommend:

📦 Startup Organization Template (Recommended)
   Target: Pre-seed to seed stage (0-10 people)
   Focus: Speed, iteration, product-market fit
   Includes: Lean documentation, fundraising support, multi-hat role guides
   Structure: Flat organization (no hierarchy)

Also available:

📦 Full Software Organization Template
   Target: Established companies (50+ people)
   Focus: Formal processes, governance, enterprise standards
   Includes: 6 role guides, comprehensive standards, multi-level OKRs
   Structure: Hierarchical (company/system/product/project)

Which template would you like to use?
1. Startup Organization (Recommended)
2. Full Software Organization
3. Tell me more about these templates

You: 1

Agent: Great! I'll set up the Startup Organization template.

This will create:
- .claude/role-guides/ directory (ready for your roles)
- .claude/preferences.json (configuration)
- Organizational structure (strategic/, product/, engineering/, etc.)
- 4 starter documents (CLAUDE.md, README.md, etc.)

Proceed with setup? (yes/no)

You: yes

Agent: ✓ Created .claude directory structure
✓ Copied startup organizational framework
✓ Set organizational level to "company"
✓ Recorded template: startup-org v1.0.0

Template applied successfully!

Next steps:
1. Set your role: /set-role founder-ceo
2. View your context: /show-role-context
3. Customize as needed

Available roles in this template:
- founder-ceo
- technical-cofounder-cto
- product-cofounder-cpo
- founding-engineer
- early-hire
- advisor

Would you like me to help you set your role now?
```

---

## Template Structure

### Directory Layout

Every template must have this structure:

```
template-name/
├── manifest.json              # Required: Template metadata
├── .claude/                   # Required: Claude Code configuration
│   ├── role-guides/           # Required: At least one role guide
│   │   └── *.md
│   ├── document-guides/       # Optional: Document generation guides
│   │   └── *.md
│   ├── organizational-level.json  # Optional: Default org level
│   └── role-references.json   # Optional: Role-to-document mappings
└── *.md                       # Optional: Organizational documents
```

### Manifest File (`manifest.json`)

Required fields:

```json
{
  "id": "template-id",
  "name": "Human-Readable Template Name",
  "version": "1.0.0",
  "description": "Brief description of the template",
  "org_levels": ["company", "system", "product", "project"],
  "target_audience": "Who should use this template",
  "roles": [
    "role-name-1",
    "role-name-2"
  ],
  "included_files": {
    ".claude/role-guides": "Description of role guides",
    ".claude/document-guides": "Description of document guides",
    "organizational_docs": [
      "list-of-org-documents.md"
    ]
  },
  "features": [
    "Feature 1",
    "Feature 2"
  ],
  "when_to_use": [
    "Condition 1",
    "Condition 2"
  ],
  "changelog": [
    {
      "version": "1.0.0",
      "date": "2026-01-05",
      "changes": ["Initial release"]
    }
  ]
}
```

Optional fields:
- `graduation_path`: Suggested template to move to when outgrowing this one
- `license`: License for template content
- `author`: Template creator
- `repository`: Source repository URL

### Role Guide Format

Role guides should follow this structure (see bundled templates for examples):

```markdown
# [Role Name] Guide

## Role Overview
[Brief description]

## Key Responsibilities
- Responsibility 1
- Responsibility 2

## Organizational Level
[company|system|product|project]

## Documents [Role] References
### Documents [Role] Reads Regularly
- Document 1
- Document 2

### Documents [Role] Creates/Updates
- Document 1
- Document 2

## Deterministic Behaviors (AI MUST)
1. [Behavior 1]
2. [Behavior 2]

## Agentic Opportunities (AI SHOULD)
1. [Opportunity 1]
2. [Opportunity 2]

## Common Workflows
### Workflow 1: [Name]
**Steps**:
1. Step 1
2. Step 2

## Example Scenarios
### Scenario 1: [Name]
**Context**: [situation]
**AI assistance**: [how AI helps]
```

---

## Creating Custom Templates

### Option 1: Extend Bundled Template

Start with a bundled template and customize:

1. Apply a bundled template: `/init-org-template`
2. Customize role guides, add documents, adjust standards
3. Package your `.claude` directory as a new template

### Option 2: Create from Scratch

1. **Create template directory structure**:
   ```bash
   mkdir -p my-template/.claude/role-guides
   mkdir -p my-template/.claude/document-guides
   ```

2. **Create manifest.json** (see structure above)

3. **Add role guides**: Create `.md` files in `.claude/role-guides/`

4. **Add document guides** (optional): Create guides in `.claude/document-guides/`

5. **Add organizational documents**: Place standard docs in root

6. **Test your template**:
   ```bash
   # Validate structure
   bash scripts/template-manager.sh validate my-template

   # Apply to test directory
   cd /path/to/test-project
   bash /path/to/plugin/scripts/template-manager.sh apply my-template
   ```

### Custom Template Best Practices

**Role guides**:
- Include at least 3-5 roles common to your industry
- Follow the standard role guide structure
- Adapt tone to organizational stage (formal vs informal)
- Include concrete examples and workflows

**Document guides**:
- Create guides for your most common document types
- Include prompts for gathering information
- Specify required sections and format
- Provide examples

**Organizational documents**:
- Include essential standards and policies
- Reference industry-specific best practices
- Keep documents concise and actionable
- Use consistent formatting

**Manifest**:
- Be specific about target audience
- List clear "when to use" conditions
- Include comprehensive feature list
- Document what's included

---

## Template Versioning

Templates use semantic versioning (`MAJOR.MINOR.PATCH`):

- **MAJOR**: Breaking changes, incompatible updates
- **MINOR**: New features, backward-compatible additions
- **PATCH**: Bug fixes, clarifications, minor updates

### Version Management

When you apply a template, version is tracked in `.claude/preferences.json`:

```json
{
  "applied_template": {
    "id": "software-org",
    "version": "1.0.0",
    "applied_date": "2026-01-05T14:30:22Z"
  }
}
```

This enables:
- **Update detection**: Compare your version with registry
- **Auto-update**: Optionally sync to latest version automatically
- **Rollback**: Restore from backups if needed

---

## Auto-Update System

### How Auto-Update Works

**If `auto_update_templates` is `true` (default)**:
1. Plugin periodically checks for template updates (daily)
2. Compares your `applied_template.version` with registry
3. If newer version available, triggers template-sync agent
4. User is notified and can approve changes
5. Updates are applied while preserving customizations

**If `auto_update_templates` is `false`:
- Updates only occur when you run `/sync-template` manually
- You control when to adopt template changes

### Configuring Auto-Update

**Enable/disable in `.claude/preferences.json`**:
```json
{
  "auto_update_templates": true  // or false
}
```

**When to disable**:
- You need strict control over template versions
- You're testing or developing custom changes
- Your setup is highly customized
- You prefer manual review before updates

### SessionStart Hook Integration

The SessionStart hook automatically checks for template updates when you start a session (if `auto_update_templates` is `true`):

**How it works:**
- **Silent check**: Compares your version with registry on every session start
- **Non-intrusive**: Only notifies if update available, never applies automatically
- **User control**: Never applies updates without your explicit approval
- **Opt-out**: Set `auto_update_templates` to `false` to disable automatic checks

**What you'll see:**
```
# If up-to-date
✓ Template up-to-date (software-org v1.0.0)

# If update available
ℹ Template update available (v1.0.0 → v1.1.0). Run /sync-template to update.

# If auto_update_templates is false
(no output - checks are skipped)
```

**Benefits:**
- Always aware of available updates without manual checking
- Updates are announced but never forced
- Organizational standards stay current across teams
- Zero disruption to your workflow

This ensures your organizational standards stay current without manual checking.

### What Gets Updated

**Safe updates (applied automatically)**:
- New role guides added
- New document guides added
- Bug fixes in existing guides
- New organizational documents you don't have

**Merges (intelligently combined)**:
- Updates to role guides you've customized
- Document reference changes where you have custom refs
- Standards updates where you modified standards

**Conflicts (require your decision)**:
- You and template both modified same section
- Incompatible changes
- Breaking changes in structure

### Customization Preservation

The sync agent preserves:
- **`.local.json` files**: User overrides always kept
- **Custom role guides**: Guides not in template
- **User customizations**: Detected modifications in template files
- **Document references**: Custom additions and removals

---

## Template Sync & Merging

### Manual Sync

Check for and apply updates:

```bash
/sync-template
```

Preview changes without applying:

```bash
/sync-template --preview
```

### Sync Process

1. **Version Check**: Compare your version with registry
2. **Difference Analysis**: Identify what changed in new version
3. **Categorization**: Safe updates, merges, conflicts, preserved items
4. **Backup Creation**: Automatic backup before any changes
5. **Intelligent Merge**: Apply updates, merge changes, handle conflicts
6. **Conflict Resolution**: Present conflicts to user for decisions
7. **Validation**: Run framework-validator to confirm success
8. **Report Generation**: Detailed migration report created

### Example Sync

```
You: /sync-template

Agent: Checking for template updates...

📦 Template update available: software-org v1.0.0 → v1.1.0

Changes in this update:
- 3 new role guides added (DevSecOps Engineer, Staff Engineer, Technical Writer)
- 2 role guides updated (Software Engineer, Product Manager)
- Updated engineering-standards.md (added test coverage requirements)
- New document guide for technical spikes

Your customizations will be preserved.
A backup will be created before applying changes.

Proceed with sync? (yes / preview / cancel)

You: yes

Agent: Creating backup...
✓ Backup created: .claude/.backups/20260105_143022

Applying updates...
✓ Added 3 new role guides
✓ Merged software-engineer-guide.md (your customizations preserved)
⚠ Conflict in product-manager-guide.md

Conflict: Deterministic Behaviors section
  Template added: "Review PRDs before engineering kickoff"
  You added: "Coordinate with design team weekly"

  These don't conflict - both can be applied.
  Keep both? (yes / keep mine / use template / manual)

You: yes

Agent: ✓ Merged product-manager-guide.md
✓ Updated engineering-standards.md
✓ Added technical-spike document guide
✓ Updated template version to v1.1.0

Template synced successfully!

Summary:
- 5 files updated
- 0 conflicts requiring manual resolution
- All user customizations preserved

Migration report: .claude/.sync-reports/20260105_143022.md
Backup location: .claude/.backups/20260105_143022

Would you like me to run validation? (recommended)
```

### Rollback

If sync causes issues, rollback to backup:

```bash
# List available backups
bash scripts/template-manager.sh list-backups

# Restore from backup
# (Copy backup files back to .claude/)
```

Or use the template-sync agent to handle rollback with proper conflict checking.

---

## FAQ

### Can I use both templates?

Templates are applied per-directory. You could have:
- Root directory: software-org template
- Specific project: startup-org template (override)

### How do I share a custom template?

1. Package your template directory (with manifest.json)
2. Share via git repository or file sharing
3. Recipients use `/init-org-template` pointing to your template path
4. Or submit to plugin marketplace (if public)

### What if I outgrow my template?

Use the `graduation_path` from template manifest, or:
1. Back up current setup
2. Run `/init-org-template` with new template
3. Or manually migrate customizations to new template structure

### Can I mix templates?

Not recommended. Templates are designed to be cohesive. However, you can:
- Cherry-pick role guides from different templates
- Use one template as base, add custom roles from another
- Create a custom template combining elements

### How do I opt out of auto-updates?

Set in `.claude/preferences.json`:
```json
{
  "auto_update_templates": false
}
```

### What happens to my customizations during sync?

They're preserved! The sync agent:
- Detects your modifications
- Performs three-way merge (base, template, yours)
- Only asks about conflicts when both changed same section
- Never silently overwrites your work

---

## Next Steps

- **View bundled templates**: Browse `templates/` directory in plugin
- **Try template setup**: Run `/init-org-template`
- **Explore role guides**: Read `.claude/role-guides/` after applying template
- **Customize**: Add your organization's specific needs
- **Share**: Package and distribute your custom template to your team

For more information:
- [Main README](README.md)
- [Command Reference](README.md#commands-reference)
- [Agent Documentation](agents/)
- [GitHub Issues](https://github.com/WAdamBrooksFS/role-context-manager-marketplace/issues)
