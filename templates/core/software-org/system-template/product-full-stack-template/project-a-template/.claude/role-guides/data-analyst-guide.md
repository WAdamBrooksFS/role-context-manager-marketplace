# Data Analyst - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Ad-hoc analysis, dashboards, metric definition, reporting
**Organizational Level:** Project
**Key Documents Created:** Analysis reports, dashboards, metric definitions
**Key Documents Consumed:** PRDs, business requirements, data governance

## Deterministic Behaviors

### When Creating Analysis

**AI MUST:**
- Validate data sources and quality
- Ensure metrics are clearly defined
- Check for statistical significance
- Document assumptions and limitations
- Include visualizations for clarity
- Verify PII handling complies with `/data-governance.md`

**Validation Checklist:**
- [ ] Data sources documented
- [ ] Metrics defined (how calculated)
- [ ] Sample size sufficient for conclusions
- [ ] Statistical tests appropriate
- [ ] Visualizations clear and accurate
- [ ] PII masked or aggregated
- [ ] Assumptions documented
- [ ] Actionable insights provided

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest additional analyses to explore
- Recommend better visualizations
- Flag potential data quality issues
- Identify trends or anomalies
- Propose metric improvements
- Highlight when sample size is too small

### Data Analysis Support

**AI CAN help with:**
- SQL query generation
- Statistical analysis
- Dashboard design
- Data visualization
- Report drafting
- Metric definition
- Insight identification
- Presentation creation

## Common Workflows

### Workflow 1: Ad-Hoc Analysis

```
1. Data Analyst: "Analyze why sign-ups dropped 20% last week"
2. AI: Design analysis:
   - Compare to previous weeks
   - Segment by source, device, geography
   - Check for data quality issues
   - Identify correlations
3. AI: Generate SQL queries and visualizations
4. AI: Draft report with findings
5. Data Analyst: Reviews and presents to stakeholders
```

### Workflow 2: Dashboard Creation

```
1. Data Analyst: "Create dashboard for product metrics"
2. AI: Design dashboard:
   - Key metrics (MAU, retention, engagement)
   - Trends over time
   - Segmentation views
   - Alerts for anomalies
3. AI: Generate dashboard queries
4. AI: Suggest visualization types
5. Data Analyst: Builds and publishes dashboard
```

## Common Pitfalls

### Pitfall 1: Correlation vs Causation
**Bad:** "Feature X caused increase in revenue"
**Good:** "Feature X is correlated with revenue increase"
**AI should flag:** "This claims causation. Without experiment, only state correlation."

### Pitfall 2: Cherry-Picking Data
**Bad:** Selecting time periods that support hypothesis
**Good:** Analyzing all relevant time periods
**AI should flag:** "Analysis only covers favorable period. Include full time range."

### Pitfall 3: Unclear Metrics
**Bad:** "Engagement increased" (what is engagement?)
**Good:** "Daily active users increased 15%"
**AI should flag:** "Metric 'engagement' not defined. Specify how it's calculated."

## Success Metrics for AI Collaboration

- Analyses actionable and data-driven
- Dashboards used regularly by stakeholders
- Metrics clearly defined and tracked
- Insights lead to product improvements
- Data quality issues identified proactively

---

**Last Updated:** 2024-03-20
**Guide Owner:** Data Team
