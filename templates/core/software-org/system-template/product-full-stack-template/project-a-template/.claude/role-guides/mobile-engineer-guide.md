# Mobile Engineer - AI Collaboration Guide

## Role Overview

**Primary Responsibility:** Build and maintain mobile applications (iOS/Android)
**Organizational Level:** Project
**Key Documents Created:** Mobile app code, platform-specific documentation
**Key Documents Consumed:** PRDs, UI/UX designs, API documentation, engineering standards

## Deterministic Behaviors

### When Writing Mobile Code

**AI MUST:**
- Follow platform guidelines (Apple HIG, Material Design)
- Follow engineering standards from `/engineering-standards.md`
- Include unit and UI tests (80%+ coverage)
- Optimize for performance (battery, memory, network)
- Handle offline scenarios gracefully
- Implement proper error handling with user-friendly messages
- Never hardcode API URLs or secrets
- Support platform-specific features (push notifications, deep links)

**Validation Checklist:**
- [ ] Code follows platform conventions (Swift/Kotlin style guides)
- [ ] Unit tests for business logic
- [ ] UI tests for critical flows
- [ ] Responsive design (different screen sizes, orientations)
- [ ] Offline functionality where appropriate
- [ ] Loading states during network operations
- [ ] Error handling with retry options
- [ ] Battery and memory optimized
- [ ] Accessibility (VoiceOver, TalkBack, Dynamic Type)
- [ ] App store requirements met

## Agentic Opportunities

### Proactive Suggestions

**AI SHOULD:**
- Suggest performance optimizations (memory leaks, battery drain)
- Recommend platform best practices
- Flag accessibility issues
- Identify network efficiency improvements
- Propose better offline experience
- Highlight potential app store rejection reasons

### Mobile Development Support

**AI CAN help with:**
- Platform-specific feature implementation
- UI/UX implementation
- API integration
- Performance optimization
- Memory leak detection
- Test writing
- App store submission preparation
- Platform compatibility checks

## Common Workflows

### Workflow 1: Implement Feature with Offline Support

```
1. Mobile Engineer: "Implement article reading with offline support"
2. AI: Design offline-first approach:
   - Cache articles locally (Core Data/Room)
   - Sync when online
   - Show cached content when offline
   - Indicate stale data
3. AI: Implement with:
   - Local database schema
   - Network sync logic
   - UI indicators (offline mode, syncing)
   - Conflict resolution
4. AI: Add tests for offline scenarios
5. Mobile Engineer: Reviews and tests on device
```

### Workflow 2: Optimize App Performance

```
1. Mobile Engineer: "App draining battery, investigate"
2. AI: Profile app performance:
   - Identify background activity
   - Check network requests
   - Analyze wake locks
3. AI: Find issues:
   - Polling server every 30 seconds
   - Location updates not stopped when app backgrounded
4. AI: Propose fixes:
   - Use push notifications instead of polling
   - Stop location updates when not needed
5. Mobile Engineer: Implements optimizations
```

## Common Pitfalls

### Pitfall 1: Not Handling Offline
**Bad:** App crashes or shows errors when network unavailable
**Good:** Graceful offline mode with cached content
**AI should flag:** "Network request has no offline handling. Cache data locally or show offline message."

### Pitfall 2: Battery Drain
**Bad:** Continuous background activity, frequent wake locks
**Good:** Efficient background tasks, minimal wake locks
**AI should flag:** "Location updates running continuously. Stop when app backgrounded."

### Pitfall 3: Missing Accessibility
**Bad:** Custom UI without accessibility labels
**Good:** VoiceOver/TalkBack support, Dynamic Type
**AI should flag:** "Custom button missing accessibility label. Add for screen reader support."

## Success Metrics for AI Collaboration

- App performance optimized (low battery drain, fast load times)
- Offline functionality works reliably
- Accessibility requirements met
- App store submissions succeed
- Zero critical bugs in production

---

**Last Updated:** 2024-03-20
**Guide Owner:** Mobile Engineering Team
