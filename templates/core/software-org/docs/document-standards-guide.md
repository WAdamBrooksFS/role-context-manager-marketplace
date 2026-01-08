# Document Standards Guide

<!-- LLM: This is the master guide for the documentation system. When users ask about documentation structure, refer them here. When creating or updating any document, ensure it follows the standards outlined in this guide. -->

**Status:** Living | **Update Frequency:** Quarterly
**Primary Roles:** All roles - this is the foundation for the entire documentation system
**Related Documents:** All documents in this repository

## Purpose

This guide defines the standardized documentation framework that enables effective human-AI collaboration across all organizational levels. Every document in this repository serves two purposes:

1. **Human Communication**: Provides clear, actionable information for team members
2. **AI Context**: Gives Large Language Models the context needed for deterministic behavior and helpful agentic work

## Core Principles

### 1. Single Source of Truth
Each type of information lives at exactly one organizational level to avoid duplication and confusion:
- **Company Level**: Strategic direction, organization-wide standards, role definitions
- **System Level**: System-specific strategy, cross-product coordination
- **Product Level**: Product roadmaps, feature requirements, customer-facing information
- **Project Level**: Technical implementation, day-to-day operations, code-level decisions

### 2. Living vs Static Documents
Every document is marked with its update frequency:
- **Living Documents**: Updated regularly as situations change (e.g., roadmaps, runbooks)
- **Static Documents**: Finalized and rarely changed (e.g., Architecture Decision Records, post-mortems)

### 3. Hybrid Content
Documents use a hybrid approach:
- **Template sections** with `[Placeholder instructions]` for teams to fill in
- **Example sections** with realistic, annotated sample content showing proper usage
- **Inline guidance** to help both humans and AI understand intent

### 4. AI Integration
Two layers of AI guidance:
- **Inline instructions**: HTML comments within documents (e.g., `<!-- LLM: Validate acceptance criteria -->`)
- **Companion guides**: Detailed workflow files in `.claude/` directories for complex processes

## Organizational Hierarchy

```
software-org-template/              (Company Level)
├── docs/                           Strategic & template docs
├── .claude/                        AI guidance files
│
└── system-template/                (System Level)
    ├── docs/                       System-specific docs
    ├── .claude/                    System-level AI guidance
    │
    ├── product-*-template/         (Product Level)
    │   ├── docs/                   Product-specific docs
    │   ├── .claude/                Product-level AI guidance
    │   │
    │   └── project-*-template/     (Project Level)
    │       ├── docs/               Project-specific docs
    │       └── .claude/            Project-level AI guidance
```

## Document Types by Level

### Company Level Documents (`/`)

**Strategic Direction:**
- `objectives-and-key-results.md` - Company OKRs (Living, Quarterly)
- `strategy.md` - Company strategy and vision (Living, Quarterly)
- `roadmap.md` - High-level company roadmap (Living, Quarterly)
- `product-vision.md` - Product philosophy (Living, Quarterly)

**Standards & Policies:**
- `engineering-standards.md` - Coding standards, tech stack (Living, Quarterly)
- `quality-standards.md` - Testing philosophy (Living, Semi-annually)
- `infrastructure-standards.md` - Cloud, security baselines (Static, Annual)
- `security-policy.md` - Security requirements (Static, Annual)
- `compliance-requirements.md` - Regulatory requirements (Static, Annual)
- `data-governance.md` - Data policies (Static, Annual)
- `design-system-standards.md` - Brand, accessibility (Living, Quarterly)
- `agile-practices.md` - Company agile methodology (Living, Semi-annually)

**Organizational:**
- `roles-and-responsibilities.md` - All role definitions (Living, Quarterly)
- `hiring-practices.md` - Hiring standards (Living, Quarterly)

**Templates:**
- `docs/templates/` - All document templates for reuse

**AI Guidance:**
- `.claude/role-guides/` - Role-specific AI context
- `.claude/document-guides/` - Document workflow guides

### System Level Documents (`system-template/`)

**Strategic:**
- `objectives-and-key-results.md` - System OKRs (Living, Quarterly)
- `roadmap.md` - System roadmap (Living, Monthly)
- `program-overview.md` - Cross-product initiatives (Living, Monthly)

**Technical:**
- `engineering-context.md` - System tech decisions (Living, Monthly)
- `infrastructure-overview.md` - System infrastructure (Living, Monthly)
- `security-overview.md` - System security architecture (Living, Quarterly)
- `docs/data-architecture.md` - System data flows (Living, Quarterly)
- `docs/architecture-decision-records/` - System-wide decisions (Static)

### Product Level Documents (`product-*-template/`)

**Strategic:**
- `product-overview.md` - Product purpose, users (Living, Quarterly)
- `roadmap.md` - Feature roadmap (Living, Weekly)
- `docs/release-notes.md` - Release history (Living, Weekly)

**Requirements:**
- `docs/product-requirements-documents/` - Feature requirements (Living, Daily)

**Quality:**
- `docs/test-strategy.md` - Testing approach (Living, Quarterly)

**Design:**
- `docs/design-specifications/` - Design specs (Living, Weekly)
- `docs/user-research/` - Research findings (Living, Monthly)

**Customer-Facing:**
- `docs/customer-success-playbook.md` - Implementation guides (Living, Monthly)
- `docs/troubleshooting-guide.md` - Common issues (Living, Weekly)

### Project Level Documents (`project-*-template/`)

**Developer Onboarding:**
- `contributing.md` - How to contribute (Living, Daily)
- `development-setup.md` - Local environment (Living, Weekly)

**Technical:**
- `docs/technical-design-document.md` - Technical design (Static)
- `docs/api-documentation.md` - API docs (Living, Daily)
- `docs/architecture-decision-records/` - Project decisions (Static)
- `docs/requests-for-comments/` - Technical proposals (Living, Weekly)

**Operations:**
- `docs/operational-runbook.md` - Operations procedures (Living, Daily)
- `docs/deployment-guide.md` - Deployment procedures (Living, Weekly)

**Testing:**
- `docs/test-plan.md` - Test plans (Living, Daily)
- `docs/test-cases/` - Test case library (Living, Daily)

**Security:**
- `docs/security-considerations.md` - Project security (Living, Monthly)
- `docs/threat-model.md` - Threat modeling (Living, Quarterly)

## Document Structure Standard

Every document should follow this structure:

```markdown
<!-- LLM: [Brief instruction about when/how AI should use this document] -->

# Document Title

**Status:** [Living/Static] | **Update Frequency:** [Daily/Weekly/Monthly/Quarterly/Annual]
**Primary Roles:** [Comma-separated list of roles who primarily use this]
**Related Documents:** [Links to related documents]

## Purpose
[1-2 sentences explaining what this document is for]

## Template Section
[Placeholder text with clear instructions]
[Use square brackets for placeholders: [Your content here]]

## Example Section (Annotated)
<!-- Example: This shows a realistic use case for... -->
[Realistic example content that demonstrates proper usage]

<!-- LLM: When updating this section, ensure you [validation rule] -->

## Additional Sections
[As needed for document type]
```

## Role-Based Documentation

Each role has a guide file at their primary working level:

**Company-Level Roles** (Strategic):
- CTO/VP Engineering, CPO/VP Product, Director QA, CISO, Cloud Architect, etc.
- Guides: `/.claude/role-guides/[role]-guide.md`

**System-Level Roles** (Coordination):
- Engineering Manager, QA Manager, Platform Engineer, Technical Program Manager
- Guides: `system-template/.claude/role-guides/[role]-guide.md`

**Product-Level Roles** (Features):
- Product Manager, UX/UI Designer, Customer Success Manager
- Guides: `product-*-template/.claude/role-guides/[role]-guide.md`

**Project-Level Roles** (Daily Work):
- Software Engineers, QA Engineers, DevOps Engineers, SREs, Data Analysts
- Guides: `project-*-template/.claude/role-guides/[role]-guide.md`

## Using This System

### For Humans

**When starting a new initiative:**
1. Check if a template exists in `/docs/templates/`
2. Copy template to appropriate organizational level
3. Fill in placeholder sections
4. Reference example sections for guidance
5. Mark document status (Living/Static) and update frequency

**When updating documents:**
1. Check document's update frequency - is it time for review?
2. Update content following existing structure
3. Maintain inline AI guidance comments
4. Update "Related Documents" links if needed

### For AI (Large Language Models)

**Reading inline instructions:**
- Look for `<!-- LLM: ... -->` comments throughout documents
- These provide specific guidance on validation, constraints, and workflows

**Following role guides:**
- When working with a specific role, read their guide in `.claude/role-guides/`
- Role guides define deterministic behaviors and agentic opportunities

**Following document guides:**
- When creating/updating a document type, read its guide in `.claude/document-guides/`
- Document guides provide workflows, validation rules, and cross-references

**Deterministic behavior:**
- Follow validation rules strictly
- Maintain document structure standards
- Preserve inline guidance for future AI interactions

**Agentic behavior:**
- Suggest updates when documents are stale (based on update frequency)
- Cross-reference related documents
- Identify missing required information
- Propose new documents when gaps are discovered

## Document Lifecycle

### Creation
1. Identify need for new document
2. Find appropriate template in `/docs/templates/`
3. Place at correct organizational level (use decision matrix above)
4. Fill in template using examples as guide
5. Add inline AI instructions if needed
6. Link from related documents

### Maintenance
1. Review document based on update frequency
2. Update content following existing structure
3. Increment version if using versioning
4. Update "Related Documents" if links changed

### Archiving
1. Static documents are rarely archived (they're historical records)
2. Living documents may be moved to `docs/archive/` when no longer relevant
3. Update links from other documents when archiving

## Getting Started

### For New Organizations
1. Start at company level - create strategic documents (OKRs, strategy, roadmap)
2. Define standards and policies
3. Create your first system, product, and project directories
4. Copy templates to each level and customize
5. Add role guides for your team's roles

### For Existing Projects
1. Review current documentation
2. Map existing docs to this structure
3. Fill gaps using templates
4. Add AI guidance incrementally
5. Train team on new structure

## Templates Available

All templates are in `/docs/templates/`:
- `product-requirements-document-template.md`
- `request-for-comments-template.md`
- `technical-design-document-template.md`
- `architecture-decision-record-template.md`
- `test-plan-template.md`
- `post-mortem-template.md`
- `user-story-template.md`
- `runbook-template.md`

## Questions?

**Where does document X go?**
- See "Document Types by Level" section above

**How often should I update document Y?**
- Check the document's "Update Frequency" metadata

**What if my role isn't listed?**
- Create a role guide following the template in `.claude/role-guides/`

**Can I create new document types?**
- Yes! Follow the structure standard above and add inline AI guidance

## Benefits of This System

**For Humans:**
- Clear structure reduces decision fatigue
- Examples accelerate document creation
- Single source of truth reduces confusion
- Version control tracks all changes

**For AI:**
- Structured context enables better assistance
- Validation rules ensure consistency
- Role guides enable context-aware suggestions
- Document guides enable workflow automation

**For Organization:**
- Knowledge is preserved and discoverable
- Onboarding is faster
- Cross-team communication improves
- AI becomes a force multiplier, not a risk

---

<!-- LLM: When users reference "the document system" or ask about "where should I put this document", always point them to this guide. When creating new documents, always follow the structure defined here. -->
