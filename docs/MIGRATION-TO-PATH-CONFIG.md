# Migration Guide: Upgrading to Custom Path Configuration

Complete guide for migrating from Role Context Manager v1.6.0 to the new custom path configuration system.

## Table of Contents

- [Overview](#overview)
- [Should You Migrate?](#should-you-migrate)
- [Pre-Migration Checklist](#pre-migration-checklist)
- [Migration Steps](#migration-steps)
- [Migration Scenarios](#migration-scenarios)
- [Rollback Procedure](#rollback-procedure)
- [Troubleshooting](#troubleshooting)
- [Post-Migration Tasks](#post-migration-tasks)
- [FAQ](#faq)

---

## Overview

### What's Changing?

Starting with v1.7.0, Role Context Manager introduces **custom path configuration**, allowing you to customize the directory structure used for storing configuration and role guides.

**Before (v1.6.0 and earlier)**:
- Fixed directory names: `.claude` and `role-guides`
- No customization options
- Single naming scheme for all projects

**After (v1.7.0+)**:
- Customizable directory names via configuration
- Environment variable overrides
- Hierarchical configuration (global, local, environment)
- Migration tools for seamless transition

### What's New?

1. **Configurable Directory Names**: Choose `.myorg` instead of `.claude`
2. **Path Configuration Manifests**: Store preferences in `paths.json`
3. **Migration Command**: Automated migration with `/configure-paths --migrate`
4. **Multiple Configuration Levels**: Global, local, and environment-based
5. **Backward Compatible**: Existing setups continue working without changes

### Do I Need to Migrate?

**You can continue using the defaults** - no migration required if you're happy with `.claude` and `role-guides`.

**Consider migrating if you**:
- Need organization-specific directory naming (`.acme-ai` instead of `.claude`)
- Have conflicts with other tools using `.claude`
- Want to comply with internal naming standards
- Need different configurations per project
- Are consolidating multiple AI tool configurations

---

## Should You Migrate?

### Migration Decision Tree

```
Do you need custom directory names?
├─ No → Skip migration, keep using defaults
└─ Yes → Do you have existing .claude directories?
   ├─ No → Use /configure-paths to set up from scratch
   └─ Yes → Use /configure-paths --migrate to rename existing
```

### When to Migrate

**Migrate Now If**:
- Your organization requires specific directory naming conventions
- You're experiencing conflicts with other `.claude` tools
- You're starting a new project and want custom naming from the beginning
- You're consolidating configurations across multiple tools

**Delay Migration If**:
- You're in the middle of critical project work (wait for downtime)
- Your team hasn't been notified about the change
- You haven't tested the migration in a safe environment
- You don't have recent backups of your configuration

**Don't Migrate If**:
- You're happy with `.claude` and `role-guides` defaults
- You don't have specific naming requirements
- The change provides no benefit to your workflow

---

## Pre-Migration Checklist

Before starting migration, complete these steps:

### 1. Verify Current Version

```bash
# Check RCM version (should be v1.7.0 or later)
/validate-setup --version

# Verify migration commands are available
/configure-paths --help | grep -q migrate && echo "Migration available" || echo "Update required"
```

### 2. Backup Current Configuration

```bash
# Create backup directory
mkdir -p ~/rcm-backup-$(date +%Y%m%d)

# Backup .claude directories
find . -type d -name ".claude" -exec cp -r {} ~/rcm-backup-$(date +%Y%m%d)/ \;

# Backup global configuration
[ -d "$HOME/.claude" ] && cp -r "$HOME/.claude" ~/rcm-backup-$(date +%Y%m%d)/home-claude

# Verify backup
ls -la ~/rcm-backup-$(date +%Y%m%d)/
```

### 3. Document Current Setup

```bash
# Record current directory locations
find . -type d -name ".claude" > ~/rcm-migration-inventory.txt

# Check for customizations
find . -name ".claude" -type d -exec find {} -type f \; > ~/rcm-migration-files.txt

# Show current paths (if already using v1.7.0)
/show-paths --verbose > ~/rcm-current-paths.txt 2>&1 || echo "Old version, no paths command"
```

### 4. Review With Team

- [ ] Notify team members about upcoming changes
- [ ] Document new directory naming scheme
- [ ] Schedule migration during low-activity period
- [ ] Coordinate with anyone actively using RCM

### 5. Choose New Directory Names

**Planning Questions**:
- What will the new claude directory be called? (e.g., `.myorg-ai`)
- What will role guides directory be called? (e.g., `role-guides` or `guides`)
- Will this be global (all projects) or local (per-project)?

**Naming Rules**:
- Alphanumeric, dots, hyphens, underscores only
- Must match pattern: `^[a-zA-Z0-9._-]+$`
- No spaces, no path separators, no `..`
- 1-255 characters

**Examples**:
```bash
# Valid names
.myorg-rcm      ✅ Organization branded
.acme-ai        ✅ Company name
claude-config   ✅ Descriptive
.rcm            ✅ Abbreviated

# Invalid names
.my org         ❌ Contains space
../etc          ❌ Path traversal
/etc/config     ❌ Absolute path
```

### 6. Test Environment Preparation

```bash
# Create test directory
mkdir -p ~/rcm-migration-test
cd ~/rcm-migration-test

# Create test .claude directory
mkdir -p .claude/role-guides
echo '{"current_role":"test"}' > .claude/config.json

# Test dry-run migration
/configure-paths --dry-run --migrate .claude .test-new

# Clean up test
cd ~ && rm -rf ~/rcm-migration-test
```

---

## Migration Steps

### Step 1: Preview Migration (Dry Run)

Always start with a dry run to see what will change:

```bash
# Preview migration from .claude to .myorg-rcm
/configure-paths --dry-run --migrate .claude .myorg-rcm
```

**Expected Output**:
```
[DRY RUN] Migration Preview:

Searching for directories named '.claude'...
Found 3 directories to migrate:
  ./.claude -> ./.myorg-rcm
  ./project-a/.claude -> ./project-a/.myorg-rcm
  ./backend/.claude -> ./backend/.myorg-rcm

Manifest changes:
  Would create: ./.myorg-rcm/paths.json
  Would create: ./project-a/.myorg-rcm/paths.json
  Would create: ./backend/.myorg-rcm/paths.json

No changes made (dry run mode)
```

**Review the output carefully**:
- Verify all expected directories are found
- Check for unexpected directories
- Confirm target names are correct
- Note any warnings or conflicts

### Step 2: Execute Migration

Once dry run looks correct, execute the migration:

```bash
# Execute migration (interactive confirmation)
/configure-paths --migrate .claude .myorg-rcm
```

**Interactive Prompts**:
```
Searching for directories named '.claude'...
Found 3 directories to migrate:
  ./.claude -> ./.myorg-rcm
  ./project-a/.claude -> ./project-a/.myorg-rcm
  ./backend/.claude -> ./backend/.myorg-rcm

Proceed with migration? (y/n): y

Migrating directories...
✓ Renamed: ./.claude -> ./.myorg-rcm
✓ Renamed: ./project-a/.claude -> ./project-a/.myorg-rcm
✓ Renamed: ./backend/.claude -> ./backend/.myorg-rcm

Creating path configuration manifests...
✓ Created: ./.myorg-rcm/paths.json
✓ Created: ./project-a/.myorg-rcm/paths.json
✓ Created: ./backend/.myorg-rcm/paths.json

Migration complete!
```

**Migration Actions**:
1. Renames each `.claude` directory to `.myorg-rcm`
2. Preserves all contents (config, role guides, templates)
3. Creates `paths.json` manifest in each migrated directory
4. Updates configuration to use new names

### Step 3: Verify Migration

Confirm the migration was successful:

```bash
# Check new directory exists
ls -la .myorg-rcm/
ls -la .myorg-rcm/role-guides/

# Verify old directory is gone
ls -la .claude/ 2>&1 | grep -q "No such file" && echo "✓ Old directory removed" || echo "⚠ Old directory still exists"

# Show current path configuration
/show-paths --verbose

# Validate setup
/validate-setup
```

**Expected Results**:
```
Path Configuration:
  Claude directory: .myorg-rcm
  Role guides directory: role-guides
  Source: Local manifest (./.myorg-rcm/paths.json)

✓ Configuration file found: .myorg-rcm/config.json
✓ Role guides directory exists: .myorg-rcm/role-guides/
✓ Setup is valid
```

### Step 4: Test Core Functionality

Verify RCM commands work with new paths:

```bash
# Test role loading
/load-role-context --verbose

# Test role switching
/set-role engineer

# Test validation
/validate-setup

# Test template operations (if using templates)
/init-org-template --dry-run
```

### Step 5: Update Documentation

Document the change for your team:

```bash
# Create migration note
cat >> MIGRATION-NOTES.md << 'NOTES'
## RCM Path Migration - $(date +%Y-%m-%d)

Migrated Role Context Manager from .claude to .myorg-rcm

**Changes**:
- Directory: .claude → .myorg-rcm
- Configuration: Added .myorg-rcm/paths.json
- All role guides preserved

**Team Action Required**:
- Pull latest changes
- Run: /show-paths to verify configuration
- Run: /validate-setup to confirm setup

**Rollback**: See docs/MIGRATION-TO-PATH-CONFIG.md
NOTES

# Commit changes (if using version control)
git add .myorg-rcm/ MIGRATION-NOTES.md
git commit -m "Migrate to custom path configuration (.myorg-rcm)"
git push
```

---

## Migration Scenarios

### Scenario A: Simple Single-Project Migration

**Situation**: Single project with `.claude` directory, want to rename to `.myorg`.

**Steps**:
```bash
# 1. Dry run
/configure-paths --dry-run --migrate .claude .myorg

# 2. Execute
/configure-paths --migrate .claude .myorg

# 3. Verify
/show-paths && /validate-setup

# 4. Commit
git add .myorg/ && git commit -m "Migrate to .myorg"
```

**Time Required**: 2-5 minutes

---

### Scenario B: Multi-Project Migration

**Situation**: Multiple projects sharing a parent directory, all using `.claude`.

**Steps**:
```bash
# 1. Navigate to parent directory
cd ~/projects/

# 2. Preview all changes
/configure-paths --dry-run --migrate .claude .myorg-ai

# 3. Execute migration (will find all subdirectories)
/configure-paths --migrate .claude .myorg-ai

# 4. Verify each project
for dir in project-a project-b project-c; do
  echo "Checking $dir..."
  (cd $dir && /validate-setup)
done
```

**Time Required**: 5-10 minutes

---

### Scenario C: Global Configuration Migration

**Situation**: Using global `$HOME/.claude`, want organization-wide custom name.

**Steps**:
```bash
# 1. Migrate global configuration
cd ~
/configure-paths --migrate .claude .myorg-ai

# 2. Set as global default
/configure-paths --global --claude-dir=.myorg-ai

# 3. Verify in any project
cd ~/any-project
/show-paths --verbose
# Should show: Source: Global manifest ($HOME/.myorg-ai/paths.json)

# 4. Test commands
/validate-setup
```

**Time Required**: 3-5 minutes

---

### Scenario D: Selective Migration (Some Projects Only)

**Situation**: Want custom names in new projects, but keep `.claude` in legacy projects.

**Steps**:
```bash
# 1. Don't use global --migrate (would change everything)

# 2. In new project only
cd ~/projects/new-project
/configure-paths --local --claude-dir=.myorg-ai

# 3. Legacy projects keep using .claude
cd ~/projects/legacy-project
/show-paths
# Shows: Claude directory: .claude (default)
```

**Time Required**: 2 minutes per project

---

### Scenario E: Team Coordination Migration

**Situation**: Team project, need coordinated migration across all team members.

**Steps**:
```bash
# Team Lead:
# 1. Create migration branch
git checkout -b migrate-to-myorg

# 2. Execute migration
/configure-paths --migrate .claude .myorg

# 3. Commit and push
git add .myorg/ && git commit -m "Migrate to .myorg paths"
git push -u origin migrate-to-myorg

# 4. Create PR with instructions

# Team Members:
# 1. Pull migration branch
git fetch && git checkout migrate-to-myorg

# 2. Verify migration
/show-paths && /validate-setup

# 3. Test workflows
/load-role-context

# 4. Report any issues before merging
```

**Time Required**: 15-30 minutes (coordinated)

---

### Scenario F: Automated Migration Script

**Situation**: Enterprise environment with many projects, need automated migration.

**Script**:
```bash
#!/bin/bash
# migrate-all-projects.sh

OLD_NAME=".claude"
NEW_NAME=".acme-ai"
PROJECTS_ROOT="$HOME/projects"

# Find all projects with .claude
find "$PROJECTS_ROOT" -maxdepth 2 -type d -name "$OLD_NAME" | while read claude_dir; do
  project_dir=$(dirname "$claude_dir")
  echo "Processing: $project_dir"
  
  # Navigate to project
  cd "$project_dir"
  
  # Execute migration
  /configure-paths --migrate "$OLD_NAME" "$NEW_NAME"
  
  # Verify
  if /validate-setup &>/dev/null; then
    echo "✓ Migration successful: $project_dir"
  else
    echo "✗ Migration failed: $project_dir"
  fi
  
  echo "---"
done

echo "Migration complete. Review output above for any failures."
```

**Usage**:
```bash
# Review script first
cat migrate-all-projects.sh

# Execute
bash migrate-all-projects.sh

# Verify all projects
find ~/projects -type d -name ".acme-ai" | wc -l
```

**Time Required**: 20-60 minutes (depending on project count)

---

## Rollback Procedure

If migration causes issues, follow these steps to revert:

### Quick Rollback (Rename Back)

```bash
# 1. Rename directories back to .claude
mv .myorg-rcm .claude
mv project-a/.myorg-rcm project-a/.claude

# 2. Remove new path manifests
rm .claude/paths.json
rm project-a/.claude/paths.json

# 3. Clear environment variables (if set)
unset RCM_CLAUDE_DIR_NAME
unset RCM_ROLE_GUIDES_DIR

# 4. Clear cache
export RCM_CACHE_ENABLED="false"

# 5. Verify rollback
/show-paths && /validate-setup
```

### Complete Rollback (From Backup)

```bash
# 1. Remove new directories
rm -rf .myorg-rcm
rm -rf project-a/.myorg-rcm

# 2. Restore from backup
cp -r ~/rcm-backup-20260205/.claude ./
cp -r ~/rcm-backup-20260205/project-a/.claude project-a/

# 3. Clear configuration
unset RCM_CLAUDE_DIR_NAME
export RCM_CACHE_ENABLED="false"

# 4. Verify restoration
ls -la .claude/
/validate-setup
```

### Git Rollback (Version Controlled Projects)

```bash
# 1. Check git status
git status

# 2. Revert migration commit
git log --oneline | head -5  # Find migration commit
git revert <commit-hash>

# Or reset to before migration
git reset --hard HEAD~1

# 3. Clean untracked files
git clean -fd

# 4. Verify
/show-paths && /validate-setup
```

### Partial Rollback (Rollback One Project)

```bash
# Keep global/other projects migrated, rollback one project

cd problem-project

# 1. Rename back
mv .myorg-rcm .claude

# 2. Remove local manifest
rm .claude/paths.json

# 3. This project uses defaults, others use custom names
/show-paths  # Shows .claude (default)

cd ../other-project
/show-paths  # Shows .myorg-rcm (from global config)
```

---

## Troubleshooting

### Issue: Migration Can't Find Directories

**Symptom**:
```
Searching for directories named '.claude'...
No directories found matching '.claude'
```

**Causes**:
- Running from wrong directory
- Directories already renamed
- Looking for wrong name

**Solutions**:
```bash
# 1. Verify current directory
pwd

# 2. Search manually
find . -type d -name ".claude"

# 3. Check if already migrated
find . -type d -name ".myorg-rcm"

# 4. Run from parent directory if needed
cd .. && /configure-paths --migrate .claude .myorg-rcm
```

---

### Issue: Target Directory Already Exists

**Symptom**:
```
Error: Target directory already exists: ./.myorg-rcm
Cannot proceed with migration
```

**Causes**:
- Previous failed migration
- Name conflict with existing directory
- Duplicate run

**Solutions**:
```bash
# 1. Check if target is from previous migration
ls -la .myorg-rcm/

# 2. If empty or corrupt, remove and retry
rm -rf .myorg-rcm
/configure-paths --migrate .claude .myorg-rcm

# 3. If has data, backup and merge manually
mv .myorg-rcm .myorg-rcm.old
/configure-paths --migrate .claude .myorg-rcm
# Then merge any needed files from .myorg-rcm.old
```

---

### Issue: Commands Still Looking for Old Directory

**Symptom**:
```
Error: Configuration file not found: ./.claude/config.json
```

**Causes**:
- Environment variable override
- Cache not cleared
- Migration incomplete

**Solutions**:
```bash
# 1. Check environment variables
env | grep RCM_

# 2. Clear environment overrides
unset RCM_CLAUDE_DIR_NAME
unset RCM_ROLE_GUIDES_DIR

# 3. Disable cache
export RCM_CACHE_ENABLED="false"

# 4. Verify path configuration
/show-paths --verbose

# 5. Check manifest exists
cat ./.myorg-rcm/paths.json
```

---

### Issue: Git Conflicts After Migration

**Symptom**:
```
error: The following untracked working tree files would be overwritten by merge:
  .myorg-rcm/config.json
```

**Causes**:
- Team member merged changes before you migrated
- Different migration approaches

**Solutions**:
```bash
# 1. Stash local migration
git stash

# 2. Pull team's migration
git pull

# 3. Drop your stash (team's migration is authoritative)
git stash drop

# 4. Verify team's configuration
/show-paths && /validate-setup
```

---

### Issue: Permission Denied During Migration

**Symptom**:
```
mv: cannot move '.claude' to '.myorg-rcm': Permission denied
```

**Causes**:
- Insufficient permissions
- Files in use
- Filesystem restrictions

**Solutions**:
```bash
# 1. Check permissions
ls -la .claude/

# 2. Close any programs using the directory
lsof | grep .claude

# 3. Try with sudo (if appropriate)
sudo /configure-paths --migrate .claude .myorg-rcm

# 4. Or manually with sudo
sudo mv .claude .myorg-rcm
```

---

### Issue: Migration Partial Success

**Symptom**:
```
✓ Renamed: ./.claude -> ./.myorg-rcm
✗ Failed: ./project-a/.claude (permission denied)
✓ Renamed: ./backend/.claude -> ./backend/.myorg-rcm
```

**Causes**:
- Permission issues
- Files in use
- Filesystem problems

**Solutions**:
```bash
# 1. Fix failed project manually
cd project-a
sudo mv .claude .myorg-rcm
/configure-paths --local --claude-dir=.myorg-rcm

# 2. Or rerun migration for just that project
cd project-a
/configure-paths --migrate .claude .myorg-rcm

# 3. Verify all projects
/show-paths && /validate-setup
```

---

## Post-Migration Tasks

### 1. Update Team Documentation

```bash
# Update README
cat >> README.md << 'EOF'

## RCM Configuration

This project uses Role Context Manager with custom path configuration:
- Configuration directory: `.myorg-rcm`
- Path configuration: `.myorg-rcm/paths.json`

New team members: Run `/show-paths` to verify configuration.
