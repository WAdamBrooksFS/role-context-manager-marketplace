# AI-Enabled Software Organization Framework - Summary

## 🎯 Core Mission

Enable software companies to partner with AI through **standardized documentation and shared context** that provides:
1. **Deterministic AI behavior** - Validation rules AI must enforce
2. **Agentic AI capabilities** - Proactive suggestions AI should make
3. **Single source of truth** - Each fact lives in exactly one place
4. **Role-based context** - Documentation at the level where work happens

---

## 📊 Current Status

### ✅ Complete (Production Ready)

**Core Framework:**
- ✅ Master guide: `docs/document-standards-guide.md`
- ✅ Comprehensive README with full overview
- ✅ Root CLAUDE.md explaining system to AI

**Strategic Documents (Company Level):**
- ✅ objectives-and-key-results.md
- ✅ strategy.md
- ✅ roadmap.md
- ✅ product-vision.md

**Standards & Policies (7 documents):**
- ✅ engineering-standards.md
- ✅ quality-standards.md
- ✅ security-policy.md
- ✅ data-governance.md
- ✅ infrastructure-standards.md
- ✅ agile-practices.md
- ✅ roles-and-responsibilities.md (all 40+ roles defined)

**Templates (8 documents in `/docs/templates/`):**
- ✅ product-requirements-document-template.md
- ✅ technical-design-document-template.md
- ✅ architecture-decision-record-template.md
- ✅ request-for-comments-template.md
- ✅ test-plan-template.md
- ✅ post-mortem-template.md
- ✅ user-story-template.md
- ✅ operational-runbook-template.md

**Process Guides (2 documents in `/docs/processes/`):**
- ✅ incident-response.md
- ✅ Embedded in post-mortem template

**Document Workflow Guides (3 documents in `/.claude/document-guides/`):**
- ✅ product-requirements-document-guide.md (with approval requirements)
- ✅ objectives-and-key-results-guide.md (with approval requirements)
- ✅ architecture-decision-record-guide.md (with approval requirements)

**Example Documents at Each Level:**
- ✅ System: objectives-and-key-results.md
- ✅ Product: roadmap.md
- ✅ Project: contributing.md

### 🔧 In Progress - Role Guides (26 guides for Eng/QA/Product/PM roles)

**Completed (4 guides):**
- ✅ `/.claude/role-guides/product-manager-guide.md` (Product level)
- ✅ `/project-*/.claude/role-guides/software-engineer-guide.md` (Project level)
- ✅ `/.claude/role-guides/cto-vp-engineering-guide.md` (Company level)
- ✅ `/.claude/role-guides/director-qa-guide.md` (Company level)

**Template Created:**
- ✅ `/.claude/ROLE-GUIDES-COMPLETION-PLAN.md` - Complete template and instructions for remaining 22 guides

**Remaining (22 guides):**
- 3 company-level: Cloud Architect, CISO, CPO
- 6 system-level: Engineering Manager, Platform Engineer, Data Engineer, Security Engineer, TPM, Technical Program Manager
- 4 product-level: QA Manager, UX Designer, UI Designer, (TPM)
- 9 project-level: Frontend/Backend/Full-Stack/Mobile Engineers, DevOps, SRE, Data Scientist/Analyst, SDET, QA Engineer, Scrum Master

---

## 🏗️ Framework Architecture

### Information Flow (Cascading Context)
```
Company Strategy & OKRs
    ↓ (supports)
System OKRs
    ↓ (enables)
Product Roadmap
    ↓ (defines)
PRDs (Requirements)
    ↓ (implements)
Technical Designs
    ↓ (produces)
Code & Tests
```

### Organizational Hierarchy
```
Company (/)
├── Strategic docs (OKRs, strategy, roadmap, vision)
├── Standards (engineering, quality, security, data, infrastructure, agile)
├── Templates (8 reusable templates)
├── Role guides (leadership roles)
│
└── System (system-template/)
    ├── System OKRs
    ├── System architecture docs
    ├── Role guides (management/coordination roles)
    │
    ├── Product (product-*-template/)
    │   ├── Product roadmap
    │   ├── PRDs
    │   ├── Role guides (PM, design, QA manager)
    │   │
    │   └── Project (project-*-template/)
    │       ├── Contributing guide
    │       ├── Technical docs (TDD, API, runbook)
    │       ├── Tests & code
    │       └── Role guides (engineers, QA, DevOps, SRE)
```

### Two-Layer AI Guidance System

**Layer 1: Inline Instructions** (in every document)
```markdown
<!-- LLM: When reviewing PRDs, ensure acceptance criteria are testable -->
```
- Provides immediate context
- Enforces validation rules
- Guides AI behavior within document

**Layer 2: Companion Guides** (in `.claude/` directories)
- **Role guides**: How AI assists each role (deterministic + agentic)
- **Document guides**: Workflows for document types (with approvals)
- Detailed validation rules and common workflows

---

## 🎯 Key AI Capabilities Enabled

### Deterministic Behaviors (MUST enforce)
- Validate required fields in documents
- Check cross-references and linkages
- Enforce approval requirements
- Verify compliance with standards
- Ensure OKRs cascade properly

### Agentic Behaviors (SHOULD suggest)
- Identify missing content proactively
- Spot inconsistencies across documents
- Recommend improvements
- Flag risks and gaps
- Propose next steps in workflows

---

## 📝 Document Classification

### Living Documents (Updated Frequently)
- OKRs (Quarterly)
- Roadmaps (Weekly/Monthly)
- Runbooks (As needed)
- Standards (Quarterly review)

### Static Documents (Historical Records)
- ADRs (Never edited after acceptance)
- Post-mortems (Finalized after incident)
- Major strategy docs (Annual updates)

### Status Markers in Every Document
- Status: Living or Static
- Update Frequency: Daily/Weekly/Monthly/Quarterly/Annual
- Primary Roles: Who creates/consumes
- Related Documents: Cross-references

---

## 🚀 Using the Framework

### For Organizations

**Immediate Actions:**
1. Read `/README.md` and `/docs/document-standards-guide.md`
2. Customize strategic documents with your data
3. Rename `system-template/` to actual system name
4. Use templates from `/docs/templates/` for new documents

**Setup:**
```bash
# 1. Update company info
edit objectives-and-key-results.md
edit strategy.md
edit roadmap.md

# 2. Rename structures
mv system-template/ system-[your-name]/
mv product-*-template/ product-[your-name]/

# 3. Start using templates
cp docs/templates/product-requirements-document-template.md \
   system-*/product-*/docs/product-requirements-documents/feature-name.md
```

### For AI Assistants

**How to Use This Framework:**
1. Read `CLAUDE.md` at each organizational level
2. Read relevant role guide for the user you're assisting
3. Follow inline `<!-- LLM: ... -->` instructions in documents
4. Use document workflow guides when creating/updating documents
5. Enforce MUST rules, suggest SHOULD improvements

**Context Priority:**
1. Role guide (who am I helping?)
2. Document guide (what document type?)
3. Inline instructions (specific guidance)
4. Standards documents (what rules apply?)

---

## 📦 What's Included

**Total Documents Created:** ~40 foundational documents
- Strategic: 4
- Standards: 7
- Templates: 8
- Processes: 2
- Document guides: 3
- Role guides: 4 complete + template for 22 more
- Examples: Multiple at each level

**Directory Structure:** Complete 4-level hierarchy (Company/System/Product/Project)

**AI Integration:** Dual-layer guidance system (inline + companion guides)

---

## ✅ Next Steps to Complete Framework

### Priority 1: Complete Core Role Guides (if desired)
Use template in `/.claude/ROLE-GUIDES-COMPLETION-PLAN.md` to create remaining 22 guides:
- Start with most common roles: Engineering Manager, DevOps, SDET, QA Engineer
- Reference existing guides for patterns
- ~30-45 min per guide

### Priority 2: Populate Additional Examples (optional)
- Add more system directories
- Create multiple product examples
- Add complete docs at each level

### Priority 3: Customize for Your Organization
- Replace placeholder content with real data
- Add organization-specific standards
- Create additional role guides as needed

---

## 💡 Key Success Factors

**For Humans:**
- Clear structure (no "where does this go?" questions)
- Consistent templates accelerate work
- Examples show proper usage
- Version-controlled knowledge base

**For AI:**
- Rich context at every level
- Clear validation rules
- Role-aware assistance
- Workflow automation guidance

**For Organization:**
- Knowledge preservation
- Faster onboarding
- Improved quality through automation
- AI as force multiplier, not risk

---

## 📄 Essential Files Reference

| Purpose | File Path |
|---------|-----------|
| **Start here** | `/README.md` |
| **Master guide** | `/docs/document-standards-guide.md` |
| **AI context** | `/CLAUDE.md` (at each level) |
| **All roles** | `/roles-and-responsibilities.md` |
| **Templates** | `/docs/templates/*.md` |
| **Your role guide** | `/.claude/role-guides/[role]-guide.md` |
| **Document workflows** | `/.claude/document-guides/*.md` |
| **Completion plan** | `/.claude/ROLE-GUIDES-COMPLETION-PLAN.md` |

---

## 🎓 Framework Version

**Version:** 1.0
**Status:** Production ready (core complete, role guides in progress)
**Created:** 2024
**Purpose:** Enable deterministic and agentic AI collaboration through shared context

**Core Innovation:** Two-layer AI guidance (inline instructions + companion guides) at every organizational level, with role-based context enabling both validation and proactive assistance.
