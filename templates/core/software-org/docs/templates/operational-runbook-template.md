# Operational Runbook: [Service/System Name]

<!-- LLM: Runbooks should provide clear, step-by-step instructions for operations and troubleshooting. Help on-call engineers resolve issues quickly. Keep procedures up-to-date. -->

**Service:** [Service Name]
**Owner:** [Team Name]
**On-Call:** [Rotation schedule link]
**Last Updated:** [Date]

---

## Service Overview

**Purpose:** [What this service does]
**Dependencies:** [What this service depends on]
**Dependents:** [What depends on this service]
**SLA:** [Uptime target, e.g., 99.9%]

---

## Architecture

[Architecture diagram showing service components]

**Key Components:**
- **Component 1:** [Description]
- **Component 2:** [Description]

---

## Health Checks

### Service Health
- **Endpoint:** `GET /health`
- **Expected Response:** `{"status": "healthy"}`
- **Response Time:** < 100ms

### Dependencies Health
- **Database:** [How to check]
- **External API:** [How to check]
- **Cache:** [How to check]

---

## Monitoring & Alerts

### Dashboards
- **Primary Dashboard:** [Link]
- **Metrics Dashboard:** [Link]

### Key Metrics
- **Request Rate:** [Normal range]
- **Error Rate:** [Acceptable threshold]
- **Latency (p95):** [Target]
- **CPU Usage:** [Normal range]
- **Memory Usage:** [Normal range]

### Alerting
| Alert | Severity | Threshold | Response |
|-------|----------|-----------|----------|
| Service Down | Critical | 0 healthy instances | Page on-call immediately |
| High Error Rate | High | > 1% errors for 5min | Investigate within 15min |
| High Latency | Medium | p95 > 500ms for 10min | Investigate within 1hr |

---

## Common Operations

### Deployment

**Normal Deployment:**
```bash
# Deploy to staging
./deploy.sh staging

# Verify staging
curl https://staging.example.com/health

# Deploy to production
./deploy.sh production

# Monitor for 15 minutes
# Check dashboard: [link]
```

**Rollback:**
```bash
# Rollback to previous version
./deploy.sh production rollback

# Verify
curl https://api.example.com/health
```

### Scaling

**Manual Scale Up:**
```bash
# Increase replicas
kubectl scale deployment service-name --replicas=10

# Verify
kubectl get pods | grep service-name
```

**Manual Scale Down:**
```bash
# Decrease replicas
kubectl scale deployment service-name --replicas=5
```

### Configuration Changes

```bash
# Update config
kubectl edit configmap service-config

# Restart pods to pick up new config
kubectl rollout restart deployment service-name
```

---

## Troubleshooting

### Issue: Service is down / not responding

**Symptoms:**
- Health check endpoint returns 503 or times out
- All pods show as unhealthy
- Customers cannot access service

**Diagnosis:**
1. Check pod status: `kubectl get pods -l app=service-name`
2. Check logs: `kubectl logs -l app=service-name --tail=100`
3. Check events: `kubectl get events --sort-by='.lastTimestamp'`

**Common Causes & Solutions:**

**Cause 1: Database connection failure**
```bash
# Check database connectivity
kubectl exec -it <pod-name> -- psql -h $DB_HOST -U $DB_USER -c "SELECT 1"

# Solution: Check database status, restart if needed
# If database is fine, check network policies
```

**Cause 2: Out of memory**
```bash
# Check memory usage
kubectl top pods

# Solution: Increase memory limits or scale horizontally
kubectl set resources deployment service-name --limits=memory=2Gi
```

**Cause 3: Bad deployment**
```bash
# Rollback to previous version
kubectl rollout undo deployment service-name

# Verify rollback
kubectl rollout status deployment service-name
```

---

### Issue: High error rate

**Symptoms:**
- Error rate > 1%
- Specific endpoints returning 500 errors

**Diagnosis:**
1. Check error logs: `kubectl logs -l app=service-name | grep ERROR`
2. Check specific error patterns
3. Check downstream dependencies

**Solutions:**
- If external API is failing: Enable circuit breaker, use fallback
- If database queries failing: Check slow query log, optimize queries
- If memory/CPU exhausted: Scale up

---

### Issue: High latency

**Symptoms:**
- p95 latency > 500ms
- Slow response times

**Diagnosis:**
1. Check distributed tracing: [Link to tracing dashboard]
2. Identify slow component
3. Check database query performance
4. Check cache hit rate

**Solutions:**
- Database slow: Add indexes, optimize queries
- Cache miss: Warm up cache, adjust TTL
- External API slow: Increase timeout, implement async processing

---

## Emergency Procedures

### Complete Outage

**If service is completely down:**
1. **Notify:** Post in #incidents Slack channel
2. **Assess:** Check all pods, logs, dependencies
3. **Mitigate:** Rollback if recent deployment, scale if resource issue
4. **Communicate:** Update status page
5. **Resolve:** Fix root cause
6. **Follow-up:** Post-mortem within 48 hours

### Data Corruption

**If data corruption detected:**
1. **STOP:** Immediately stop writes to affected data
2. **Isolate:** Take corrupted instances out of rotation
3. **Restore:** From most recent known-good backup
4. **Verify:** Data integrity before returning to service
5. **Investigate:** Determine cause, prevent recurrence

### Security Incident

**If security breach suspected:**
1. **DO NOT** attempt to fix yourself
2. **Immediately** page security team: [Contact]
3. **Preserve** logs and evidence
4. **Follow** security incident response: `/docs/processes/incident-response.md`

---

## Maintenance Windows

### Planned Maintenance

**Scheduling:**
- Schedule during low-traffic hours: [Time window]
- Announce 72 hours in advance
- Update status page

**Procedure:**
1. Announce maintenance window
2. Take traffic snapshot/backup
3. Perform maintenance
4. Validate changes
5. Return to service
6. Monitor for 1 hour
7. Close maintenance window

---

## Disaster Recovery

### Backup Strategy
- **Frequency:** Daily automated backups
- **Retention:** 30 days
- **Location:** Cross-region replication
- **Testing:** Quarterly restore tests

### Recovery Procedure
1. Assess extent of disaster
2. Determine Recovery Point Objective (RPO): [1 hour]
3. Determine Recovery Time Objective (RTO): [4 hours]
4. Restore from backup
5. Verify data integrity
6. Return to service
7. Post-mortem

---

## Useful Commands

### Logs
```bash
# Recent logs
kubectl logs -l app=service-name --tail=100

# Follow logs
kubectl logs -l app=service-name --follow

# Logs from specific time
kubectl logs <pod-name> --since=1h
```

### Debugging
```bash
# Exec into pod
kubectl exec -it <pod-name> -- /bin/bash

# Port forward for local debugging
kubectl port-forward <pod-name> 8080:8080

# Describe pod
kubectl describe pod <pod-name>
```

### Metrics
```bash
# Resource usage
kubectl top pods
kubectl top nodes

# Check autoscaling
kubectl get hpa
```

---

## On-Call Handoff

**Handoff Checklist:**
- [ ] Review open incidents
- [ ] Check system health
- [ ] Review recent changes
- [ ] Note any scheduled maintenance
- [ ] Confirm contact information

---

## Contacts

**Team:** [Team name]
**Slack Channel:** [#team-channel]
**On-Call Rotation:** [PagerDuty/Opsgenie link]
**Escalation:** [Engineering Manager name/contact]

**Key Personnel:**
- **Service Owner:** [Name]
- **On-Call:** [Current on-call engineer]
- **Backup:** [Backup on-call]

---

**Last Updated:** [Date]
**Next Review:** [Date]

<!-- LLM: Runbooks should be kept up-to-date. When procedures change, update this document. Help on-call engineers by providing clear, step-by-step instructions. Include actual commands, not just descriptions. -->
