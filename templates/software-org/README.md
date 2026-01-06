# Software Organization Template with AI-Enabled Documentation

This repository provides a comprehensive framework for organizing software projects with built-in AI collaboration capabilities. It demonstrates how to structure systems, products, and projects while maintaining standardized documentation that enables effective human-LLM partnerships.

## 🎯 Purpose

This template solves two critical problems:

1. **Organizational Structure**: Provides a clear hierarchy for systems, products, and projects within a software organization
2. **AI Collaboration**: Enables deterministic and agentic AI behavior through standardized, context-rich documentation

## 🏗️ Repository Structure

```
software-org-template/                    (Company Level)
├── README.md                             This file
├── CLAUDE.md                             AI context for this repo
├── docs/
│   ├── document-standards-guide.md       ⭐ START HERE - Master guide
│   ├── templates/                        Reusable document templates
│   └── processes/                        Process guides
├── .claude/
│   ├── role-guides/                      Role-specific AI collaboration guides
│   └── document-guides/                  Document workflow guides
│
├── objectives-and-key-results.md         Company OKRs
├── strategy.md                           Company strategy
├── roadmap.md                            Company roadmap
├── product-vision.md                     Product vision
├── engineering-standards.md              Coding standards
├── quality-standards.md                  Testing standards
├── security-policy.md                    Security requirements
├── data-governance.md                    Data handling policies
├── infrastructure-standards.md           Infrastructure standards
├── agile-practices.md                    Agile methodology
├── roles-and-responsibilities.md         All role definitions
│
└── system-template/                      (System Level)
    ├── CLAUDE.md                         System-level context
    ├── objectives-and-key-results.md     System OKRs
    ├── docs/architecture-decision-records/ System ADRs
    ├── .claude/role-guides/              System-level roles
    │
    ├── product-full-stack-template/      (Product Level)
    │   ├── CLAUDE.md                     Product context
    │   ├── roadmap.md                    Product roadmap
    │   ├── docs/product-requirements-documents/
    │   ├── .claude/role-guides/          Product-level roles
    │   │
    │   └── project-a-template/           (Project Level)
    │       ├── CLAUDE.md                 Project context
    │       ├── contributing.md           How to contribute
    │       ├── docs/
    │       │   ├── technical-design-document.md
    │       │   ├── api-documentation.md
    │       │   ├── operational-runbook.md
    │       │   ├── test-plan.md
    │       │   └── architecture-decision-records/
    │       └── .claude/role-guides/      Project-level roles (engineers, QA, DevOps)
    │
    └── product-subdivided-template/
        ├── project-backend-template/
        └── project-frontend-template/
```

## 🚀 Getting Started

### For Organizations

**1. Start with the Master Guide**
Read `/docs/document-standards-guide.md` - this explains the entire documentation system.

**2. Customize Strategic Documents**
- Update `/objectives-and-key-results.md` with your company OKRs
- Update `/strategy.md` with your strategy
- Update `/roadmap.md` with your initiatives
- Update `/roles-and-responsibilities.md` with your team structure

**3. Create Your Structure**
- Rename `system-template/` to your actual system name
- Create additional systems as needed
- Populate products and projects

**4. Use the Templates**
Copy templates from `/docs/templates/` when creating:
- Product Requirements Documents (PRDs)
- Technical Design Documents (TDDs)
- Architecture Decision Records (ADRs)
- Test Plans
- Post-Mortems
- Runbooks

### For AI Assistants

**1. Read Documentation Guides**
- **Master Guide**: `/docs/document-standards-guide.md`
- **Document Guides**: `/.claude/document-guides/*.md`
- **Role Guides**: `/.claude/role-guides/*.md`

**2. Follow Inline Instructions**
Look for `<!-- LLM: ... -->` comments in every document. These provide:
- Validation rules (what MUST be enforced)
- Proactive suggestions (what SHOULD be recommended)
- Common pitfalls to avoid

**3. Understand Role Context**
When assisting a specific role:
1. Find their guide in `.claude/role-guides/[role]-guide.md`
2. Follow deterministic behaviors (MUST rules)
3. Make agentic suggestions (SHOULD recommendations)
4. Use common workflows provided

## 📚 Key Documents

### Strategic Direction
| Document | Level | Owner | Purpose |
|----------|-------|-------|---------|
| `objectives-and-key-results.md` | Company, System | CEO, Engineering Manager | Quarterly goals |
| `strategy.md` | Company | CEO | Long-term strategy |
| `roadmap.md` | Company, System, Product | Leadership, PM | Initiative timeline |
| `product-vision.md` | Company | CPO | Product direction |

### Standards & Policies
| Document | Owner | Purpose |
|----------|-------|---------|
| `engineering-standards.md` | CTO | Code, API, version control standards |
| `quality-standards.md` | Director QA | Testing requirements |
| `security-policy.md` | CISO | Security requirements |
| `data-governance.md` | CISO + Compliance | PII, retention, compliance |
| `infrastructure-standards.md` | Cloud Architect | Infrastructure/cloud standards |
| `agile-practices.md` | Agile Coach | Agile methodology |

### Templates
All templates in `/docs/templates/`:
- `product-requirements-document-template.md`
- `technical-design-document-template.md`
- `architecture-decision-record-template.md`
- `request-for-comments-template.md`
- `test-plan-template.md`
- `post-mortem-template.md`
- `user-story-template.md`
- `operational-runbook-template.md`

## 🤝 AI Collaboration Model

### Two-Layer AI Guidance

**1. Inline Instructions** (in documents)
```markdown
<!-- LLM: When reviewing PRDs, ensure all acceptance criteria are testable -->
```

**2. Companion Guides** (in `.claude/` directories)
- **Role Guides**: How AI should assist each role
- **Document Guides**: Workflows for each document type

### Deterministic Behaviors (MUST)
AI assistants MUST:
- Enforce validation rules
- Ensure required sections are complete
- Check cross-references and linkages
- Follow approval requirements
- Maintain document standards

### Agentic Opportunities (SHOULD)
AI assistants SHOULD:
- Suggest missing content proactively
- Identify risks and gaps
- Recommend improvements
- Cross-check consistency
- Propose next steps

## 🔄 Information Flow

```
Company Strategy & OKRs  →  "Why we exist, what we're achieving"
         ↓
System OKRs              →  "How this system contributes"
         ↓
Product Roadmap          →  "What features we're building"
         ↓
PRDs                     →  "Detailed requirements"
         ↓
Technical Designs        →  "How we'll build it"
         ↓
Code & Tests             →  "Implementation"
```

## 📊 Document Lifecycle

### Living Documents
Updated frequently, reflect current state:
- OKRs (Quarterly)
- Roadmaps (Weekly for products, Monthly for systems)
- Quality metrics (Continuous)
- Runbooks (As procedures change)

### Static Documents
Finalized, rarely changed (historical records):
- Architecture Decision Records (ADRs)
- Post-Mortems
- Major strategy documents (Annual updates)

## 👥 Role-Based Documentation

Documentation is organized by the level where work happens:

**Company-Level Roles** (Strategic):
- CEO, CTO/VP Engineering, CPO/VP Product, CISO, Cloud Architect
- Guides in `/.claude/role-guides/`

**System-Level Roles** (Coordination):
- Engineering Managers, QA Managers, Platform Engineers, Technical Program Managers
- Guides in `system-*/.claude/role-guides/`

**Product-Level Roles** (Features):
- Product Managers, UX/UI Designers, Customer Success Managers
- Guides in `product-*/.claude/role-guides/`

**Project-Level Roles** (Daily Work):
- Software Engineers, QA Engineers, DevOps, SREs, Data Analysts
- Guides in `project-*/.claude/role-guides/`

## ✅ Benefits

### For Humans
- **Clear Structure**: No more "where should this document live?"
- **Consistent Standards**: Templates ensure quality
- **Faster Onboarding**: Documentation is discoverable
- **Better Collaboration**: Shared understanding

### For AI
- **Rich Context**: Understands organizational structure
- **Validation Rules**: Enforces standards automatically
- **Role Awareness**: Tailors assistance to user's role
- **Workflow Guidance**: Knows document lifecycles

### For the Organization
- **Knowledge Preservation**: Version-controlled documentation
- **Alignment**: OKRs cascade from company to team
- **Quality**: Automated validation of standards
- **Velocity**: AI accelerates documentation tasks

## 🛠️ Extending the Framework

### Adding a New System
```bash
cp -r system-template/ system-[your-system-name]/
# Update CLAUDE.md, OKRs, and docs/
```

### Adding a New Product
```bash
cd system-[your-system]/
cp -r product-full-stack-template/ product-[your-product]/
# Update roadmap, PRDs, etc.
```

### Adding a New Document Type
1. Create template in `/docs/templates/`
2. Add workflow guide in `/.claude/document-guides/`
3. Update `/docs/document-standards-guide.md`
4. Add inline LLM instructions

### Adding a New Role
1. Add to `/roles-and-responsibilities.md`
2. Create role guide in appropriate `.claude/role-guides/`
3. Define deterministic behaviors and agentic opportunities

## 📖 Documentation Standards

Every document includes:
- **Status**: Living or Static
- **Update Frequency**: Daily, Weekly, Monthly, Quarterly, Annual
- **Primary Roles**: Who creates/consumes this document
- **Related Documents**: Cross-references
- **Inline LLM Instructions**: `<!-- LLM: ... -->` comments

## 🎓 Learning Resources

**Essential Reading Order:**
1. This README (overview)
2. `/docs/document-standards-guide.md` (master guide)
3. `/roles-and-responsibilities.md` (find your role)
4. `/.claude/role-guides/[your-role]-guide.md` (your role's guide)
5. Relevant standards for your work

## 📝 Contributing

When adding to this framework:
1. Follow existing document structure standards
2. Add inline LLM instructions
3. Create/update role guides as needed
4. Update cross-references
5. Test with AI assistant to ensure usability

## 📄 License

This template is designed to be duplicated and customized for your organization. No attribution required.

## 🤖 AI Compatibility

This framework is designed to work with:
- Claude Code (Anthropic)
- GitHub Copilot
- Cursor
- Any LLM that can read context and follow instructions

---

**Questions?** See `/docs/document-standards-guide.md` for comprehensive documentation.

**Created:** 2024
**Framework Version:** 1.0
