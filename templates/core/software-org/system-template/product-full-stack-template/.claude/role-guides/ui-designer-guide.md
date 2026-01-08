# UI Designer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Visual design, design system, high-fidelity mockups
**Organizational Level:** Product
**Key Documents Created:** Design specifications, design system documentation, visual mockups
**Key Documents Consumed:** Wireframes, brand guidelines, user research, PRDs

## Deterministic Behaviors

### When Creating Design Specifications

**AI MUST:**
- Ensure all UI states are documented (default, hover, active, disabled, loading, error)
- Validate that spacing follows design system standards
- Check that color usage meets accessibility contrast requirements (WCAG AA)
- Verify typography choices align with design system
- Ensure responsive behavior is specified
- Check that animations/transitions are documented

**Validation Checklist:**
- [ ] All component states documented
- [ ] Spacing uses design tokens (8px grid, standard margins)
- [ ] Color contrast ratios meet WCAG AA (4.5:1 for text, 3:1 for UI)
- [ ] Typography from design system
- [ ] Responsive breakpoints specified (mobile, tablet, desktop)
- [ ] Interactive elements have clear affordances
- [ ] Animations/transitions specified (duration, easing)
- [ ] Accessibility annotations (ARIA labels, keyboard focus)

### When Updating Design System

**AI MUST:**
- Ensure changes are backward compatible or migration plan exists
- Validate that new components follow existing patterns
- Check that documentation is complete
- Verify code examples are provided
- Ensure accessibility requirements are met

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Flag when designs don't follow design system
- Suggest when accessibility requirements aren't met
- Recommend when visual hierarchy could be improved
- Identify when brand consistency is missing
- Propose when design patterns could be reused
- Highlight when responsive behavior isn't specified

### UI Design Support

**AI CAN help with:**
- Design specification generation
- Accessibility assessment (contrast checks, ARIA labels)
- Design system documentation
- Component documentation with code examples
- Responsive design recommendations
- Design critique and feedback
- Visual consistency checking across designs

**AI CANNOT:**
- Make subjective design decisions (colors, layouts)
- Override brand guidelines
- Approve designs without designer review
- Skip accessibility requirements

## Common Workflows

### Workflow 1: Design Specification from Mockup

```
1. UI Designer: "Create design specs for this button component"
2. AI: Analyze design:
   - Colors (background, text, border)
   - Typography (font, size, weight, line-height)
   - Spacing (padding, margins)
   - Border (radius, width)
3. AI: Generate spec for all states:
   - Default
   - Hover (background 10% darker)
   - Active (background 20% darker)
   - Disabled (opacity 50%)
   - Focus (outline for keyboard navigation)
4. AI: Check accessibility:
   - Contrast ratios for each state
   - Focus indicator visible
   - Min touch target 44x44px (mobile)
5. UI Designer: Reviews, adjusts if needed
```

### Workflow 2: Accessibility Review

```
1. UI Designer: "Check accessibility of this form design"
2. AI: Review design:
   - Color contrast (all text readable?)
   - Form labels (clear and descriptive?)
   - Error messages (clear and helpful?)
   - Keyboard navigation (logical tab order?)
   - Touch targets (large enough for mobile?)
3. AI: Identify issues:
   - ⚠️ "Success" green text on white: 2.8:1 contrast (needs 4.5:1)
   - ⚠️ Form error messages use color only (need icons too)
   - ⚠️ Placeholder text as label (accessibility issue)
4. AI: Provide fixes:
   - Use darker green (#008800) for 4.5:1 contrast
   - Add error icon with text
   - Add proper <label> elements above fields
5. UI Designer: Updates design
```

### Workflow 3: Design System Documentation

```
1. UI Designer: "Document the new card component for design system"
2. AI: Generate documentation:
   - Component description and usage
   - Anatomy (visual breakdown of parts)
   - Variants (default, elevated, outlined)
   - States (default, hover, active)
   - Spacing and sizing
   - Accessibility considerations
   - Code examples (HTML/CSS, React)
   - Do's and don'ts
3. UI Designer: Reviews, adds design examples
```

## Cross-Role Collaboration

### With UX Designers
- **UI Designer Creates → UX Designers Consume:** Visual design constraints, component library
- **UI Designer Consumes ← UX Designers Create:** Wireframes, user flows, interaction specs
- **AI should facilitate:** Ensuring visual designs match UX intent

### With Frontend Engineers
- **UI Designer Creates → Engineers Consume:** Design specs, design tokens, visual mockups
- **UI Designer Consumes ← Engineers Create:** Implementation questions, technical constraints
- **AI should facilitate:** Translating designs to implementation-ready specs

### With Product Managers
- **UI Designer Creates → PMs Consume:** Design proposals, prototypes
- **UI Designer Consumes ← PMs Create:** Product requirements, brand goals
- **AI should facilitate:** Ensuring designs meet product goals

## Document References

### Documents UI Designer Creates
- `product-*/docs/design-specifications/*.md`
- `product-*/docs/design-system/*.md`
- Visual designs (typically in Figma, linked from docs)

### Documents UI Designer References
- Brand guidelines (typically external)
- `/product-vision.md` (for brand alignment)
- `product-*/docs/user-research/*.md` (for design context)

### Templates UI Designer Uses
- Design system component template (if exists)

## Common Pitfalls

### Pitfall 1: Missing Interactive States
**Bad:** Only designing default state of components
**Good:** Designing all states (hover, active, disabled, loading, error, success, empty)
**AI should flag:** "Button design only shows default state. Add hover, active, focus, and disabled states."

### Pitfall 2: Accessibility Not Considered
**Bad:** Low contrast text, unclear interactive elements
**Good:** WCAG AA compliant contrast, clear affordances, keyboard accessible
**AI should flag:** "This text has 2.5:1 contrast (needs 4.5:1 for WCAG AA). Use darker color."

### Pitfall 3: Inconsistent with Design System
**Bad:** Creating new button styles instead of using design system
**Good:** Using existing components or proposing additions to design system
**AI should flag:** "This button design doesn't match design system. Use primary-button component or propose design system update."

### Pitfall 4: No Responsive Specifications
**Bad:** Only designing desktop, assuming mobile "will figure it out"
**Good:** Specifying responsive behavior at all breakpoints
**AI should flag:** "Design only shows desktop (1440px). Specify mobile (375px) and tablet (768px) layouts."

## Example Interactions

### Example 1: Design Specification Generation

**UI Designer:** "Generate design specs for this input field component."

**AI Response:**
```
**Design Specification: Input Field Component**

📐 **Anatomy:**
- Container (outer wrapper)
- Label (above input)
- Input field (text entry)
- Helper text (below input)
- Error message (replaces helper text on error)
- Icon (optional, left or right)

🎨 **Visual Properties:**

**Default State:**
- Label: Gray-700, 14px, Medium weight, 20px line height
- Input: White background, Gray-300 border (1px), Gray-900 text
- Height: 44px (meets touch target requirements)
- Padding: 12px horizontal, 10px vertical
- Border radius: 4px
- Helper text: Gray-600, 12px, Regular

**Hover State:**
- Border: Gray-400 (darker on hover)
- Background: White (no change)

**Focus State:**
- Border: Blue-500 (2px)
- Outline: Blue-200 (4px, 0px offset) for keyboard focus
- Remove outline on mouse click (only show for keyboard)

**Error State:**
- Border: Red-500 (1px)
- Background: Red-50 (light red tint)
- Error message: Red-700, 12px, replaces helper text
- Error icon: Red-500, 16px, left of message

**Disabled State:**
- Background: Gray-100
- Border: Gray-200
- Text: Gray-500
- Cursor: not-allowed

**Filled State:**
- Border: Gray-400
- Text: Gray-900 (user input)

📱 **Responsive:**
- Mobile (< 768px): Full width, 44px height (touch-friendly)
- Tablet/Desktop: Min width 280px, max width 400px

♿ **Accessibility:**
- Label associated with input (<label for="input-id">)
- ARIA attributes: aria-invalid="true" on error
- Contrast ratios:
  - Label text: 7.2:1 ✅
  - Input text: 14.5:1 ✅
  - Helper text: 4.8:1 ✅
  - Error text: 8.1:1 ✅
- Keyboard navigable (Tab to focus, Escape to clear)
- Min touch target: 44x44px ✅

💾 **Design Tokens:**
```css
--input-height: 44px;
--input-padding-x: 12px;
--input-padding-y: 10px;
--input-border-radius: 4px;
--input-border-width: 1px;
--input-border-color: var(--gray-300);
--input-border-color-hover: var(--gray-400);
--input-border-color-focus: var(--blue-500);
--input-border-color-error: var(--red-500);
```

Should I generate the React component code for engineers?
```

### Example 2: Accessibility Check

**UI Designer:** "Check accessibility of this dashboard design."

**AI Response:**
```
**Accessibility Assessment: Dashboard Design**

✅ **Passes:**
- Heading hierarchy correct (h1 → h2 → h3)
- All images have alt text
- Buttons large enough for touch (48x48px)
- Keyboard navigation logical (left to right, top to bottom)

⚠️ **Issues Found:**

**CRITICAL (Must Fix):**

1. **Low Contrast: Chart Labels**
   - Current: Gray-400 text on white (2.7:1 contrast)
   - Required: 4.5:1 for WCAG AA
   - Fix: Use Gray-700 (4.8:1 contrast) ✅

2. **Color-Only Information: Status Indicators**
   - Red/Yellow/Green dots with no text/icon
   - Color-blind users can't distinguish
   - Fix: Add icon + text label (e.g., ✓ Active, ⚠ Warning, ✗ Error)

3. **Missing Focus Indicators: Interactive Charts**
   - Charts are interactive but no focus outline
   - Keyboard users can't see where they are
   - Fix: Add visible focus outline (2px solid blue)

**HIGH (Should Fix):**

4. **Small Touch Targets: Filter Buttons**
   - Current: 32x32px (too small for mobile)
   - Required: 44x44px minimum
   - Fix: Increase to 44x44px or add more padding

5. **No Skip Link**
   - Users must tab through entire nav to reach content
   - Fix: Add "Skip to main content" link at top

6. **Ambiguous Link Text**
   - "Click here" and "Learn more" (not descriptive)
   - Fix: "View sales report" or "Learn more about Q2 goals"

**MEDIUM (Nice to have):**

7. **No Reduced Motion Support**
   - Animations may trigger vestibular disorders
   - Fix: Add prefers-reduced-motion media query

📋 **Remediation Checklist:**
- [ ] Fix low contrast (use Gray-700)
- [ ] Add icons to status indicators
- [ ] Add focus indicators to charts
- [ ] Increase touch targets to 44px
- [ ] Add skip link
- [ ] Improve link text
- [ ] Support reduced motion

Should I create a revised design with these fixes?
```

## Success Metrics for AI Collaboration

- All designs meet accessibility requirements (WCAG AA)
- Design specifications complete before engineering starts
- Design system maintained and up-to-date
- Visual consistency across all product screens
- No accessibility issues in production
- Engineers can implement without design clarifications

---

**Last Updated:** 2024-03-20
**Guide Owner:** Design Organization
