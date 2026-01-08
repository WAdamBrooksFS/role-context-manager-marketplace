# Set Organizational Level Command

Set or override the organizational level for the current directory.

## Command

```bash
/set-org-level [level]
```

## Arguments

- No arguments: Show current level and available roles
- `company`: Set to company/root level
- `system`: Set to system level
- `product`: Set to product level
- `project`: Set to project level
- `--global`: Apply to global config (~/.claude/)
- `--project-scope`: Apply to project config (./.claude/)
- `--scope <auto|global|project>`: Explicitly specify scope (default: auto)

## What This Command Does

1. Sets the organizational level explicitly in `.claude/organizational-level.json`
2. Validates your current role is appropriate for the new level
3. Lists available roles at the specified level
4. Prompts to change role if current role is invalid for new level

## Usage Examples

```bash
# Show current level
/set-org-level

# Set to project level
/set-org-level project

# Set to company level
/set-org-level company

# Set to system level
/set-org-level system

# Set to product level
/set-org-level product
```

## When to Use This Command

**Show current level (no arguments)**:
- Check which organizational level is detected
- See available roles at current level

**Set level explicitly**:
- Directory structure doesn't match standard patterns
- Auto-detection is ambiguous or incorrect
- Working in incomplete or custom structure
- Want to override automatic detection

## Organizational Levels

### Company Level
**Typical roles**: CTO, CPO, CISO, VP Engineering, VP Product, Director QA, Cloud Architect

**Indicators**:
- At repository root
- Contains strategy.md, company OKRs
- Executive-level role guides

### System Level
**Typical roles**: Engineering Manager, Platform Engineer, Data Engineer, Security Engineer, Technical Product Manager, Technical Program Manager

**Indicators**:
- Contains multiple product directories
- System-level OKRs and architecture
- Management/platform role guides

### Product Level
**Typical roles**: QA Manager, UX Designer, UI Designer

**Indicators**:
- Contains multiple project directories
- Product documentation (roadmap, overview)
- Coordination role guides

### Project Level
**Typical roles**: Software Engineer, Frontend Engineer, Backend Engineer, DevOps Engineer, SRE, QA Engineer, SDET, Data Scientist

**Indicators**:
- Has build files (package.json, pom.xml, etc.)
- Source code directories (src/, lib/)
- Implementation role guides

## Instructions for Claude

When this command is executed:

1. Parse arguments:
   - Level argument (company, system, product, project)
   - Scope flags (--global, --project-scope, --scope)

2. Determine scope value:
   - If `--global` present: scope = "global"
   - If `--project-scope` present: scope = "project"
   - If `--scope <value>` present: scope = value
   - Otherwise: scope = "auto" (default)

2. **Check if .claude directory exists**:
   ```bash
   if [ ! -d .claude ]; then
     # No .claude directory - first time setup
   fi
   ```

3. **If .claude doesn't exist** (first-time setup):
   - Inform user: "You don't have a .claude directory yet."
   - Suggest: "Would you like to initialize your organizational framework?"
   - Based on the level they're trying to set, recommend appropriate template:
     - **company or system level** → Suggest software-org template (established company)
     - **project level** → Ask company size:
       - Small (0-10 people) → Suggest startup-org template
       - Larger (50+ people) → Suggest software-org template
   - If user agrees, invoke template-setup-assistant agent
   - After template setup, proceed with setting level

4. **If .claude exists**, call the level-detector.sh script with scope:
   ```bash
   # Show current level
   SCOPE=[scope] bash ~/.claude/plugins/role-context-manager/scripts/level-detector.sh

   # Set level explicitly with scope
   # Create or update appropriate organizational-level.json (global or project)
   ```

5. If no argument (show mode):
   - Detect or read current level
   - List available roles at this level from `.claude/role-guides/`
   - Show current role if set
   - Display whether current role is valid for this level

6. If level argument provided (set mode):
   - Validate level is one of: company, system, product, project
   - Create `.claude/organizational-level.json` with the level
   - Check if current role exists at new level
   - If current role invalid, prompt to use `/set-role`
   - List available roles at new level

7. After setting level, check role compatibility:
   - If role guide exists at new level: ✓ valid
   - If role guide missing at new level: prompt to change role

## Example Output

### Show Current Level (no arguments)

```
Current organizational level: project
Level source: Auto-detected

Available roles at this level:
  - software-engineer
  - frontend-engineer
  - backend-engineer
  - devops-engineer
  - qa-engineer
  - sdet
  - data-scientist

Current role: software-engineer ✓ (valid for this level)

Use /set-role [role-name] to change your role.
```

### Set Level

```
✓ Organizational level set to: system

Available roles at this level:
  - engineering-manager
  - platform-engineer
  - data-engineer
  - security-engineer
  - technical-product-manager

Current role: software-engineer ⚠️ (not available at this level)

Please set an appropriate role for this level:
  /set-role engineering-manager
```

### Set Level with Valid Role

```
✓ Organizational level set to: project

Available roles at this level:
  - software-engineer
  - frontend-engineer
  - backend-engineer
  - devops-engineer

Current role: software-engineer ✓ (valid for this level)

Use /show-role-context to see your document context.
```

## What Gets Updated

**`.claude/organizational-level.json`**:
```json
{
  "level": "project",
  "level_name": "my-project-name"
}
```

This file:
- Stores the explicit level setting
- Overrides auto-detection
- Is read first by level-detector.sh
- Should be committed to git for team consistency

## Auto-Detection vs Explicit Setting

**Auto-detection**:
- Uses heuristics to guess level
- Based on directory structure, files, role guides
- May be ambiguous in non-standard structures

**Explicit setting**:
- Always takes precedence
- Stored in organizational-level.json
- Reliable and consistent
- Recommended for non-standard structures

## Level Detection Heuristics

The plugin auto-detects level using:
1. Explicit marker in organizational-level.json (highest priority)
2. Heuristics scoring:
   - Build files (project level)
   - Source directories (project level)
   - Multiple project subdirs (product level)
   - Multiple product subdirs (system level)
   - Strategy docs (company level)
   - Role guide types
3. Prompt user if ambiguous
4. Default to project level if all else fails

## Related Commands

- `/set-role` - Set your role
- `/show-role-context` - View document context
- `/init-role-docs` - Initialize documents for role
