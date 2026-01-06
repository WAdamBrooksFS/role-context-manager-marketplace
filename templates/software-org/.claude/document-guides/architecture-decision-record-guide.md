# Architecture Decision Record (ADR) - Workflow Guide

## Purpose
ADRs document significant architectural decisions for future reference.

## Approval Requirements

**System-Level ADRs** (`system-template/docs/architecture-decision-records/`)
**Must be approved by:**
- Cloud Architect / Staff Engineer
- Engineering Manager
- CTO/VP Engineering (for major decisions)

**Project-Level ADRs** (`project-*/docs/architecture-decision-records/`)
**Must be approved by:**
- Tech Lead / Senior Engineer
- Engineering Manager
- Architect (for decisions with system-wide impact)

**When Security Review Required:**
- Any decision affecting data security
- Authentication/authorization changes
- Encryption/cryptography decisions
→ **Must include:** CISO or Security Engineer approval

---

## When to Create an ADR
- Choosing technologies (databases, frameworks, languages)
- Significant architectural patterns (microservices vs monolith)
- Security/privacy decisions
- Any decision that's hard to reverse
- Any decision future engineers will question "why did they do it this way?"

## ADR Workflow

### Step 1: Context
**Document:**
- What situation/problem led to this decision?
- What forces/constraints exist?
- What's the current state?
- Who was involved in the decision?

### Step 2: Decision
**State clearly:** "We will [decision]"
- Use present tense (decision is now in effect)
- Be specific and unambiguous
- Date the decision

### Step 3: Alternatives
**For each alternative (minimum 2):**
- Description of alternative
- Pros (advantages)
- Cons (disadvantages)
- Why not chosen (explicit reasoning)

### Step 4: Consequences
**Document honestly:**
- **Positive consequences:** What improves
- **Negative consequences:** What trade-offs we're accepting
- **Neutral consequences:** Other changes needed

### Step 5: Rationale
**Explain why:**
- Technical reasons
- Business reasons
- Team/organizational reasons
- Timeline/resource constraints

## Key Rules

**AI MUST enforce:**
- [ ] ADRs are immutable after approval (never edit - create new ADR to supersede)
- [ ] If decision changes, new ADR references this one ("Supersedes ADR-023")
- [ ] Always document at least 2 alternatives considered
- [ ] Focus on "why" not just "what"
- [ ] Include consequences (both positive and negative)
- [ ] Proper approvals obtained before marking "Accepted"

## ADR Status Lifecycle

1. **Proposed** - Initial draft, under discussion
2. **Accepted** - Decision approved and implemented
3. **Deprecated** - No longer recommended but still in use
4. **Superseded** - Replaced by newer ADR (link to new one)

## Common Patterns

**Good ADR:**
- Clear context (problem statement)
- Explicit decision statement
- Multiple alternatives evaluated
- Honest about trade-offs (pros AND cons)
- Explains "why" thoroughly

**Bad ADR:**
- No alternatives considered ("we had no choice")
- Doesn't explain "why"
- Only lists pros, ignores cons
- Vague decision statement
- No consideration of consequences

## Examples

**Good Example:**
"We will use PostgreSQL as our primary database instead of MongoDB because our data is highly relational, we need ACID guarantees for financial transactions, and the team has deep PostgreSQL expertise. This means we sacrifice MongoDB's flexible schema, but we gain data integrity which is more important for our use case."

**Bad Example:**
"We will use PostgreSQL because it's better." (No alternatives, no reasoning, no consequences)

---

<!-- LLM: ADRs are historical records preserving decision context. Help engineers document "why" thoroughly. ADRs should never be edited after acceptance - create new ADR to supersede. -->
