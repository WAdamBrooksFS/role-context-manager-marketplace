# /enhance-claude-md

Analyzes and enhances existing CLAUDE.md files with intelligent suggestions based on best practices and project context.

## Purpose

This command helps improve CLAUDE.md files that were preserved during template initialization. It:
- Analyzes existing CLAUDE.md content and structure
- Identifies missing or incomplete sections
- Generates context-aware enhancement suggestions
- Guides implementation of improvements
- Provides plan mode for reviewing suggestions before making changes

## Syntax

```bash
/enhance-claude-md [OPTIONS] [FILE]
```

## Flags

### `--list`
List all enhancement suggestions without implementing them.

**Output**: Summary of suggestions grouped by priority (high, medium, low) with descriptions and rationale.

**Use case**: Quick overview of what improvements are available.

**Example**:
```bash
/enhance-claude-md --list
```

### `--plan`
Generate a detailed enhancement plan without making changes.

**Output**: Comprehensive plan document with:
- Current state assessment
- Prioritized suggestions with examples
- Implementation sequence
- Effort estimates
- Success criteria

**Use case**: Review and understand all suggestions before committing to changes.

**Example**:
```bash
/enhance-claude-md --plan
```

### No flags (Interactive Mode)
Interactive enhancement session with the claude-md-enhancer agent.

**Behavior**:
1. Loads existing CLAUDE.md and suggestions
2. Presents prioritized improvements
3. Gathers project context from user
4. Drafts enhancements with examples
5. Shows previews before applying
6. Implements approved changes

**Use case**: Guided, step-by-step enhancement process.

**Example**:
```bash
/enhance-claude-md
```

### Specify File
Enhance a specific CLAUDE.md file (default: ./CLAUDE.md).

**Example**:
```bash
/enhance-claude-md ./docs/CLAUDE.md
/enhance-claude-md --list ./subproject/CLAUDE.md
```

## Usage Examples

### List Suggestions for Current Directory
```bash
/enhance-claude-md --list
```

**Output**:
```
Enhancement Suggestions for ./CLAUDE.md (47 lines):

HIGH PRIORITY (3 suggestions):
  1. Add Mission Statement
     Why: Helps AI understand project purpose and goals

  2. Add Capabilities Section
     Why: Enables AI to understand system architecture

  3. Add Development Guidelines
     Why: Ensures consistent code quality

MEDIUM PRIORITY (2 suggestions):
  4. Document Tools and Dependencies
     Why: Helps AI suggest compatible solutions

  5. Add Example Patterns
     Why: Provides concrete patterns to follow

Use /enhance-claude-md to implement these suggestions interactively.
Use /enhance-claude-md --plan for detailed implementation plan.
```

### Generate Detailed Plan
```bash
/enhance-claude-md --plan
```

**Output**: Full enhancement plan document (see Plan Mode section below).

### Interactive Enhancement
```bash
/enhance-claude-md
```

**Behavior**: Launches claude-md-enhancer agent for guided enhancement process.

### Enhance Specific File
```bash
/enhance-claude-md ./backend/CLAUDE.md
```

**Behavior**: Analyzes and enhances the specified file instead of ./CLAUDE.md.

## How It Works

### Step 1: Load Suggestions

The command looks for pre-generated suggestions in `.claude/claude-md-suggestions.json`, which are created automatically when:
- Template is applied with preserved CLAUDE.md files
- User runs `claude-md-analyzer.sh --suggest` manually

If no suggestions file exists, the command generates suggestions on-the-fly.

### Step 2: Adaptive Suggestions

Suggestions are tailored based on file size:

**Small files (<100 lines)**:
- 2-3 high-level suggestions
- Focus on critical missing sections
- Concise, actionable recommendations

**Large files (≥100 lines)**:
- 5-7 detailed suggestions with examples
- Comprehensive section-by-section analysis
- Specific implementation guidance

### Step 3: Present or Implement

Depending on the flag:
- **`--list`**: Show summary of suggestions
- **`--plan`**: Generate detailed plan document
- **No flag**: Launch interactive enhancement with agent

## Plan Mode

When invoked with `--plan`, generates a comprehensive enhancement plan:

```markdown
# CLAUDE.md Enhancement Plan

**File**: ./CLAUDE.md
**Current size**: 47 lines
**Analysis date**: 2026-02-02

## Current State Assessment

### What's Working Well
- Clear project description
- Basic setup instructions

### Gaps and Opportunities
- No mission statement or goals
- Missing capabilities documentation
- No development guidelines
- Tech stack not documented

## Recommended Enhancements

### High Priority (Implement First)

#### 1. Add Mission Statement
**Why**: Helps AI understand project purpose and align suggestions with goals

**What to include**:
- Project purpose and problem it solves
- Target users or use cases
- Key success criteria

**Example structure**:
[Example content here]

**Estimated effort**: 15-30 minutes

[... additional high priority items ...]

### Medium Priority
[... medium priority items ...]

### Low Priority
[... optional enhancements ...]

## Implementation Sequence

1. Week 1: High priority items (Mission, Capabilities)
2. Week 2: Medium priority items (Guidelines, Tools)
3. Week 3: Optional enhancements

## Success Criteria

After implementing this plan, your CLAUDE.md will:
✓ Clearly communicate project purpose
✓ Provide context for accurate suggestions
✓ Include coding standards
✓ Document technology stack
```

## Interactive Enhancement Workflow

When invoked without flags, launches the claude-md-enhancer agent:

1. **Assessment**: Analyzes current CLAUDE.md and loads suggestions
2. **Presentation**: Shows prioritized suggestions with rationale
3. **Selection**: User chooses which enhancements to implement
4. **Context Gathering**: Asks project-specific questions
5. **Drafting**: Creates enhancement content with examples
6. **Preview**: Shows proposed changes before applying
7. **Implementation**: Applies approved enhancements
8. **Iteration**: Continues with additional improvements if desired

## Prerequisites

### Suggestions File

For best results, ensure `.claude/claude-md-suggestions.json` exists. This is automatically created when:
- Applying a template to a project with existing CLAUDE.md
- Running template-setup-assistant after template application

To generate manually:
```bash
PLUGIN_DIR=~/.claude/plugins/role-context-manager
bash $PLUGIN_DIR/scripts/claude-md-analyzer.sh --suggest ./CLAUDE.md software-org
```

### Existing CLAUDE.md

The command requires an existing CLAUDE.md file to enhance. If none exists:
1. Create a basic CLAUDE.md with project description
2. Run this command to enhance it
3. Or apply a template which includes CLAUDE.md

## Integration with Template Workflow

This command is designed to work with the template preservation feature:

1. **User applies template** to project with existing CLAUDE.md
2. **Template-manager preserves** the existing file (doesn't overwrite)
3. **Suggestions are generated** automatically during template application
4. **User runs `/enhance-claude-md`** to review and apply improvements
5. **CLAUDE.md is enhanced** while preserving original content and style

## Agent Context

When invoked without flags, this command loads the `claude-md-enhancer` agent, which provides:
- Intelligent content analysis
- Context-aware suggestions
- Project-specific examples
- Step-by-step guidance
- Preview before changes
- Iterative enhancement workflow

## Output Locations

- **Suggestions**: `.claude/claude-md-suggestions.json`
- **Enhanced file**: Original CLAUDE.md location (in-place updates)
- **Backups**: None (changes made interactively with user approval)

## Best Practices

### Start with --list or --plan

Before making changes, review suggestions:
```bash
/enhance-claude-md --list    # Quick overview
/enhance-claude-md --plan    # Detailed plan
```

### Implement Incrementally

Don't try to implement all suggestions at once. Start with 1-2 high-priority items, verify they help, then continue.

### Provide Project Context

The interactive mode asks questions about your project. Detailed answers lead to better, more relevant enhancements.

### Review Changes

Always review proposed changes before approving. The agent shows previews specifically for this purpose.

### Keep It Current

As your project evolves, re-run this command periodically to identify new enhancement opportunities.

## Example Session

```bash
$ /enhance-claude-md

Loading suggestions for ./CLAUDE.md...

I've analyzed your CLAUDE.md file (47 lines) and found 5 enhancement opportunities:

HIGH PRIORITY (3 suggestions):
1. Add Mission Statement - Helps AI understand project goals
2. Add Capabilities Section - Documents what the system does
3. Add Development Guidelines - Ensures consistent code quality

Would you like to implement high-priority items? (yes/no): yes

Great! Let's start with the Mission Statement.

What is the main purpose of this project?
> [user provides answer]

What problem does it solve?
> [user provides answer]

[... interactive context gathering ...]

Based on your input, I've drafted the following Mission section:

=== PROPOSED ADDITION ===

## Mission

[drafted content based on user input]

=== END ADDITION ===

Does this accurately represent your project? (yes/no/revise): yes

Adding Mission section to CLAUDE.md...
✓ Mission section added

Would you like to continue with the next suggestion (Capabilities)? (yes/no): yes

[... continues with next enhancement ...]
```

## Related Commands

- `/load-role-context` - Load role-specific context into session
- `/set-role` - Switch to a different role guide
- `/sync-template` - Sync template updates while preserving CLAUDE.md

## Implementation Details

This command invokes the claude-md-enhancer agent with the appropriate parameters based on flags.

### Script Invocation

```bash
# Determine plugin directory
PLUGIN_DIR="${CLAUDE_PLUGIN_DIR:-$HOME/.claude/plugins/role-context-manager}"

# For --list flag
bash "$PLUGIN_DIR/scripts/claude-md-analyzer.sh" --suggest ./CLAUDE.md software-org | jq '.enhancements[] | "[\\(.priority)] \\(.section): \\(.description)"' -r

# For interactive mode
# Load claude-md-enhancer agent context and begin enhancement workflow
```

The agent handles the interactive enhancement process, while the analyzer script handles suggestion generation and listing.
