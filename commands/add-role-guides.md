# Add Role Guides Command

Add role guides to an existing organizational setup, either from templates or as custom placeholders.

## Command

```bash
/add-role-guides <guide1> [guide2] [CUSTOM:name] ...
```

## Arguments

- `guide-name` (required): One or more role guide filenames to add
- `CUSTOM:name` (optional): Create a custom role guide with the specified name

## What This Command Does

1. Validates you're in a role-context-manager setup (`.claude/` directory exists)
2. Determines your current organizational level
3. Filters guides based on parent-level inheritance
4. Copies selected guides from template system to your `.claude/role-guides/` directory
5. Generates placeholder markdown for custom guides
6. Reports what was added, skipped, or filtered

## Use Cases

### Add Template-Based Guides

Add role guides from the plugin's template system:

```bash
# Add single guide
/add-role-guides software-engineer-guide.md

# Add multiple guides
/add-role-guides qa-engineer-guide.md devops-engineer-guide.md

# Extension optional
/add-role-guides software-engineer
```

### Create Custom Guides

Create placeholder guides for roles not in the template system:

```bash
# Create custom guide
/add-role-guides CUSTOM:platform-sre

# Creates: .claude/role-guides/platform-sre-guide.md
# (with standard role guide structure to customize)
```

### Mix Template and Custom

Combine both approaches:

```bash
/add-role-guides software-engineer-guide.md CUSTOM:devops-lead CUSTOM:security-engineer
```

## Parent-Level Filtering

The command respects organizational hierarchy. If you're in a sub-level setup (e.g., a project under a product), it will automatically filter out guides that should be inherited from the parent level.

**Example:**

```
Parent (product level):
  .claude/role-guides/
    product-manager-guide.md
    qa-manager-guide.md

Current (project level):
  Running: /add-role-guides qa-manager-guide.md software-engineer-guide.md

  Result:
    ✓ Added: software-engineer-guide.md
    Skipped: qa-manager-guide.md (inherited from parent product level)
```

This prevents duplication and ensures role guides exist at the appropriate organizational level.

## Custom Guide Names

Custom guide names must follow kebab-case format:
- Start with lowercase letter
- Use lowercase letters, numbers, and hyphens only
- No spaces, underscores, or special characters
- No path traversal (`.` or `/`)

**Valid examples:**
- `platform-sre`
- `security-architect`
- `mobile-engineer`
- `data-scientist`

**Invalid examples:**
- `PlatformSRE` (not lowercase)
- `platform_sre` (underscore not allowed)
- `platform sre` (space not allowed)
- `../other-role` (path traversal)

## Custom Guide Placeholders

When you create a custom guide with `CUSTOM:name`, the command generates a structured markdown template with:

- Role overview section
- Deterministic behaviors (rules Claude must follow)
- Agentic opportunities (proactive suggestions Claude can make)
- Common workflows
- Document integration points

You should customize this placeholder to define how Claude should assist users in this role.

## Examples

### Example 1: Adding Guides for Team Growth

Your team is growing from 1 engineer to 3 engineers + 1 QA:

```bash
# Add guides for new team members
/add-role-guides qa-engineer-guide.md devops-engineer-guide.md

# Summary: Added 2 guides, created 0 custom placeholders, skipped 0
```

### Example 2: Specialized Role Creation

Your organization has a unique "Platform SRE" role:

```bash
# Create custom guide
/add-role-guides CUSTOM:platform-sre

# Output:
# ✓ Created custom guide: platform-sre-guide.md
#
# Role guides have been added. To use them:
#   1. Customize any placeholder content in new guides
#   2. Run /set-role <role-name> to activate a role
#   3. Run /load-role-context to load role context into session
```

Then edit `.claude/role-guides/platform-sre-guide.md` to customize the role definition.

### Example 3: Skipping Duplicates

```bash
# Try to add guide that already exists
/add-role-guides software-engineer-guide.md

# Output:
# Skipped: software-engineer-guide.md (already exists)
# Summary: Added 0 guides, created 0 custom placeholders, skipped 1
```

## After Adding Guides

Once guides are added:

1. **Customize placeholders**: Edit any `CUSTOM:*` guides to add role-specific rules and workflows
2. **Activate a role**: Use `/set-role <role-name>` to set your current role
3. **Load context**: Run `/load-role-context` to inject the role guide into your session

## Available Template Guides

To see which guides are available in the template system for your organizational level:

```bash
/list-roles
```

## Comparison to Initial Setup

This command is for **post-initialization** guide management. It differs from initial template setup:

| Feature | /init-org-template (Section 3.6) | /add-role-guides |
|---------|----------------------------------|------------------|
| When | During initial setup | After setup |
| Interaction | Interactive selection UI | Command-line arguments |
| Scope | Applies full template + selected guides | Adds individual guides only |
| Use case | First-time initialization | Incremental updates |

## Error Handling

### Guide Not Found

```bash
/add-role-guides nonexistent-guide.md

# Warning: Guide 'nonexistent-guide.md' not found in template system
#          Available guides can be listed with: /list-roles
# Summary: Added 0 guides, created 0 custom placeholders, skipped 1
```

### No .claude Directory

```bash
/add-role-guides software-engineer-guide.md

# Error: Not in a role-context-manager setup (.claude directory not found)
# Run /init-org-template first to initialize the organizational structure
```

### Invalid Custom Name

```bash
/add-role-guides CUSTOM:Platform_SRE

# Error: Custom guide name 'Platform_SRE' must be kebab-case (lowercase, hyphens only)
```

## Technical Details

### Implementation

The command:
1. Sources `scripts/role-manager.sh`
2. Calls `cmd_add_role_guides()` function
3. Reads `.claude/organizational-level.json` for current and parent levels
4. Uses `should_include_role_guide()` from `template-manager.sh` for filtering
5. Uses `generate_custom_role_guide_placeholder()` for custom guides

### File Structure

After running the command, your `.claude/role-guides/` directory will contain:

```
.claude/role-guides/
├── software-engineer-guide.md      # From template
├── qa-engineer-guide.md            # From template
└── platform-sre-guide.md           # Custom placeholder
```

## See Also

- `/set-role` - Set your active role
- `/show-role-context` - Display current role and referenced documents
- `/load-role-context` - Load role context into session
- `/list-roles` - List available role guides
- `/init-org-template` - Initial template setup with role selection
