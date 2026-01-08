# Frontend Engineer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Build and maintain frontend user interfaces
**Organizational Level:** Project
**Key Documents Created:** Frontend code, component documentation, E2E tests
**Key Documents Consumed:** PRDs, technical designs, UI specifications, engineering standards

## Deterministic Behaviors

### When Writing Frontend Code

**AI MUST:**
- Follow engineering standards from `/engineering-standards.md`
- Implement designs according to UI specifications
- Include unit tests for components (80%+ coverage)
- Use design system components (not custom implementations)
- Ensure accessibility (WCAG AA: keyboard nav, ARIA labels, contrast)
- Handle all UI states (loading, error, empty, success)
- Never hardcode API URLs, secrets, or configuration

**Validation Checklist:**
- [ ] Code follows engineering standards (linting passes)
- [ ] Component tests included (Jest/React Testing Library)
- [ ] E2E tests for critical user flows (Cypress/Playwright)
- [ ] Accessibility: keyboard navigation, screen reader support, ARIA
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] Loading states during async operations
- [ ] Error handling with user-friendly messages
- [ ] Empty states when no data
- [ ] Performance: lazy loading, code splitting, optimized images

### When Implementing UI Designs

**AI MUST:**
- Match design specifications (spacing, colors, typography)
- Implement all interactive states (hover, active, disabled, focus)
- Ensure responsive behavior matches design breakpoints
- Validate accessibility requirements are met
- Handle edge cases (long text, missing data, large datasets)

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest performance optimizations (lazy loading, memoization)
- Recommend accessibility improvements
- Flag when designs deviate from design system
- Propose better error handling
- Identify code duplication (create reusable components)
- Highlight potential UX issues
- Suggest improved test coverage

### Frontend Development Support

**AI CAN help with:**
- Component implementation
- Test writing (unit, integration, E2E)
- Accessibility fixes
- Performance optimization
- Debugging frontend issues
- API integration code
- Responsive design implementation
- Documentation

**AI CANNOT:**
- Skip accessibility requirements
- Ignore design specifications
- Commit code without tests
- Deploy without code review approval

## Common Workflows

### Workflow 1: Implement New Feature from PRD

```
1. Frontend Engineer: "Implement search feature from PRD-123"
2. AI: Read PRD and UI specs
3. AI: Generate component structure:
   - SearchBar component
   - SearchResults component
   - SearchFilters component
4. AI: Implement with:
   - All UI states (empty, loading, results, error, no results)
   - Accessibility (keyboard nav, ARIA labels, focus management)
   - Responsive design
   - API integration
5. AI: Generate tests:
   - Unit tests for components
   - E2E test for search flow
6. Frontend Engineer: Reviews, refines, submits PR
```

### Workflow 2: Debug Performance Issue

```
1. Frontend Engineer: "Page load is slow (5 seconds), optimize"
2. AI: Analyze bundle size and render performance
3. AI: Identify issues:
   - Large bundle (2MB) - not code-split
   - Heavy component re-renders
   - Images not optimized
   - No lazy loading
4. AI: Propose fixes:
   - Code splitting by route
   - Memoize expensive computations (useMemo, React.memo)
   - Optimize images (WebP, lazy load)
   - Virtual scrolling for long lists
5. AI: Estimate impact: 5s → 1.5s load time
6. Frontend Engineer: Implements optimizations
```

### Workflow 3: Accessibility Remediation

```
1. Frontend Engineer: "Fix accessibility issues in dashboard"
2. AI: Run accessibility audit
3. AI: Identify issues:
   - Missing ARIA labels on interactive elements
   - Keyboard focus not visible
   - Color contrast too low
   - Images missing alt text
4. AI: Generate fixes:
   - Add aria-label to icon buttons
   - Add focus-visible styles
   - Update colors for 4.5:1 contrast
   - Add descriptive alt text
5. Frontend Engineer: Reviews and applies fixes
```

## Cross-Role Collaboration

### With UI Designers
- **Frontend Engineer Creates → UI Designers Consume:** Implementation feedback, technical constraints
- **Frontend Engineer Consumes ← UI Designers Create:** UI specifications, design assets
- **AI should facilitate:** Ensuring implementation matches design intent

### With Backend Engineers
- **Frontend Engineer Creates → Backend Engineers Consume:** API requirements (endpoints, data shape)
- **Frontend Engineer Consumes ← Backend Engineers Create:** API documentation, endpoints
- **AI should facilitate:** API integration, contract alignment

### With QA Engineers/SDETs
- **Frontend Engineer Creates → QA Consumes:** Features to test, test IDs for automation
- **Frontend Engineer Consumes ← QA Creates:** Bug reports, test results
- **AI should facilitate:** Making code testable, adding test IDs

## Document References

### Documents Frontend Engineer Creates
- `project-*/src/` (code)
- `project-*/docs/component-documentation.md`
- `project-*/tests/` (tests)

### Documents Frontend Engineer References
- `/engineering-standards.md`
- `/quality-standards.md`
- `product-*/docs/product-requirements-documents/*.md`
- `project-*/docs/technical-design-document.md`
- UI design specs (typically Figma)

### Templates Frontend Engineer Uses
- Component template (if exists in project)

## Common Pitfalls

### Pitfall 1: Missing Accessibility
**Bad:** No keyboard navigation, missing ARIA labels, poor contrast
**Good:** WCAG AA compliant, keyboard accessible, screen reader friendly
**AI should flag:** "Button missing aria-label. Add descriptive label for screen readers."

### Pitfall 2: Not Handling Loading/Error States
**Bad:** Only implementing happy path UI
**Good:** All states: loading spinner, error messages, empty states
**AI should flag:** "API call has no loading state. Show spinner while data loads."

### Pitfall 3: Hardcoded Values
**Bad:** Hardcoded API URLs, colors, spacing
**Good:** Use environment variables, design tokens, constants
**AI should flag:** "API URL hardcoded. Use environment variable: process.env.REACT_APP_API_URL"

### Pitfall 4: Performance Anti-patterns
**Bad:** No memoization, inline function definitions in render, large bundles
**Good:** Memoization, code splitting, optimized images
**AI should flag:** "Component re-renders on every parent render. Wrap with React.memo()."

## Example Interactions

### Example 1: Component Implementation

**Frontend Engineer:** "Implement a data table component with sorting and pagination."

**AI Response:**
```javascript
// DataTable.tsx
import React, { useState, useMemo } from 'react';

interface Column<T> {
  key: keyof T;
  header: string;
  sortable?: boolean;
}

interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  pageSize?: number;
}

export function DataTable<T>({ data, columns, pageSize = 10 }: DataTableProps<T>) {
  const [sortColumn, setSortColumn] = useState<keyof T | null>(null);
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('asc');
  const [currentPage, setCurrentPage] = useState(1);

  // Sort data
  const sortedData = useMemo(() => {
    if (!sortColumn) return data;

    return [...data].sort((a, b) => {
      const aVal = a[sortColumn];
      const bVal = b[sortColumn];

      if (aVal < bVal) return sortDirection === 'asc' ? -1 : 1;
      if (aVal > bVal) return sortDirection === 'asc' ? 1 : -1;
      return 0;
    });
  }, [data, sortColumn, sortDirection]);

  // Paginate data
  const paginatedData = useMemo(() => {
    const start = (currentPage - 1) * pageSize;
    return sortedData.slice(start, start + pageSize);
  }, [sortedData, currentPage, pageSize]);

  const totalPages = Math.ceil(data.length / pageSize);

  const handleSort = (column: keyof T) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortColumn(column);
      setSortDirection('asc');
    }
  };

  return (
    <div role="region" aria-label="Data table">
      <table>
        <thead>
          <tr>
            {columns.map((col) => (
              <th key={String(col.key)}>
                {col.sortable ? (
                  <button
                    onClick={() => handleSort(col.key)}
                    aria-label={`Sort by ${col.header}`}
                    aria-sort={sortColumn === col.key ? sortDirection : 'none'}
                  >
                    {col.header}
                    {sortColumn === col.key && (
                      <span aria-hidden="true">
                        {sortDirection === 'asc' ? ' ↑' : ' ↓'}
                      </span>
                    )}
                  </button>
                ) : (
                  col.header
                )}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {paginatedData.length === 0 ? (
            <tr>
              <td colSpan={columns.length}>No data available</td>
            </tr>
          ) : (
            paginatedData.map((row, rowIndex) => (
              <tr key={rowIndex}>
                {columns.map((col) => (
                  <td key={String(col.key)}>{String(row[col.key])}</td>
                ))}
              </tr>
            ))
          )}
        </tbody>
      </table>

      {totalPages > 1 && (
        <nav aria-label="Table pagination">
          <button
            onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
            disabled={currentPage === 1}
            aria-label="Previous page"
          >
            Previous
          </button>
          <span aria-live="polite">
            Page {currentPage} of {totalPages}
          </span>
          <button
            onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
            disabled={currentPage === totalPages}
            aria-label="Next page"
          >
            Next
          </button>
        </nav>
      )}
    </div>
  );
}
```

**Accessibility features included:**
- ✅ Semantic HTML (table, thead, tbody)
- ✅ ARIA labels on interactive elements
- ✅ aria-sort for sorted column
- ✅ Keyboard accessible (buttons, not divs)
- ✅ Empty state handling
- ✅ Screen reader friendly pagination

**Should I also create the tests for this component?**
```

## Success Metrics for AI Collaboration

- Code follows engineering standards (linting passes 100%)
- Test coverage meets standards (80%+)
- Accessibility issues caught before production (0 WCAG violations)
- UI matches design specifications
- Performance budgets met (page load < 3s, bundle < 300KB gzipped)
- Code reviews have minimal feedback (well-implemented first time)

---

**Last Updated:** 2024-03-20
**Guide Owner:** Engineering Team
