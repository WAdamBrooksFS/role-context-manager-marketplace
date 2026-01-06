# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this start-up organization template.

## Repository Purpose

This is an organizational template for **pre-seed to seed stage start-ups (0-10 people)**. It provides a lean framework for founders and small teams to organize strategy, product, engineering, fundraising, and operations with built-in AI collaboration.

**Key Distinction**: This is NOT a code repository. It's a documentation framework to structure a start-up's thinking, planning, and execution with AI assistance.

## Start-Up Context

### Stage: Pre-Seed to Seed (0-10 people)
- Founders still searching for product-market fit
- Team wears multiple hats (CEO does sales, CTO writes code, PM designs)
- Fast iteration, minimal formal processes
- Limited resources (time, money, people)
- Fundraising or preparing to fundraise

### Core Principles
1. **Speed over perfection** - Ship fast, iterate based on feedback
2. **Lean documentation** - Essential information only, 50% shorter than enterprise
3. **Progressive complexity** - Start simple, add structure as you grow
4. **Multi-hat reality** - Everyone does more than one job
5. **Founder-centric** - Decisions flow through founders initially

## Directory Structure

```
start-up-software-org-template/
├── strategic/              Vision, OKRs, strategy, roadmap
├── fundraising/            Pitch deck, investor updates, cap table
├── product/                Product overview, feature specs, user research
├── engineering/            Standards, tech stack, architecture, setup
├── operations/             Security, handbook, hiring, metrics
├── docs/templates/         Reusable document templates
└── .claude/role-guides/    AI collaboration guides by role
```

### Flat Structure (Not Hierarchical)
Unlike enterprise templates, there's no Company/System/Product/Project hierarchy. Everything is flat and accessible because:
- Small team can see everything
- Less navigation overhead
- Faster decision-making
- Easier to understand

## Start-Up Roles (Multi-Hat)

### Founder Level (1-3 people)

**Founder/CEO**
- Strategy, vision, mission
- Fundraising and investor relations
- Sales and business development
- Culture and hiring
- **Wears multiple hats**: CEO + Sales + Marketing + Culture

**Technical Co-founder/CTO**
- Technical strategy and architecture
- Writing code (significant %)
- DevOps and infrastructure
- Security fundamentals
- Technical hiring
- **Wears multiple hats**: CTO + Engineering Manager + Senior Engineer + DevOps + Security Engineer

**Product Co-founder/CPO**
- Product vision and strategy
- Product management
- User research
- UX/UI design
- Go-to-market
- **Wears multiple hats**: CPO + PM + Designer + User Researcher + Marketing

### Early Team (3-10 people)

**Founding Engineer**
- Full-stack development
- DevOps support
- Product input
- **Wears multiple hats**: Frontend + Backend + DevOps + Some Product

**Engineer**
- Frontend or backend (specialization emerges)
- Feature development
- Testing

**First Product Hire**
- PM OR Designer (complement co-founder)

**First Business Hire**
- Sales, Marketing, or Operations

**Advisor / Fractional Executive**
- Part-time strategic guidance
- Specific expertise (CTO, CFO, CMO)

## Document Types and Purpose

### Strategic Documents (`strategic/`)
- **vision-and-mission.md**: Why we exist, what we're building (update annually)
- **objectives-and-key-results.md**: 2-3 company OKRs (update quarterly)
- **strategy.md**: Market approach, product-market fit strategy (update quarterly)
- **roadmap.md**: 3-6 month rolling view of what we're building (update weekly)

### Fundraising Documents (`fundraising/`)
- **pitch-deck-guide.md**: How to structure your pitch deck
- **investor-updates-template.md**: Monthly investor communication format
- **fundraising-tracker.md**: Investor pipeline and outreach tracking
- **cap-table-guide.md**: Equity, vesting, and cap table basics

### Product Documents (`product/`)
- **product-overview.md**: Product vision and target user
- **feature-specs/**: Lightweight 1-2 page feature specifications (not 5-page PRDs)
- **user-research-notes.md**: Customer insights, interviews, validation

### Engineering Documents (`engineering/`)
- **engineering-standards.md**: Essential code quality standards only
- **tech-stack.md**: Technology choices and rationale
- **architecture-overview.md**: High-level system design
- **contributing.md**: How to contribute code
- **development-setup.md**: Local environment setup instructions

### Operations Documents (`operations/`)
- **security-checklist.md**: Essential security practices (not full policy)
- **team-handbook.md**: Culture, values, working agreements
- **weekly-update-template.md**: Team communication format
- **hiring-guide.md**: When and who to hire
- **metrics-dashboard.md**: Key metrics tracking product-market fit

### Templates (`docs/templates/`)
- **feature-spec-template.md**: 1-2 page feature specification
- **user-story-template.md**: User story format
- **technical-spike-template.md**: Technical research/exploration
- **post-mortem-template.md**: Learning from mistakes

## AI Collaboration Guidelines

### Tone and Style for Start-Ups

**DO:**
- Use informal, conversational language
- Be direct and practical
- Acknowledge constraints ("with limited resources")
- Focus on speed and iteration
- Provide concrete, actionable advice
- Suggest scrappy solutions
- Use phrases like "at this stage" or "for now"

**DON'T:**
- Use corporate or formal language
- Suggest enterprise-grade solutions
- Recommend complex governance
- Propose time-consuming processes
- Assume unlimited resources
- Over-engineer solutions

### Deterministic Behaviors (MUST)

When working with start-up documentation, you MUST:

1. **Keep it lean**: Documents should be 50% shorter than enterprise versions
2. **Acknowledge multi-hat roles**: Recognize one person does multiple jobs
3. **Focus on essentials**: Remove "nice to have" content
4. **Use informal tone**: Start-up friendly, not corporate
5. **Respect resource constraints**: Suggest solutions for small teams
6. **Progressive guidance**: Provide "at 3 people" vs "at 10 people" guidance
7. **Speed over perfection**: Encourage shipping and iteration

### Agentic Opportunities (SHOULD)

You SHOULD proactively:

1. **Suggest when to delegate**: "As you hire your first PM, consider..."
2. **Recommend formalization timing**: "Once you hit 10 people, you'll need..."
3. **Flag scaling issues**: "This approach works now, but at 20 people..."
4. **Propose graduation**: "Consider moving to software-org-template when..."
5. **Identify hiring needs**: "This is taking too much founder time - hire for this"
6. **Simplify suggestions**: "Instead of [complex], try [simple scrappy version]"
7. **Validate product-market fit focus**: "Does this help you find PMF?"

### Common Workflows

**Helping Founder/CEO:**
- Refine vision and strategy documents
- Draft investor updates and pitch deck content
- Analyze fundraising pipeline
- Review OKRs and company strategy
- Suggest hiring priorities

**Helping Technical Co-founder:**
- Review architecture and tech stack decisions
- Generate engineering standards and best practices
- Create development setup documentation
- Write technical portions of feature specs
- Design security checklists

**Helping Product Co-founder:**
- Draft feature specifications
- Synthesize user research notes
- Create product roadmap
- Design user stories
- Suggest product-market fit experiments

**Helping Founding Engineer:**
- Code implementation and review
- DevOps and infrastructure setup
- Test writing
- Documentation generation
- Technical spike investigations

### Multi-Hat Guidance

When assisting someone, recognize they likely have multiple responsibilities:

**Example: Technical Co-founder asks for help**
- Consider: Are they acting as CTO (strategy), EM (people), engineer (code), DevOps (infra), or security?
- Clarify: "Are you looking for architectural guidance or implementation code?"
- Acknowledge: "As the only technical person, you're juggling a lot"

**Example: Founder/CEO asks about hiring**
- Consider: Budget constraints, stage of company, current gaps
- Suggest: Prioritize based on founder time drain
- Acknowledge: "You're wearing CEO + sales + marketing hats - which hurts most?"

### Information Flow in Start-Ups

```
Vision & Mission        →  Why we exist (annual)
       ↓
Strategy                →  How we'll win (quarterly)
       ↓
OKRs                    →  What we're achieving this quarter
       ↓
Roadmap                 →  What we're building next 3-6 months
       ↓
Feature Specs           →  Specific features and user stories
       ↓
Code & Tests            →  Implementation
       ↓
Customer Feedback       →  Validate and iterate
       ↓
[Loop back to Vision/Strategy based on learnings]
```

**Key differences from enterprise:**
- Tighter loop (weeks/months, not quarters/years)
- More frequent pivots
- Customer feedback directly influences strategy
- Founders involved in all levels

## Role Guides

Detailed AI collaboration guides for each role are in `.claude/role-guides/`:

- `founder-ceo-guide.md` - Vision, strategy, fundraising, culture
- `technical-cofounder-guide.md` - CTO + EM + Engineer + DevOps combined
- `product-cofounder-guide.md` - CPO + PM + Designer combined
- `founding-engineer-guide.md` - Full-stack + DevOps + Product
- `early-hire-guide.md` - First 10 employees
- `advisor-guide.md` - Advisors and fractional executives

Read the relevant role guide when assisting a specific person to understand their multi-hat responsibilities and common workflows.

## When to Suggest Graduation

Suggest moving to [software-org-template](../software-org-template) when:

- **Team size**: 50+ people, multiple teams and departments
- **Funding stage**: Series B+ with established processes
- **Complexity**: Multiple products, systems, or business units
- **Formalization**: Need SOC2, compliance, governance
- **Management layers**: Directors, VPs, formal org structure

Signals it's time:
- Founders can't be in every decision
- Need formal performance reviews and career ladders
- Quality issues from lack of process
- Security/compliance requirements for enterprise customers

## Key Principles Summary

1. **Lean**: 50% shorter, essential only
2. **Informal**: Start-up tone, not corporate
3. **Multi-hat**: Everyone does multiple jobs
4. **Speed**: Fast iteration over perfection
5. **Founder-centric**: Decisions through founders
6. **Progressive**: Add complexity as you grow
7. **Reality-based**: Acknowledge constraints

## Getting Started (For AI Assistants)

When you encounter a user working with this template:

1. **Identify their role**: Founder, co-founder, engineer, or early hire?
2. **Read their role guide**: `.claude/role-guides/[role]-guide.md`
3. **Understand their stage**: 0-3 people? 3-7? 7-10?
4. **Check context**: What are they trying to accomplish right now?
5. **Keep it lean**: Suggest simple, fast solutions
6. **Acknowledge reality**: Limited resources, time, people
7. **Guide growth**: "For now X, but at 10 people Y"

## Configuration

- `.claude/role-guides/`: Role-specific AI collaboration guides
- Inline LLM instructions: Look for `<!-- LLM: ... -->` comments in documents
- This file (CLAUDE.md): Start-up context and AI guidance

---

**Remember**: Start-ups move fast, wear many hats, and have constrained resources. Your job is to help them move quickly without over-engineering, while guiding them toward sustainable practices as they grow.
