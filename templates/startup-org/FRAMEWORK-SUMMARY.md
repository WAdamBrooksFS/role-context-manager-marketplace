# Start-Up Software Organization Framework - Quick Reference

## At a Glance

**Purpose**: Lean organizational template for pre-seed to seed stage start-ups (0-10 people)

**Key Features**:
- Flat structure (no complex hierarchy)
- Founder and multi-hat role focus
- Fundraising documentation
- 50% shorter than enterprise templates
- AI collaboration built-in

## Who This is For

**Perfect fit:**
- 0-10 person start-up
- Pre-seed to Seed stage
- Searching for product-market fit
- Fundraising or preparing to
- Founders wearing multiple hats

**Not right for you:**
- 50+ people → Use [software-org-template](../software-org-template)
- Series B+ → Use software-org-template
- Established processes → Use software-org-template

## Directory Structure

```
strategic/         Vision, OKRs, strategy, roadmap
fundraising/       Pitch deck, investor updates, cap table
product/           Overview, feature specs, user research
engineering/       Standards, tech stack, architecture
operations/        Security, handbook, hiring, metrics
docs/templates/    Reusable templates
.claude/           AI role guides
```

## Core Documents (by Priority)

### Must Have (Week 1)
1. `strategic/vision-and-mission.md` - Why you exist
2. `strategic/objectives-and-key-results.md` - 2-3 quarterly goals
3. `strategic/roadmap.md` - Next 3-6 months
4. `product/product-overview.md` - What you're building
5. `operations/team-handbook.md` - Culture and values

### Should Have (Week 2-3)
6. `strategic/strategy.md` - How you'll win
7. `fundraising/pitch-deck-guide.md` - Fundraising prep
8. `engineering/tech-stack.md` - Technology choices
9. `engineering/development-setup.md` - Developer onboarding
10. `operations/metrics-dashboard.md` - Key metrics

### Nice to Have (Month 2+)
11. `fundraising/investor-updates-template.md` - Monthly updates
12. `engineering/architecture-overview.md` - System design
13. `operations/hiring-guide.md` - Hiring priorities
14. `product/user-research-notes.md` - Customer insights

## Roles (Multi-Hat Reality)

### Founder Level
- **CEO**: Strategy + Fundraising + Sales + Marketing + Culture
- **Technical Co-founder**: CTO + EM + Engineer + DevOps + Security
- **Product Co-founder**: CPO + PM + Designer + Research + Marketing

### Early Team (3-10)
- **Founding Engineer**: Full-stack + DevOps + Product
- **Engineer**: Frontend or Backend (specialization emerges)
- **First Product Hire**: PM or Designer
- **First Business Hire**: Sales, Marketing, or Ops

### Supporting
- **Advisor**: Part-time strategic guidance
- **Fractional Executive**: Part-time CTO, CFO, CMO

## Document Update Frequency

| Frequency | Documents |
|-----------|-----------|
| **Weekly** | Roadmap, Metrics dashboard, Fundraising tracker |
| **Monthly** | Product overview, Team handbook, Investor updates |
| **Quarterly** | OKRs, Strategy, Engineering standards |
| **Annually** | Vision & mission |
| **As needed** | Pitch deck, Tech stack, Architecture |

## Information Flow

```
Vision & Mission  →  Why we exist
    ↓
Strategy          →  How we'll win (PMF focus)
    ↓
OKRs              →  2-3 quarterly goals
    ↓
Roadmap           →  3-6 month feature plan
    ↓
Feature Specs     →  1-2 page specs
    ↓
Code & Ship       →  Build and iterate
    ↓
Customer Feedback →  Learn and pivot
    ↓
[Loop back based on learnings]
```

## Key Principles

1. **Speed > Perfection** - Ship fast, iterate
2. **Lean Docs** - 50% shorter, essential only
3. **Multi-Hat** - Everyone does multiple jobs
4. **Founder-Centric** - Decisions through founders
5. **Progressive** - Start simple, add complexity as you grow
6. **Reality-Based** - Acknowledge constraints

## AI Collaboration

### For AI Assistants

**Tone**: Informal, practical, direct
**Length**: 50% shorter than enterprise
**Focus**: Speed, iteration, scrappy solutions
**Acknowledge**: Limited resources, multi-hat roles

**Role Guides**: `.claude/role-guides/[role]-guide.md`
- founder-ceo-guide.md
- technical-cofounder-guide.md
- product-cofounder-guide.md
- founding-engineer-guide.md
- early-hire-guide.md
- advisor-guide.md

## Start-Up Stages (Growth Path)

### 0-3 People (Pre-Seed)
- Founders only or +1-2 founding engineers
- Everyone does everything
- Minimal documentation
- Focus: Validate idea, build MVP

### 3-7 People (Seed)
- First key hires (engineer, PM/designer, business)
- Some specialization emerges
- Basic processes (standups, weekly updates)
- Focus: Find product-market fit

### 7-10 People (Seed+)
- Small specialized teams
- More formal processes
- Clear role boundaries
- Focus: Scale what works

### 50+ People (Series B+)
- Graduate to [software-org-template](../software-org-template)
- Formal departments and management
- Established processes
- Focus: Scale operations

## Common Questions

**Q: How is this different from software-org-template?**
A: 50% shorter docs, flat structure, founder-focus, fundraising docs, informal tone, multi-hat roles

**Q: When should I graduate to software-org-template?**
A: At 50+ people, Series B+, or when you need formal processes and compliance

**Q: Do I need all these documents?**
A: No! Start with "Must Have" list (5 docs), add more as you grow

**Q: Can I customize this?**
A: Absolutely! This is a starting point - adapt to your needs

**Q: What if I'm bootstrapped, not fundraising?**
A: Skip the fundraising/ folder or adapt it for profitability tracking

## Quick Start Checklist

**Day 1-7:**
- [ ] Copy this template to your company repo
- [ ] Fill out `strategic/vision-and-mission.md`
- [ ] Set 2-3 OKRs in `strategic/objectives-and-key-results.md`
- [ ] Draft `product/product-overview.md`
- [ ] Create `operations/team-handbook.md`

**Day 8-14:**
- [ ] Complete `strategic/strategy.md`
- [ ] Map out `strategic/roadmap.md` (3-6 months)
- [ ] Document `engineering/tech-stack.md`
- [ ] Set up `engineering/development-setup.md`
- [ ] Define `operations/metrics-dashboard.md`

**Day 15-30:**
- [ ] Prepare `fundraising/pitch-deck-guide.md`
- [ ] Start tracking `fundraising/fundraising-tracker.md`
- [ ] Write first feature specs in `product/feature-specs/`
- [ ] Create `engineering/architecture-overview.md`
- [ ] Establish `operations/hiring-guide.md`

**Ongoing:**
- [ ] Weekly: Update roadmap, metrics, fundraising tracker
- [ ] Monthly: Investor updates, product overview, handbook
- [ ] Quarterly: Review OKRs, strategy, standards

## Templates Available

In `docs/templates/`:
1. **feature-spec-template.md** - 1-2 page feature spec
2. **user-story-template.md** - User story format
3. **technical-spike-template.md** - Research doc
4. **post-mortem-template.md** - Learn from mistakes

## Essential Files Reference

| Purpose | File Path |
|---------|-----------|
| **Start here** | `/README.md` |
| **AI context** | `/CLAUDE.md` |
| **This doc** | `/FRAMEWORK-SUMMARY.md` |
| **Your role** | `/.claude/role-guides/[role]-guide.md` |
| **Vision** | `/strategic/vision-and-mission.md` |
| **Goals** | `/strategic/objectives-and-key-results.md` |
| **Fundraising** | `/fundraising/pitch-deck-guide.md` |
| **Product** | `/product/product-overview.md` |
| **Engineering** | `/engineering/tech-stack.md` |

## Success Metrics

You know this framework is working when:
- ✅ New team members can onboard in < 1 day
- ✅ Founders spend < 2 hours/week on documentation
- ✅ AI can effectively assist across all functions
- ✅ Strategic decisions are documented and shared
- ✅ Investors get clear, consistent updates
- ✅ Team is aligned on vision, strategy, and roadmap

## Anti-Patterns (What NOT to Do)

❌ **Over-document** - More docs don't mean better organization
❌ **Copy enterprise processes** - You're not Google, you're 5 people
❌ **Premature formalization** - Don't add governance at 3 people
❌ **Stale docs** - Better to delete than have outdated info
❌ **Analysis paralysis** - Don't spend weeks planning, start building

## Getting Help

**For Humans:**
- Read this summary
- Check README.md for details
- Review your role guide in `.claude/role-guides/`
- Ask AI for help (it has full context)

**For AI Assistants:**
- Read `/CLAUDE.md` for full context
- Review user's role guide
- Follow inline `<!-- LLM: ... -->` instructions
- Keep responses lean and practical

---

**Framework Version:** 1.0 (Start-Up Edition)
**Last Updated:** 2024
**Based on:** [software-org-template](../software-org-template)

**Remember**: Keep it lean, ship fast, iterate based on reality. Perfect is the enemy of done.
