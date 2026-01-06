# Create Role Guide Command

Create new role guides following established patterns and organizational conventions.

## Purpose

This command helps users create custom role guides when their organization needs roles not included in standard templates. It analyzes existing role guides to learn patterns and generates comprehensive, contextually appropriate role guides.

## When to Use

- You need a custom role not included in your template
- Your organization has specialized roles unique to your domain
- You want to extend the framework with company-specific roles
- You're adding a new role to your team structure

## Usage

```bash
# Interactive mode - agent will ask questions
/create-role-guide

# Specify role name
/create-role-guide data-engineer

# For startup multi-hat roles
/create-role-guide founding-designer
```

## Instructions for Claude

When this command is executed, invoke the **role-guide-generator agent** to create the role guide.

**Implementation**:

1. **Parse command arguments**:
   - Check if role name is specified (e.g., "data-engineer", "devops-engineer")
   - Extract any other parameters

2. **Invoke the agent**:
   ```
   Use the Task tool with:
   - subagent_type: 'role-guide-generator'
   - description: 'Create new role guide'
   - prompt: 'Create a role guide for [role-name]. Analyze existing role guides in .claude/role-guides/ to learn organizational patterns. Ask questions about role responsibilities, organizational level, and AI assistance needs. Generate a comprehensive role guide following established patterns. Integrate the new role into role-references.json.'
   ```

   If role name specified:
   - Add to prompt: 'User wants to create a guide for: [role-name]'

3. **The agent will**:
   - Analyze existing role guides for patterns
   - Identify naming conventions and structure
   - Determine organizational level for the role
   - Ask user about role responsibilities and context
   - Ask about deterministic behaviors (AI MUST do)
   - Ask about agentic opportunities (AI SHOULD suggest)
   - Identify document references for this role
   - Generate role guide following patterns
   - Add role to `role-references.json` with default documents
   - Adapt tone for organizational stage (startup vs enterprise)

4. **After agent completes**:
   - Show where role guide was created
   - Summarize what was included
   - Confirm role is now available for selection
   - Suggest next steps (review, customize, set role)

## Example Usage

### Interactive Mode

```bash
/create-role-guide

# Agent will ask:
# "What role are you creating a guide for?"
# > data-engineer
#
# "What organizational level is this role? (company/system/product/project)"
# > system
#
# "What are the primary responsibilities of this role?"
# > Design and maintain data pipelines, ensure data quality, ...
#
# "Who does this role collaborate with most often?"
# > Backend engineers, data scientists, product managers
#
# "What documents does this role regularly read?"
# > Data governance policy, engineering standards, architecture docs
#
# "What repetitive tasks could AI help automate for this role?"
# > Writing data pipeline tests, generating data models, ...
#
# Then generates:
# ✓ Created .claude/role-guides/data-engineer-guide.md
# ✓ Added data-engineer to role-references.json
#
# Role guide includes:
# - Role overview and purpose
# - Key responsibilities
# - Organizational level: System
# - Document references (data-governance.md, engineering-standards.md, etc.)
# - Deterministic behaviors for AI
# - Agentic opportunities for AI
# - Common workflows
# - Example scenarios
#
# The data-engineer role is now available!
# Set it with: /set-role data-engineer
```

### With Role Name Specified

```bash
/create-role-guide devops-engineer

# Agent will confirm:
# "Creating role guide for: devops-engineer"
#
# Then ask remaining questions:
# "What organizational level is this role?"
# "What are the primary responsibilities?"
# ...
```

## Role Guide Structure

The generated role guide will include:

### Standard Sections
- **Role Overview**: Brief description and purpose
- **Key Responsibilities**: Bulleted list of primary duties
- **Organizational Level**: Where role sits in hierarchy
- **Document References**:
  - Documents this role reads regularly
  - Documents this role creates/updates
  - Standards this role must follow
- **Deterministic Behaviors (AI MUST)**: Required AI behaviors
- **Agentic Opportunities (AI SHOULD)**: Proactive suggestions
- **Common Workflows**: Step-by-step workflow examples
- **Example Scenarios**: Realistic assistance scenarios
- **Integration with Other Roles**: Collaboration patterns
- **Tools and Technologies**: Role-specific tooling
- **Success Metrics for AI Assistance**: How to measure effectiveness

## Organizational Level Guidance

The agent understands role placement by level:

**Company Level** (Executive/Strategic):
- Examples: CTO, CISO, CPO, VP Engineering, Cloud Architect
- Focus: Strategy, organization-wide decisions, cross-team coordination

**System Level** (Coordination):
- Examples: Engineering Manager, Platform Engineer, Data Engineer, Security Engineer
- Focus: System architecture, multi-project coordination, infrastructure

**Product Level** (Product Management):
- Examples: Product Manager, QA Manager, UX Designer, Product Owner
- Focus: Product roadmap, feature prioritization, user experience

**Project Level** (Implementation):
- Examples: Software Engineer, DevOps Engineer, QA Engineer, Frontend Engineer
- Focus: Implementation, code, testing, deployment

**Startup Multi-Hat** (Flat Structure):
- Examples: Founder/CEO, Technical Co-founder, Founding Engineer
- Focus: Multiple responsibilities, speed, iteration
- Note: Agent will ask which "hats" this role wears

## Pattern Learning

The agent learns from existing guides:

**Structure patterns**:
- Section ordering and naming
- Heading styles
- Example formats

**Tone and style**:
- Formal vs informal language
- Level of detail
- Directive vs suggestive phrasing

**Content patterns**:
- How deterministic behaviors are phrased
- How agentic opportunities are described
- What workflows typically include

**Organizational specifics**:
- Custom terminology
- Company-specific processes
- Unique collaboration patterns

## Template Adaptation

**For Enterprise Organizations** (software-org template):
- More formal, structured tone
- Detailed process descriptions
- Emphasis on compliance and governance
- References to multiple standards and policies
- Complex collaboration patterns

**For Startups** (startup-org template):
- Informal, conversational tone
- Emphasis on speed and iteration
- Multi-hat acknowledgment
- Scrappy, practical suggestions
- ~50% shorter than enterprise guides
- Focus on essential behaviors only

## Document References

The agent automatically identifies which documents this role should reference:

**Based on responsibilities**:
- Engineers → engineering-standards.md, quality-standards.md
- Product roles → product-vision.md, roadmap.md
- Security roles → security-policy.md, compliance-docs
- Executives → strategy.md, objectives-and-key-results.md

**These become default documents** in `role-references.json` for users who set this role.

## Integration

After creation:
- Role guide saved to `.claude/role-guides/[role]-guide.md`
- Role added to `role-references.json` with document references
- Role available immediately for `/set-role` command
- Can be customized further by editing the file

## Error Handling

**If role guide already exists**:
- Agent will warn before overwriting
- Offer to create variant (e.g., "data-engineer-v2-guide.md") or cancel
- Suggest reviewing existing guide first

**If no existing role guides to learn from**:
- Agent will use standard structure
- Adapt based on template type (startup vs enterprise)
- Explain that guide follows standard format

**If role seems duplicate of existing**:
- Agent will show similar existing role
- Ask how new role differs
- Offer to extend existing vs create new

**If role level is ambiguous**:
- Agent will ask for clarification
- Explain typical responsibilities at each level
- Suggest most appropriate based on duties

## Notes

- Generated guides are starting points - customize as needed
- Agent creates comprehensive guides, not minimal stubs
- Deterministic behaviors ensure consistent AI assistance
- Agentic opportunities enable proactive help
- Role guides help both humans (onboarding) and AI (assistance)

## Best Practices

**When creating custom roles**:
1. Check if similar role already exists (may just need extension)
2. Be specific about responsibilities (helps agent generate better guidance)
3. Think about common workflows (helps define useful AI behaviors)
4. Consider what documents this role needs (improves context loading)
5. Review and refine generated guide for your organization

**For multi-hat roles** (startups):
- Clearly specify all hats this role wears
- Describe how to detect which hat they're wearing
- Include workflows for each hat
- Acknowledge resource constraints in guidance

## Integration with Other Commands

- `/set-role [new-role]` - Set yourself to the newly created role
- `/show-role-context` - See documents that will load for new role
- `/update-role-docs` - Customize document references for the role
- `/validate-setup` - Verify role guide has proper structure
