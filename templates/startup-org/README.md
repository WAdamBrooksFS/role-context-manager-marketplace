# Start-Up Software Organization Template

A lean organizational framework for pre-seed to seed stage start-ups (0-10 people) with built-in AI collaboration capabilities. Designed for founders and small teams where everyone wears multiple hats.

## Purpose

This template solves critical problems for early-stage start-ups:

1. **Organizational Clarity**: Simple structure for strategy, product, engineering, and operations
2. **Founder Guidance**: Clear roles and responsibilities for founders wearing multiple hats
3. **Fundraising Support**: Documentation for investors, pitch decks, and updates
4. **AI Collaboration**: Rich context enabling effective AI assistance across all functions
5. **Progressive Complexity**: Start lean, add structure as you grow

## Who This is For

**Company Stage**: Pre-seed to Seed (0-10 people)
- Founders still defining product-market fit
- Small team with multi-hat roles
- Fast iteration, minimal processes
- Fundraising or preparing to fundraise

**Not for you?** If you're 50+ people or Series B+, use the [software-org-template](../software-org-template) instead.

## Repository Structure

```
start-up-software-org-template/
├── README.md                           This file
├── CLAUDE.md                           AI context for start-ups
├── FRAMEWORK-SUMMARY.md                Quick reference guide
│
├── strategic/
│   ├── vision-and-mission.md          Why we exist, what we're building
│   ├── objectives-and-key-results.md  2-3 company OKRs (quarterly)
│   ├── strategy.md                    Market, product-market fit, growth
│   └── roadmap.md                     3-6 month rolling roadmap
│
├── fundraising/
│   ├── pitch-deck-guide.md            Pitch deck structure and storytelling
│   ├── investor-updates-template.md   Monthly investor update format
│   ├── fundraising-tracker.md         Investor pipeline and outreach
│   └── cap-table-guide.md             Equity, vesting, and cap table basics
│
├── product/
│   ├── product-overview.md            Product vision and target user
│   ├── feature-specs/                 Lightweight 1-2 page feature specs
│   └── user-research-notes.md         Customer insights and validation
│
├── engineering/
│   ├── engineering-standards.md       Essential code and git standards
│   ├── tech-stack.md                  Technology choices and rationale
│   ├── architecture-overview.md       High-level system design
│   ├── contributing.md                How to contribute code
│   └── development-setup.md           Local environment setup
│
├── operations/
│   ├── security-checklist.md          Essential security practices
│   ├── team-handbook.md               Culture, values, working agreements
│   ├── weekly-update-template.md      Team communication format
│   ├── hiring-guide.md                When and who to hire
│   └── metrics-dashboard.md           Key metrics for product-market fit
│
├── docs/
│   └── templates/                     Document templates
│       ├── feature-spec-template.md
│       ├── user-story-template.md
│       ├── technical-spike-template.md
│       └── post-mortem-template.md
│
└── .claude/
    └── role-guides/                   AI collaboration guides by role
        ├── founder-ceo-guide.md
        ├── technical-cofounder-guide.md
        ├── product-cofounder-guide.md
        ├── founding-engineer-guide.md
        ├── early-hire-guide.md
        └── advisor-guide.md
```

## Getting Started

### For Founders

**Week 1: Strategic Foundation**
1. Complete `strategic/vision-and-mission.md` - Clarify why you exist
2. Define `strategic/objectives-and-key-results.md` - Set 2-3 quarterly goals
3. Draft `strategic/strategy.md` - Document your approach to product-market fit
4. Create `strategic/roadmap.md` - Map out next 3-6 months

**Week 2: Product & Engineering**
1. Document `product/product-overview.md` - Who are you building for?
2. Set up `engineering/tech-stack.md` - Lock in your core technologies
3. Create `engineering/development-setup.md` - Enable new team members to contribute fast

**Week 3: Operations & Fundraising**
1. Write `operations/team-handbook.md` - Culture and working agreements
2. Complete `fundraising/pitch-deck-guide.md` - Prepare your fundraising materials
3. Set up `operations/metrics-dashboard.md` - Track what matters

**Ongoing:**
- Use `fundraising/investor-updates-template.md` for monthly investor communication
- Create feature specs in `product/feature-specs/` as you build
- Track customer insights in `product/user-research-notes.md`

### For AI Assistants

**1. Read Your Context**
- Start with `/CLAUDE.md` to understand the start-up context
- Find the user's role in `.claude/role-guides/[role]-guide.md`
- Follow inline `<!-- LLM: ... -->` instructions in documents

**2. Understand Multi-Hat Roles**
Early-stage roles combine multiple responsibilities:
- **Founder/CEO**: Strategy + Fundraising + Sales + Marketing + Culture
- **Technical Co-founder**: CTO + Engineering Manager + DevOps + Security
- **Product Co-founder**: PM + Designer + User Research + Marketing
- **Founding Engineer**: Full-stack + DevOps + some Product

**3. Deterministic Behaviors (MUST)**
- Keep documents lean (50% shorter than enterprise versions)
- Use informal, practical tone
- Focus on speed and iteration
- Acknowledge resource constraints
- Guide progressive complexity ("at 3 people" vs "at 10 people")

**4. Agentic Opportunities (SHOULD)**
- Suggest when to formalize processes
- Identify when founders should delegate
- Recommend hiring priorities
- Flag when template assumptions break down
- Propose graduation to full software-org-template at scale

## Core Start-Up Roles

### Founder Level (1-3 people)

**Founder/CEO**
- Vision, strategy, fundraising, investor relations
- Company culture and values
- Initial sales and business development
- Key hires and team building

**Technical Co-founder/CTO**
- Technical strategy and architecture
- Core engineering + coding
- DevOps and infrastructure
- Security fundamentals
- Technical hiring

**Product Co-founder/CPO**
- Product vision and strategy
- Product management and roadmap
- User research and validation
- UX/UI design
- Go-to-market strategy

### Early Team (3-10 people)

**Founding Engineer**
- Full-stack development
- DevOps and infrastructure support
- Some product input
- Code quality and standards

**Engineer (as team grows)**
- Frontend or backend specialization
- Feature development
- Testing and quality

**First Product Hire**
- Product management OR design (complement co-founder skills)

**First Business Hire**
- Sales, marketing, or operations

### Supporting Roles

**Advisor**
- Part-time strategic guidance
- Industry expertise
- Network and introductions

**Fractional Executive**
- Part-time CTO, CFO, CMO
- Strategic planning and execution
- Mentor founders

## Key Documents by Function

### Strategic Direction
| Document | Update Frequency | Owner | Purpose |
|----------|-----------------|-------|---------|
| `vision-and-mission.md` | Annually | Founder/CEO | Why we exist |
| `objectives-and-key-results.md` | Quarterly | Founder/CEO | What we're achieving |
| `strategy.md` | Quarterly | Founder/CEO | How we'll win |
| `roadmap.md` | Weekly | Product Co-founder | What we're building |

### Fundraising
| Document | Update Frequency | Owner | Purpose |
|----------|-----------------|-------|---------|
| `pitch-deck-guide.md` | As needed | Founder/CEO | Fundraising materials |
| `investor-updates-template.md` | Monthly | Founder/CEO | Investor communication |
| `fundraising-tracker.md` | Weekly | Founder/CEO | Pipeline management |
| `cap-table-guide.md` | As needed | Founder/CEO | Equity planning |

### Product & Engineering
| Document | Update Frequency | Owner | Purpose |
|----------|-----------------|-------|---------|
| `product-overview.md` | Monthly | Product Co-founder | Product vision |
| `engineering-standards.md` | Quarterly | Technical Co-founder | Code quality |
| `tech-stack.md` | As needed | Technical Co-founder | Technology choices |
| `architecture-overview.md` | Quarterly | Technical Co-founder | System design |

### Operations
| Document | Update Frequency | Owner | Purpose |
|----------|-----------------|-------|---------|
| `team-handbook.md` | Monthly | Founder/CEO | Culture and values |
| `security-checklist.md` | Quarterly | Technical Co-founder | Security basics |
| `hiring-guide.md` | Quarterly | Founder/CEO | Hiring priorities |
| `metrics-dashboard.md` | Weekly | Founder/CEO | Key metrics |

## AI Collaboration Model

### Two-Layer Guidance

**1. Inline Instructions** (in documents)
```markdown
<!-- LLM: For start-ups, keep this section under 200 words. Focus on essential information only. -->
```

**2. Role Guides** (in `.claude/role-guides/`)
- How AI should assist each role
- Multi-hat responsibilities
- Common workflows
- When to suggest delegation

### Key Principles for AI

**Keep It Lean:**
- 50% shorter than enterprise documentation
- Essential information only
- Remove formality and governance
- Focus on speed

**Reality-Based:**
- Acknowledge limited resources
- Suggest scrappy solutions
- Guide trade-offs explicitly
- "Perfect is the enemy of done"

**Growth-Aware:**
- "At 3 people, do X. At 10 people, add Y."
- Signal when to formalize
- Suggest graduation to software-org-template
- Recommend hiring priorities

## Information Flow

```
Vision & Mission  →  "Why we exist"
       ↓
Strategy          →  "How we'll achieve product-market fit"
       ↓
OKRs              →  "What we're achieving this quarter"
       ↓
Roadmap           →  "What we're building next 3-6 months"
       ↓
Feature Specs     →  "Specific features and user stories"
       ↓
Code & Tests      →  "Implementation"
```

## When to Graduate

**Move to software-org-template when:**
- 50+ people across multiple teams
- Formal departments and management layers
- Series B+ with established processes
- Need SOC2, compliance, governance
- Multiple products/systems

## Benefits

### For Founders
- **Clarity**: Know what to document and when
- **Fundraising**: Investor-ready materials and updates
- **Scaling**: Progressive guidance as you grow
- **AI Partnership**: Rich context for effective AI assistance

### For Early Team
- **Onboarding**: Quick ramp-up on company direction
- **Alignment**: Shared understanding of goals and strategy
- **Autonomy**: Clear enough to make decisions independently
- **Multi-Hat Guidance**: Know what responsibilities you own

### For AI Assistants
- **Context**: Understand start-up stage and constraints
- **Role Awareness**: Recognize multi-hat responsibilities
- **Tone**: Match informal, fast-paced start-up culture
- **Guidance**: Help founders know when to formalize

## Customization

This template provides structure, but customize it:
- **Add your data**: Replace placeholders with your company info
- **Adapt as needed**: Remove sections that don't apply
- **Keep it lean**: Resist over-documentation
- **Evolve with growth**: Add complexity only when necessary

## Learning Resources

**Essential Reading Order:**
1. This README (you are here)
2. `FRAMEWORK-SUMMARY.md` (quick reference)
3. `CLAUDE.md` (AI context)
4. `.claude/role-guides/[your-role]-guide.md` (your role)
5. Documents relevant to your current work

## Contributing

When populating this template:
1. Keep documents lean (50% shorter than enterprise versions)
2. Use informal, practical tone
3. Add real examples from your start-up
4. Include inline LLM instructions for AI assistance
5. Test that AI can effectively use the documentation

## License

This template is designed to be freely used and customized for your start-up. No attribution required.

## AI Compatibility

This framework works with:
- Claude Code (Anthropic)
- GitHub Copilot
- Cursor
- Any LLM that can read context and follow instructions

---

**Questions?** See `FRAMEWORK-SUMMARY.md` for a quick reference guide.

**Created:** 2024
**Framework Version:** 1.0 (Start-Up Edition)
**Based on:** [software-org-template](../software-org-template)
