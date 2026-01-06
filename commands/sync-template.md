# Sync Template Command

Synchronize template updates while preserving user customizations.

## Purpose

This command helps users update their organizational templates to newer versions while intelligently preserving customizations, handling conflicts gracefully, and ensuring smooth migrations. It enables organizations to push standards updates to all users automatically.

## When to Use

- A newer version of your template is available
- Your organization published updated standards you want to adopt
- You want to get new role guides or document guides from template
- You've been notified of template updates (auto-update check)
- You want to manually control when to adopt template changes

## Usage

```bash
# Check for and apply available updates
/sync-template

# Force check even if recently checked
/sync-template --force

# Preview changes without applying
/sync-template --preview
```

## Auto-Update Behavior

**If `auto_update_templates` preference is `true` (default)**:
- Plugin automatically checks for template updates periodically
- When update is available, sync is triggered automatically
- User customizations are always preserved
- Non-conflicting updates are applied seamlessly
- Conflicts are presented to user for resolution
- User is notified when auto-sync completes

**If `auto_update_templates` preference is `false`**:
- Updates only occur when you run this command explicitly
- You control when to adopt template changes
- Template updates don't happen automatically

**To change auto-update setting**:
```json
// In .claude/preferences.json
{
  "auto_update_templates": false  // or true
}
```

## Instructions for Claude

When this command is executed, invoke the **template-sync agent** to handle the synchronization.

**Implementation**:

1. **Parse command arguments**:
   - Check for `--force` flag (force update check)
   - Check for `--preview` flag (show changes without applying)
   - Extract any other parameters

2. **Check if template is tracked**:
   ```javascript
   // Read applied_template from preferences.json
   if (!preferences.applied_template) {
     // No template applied, can't sync
     return "No template currently applied. Use /init-org-template to apply a template first."
   }
   ```

3. **Invoke the agent**:
   ```
   Use the Task tool with:
   - subagent_type: 'template-sync'
   - description: 'Sync template updates'
   - prompt: 'Check for template updates for the user's applied template. Compare current version with registry version. If updates available, analyze differences between current setup and new template version. Categorize changes (safe to apply, merge required, conflicts, user customizations to preserve). Create backup before applying changes. Perform intelligent merge, handle conflicts with user input. Apply updates while preserving customizations. Generate migration report. Update applied_template version in preferences.'
   ```

   If `--preview` flag present:
   - Add to prompt: 'Show what would change but don't apply any updates. Generate preview report only.'

   If `--force` flag present:
   - Add to prompt: 'Force check for updates even if recently checked.'

4. **The agent will**:
   - Read current template info from `applied_template`
   - Check registry for latest version
   - Compare versions (semantic versioning)
   - If no updates: Notify user and exit
   - If updates available:
     - Analyze differences (file-level and content-level)
     - Detect user customizations
     - Categorize changes by safety/conflict level
     - Create timestamped backup
     - For safe changes: Apply automatically
     - For merges: Perform intelligent three-way merge
     - For conflicts: Present options to user
     - Apply user-selected conflict resolutions
     - Update `applied_template.version` and `.applied_date`
     - Generate detailed migration report
     - Run validation to confirm success

5. **After agent completes**:
   - Show sync summary
   - Highlight what changed
   - Note preserved customizations
   - Show backup location
   - Provide link to full migration report
   - Suggest validation if needed

## Example Usage

### Standard Sync

```bash
/sync-template

# Agent checks for updates:
# "Checking for template updates..."
#
# If no updates:
# "✓ Your template is up to date (software-org v1.1.0)"
#
# If updates available:
# "📦 Template update available: v1.0.0 → v1.1.0
#
#  Changes in this update:
#  - 3 new role guides added
#  - 2 role guides updated (software-engineer, product-manager)
#  - Updated engineering-standards.md
#  - New document guide for technical spikes
#
#  Your customizations will be preserved.
#  A backup will be created before applying changes.
#
#  Proceed with sync? (yes / preview / cancel)"
#
# User: yes
#
# "Creating backup...
#  ✓ Backup created: .claude/.backups/20260105_143022
#
#  Applying updates...
#  ✓ Added 3 new role guides
#  ✓ Merged software-engineer-guide.md (your customizations preserved)
#  ⚠ Conflict in product-manager-guide.md
#
#  Conflict: Deterministic Behaviors section
#    Template added: 'Review PRDs before engineering kickoff'
#    You added: 'Coordinate with design team weekly'
#
#    These don't conflict - both can be applied.
#    Keep both? (yes / keep mine / use template / manual)"
#
# User: yes
#
# "✓ Merged product-manager-guide.md
#  ✓ Updated engineering-standards.md
#  ✓ Added technical-spike document guide
#  ✓ Updated template version to v1.1.0
#
#  Template synced successfully!
#
#  Summary:
#  - 5 files updated
#  - 0 conflicts requiring manual resolution
#  - All user customizations preserved
#
#  Migration report: .claude/.sync-reports/20260105_143022.md
#  Backup location: .claude/.backups/20260105_143022
#
#  Would you like me to run validation? (recommended)"
```

### Preview Mode

```bash
/sync-template --preview

# Agent shows what would change:
# "Preview: Template Update v1.0.0 → v1.1.0
#
#  Would add:
#  - .claude/role-guides/technical-writer-guide.md (new)
#  - .claude/role-guides/scrum-master-guide.md (new)
#  - .claude/role-guides/site-reliability-engineer-guide.md (new)
#  - .claude/document-guides/technical-spike-guide.md (new)
#
#  Would update (merge required):
#  - .claude/role-guides/software-engineer-guide.md
#    - Template adds: Test coverage requirement
#    - You modified: Added custom document reference
#    - Resolution: Both can be applied
#
#  - engineering-standards.md
#    - Template updated: Code review section
#    - You modified: Added team-specific linting rules
#    - Resolution: Three-way merge needed
#
#  Would preserve:
#  - .claude/role-references.local.json (your customizations)
#  - custom-role-guide.md (not in template)
#  - Your additions to various role guides
#
#  No breaking changes detected.
#
#  To apply: /sync-template
#  To cancel: This was preview only, nothing changed"
```

### No Updates Available

```bash
/sync-template

# "✓ Your template is up to date
#
#  Template: software-org v1.1.0
#  Last synced: 2026-01-03
#  Last checked: Just now
#
#  No updates available."
```

## Synchronization Process

### 1. Version Check
- Compare current version with registry
- Use semantic versioning (1.0.0 format)
- Determine if update is available

### 2. Difference Analysis
**File-level**:
- New files in template
- Removed files in template
- Modified files in template
- User-created files (not in template)

**Content-level**:
- Line-by-line diff for modified files
- Identify changed sections
- Detect overlapping changes (conflicts)

### 3. Change Categorization

**Safe to auto-apply** (no conflicts):
- New role guides not modified by user
- New document guides
- New organizational documents user doesn't have
- Bug fixes where user didn't customize

**Merge required** (can be automated):
- Template updated section A, user customized section B
- Additive changes (both adding different items)
- Non-overlapping modifications

**Conflict** (user decision needed):
- Template and user both modified same section
- Incompatible structural changes
- File user removed but template updated

**Preserve** (never overwrite):
- `.local.json` files (user overrides)
- Files not in template (user-created)
- Explicitly user-customized sections (when detected)

### 4. Backup Creation

Before any changes:
```
.claude/.backups/
└── 20260105_143022/
    ├── backup-manifest.json
    ├── role-guides/
    ├── document-guides/
    ├── preferences.json
    └── ... (complete .claude copy)
```

Backup includes:
- All files from `.claude/`
- Manifest with before/after versions
- Timestamp for restore reference

### 5. Intelligent Merge

**Three-way merge** for text files:
- Base: Original template version
- Theirs: New template version
- Ours: User's customized version
- Result: Combined with both changes

**Additive merge** for lists:
- Template adds items A, B
- User added items C, D
- Result: A, B, C, D

**User preference wins** by default:
- When ambiguous, preserve user changes
- Provide option to adopt template change
- Never silently overwrite customizations

### 6. Conflict Resolution

For each conflict:
1. Show both changes with context
2. Explain the conflict
3. Offer resolution options:
   - **Keep both** (if non-conflicting)
   - **Keep mine** (preserve user change)
   - **Use template** (adopt template change)
   - **Manual** (resolve later manually)
4. Apply user choice
5. Remember preference for similar conflicts

### 7. Update Tracking

After successful sync:
```json
// Updated in .claude/preferences.json
{
  "applied_template": {
    "id": "software-org",
    "version": "1.1.0",  // Updated
    "applied_date": "2026-01-05T14:30:22Z"  // Updated
  }
}
```

### 8. Validation & Report

- Run framework-validator to confirm success
- Generate detailed migration report
- Save report to `.claude/.sync-reports/[timestamp].md`
- Notify user of completion and report location

## Migration Report Contents

The report includes:

1. **Summary**: Versions, file counts, conflict counts
2. **Changes Applied**: New files, updated files, merged files
3. **Conflicts Resolved**: How each conflict was handled
4. **User Customizations Preserved**: What was kept
5. **Breaking Changes**: Any incompatible changes (rare)
6. **Next Steps**: What user should review or do
7. **Backup Location**: Where to find backup if needed
8. **What's New**: Changelog from template manifest
9. **Rollback Instructions**: How to restore from backup if needed

## Backup & Rollback

**Automatic backup retention**:
- Last 5 backups kept automatically
- Older backups cleaned up
- Important backups can be manually preserved

**To rollback**:
```bash
# List available backups
ls -1 .claude/.backups/

# Restore specific backup
/sync-template --rollback 20260105_143022
```

(Rollback handled by template-sync agent with confirmation)

## Error Handling

**If no template is applied**:
- Can't sync without applied template
- Suggest using `/init-org-template` first

**If backup creation fails**:
- STOP immediately - don't proceed
- Explain error
- Don't make any changes without backup

**If merge fails**:
- Restore from backup automatically
- Explain what went wrong
- Provide diff output for manual merge
- Suggest specific resolution steps

**If validation fails after sync**:
- Warn user of validation issues
- Offer to rollback
- Provide validation report
- Guide troubleshooting

**If auto-update fails**:
- Log error but don't block user's command
- Notify of available update
- Suggest manual sync later
- Provide error details for debugging

## Integration with Other Commands

**After sync**:
- `/validate-setup` - Verify sync was successful
- `/show-role-context` - Check updated document references
- `/update-role-docs` - Customize new role references if needed

**Related operations**:
- `/init-org-template` - Initial template application
- `/create-role-guide` - Add custom roles after sync
- `/generate-document` - Use new document guides

## Notes

- **Default behavior**: Automatically sync when updates available (if auto_update_templates is true)
- **Safe operation**: Always creates backup first
- **Intelligent**: Preserves customizations, handles conflicts gracefully
- **Transparent**: Detailed reports of what changed
- **Reversible**: Can rollback using backups
- **Non-blocking**: Auto-update failures don't prevent other operations

## Best Practices

**For users**:
- Review migration reports after sync
- Run validation after major updates
- Keep important backups manually
- Test functionality after sync
- Report issues to template maintainers

**For organizations**:
- Version templates with semantic versioning
- Document breaking changes clearly
- Test template updates before publishing
- Provide detailed changelogs
- Consider gradual rollouts for major changes
- Enable auto-update for teams (default: true)

**When to disable auto-update**:
- You need strict control over template versions
- You're testing or developing custom changes
- Your setup is highly customized
- You prefer manual review before updates
