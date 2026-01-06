# Generate Document Command

Generate documents from templates using role context and organizational patterns.

## Purpose

This command helps users create high-quality organizational documents (ADRs, PRDs, technical designs, standards, etc.) by intelligently using templates, role guides, and organizational context.

## When to Use

- You need to create a new organizational document
- You want AI to help scaffold a document following your org's patterns
- `/show-role-context` shows missing documents you need to create
- You want consistent document structure across your organization

## Usage

```bash
# Generate with interactive prompts
/generate-document

# Generate specific document type
/generate-document architecture-decision-record

# Generate with minimal interaction (uses defaults)
/generate-document --auto prd
```

## Instructions for Claude

When this command is executed, invoke the **document-generator agent** to create the document.

**Implementation**:

1. **Parse command arguments**:
   - Check if document type is specified (e.g., "architecture-decision-record", "prd", "engineering-standards")
   - Check for `--auto` flag for batch mode
   - Extract any other parameters

2. **Invoke the agent**:
   ```
   Use the Task tool with:
   - subagent_type: 'document-generator'
   - description: 'Generate organizational document'
   - prompt: 'Generate a [document-type] document for the user. Read their role guide, organizational context, and existing documents to understand patterns. Ask questions to gather specific information. Create the document in the appropriate location following organizational style.'
   ```

   If `--auto` flag present:
   - Add to prompt: 'Use batch mode with minimal interaction. Create document with sensible defaults and TODO placeholders for user to fill in.'

   If document type specified:
   - Add to prompt: 'User wants to create a [document-type].'

3. **The agent will**:
   - Read user's role from preferences
   - Read corresponding role guide
   - Check organizational level and template
   - Read document guides if available
   - Analyze existing similar documents for style
   - Ask user document-specific questions
   - Generate document with appropriate structure
   - Place document in correct location
   - Update cross-references if needed

4. **After agent completes**:
   - Show where document was created
   - Summarize what sections were included
   - Note any TODOs user needs to complete
   - Suggest related documents if applicable

## Example Usage

### Interactive Mode (Default)

```bash
/generate-document architecture-decision-record

# Agent will ask:
# "What technical decision are you documenting?"
# "What alternatives did you consider?"
# "What are the key trade-offs?"
#
# Then generate:
# ✓ Created docs/architecture-decision-records/ADR-0005-use-postgresql-for-primary-database.md
#
# Document includes:
# - Status: Proposed
# - Context: [your answers]
# - Decision: [your answers]
# - Consequences: [trade-offs you mentioned]
# - Alternatives Considered: [alternatives you mentioned]
#
# Next steps:
# 1. Review and refine the ADR
# 2. Change Status to "Accepted" when decision is final
# 3. Link from relevant technical design docs
```

### Batch Mode

```bash
/generate-document --auto technical-design

# Agent generates with minimal interaction:
# ✓ Created docs/technical-design-document.md
#
# Document created with standard structure.
# Fill in TODO sections:
# - [ ] Background / Context
# - [ ] Proposed Design details
# - [ ] Testing Strategy
# - [ ] Open Questions
```

## Supported Document Types

The agent understands many document types:

**Technical**:
- `architecture-decision-record` (ADR)
- `technical-design` (TDD)
- `api-documentation`
- `operational-runbook`

**Product**:
- `product-requirements-document` (PRD)
- `feature-spec`
- `user-story`
- `product-overview`

**Strategic**:
- `objectives-and-key-results` (OKRs)
- `roadmap`
- `strategy`
- `vision-and-mission`

**Standards**:
- `engineering-standards`
- `quality-standards`
- `security-policy`
- `code-of-conduct`

**Process**:
- `contributing-guide`
- `development-setup`
- `team-handbook`
- `incident-response`

**Fundraising** (for startup template):
- `pitch-deck-guide`
- `investor-update`

If you specify a type not listed, the agent will do its best to infer structure or ask for clarification.

## Document Placement

The agent intelligently places documents based on:
- Organizational level (company/system/product/project)
- Document type conventions
- Existing directory structure
- Template patterns

**Typical locations**:
```
Company level: /engineering-standards.md
System level: system-name/roadmap.md
Product level: product-name/docs/product-requirements-documents/
Project level: project-name/docs/architecture-decision-records/
```

## Role Context Integration

The agent adapts to your role:
- **Engineers**: Technical depth, implementation details, code examples
- **Product Managers**: User focus, business value, metrics, success criteria
- **Executives**: Strategic view, outcomes, high-level overview

The agent reads your role guide to understand what level of detail you need.

## Organizational Template Awareness

**Startup template** (lean):
- Generates shorter, more informal documents
- Focuses on essential information only
- Scrappy, practical tone
- ~50% shorter than enterprise versions

**Enterprise template** (comprehensive):
- Detailed, thorough documents
- Formal tone and structure
- Compliance-aware content
- Extensive cross-referencing

## Error Handling

**If role is not set**:
- Agent will ask about your role or continue with generic approach
- Suggest setting role with `/set-role` for better results

**If document type is ambiguous**:
- Agent will ask for clarification
- Show examples of document types
- Offer closest match

**If document already exists**:
- Agent will warn before overwriting
- Offer to create with different name or cancel

**If document guide is missing**:
- Agent will use standard structure for that document type
- Infer patterns from existing similar documents

## Notes

- Documents are generated with TODO markers for user to complete
- Agent learns from your existing documents to match style
- Cross-references are created automatically when appropriate
- You can customize generated documents - they're starting points
- Run command multiple times for different document types

## Integration with Other Commands

- `/show-role-context` shows which documents your role references
- `/update-role-docs` adds generated documents to your role's references
- `/validate-setup` checks that generated documents are properly structured
