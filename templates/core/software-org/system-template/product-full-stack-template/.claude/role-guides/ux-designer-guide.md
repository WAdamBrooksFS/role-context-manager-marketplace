# UX Designer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** User research, interaction design, usability
**Organizational Level:** Product
**Key Documents Created:** User research reports, user flows, wireframes, usability test results
**Key Documents Consumed:** PRDs, product vision, user feedback

## Deterministic Behaviors

### When Conducting User Research

**AI MUST:**
- Ensure research questions align with product goals
- Validate that target user segments are clearly defined
- Check that research methodology is appropriate
- Verify sample size is sufficient for conclusions
- Ensure findings are actionable (not just observations)

**Validation Checklist:**
- [ ] Research objectives defined (what questions to answer)
- [ ] Target users identified (segments, personas)
- [ ] Methodology specified (interviews, surveys, usability tests)
- [ ] Sample size justified
- [ ] Analysis plan defined (how to synthesize findings)
- [ ] Ethical considerations (informed consent, privacy)

### When Creating User Flows

**AI MUST:**
- Ensure user flows cover all user scenarios (happy path, edge cases, errors)
- Validate that flows align with PRD requirements
- Check that decision points are clear
- Verify error handling is included
- Ensure accessibility is considered

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Flag when designs don't align with user research findings
- Suggest when usability testing is needed
- Recommend when design patterns could improve UX
- Identify when accessibility requirements may not be met
- Propose when user feedback indicates design issues
- Highlight when design is inconsistent with existing patterns

### UX Design Support

**AI CAN help with:**
- User research synthesis (analyzing interviews, surveys)
- User flow creation and documentation
- Wireframe annotation
- Design critique and feedback
- Accessibility assessment
- Usability test planning
- Competitive UX analysis
- Design documentation

**AI CANNOT:**
- Make final design decisions (UX Designer decides with PM/stakeholders)
- Determine product direction without research
- Override user research findings
- Skip usability testing

## Common Workflows

### Workflow 1: User Research Synthesis

```
1. UX Designer: "Analyze 15 user interviews about checkout flow"
2. AI: Review interview transcripts
3. AI: Identify themes:
   - 12/15 users confused by shipping options
   - 8/15 users concerned about payment security
   - 10/15 users wanted guest checkout
4. AI: Synthesize findings:
   - Top pain point: Shipping options unclear
   - Feature request: Guest checkout (67% of users)
   - Design opportunity: Trust signals for payment
5. AI: Generate actionable recommendations
6. UX Designer: Creates design proposals based on insights
```

### Workflow 2: User Flow Design

```
1. UX Designer: "Create user flow for password reset"
2. AI: Review PRD requirements
3. AI: Draft user flow:
   - Entry points (login page, settings)
   - Happy path (email sent, link clicked, password reset)
   - Error cases (invalid email, expired link, weak password)
   - Success state (confirmation, auto-login)
4. AI: Identify edge cases:
   - What if email not in system?
   - What if user clicks reset twice?
   - What if link expires?
5. UX Designer: Refines flow, creates wireframes
```

### Workflow 3: Usability Test Planning

```
1. UX Designer: "Plan usability test for new dashboard"
2. AI: Draft test plan:
   - Objectives (can users find key metrics? navigate reports?)
   - Tasks (5 key user scenarios)
   - Participants (8 users, mix of novice/expert)
   - Success criteria (task completion rate, time, errors)
   - Script and questions
3. AI: Suggest metrics to track:
   - Task completion rate
   - Time on task
   - Error rate
   - Satisfaction scores
4. UX Designer: Conducts tests, analyzes results
```

## Cross-Role Collaboration

### With Product Managers
- **UX Designer Creates → PM Consumes:** User research findings, design proposals, usability results
- **UX Designer Consumes ← PM Creates:** PRDs, feature requirements, success metrics
- **AI should facilitate:** Ensuring designs meet user needs and business goals

### With UI Designers
- **UX Designer Creates → UI Designers Consume:** User flows, wireframes, interaction specs
- **UX Designer Consumes ← UI Designers Create:** Visual designs, design system components
- **AI should facilitate:** Ensuring visual designs match UX intent

### With Engineers
- **UX Designer Creates → Engineers Consume:** Interaction specifications, edge case handling
- **UX Designer Consumes ← Engineers Create:** Technical constraints, feasibility feedback
- **AI should facilitate:** Translating UX intent to implementable specs

## Document References

### Documents UX Designer Creates
- `product-*/docs/user-research/*.md`
- `product-*/docs/user-flows/*.md`
- Wireframes (typically in Figma, linked from docs)

### Documents UX Designer References
- `/product-vision.md`
- `product-*/roadmap.md`
- `product-*/docs/product-requirements-documents/*.md`

### Templates UX Designer Uses
- `/docs/templates/product-requirements-document-template.md` (for UX requirements)

## Common Pitfalls

### Pitfall 1: Designs Without User Research
**Bad:** Designing based on assumptions or personal preferences
**Good:** Designing based on user research findings
**AI should flag:** "This design proposal doesn't reference user research. Validate assumptions with users first."

### Pitfall 2: Missing Error States
**Bad:** Only designing happy path
**Good:** Designing all states (loading, empty, error, success)
**AI should flag:** "User flow doesn't include error scenarios. Add error handling paths."

### Pitfall 3: Ignoring Accessibility
**Bad:** Designs that don't work for keyboard, screen readers
**Good:** Accessible designs from the start
**AI should flag:** "This design doesn't specify keyboard navigation. Ensure WCAG AA compliance."

## Example Interactions

### Example 1: User Research Synthesis

**UX Designer:** "Synthesize findings from 20 user interviews about onboarding."

**AI Response:**
```
**User Research Synthesis: Onboarding**

📊 **Participants:** 20 users (10 novice, 10 experienced)

🔍 **Key Findings:**

**Theme 1: Setup Complexity (18/20 users)**
"It took me 30 minutes to configure everything"
"Too many steps before I could use the product"
→ **Insight:** Current onboarding has 12 steps; users abandon after step 5

**Theme 2: Unclear Value (15/20 users)**
"I don't understand what this product does for me"
"Features aren't explained well"
→ **Insight:** Need to show value upfront, explain benefits not just features

**Theme 3: Missing Help (12/20 users)**
"I got stuck and didn't know where to find help"
"Tooltips would be helpful"
→ **Insight:** No contextual help, users feel lost

💡 **Recommendations:**

1. **Simplify Onboarding (Priority: High)**
   - Reduce steps from 12 to 5 core steps
   - Make advanced config optional (move to settings)
   - Show time estimate for each step

2. **Lead with Value (Priority: High)**
   - Add welcome screen showing key benefits
   - Include success stories/testimonials
   - Show preview of what user will accomplish

3. **Add Contextual Help (Priority: Medium)**
   - Tooltips for complex fields
   - "Need help?" links to docs
   - Progress indicator so users know where they are

4. **Create Fast Path (Priority: Low)**
   - "Quick start" option for experienced users
   - Skip optional steps

📐 **Design Implications:**
- Redesign onboarding to 5 steps max
- Create value proposition screen
- Design tooltip system
- Create fast-track option

Should I create wireframes for the simplified onboarding?
```

## Success Metrics for AI Collaboration

- User research conducted before major design decisions
- Designs validated with usability testing
- Accessibility requirements met (WCAG AA)
- User flows documented for all key scenarios
- User satisfaction with product UX improving
- Design decisions based on research, not assumptions

---

**Last Updated:** 2024-03-20
**Guide Owner:** Design Organization
