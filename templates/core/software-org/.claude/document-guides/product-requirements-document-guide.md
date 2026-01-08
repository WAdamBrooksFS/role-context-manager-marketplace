# Product Requirements Document (PRD) - Workflow Guide

## Purpose
This guide helps AI assist with creating, reviewing, and maintaining PRDs.

## When to Create a PRD
- Before building any new feature
- When requirements are unclear or complex
- When multiple teams are involved
- Before significant engineering investment

## PRD Workflow

### Step 1: Gather Information
**AI should ask:**
- What problem are we solving?
- Who has this problem? (User persona)
- What's the success metric?
- Which company OKR does this support?
- What alternatives were considered?

### Step 2: Draft PRD
**AI should:**
1. Copy template from `/docs/templates/product-requirements-document-template.md`
2. Fill in sections based on gathered information
3. Leave `[TODO]` markers for PM input
4. Ensure all required sections present

### Step 3: Validation
**AI MUST validate:**
- [ ] Problem statement clear and customer-validated
- [ ] Success metrics are measurable (not subjective)
- [ ] Acceptance criteria are testable
- [ ] Links to OKR/strategy
- [ ] "Out of Scope" section filled
- [ ] At least one alternative considered

### Step 4: Review Process
**AI should suggest reviewers:**
- Engineering Lead (technical feasibility)
- Designer (if UI/UX work)
- QA Lead (testability)
- Security (if handling sensitive data)

## Common Issues

**Issue:** Vague acceptance criteria
**Fix:** Make specific and testable
Bad: "Dashboard is user-friendly"
Good: "Dashboard loads in <2s, users can complete task in <60s"

**Issue:** Missing "why"
**Fix:** Add business justification
- How many customers requested?
- What's the cost of not solving?
- What's the revenue opportunity?

**Issue:** Scope creep
**Fix:** Move nice-to-haves to V2, focus V1 on core value

## Cross-References
- Template: `/docs/templates/product-requirements-document-template.md`
- Role Guide: `/.claude/role-guides/product-manager-guide.md`
- Related: Technical Design Document (engineers create from PRD)

---

<!-- LLM: Help PMs create complete, clear PRDs. Enforce validation rules. Suggest improvements proactively. -->
