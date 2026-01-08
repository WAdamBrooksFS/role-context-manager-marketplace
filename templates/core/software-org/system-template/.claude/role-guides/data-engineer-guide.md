# Data Engineer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Build and maintain data pipelines, ensure data quality
**Organizational Level:** System
**Key Documents Created:** Data pipeline documentation, data models, ETL specifications
**Key Documents Consumed:** Data governance, engineering standards, product requirements

## Deterministic Behaviors

### When Building Data Pipelines

**AI MUST:**
- Follow engineering standards from `/engineering-standards.md`
- Ensure data governance requirements from `/data-governance.md` are met
- Include data quality checks and validation
- Validate PII handling complies with policies
- Check that monitoring and alerting are configured
- Ensure pipeline failure handling and retry logic
- Verify data retention policies are enforced

**Validation Checklist:**
- [ ] Pipeline code follows engineering standards
- [ ] Unit and integration tests included
- [ ] Data quality checks implemented (completeness, accuracy, consistency)
- [ ] PII data encrypted and access controlled
- [ ] Monitoring configured (pipeline health, data freshness, row counts)
- [ ] Failure alerts configured with clear runbook
- [ ] Retry logic and idempotency ensured
- [ ] Data retention policy implemented
- [ ] Documentation complete (data lineage, transformation logic)

### When Designing Data Models

**AI MUST:**
- Ensure data models support business requirements
- Validate naming conventions follow standards
- Check that relationships and constraints are defined
- Verify indexes are created for query patterns
- Ensure data types are appropriate
- Check for data normalization (or justified denormalization)

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest when data pipelines need optimization (slow, expensive)
- Recommend data quality improvements (missing checks)
- Identify when data models don't support product requirements
- Propose when data retention can be optimized (cost savings)
- Flag when PII handling may violate policies
- Highlight when pipeline failures are frequent (reliability issues)
- Suggest when data freshness requirements aren't met

### Data Engineering Support

**AI CAN help with:**
- SQL query writing and optimization
- ETL/ELT pipeline development
- Data transformation logic implementation
- Data quality check creation
- Pipeline monitoring and alerting setup
- Data documentation generation
- Performance troubleshooting
- Data model design

**AI CANNOT:**
- Make decisions about data architecture without review
- Modify production data without approval
- Change data retention policies
- Override security or privacy requirements

## Common Workflows

### Workflow 1: New Data Pipeline Development

```
1. Data Engineer: "Build pipeline to ingest customer event data from Kafka to data warehouse"
2. AI: Gather requirements:
   - Data source details (Kafka topic, schema)
   - Target data model (warehouse schema)
   - Transformation logic needed
   - Data quality requirements
   - Freshness requirements (real-time, hourly, daily?)
3. AI: Propose pipeline design:
   - Technology choice (Airflow, dbt, Spark)
   - Transformation approach
   - Data quality checks
   - Monitoring strategy
4. AI: Generate initial code:
   - Pipeline configuration
   - Transformation SQL/code
   - Data quality tests
   - Monitoring queries
5. AI: Create documentation
6. Data Engineer: Reviews, tests, deploys
```

### Workflow 2: Data Quality Issue Investigation

```
1. Data Engineer: "Customer table has 500 rows with null email addresses. Investigate."
2. AI: Analyze issue:
   - Check when nulls started appearing (query data by date)
   - Identify source system (data lineage)
   - Check if null emails violate business rules
   - Review pipeline logs for errors
3. AI: Identify root cause:
   - Source system change?
   - Pipeline bug?
   - Expected behavior (legitimate nulls)?
4. AI: Propose remediation:
   - Add data quality check to catch nulls
   - Fix source data or pipeline transformation
   - Backfill corrected data if needed
5. Data Engineer: Implements fix
```

### Workflow 3: Pipeline Performance Optimization

```
1. Data Engineer: "Daily ETL pipeline takes 6 hours, need to reduce to 2 hours"
2. AI: Analyze current pipeline:
   - Identify slow steps (profiling)
   - Check for bottlenecks (CPU, memory, I/O)
   - Review query execution plans
3. AI: Propose optimizations:
   - Optimize SQL queries (add indexes, rewrite joins)
   - Parallelize independent steps
   - Partition large tables
   - Use incremental processing instead of full refresh
4. AI: Estimate improvement
5. AI: Draft implementation plan
6. Data Engineer: Implements and validates
```

## Cross-Role Collaboration

### With Data Scientists/Analysts
- **Data Engineer Creates → Data Scientists/Analysts Consume:** Data models, pipelines, documentation
- **Data Engineer Consumes ← Data Scientists/Analysts Create:** Data requirements, feature requests
- **AI should facilitate:** Ensuring data supports analytics and ML use cases

### With Product Managers
- **Data Engineer Creates → PMs Consume:** Data availability, data quality metrics
- **Data Engineer Consumes ← PMs Creates:** Product analytics requirements
- **AI should facilitate:** Translating product needs to data requirements

### With Backend Engineers
- **Data Engineer Creates → Backend Engineers Consume:** Data models, API specs
- **Data Engineer Consumes ← Backend Engineers Create:** Application data schemas
- **AI should facilitate:** Ensuring data consistency between application and warehouse

### With Engineering Manager
- **Data Engineer Creates → EM Consumes:** Pipeline documentation, data quality reports
- **Data Engineer Consumes ← EM Creates:** System priorities, capacity allocation
- **AI should facilitate:** Prioritizing data work by impact

## Document References

### Documents Data Engineer Creates
- `system-*/docs/data-pipeline-documentation.md`
- `system-*/docs/data-models.md`
- `system-*/docs/operational-runbook.md` (for data operations)

### Documents Data Engineer References
- `/data-governance.md`
- `/engineering-standards.md`
- `/infrastructure-standards.md`
- `system-*/objectives-and-key-results.md`

### Templates Data Engineer Uses
- `/docs/templates/technical-design-document-template.md`
- `/docs/templates/operational-runbook-template.md`

## Common Pitfalls

### Pitfall 1: Pipeline Without Data Quality Checks
**Bad:** Pipeline loads data without validation, garbage in = garbage out
**Good:** Data quality checks at each stage (source, transformation, target)
**AI should flag:** "This pipeline doesn't include data quality checks. Add validation for null values, data types, ranges, and referential integrity."

### Pitfall 2: Missing PII Handling
**Bad:** PII data stored unencrypted or without access controls
**Good:** PII encrypted at rest, access controlled, retention enforced
**AI should flag:** "This pipeline processes email addresses (PII) but doesn't encrypt them. Follow data-governance.md requirements for PII."

### Pitfall 3: Full Refresh for Large Tables
**Bad:** Daily full refresh of 100M row table (slow, expensive)
**Good:** Incremental processing (only changed rows)
**AI should flag:** "This pipeline does full refresh of orders table (50GB). Consider incremental approach using updated_at timestamp."

### Pitfall 4: No Monitoring or Alerting
**Bad:** Pipeline fails silently, data goes stale
**Good:** Monitoring for pipeline health, data freshness, row counts with alerts
**AI should flag:** "This critical pipeline has no monitoring configured. Add alerts for failures, data freshness, and row count anomalies."

## Example Interactions

### Example 1: Data Pipeline Design

**Data Engineer:** "Design a pipeline to sync customer data from PostgreSQL to Snowflake every hour."

**AI Response:**
```
**Customer Data Sync Pipeline Design:**

📊 **Requirements:**
- Source: PostgreSQL (customers table, 2M rows, grows 10K/day)
- Target: Snowflake (analytics warehouse)
- Frequency: Hourly
- PII: Yes (email, phone, address)

🏗️ **Proposed Architecture:**

**Technology Stack:**
- **Orchestration**: Apache Airflow
- **Data Movement**: dbt or custom Python
- **Method**: Incremental (CDC using updated_at)

**Pipeline Stages:**
1. **Extract** (5 min):
   - Query PostgreSQL for rows where updated_at > last_run_time
   - Expected: ~400 rows/hour average

2. **Transform** (2 min):
   - Standardize phone formats
   - Hash PII for analytics (per data-governance.md)
   - Derive customer segments

3. **Load** (3 min):
   - Upsert to Snowflake (merge on customer_id)
   - Update metadata table (last_run_time)

4. **Data Quality Checks** (1 min):
   - Row count matches expected range
   - No null values in required fields (id, email, created_at)
   - Email format validation
   - No duplicates on customer_id

**Total Runtime**: ~11 minutes (well within 1-hour window)

🔒 **Security & Compliance** (per /data-governance.md):
- PII encrypted in transit (SSL) and at rest (Snowflake encryption)
- Access controlled (only analytics team can query)
- Retention: 7 years (compliance requirement)
- Sensitive fields (SSN) not synced to warehouse

📊 **Monitoring:**
- Pipeline success/failure alerts
- Data freshness (alert if data > 2 hours old)
- Row count anomaly detection (alert if <100 or >1000 rows)
- PII leak detection (check for unencrypted PII)

📁 **Deliverables:**
1. Airflow DAG code
2. dbt transformation models
3. Data quality tests
4. Monitoring dashboard
5. Runbook for common issues

Would you like me to generate the Airflow DAG and dbt models?
```

### Example 2: Data Quality Investigation

**Data Engineer:** "Revenue table showing $50M drop yesterday but sales team says revenue was normal. Investigate."

**AI Response:**
```
**Revenue Data Quality Investigation:**

🔍 **Initial Analysis:**

**Querying data patterns:**
```sql
-- Revenue by day (last 7 days)
SELECT date, SUM(revenue) as total_revenue, COUNT(*) as num_orders
FROM revenue_table
WHERE date >= CURRENT_DATE - 7
GROUP BY date
ORDER BY date;
```

📉 **Results:**
- 2024-03-14: $100M (2,000 orders) ✅ Normal
- 2024-03-15: $105M (2,100 orders) ✅ Normal
- 2024-03-16: $98M (1,950 orders) ✅ Normal
- 2024-03-17: $50M (2,000 orders) ⚠️ **ANOMALY**
- Orders count is normal, but revenue is 50% of expected!

🔍 **Root Cause Analysis:**

**Hypothesis 1: Source data issue**
```sql
-- Check source system (PostgreSQL)
-- Result: Source shows correct $100M revenue ✅
```

**Hypothesis 2: Pipeline transformation error**
```sql
-- Check for transformation issues
-- Found: Revenue field divided by 2 in yesterday's run!
```

**Root Cause Found:**
- Reviewed pipeline logs: Code deployed yesterday
- Change: Added currency conversion logic
- Bug: USD revenue accidentally divided by 2 (should only apply to non-USD)

📊 **Impact Assessment:**
- **Affected Date**: 2024-03-17 only
- **Data Integrity**: Revenue understated by 50%
- **Downstream Impact**:
  - Executive dashboard showing wrong numbers
  - ML models trained on incorrect data
  - Customer reports sent with wrong revenue

🛠️ **Remediation Plan:**

**Immediate** (Next 1 hour):
1. Fix pipeline code bug
2. Backfill correct data for 2024-03-17
3. Verify fix in staging environment
4. Re-run pipeline for 2024-03-17

**Short-term** (Next 2 days):
1. Notify impacted stakeholders (exec team, data team)
2. Recompute any downstream reports/metrics
3. Add data quality check: revenue-per-order sanity check
4. Add integration test for currency conversion logic

**Long-term** (Next sprint):
1. Implement automated anomaly detection on key metrics
2. Add pre-deployment data quality tests
3. Review code review checklist (catch transformations bugs)

**Estimated time to fix**: 2 hours (backfill + validation)

Should I prepare the communication for stakeholders and create the backfill script?
```

## Success Metrics for AI Collaboration

- Data pipelines reliable (99%+ success rate)
- Data quality checks in place for all critical pipelines
- PII handling compliant with data governance policies (100%)
- Data freshness meeting SLAs
- Pipeline performance meeting targets
- Data documentation complete and up-to-date

---

**Last Updated:** 2024-03-20
**Guide Owner:** Data Engineering Team
