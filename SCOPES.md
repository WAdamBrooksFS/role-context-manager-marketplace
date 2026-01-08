# Configuration Scopes

## Overview

Starting with v1.3.0, role-context-manager supports **multi-scope configuration**, allowing you to maintain both global defaults and project-specific overrides. This document explains how configuration scopes work and when to use each.

## The Three Scopes

### 1. Global Scope (~/.claude/)

**Location**: `~/.claude/`

**Purpose**: Personal defaults that apply across all projects

**Use when**:
- You want consistent role and document settings everywhere
- You work on multiple projects with similar needs
- You want a baseline configuration that projects can override

**Contains**:
- `preferences.json` - Your default role and settings
- `role-guides/` - Available role definitions
- `role-references.json` - Default document references
- `role-references.local.json` - Your personal document customizations
- `settings.json` - Hook configuration

**Example**:
```bash
~/.claude/
├── preferences.json              # user_role: "software-engineer"
├── role-references.json          # Default docs for role
├── role-references.local.json    # Your customizations
├── settings.json                 # Global hooks
└── role-guides/
    ├── software-engineer-guide.md
    ├── qa-engineer-guide.md
    └── ... (other roles)
```

**Commands to use**:
```bash
/set-role software-engineer --global
/init-org-template --global
/update-role-docs +doc.md --global
/validate-setup --global
```

---

### 2. Project Scope (./.claude/)

**Location**: `./.claude/` (in project directory)

**Purpose**: Project-specific configuration that overrides global defaults

**Use when**:
- Your team has standardized roles and documents for a project
- You need different role or document settings per project
- You want to override your global defaults for this specific project

**Contains**:
- `preferences.json` - Project role and settings
- `role-guides/` - Project-specific or team-standard role definitions
- `role-references.json` - Team-standard document references
- `role-references.local.json` - Your personal overrides for this project
- `settings.json` - Project-specific hook configuration

**Example**:
```bash
./my-project/.claude/
├── preferences.json              # user_role: "qa-engineer"
├── role-references.json          # Team-standard docs
├── role-references.local.json    # Your project overrides
├── settings.json                 # Project hooks
└── role-guides/
    ├── qa-engineer-guide.md      # Project-specific role guide
    └── ... (other roles)
```

**Commands to use**:
```bash
/set-role qa-engineer --project
/init-org-template --project
/update-role-docs +test-plan.md --project
/validate-setup --project
```

---

### 3. Auto Scope (Default)

**Behavior**: Automatically chooses project or global based on context

**Logic**:
- If in directory with `.claude/`: Use **project** scope
- If outside any project: Use **global** scope

**Use when**:
- You want smart defaults without thinking about scope
- You're following natural workflow (project work uses project config, personal work uses global)
- You want convenience over explicit control

**Commands** (no flag = auto):
```bash
/set-role software-engineer       # Auto-detects scope
/init-org-template               # Auto-detects scope
/update-role-docs +doc.md        # Auto-detects scope
```

---

## Configuration Hierarchy

When multiple scopes exist, this is the **order of precedence**:

```
┌─────────────────────────────────────────────┐
│  1. Project Config (./.claude/)             │  ← Highest Priority
│     - Project-specific settings             │
│     - Team standards                        │
│     - Overrides global config               │
├─────────────────────────────────────────────┤
│  2. Global Config (~/.claude/)              │  ← Fallback
│     - Your personal defaults                │
│     - Applies when no project override      │
│     - Cross-project consistency             │
├─────────────────────────────────────────────┤
│  3. Plugin Defaults (bundled templates/)    │  ← Last Resort
│     - Built-in templates                    │
│     - Used during initial setup             │
└─────────────────────────────────────────────┘
```

### How Hierarchy Works

**Example Scenario**:

Global config:
- Role: `software-engineer`
- Docs: `/engineering-standards.md`, `/quality-standards.md`

Project config:
- Role: `qa-engineer`
- Docs: `+test-plan.md`, `-/quality-standards.md`

**Effective configuration** (what you actually get):
- Role: `qa-engineer` (from project, overrides global)
- Docs:
  - `/engineering-standards.md` (from global, not overridden)
  - `test-plan.md` (added in project)
  - ~/quality-standards.md removed in project~

---

## Common Scenarios

### Scenario 1: Individual Developer - Global Only

**Setup**:
```bash
# Configure global defaults
/init-org-template --global
/set-role software-engineer --global
```

**Workflow**:
- Global config works everywhere
- No project configs needed
- Consistent experience across all projects

**Best for**:
- Solo developers
- Personal projects
- Prototyping and experimentation

---

### Scenario 2: Team Project - Project Only

**Setup**:
```bash
cd /path/to/team-project

# Initialize team standards
/init-org-template --project
/set-role qa-engineer --project

# Commit to git for team
git add .claude/
git commit -m "Add team role configuration"
```

**Workflow**:
- Team members clone project
- Everyone uses same role guides and standards
- No global config needed

**Best for**:
- Team projects with strict standards
- Open source projects with contributor guidelines
- Projects with specific role definitions

---

### Scenario 3: Hybrid - Global + Project Overrides

**Setup**:
```bash
# Set up global defaults
/init-org-template --global
/set-role software-engineer --global

# Override for specific project
cd /path/to/special-project
/set-role devops-engineer --project
```

**Workflow**:
- Most projects use global defaults
- Special projects override as needed
- Best of both worlds

**Best for**:
- Developers working on multiple types of projects
- Teams with mostly standard but some special projects
- Flexible development environments

---

## Configuration Files

### preferences.json

**Purpose**: Stores current role and plugin settings

**Example** (global):
```json
{
  "user_role": "software-engineer",
  "auto_update_templates": true,
  "applied_template": {
    "id": "software-org",
    "version": "1.0.0",
    "applied_date": "2026-01-08T12:00:00Z"
  }
}
```

**Example** (project):
```json
{
  "user_role": "qa-engineer",
  "auto_update_templates": true,
  "applied_template": {
    "id": "software-org",
    "version": "1.0.0",
    "applied_date": "2026-01-08T12:00:00Z"
  }
}
```

---

### role-references.json

**Purpose**: Team defaults for document references

**Scope**:
- Global: Your personal defaults
- Project: Team-wide defaults (committed to git)

**Example**:
```json
{
  "software-engineer": {
    "documents": [
      "/engineering-standards.md",
      "/quality-standards.md",
      "contributing.md"
    ]
  }
}
```

---

### role-references.local.json

**Purpose**: Personal customizations (gitignored)

**Scope**:
- Global: Personal additions/removals across all projects
- Project: Personal additions/removals for this project only

**Example**:
```json
{
  "custom_additions": [
    "+docs/my-notes.md",
    "+personal-checklist.md"
  ],
  "custom_removals": [
    "-/quality-standards.md"
  ]
}
```

---

### settings.json

**Purpose**: Hook configuration for SessionStart

**Scope**:
- Global: Hooks run for all projects
- Project: Hooks run for this project only (overrides global)

**Example**:
```json
{
  "hooks": {
    "SessionStart": [
      "/validate-setup --quiet",
      "/sync-template --check-only"
    ]
  }
}
```

---

## Commands by Scope

### Set Role

```bash
# Auto (project if exists, else global)
/set-role software-engineer

# Explicitly global
/set-role software-engineer --global

# Explicitly project
/set-role software-engineer --project
```

### Initialize Template

```bash
# Auto
/init-org-template

# Global
/init-org-template --global

# Project
/init-org-template --project
```

### Update Role Docs

```bash
# Auto
/update-role-docs +new-doc.md

# Global
/update-role-docs +new-doc.md --global

# Project
/update-role-docs +new-doc.md --project
```

### Show Role Context

```bash
# Shows both global and project (if exists)
/show-role-context
```

Output example:
```
Configuration Hierarchy:

  Global config: ~/.claude/
    Role: software-engineer
    Docs: /engineering-standards.md, /quality-standards.md

  Project config: /home/user/my-project/.claude/
    Role: qa-engineer (overrides global)
    Docs: +test-plan.md

─────────────────────────────────────────────────────

Effective Configuration (in current directory):
  Role: qa-engineer
  Documents: /engineering-standards.md, test-plan.md
```

### Validate Setup

```bash
# Validate both scopes
/validate-setup

# Validate only global
/validate-setup --global

# Validate only project
/validate-setup --project
```

### Sync Template

```bash
# Sync both scopes
/sync-template

# Sync only global
/sync-template --global

# Sync only project
/sync-template --project
```

---

## Best Practices

### For Individual Developers

1. **Start with global config**
   ```bash
   /init-org-template --global
   /set-role your-role --global
   ```

2. **Add project overrides only when needed**
   ```bash
   cd special-project
   /set-role different-role --project
   ```

3. **Use auto mode** for convenience
   ```bash
   /set-role software-engineer  # Auto-detects scope
   ```

### For Teams

1. **Initialize project config**
   ```bash
   /init-org-template --project
   ```

2. **Commit team standards**
   ```bash
   git add .claude/preferences.json
   git add .claude/role-references.json
   git add .claude/role-guides/
   git commit -m "Add team role configuration"
   ```

3. **Gitignore personal overrides**
   ```bash
   # Already in .gitignore:
   .claude/role-references.local.json
   .claude/*.local.json
   ```

4. **Document project setup** in README
   ```markdown
   ## Setup
   After cloning, run:
   /setup-plugin-hooks --project
   /set-role [your-role] --project
   ```

### For Mixed Environments

1. **Global defaults for personal work**
   ```bash
   /set-role software-engineer --global
   ```

2. **Project overrides for team work**
   ```bash
   cd team-project
   /set-role qa-engineer --project
   ```

3. **Let auto mode handle it**
   - In team projects: Uses project config
   - In personal projects: Uses global config
   - Seamless transition

---

## Migration Guide

### From Project-Only (v1.2.0 and earlier)

**Before**: Plugin only worked in projects with `.claude/` directory

**After**: Plugin works globally and in projects

**Migration Steps**:

1. **Existing projects continue to work** - No changes needed
   ```bash
   cd existing-project
   # .claude/ already exists
   /show-role-context  # Still works
   ```

2. **Add global config** for new convenience (optional)
   ```bash
   /init-org-template --global
   /set-role your-role --global
   ```

3. **Now works outside projects too**
   ```bash
   cd ~/anywhere
   /show-role-context  # Uses global config
   ```

### From No Configuration

**Starting fresh with v1.3.0**:

1. **Choose your approach**:
   - Global-only: `/ init-org-template --global`
   - Project-only: `cd project && /init-org-template --project`
   - Hybrid: Do both

2. **Set your role**:
   ```bash
   /set-role your-role --global  # or --project
   ```

3. **Configure hooks** (optional):
   ```bash
   /setup-plugin-hooks --global  # or --project
   ```

---

## Troubleshooting

### "Which scope am I using?"

```bash
/show-role-context
```

Look for:
- "Global config: ..." (shows global scope)
- "Project config: ..." (shows project scope)
- "Effective Configuration" (shows what's actually used)

### "My changes aren't taking effect"

**Problem**: Set role globally but project config is overriding

**Solution**:
```bash
# See the hierarchy
/show-role-context

# Either: Update project scope
/set-role your-role --project

# Or: Remove project override
rm ./.claude/preferences.json
```

### "I want to reset to defaults"

**Reset global**:
```bash
rm -rf ~/.claude
/init-org-template --global
```

**Reset project**:
```bash
rm -rf ./.claude
/init-org-template --project
```

### "Hooks not running"

**Check which hooks are configured**:
```bash
# Global hooks
cat ~/.claude/settings.json | jq '.hooks.SessionStart'

# Project hooks
cat ./.claude/settings.json | jq '.hooks.SessionStart'
```

**Reconfigure**:
```bash
/setup-plugin-hooks --global  # or --project
```

---

## Scope Decision Flowchart

```
┌─────────────────────────────────────────────┐
│ Do you work on multiple projects?           │
└──────────────┬──────────────────────────────┘
               │
        ┌──────┴──────┐
        │             │
       Yes           No
        │             │
        v             v
┌─────────────┐  ┌─────────────┐
│ Do projects │  │ Use global  │
│ have team   │  │ scope only  │
│ standards?  │  │             │
└──────┬──────┘  └─────────────┘
       │
  ┌────┴────┐
  │         │
 Yes       No
  │         │
  v         v
┌──────┐  ┌──────────┐
│ Use  │  │ Use      │
│ both │  │ global   │
│ scopes│  │ scope    │
│      │  │ only     │
└──────┘  └──────────┘
```

---

## Related Documentation

- [Multi-Scope Hooks](docs/MULTI-SCOPE-HOOKS.md) - Hook behavior with scopes
- [Test Plan](docs/TEST-PLAN.md) - Comprehensive testing scenarios
- [Setup Plugin Hooks Command](commands/setup-plugin-hooks.md)
- [Validate Setup Command](commands/validate-setup.md)
- [Implementation Plan](../plans/mutable-gliding-castle.md)

---

## Quick Reference

| Scope | Location | Use For | Command Flag |
|-------|----------|---------|--------------|
| **Global** | ~/.claude/ | Personal defaults, all projects | `--global` |
| **Project** | ./.claude/ | Team standards, this project | `--project` |
| **Auto** | Context-aware | Convenience, smart defaults | (no flag) |

**Precedence**: Project > Global > Plugin Defaults

**Best Practice**: Global defaults + project overrides = flexibility
