# Agervis Security Fix Plan
**Generated:** 2026-10-04
**Total Vulnerabilities:** 154 issues across 7 workstreams

## Priority Tiers

### TIER 0: Authentication & Authorization (MUST FIX FIRST)
**Impact:** Entire system is currently open to public without any access control
**Estimated Effort:** 2-3 days

1. **Add WebSocket Authentication**
   - Implement token-based auth on handshake
   - Reject unauthenticated connections
   - Files: `src/main/websocket/server.ts`, `src/main/websocket/connection-manager.ts`

2. **Add Admin Dashboard Authentication**
   - Implement admin login system
   - Session management with secure tokens
   - Role-based access control (admin vs viewer)
   - Files: `src/App.tsx`, `src/components/layout/Layout.tsx`

3. **Add Map Editor Authentication**
   - Restrict map editor access to authenticated admins only
   - Files: `src/renderer/map-editor/MapEditor.tsx`, `src/main/map-editor/api.ts`

**Verification:** Attempt to connect without credentials, access dashboard without login, use map editor unauthenticated

---

### TIER 1: Critical Exploits (HIGH PRIORITY)
**Impact:** Money duplication, item duplication, game-breaking exploits
**Estimated Effort:** 3-4 days

#### Game Economy Protection
4. **Fix Money Duplication Exploit**
   - Add unique constraint on transaction IDs (use UUIDs)
   - Validate positive balances before all transactions
   - Add transaction locks to prevent race conditions
   - Files: `src/main/game/economy/transactions.ts`, `src/main/database/schema.sql`

5. **Fix Item Duplication Exploit**
   - Add atomic stack operations
   - Validate inventory state before/after transfers
   - Files: `src/main/game/inventory/inventory-system.ts`

6. **Fix Negative XP Wrapping**
   - Validate XP is non-negative before applying
   - Add bounds checking on skill progression
   - Files: `src/main/game/skills/skill-progression.ts`

**Verification:** Attempt duplication exploits, test with negative values, concurrent transaction tests

---

### TIER 2: Injection Vulnerabilities (HIGH PRIORITY)
**Impact:** Code execution, data theft, system compromise
**Estimated Effort:** 4-5 days

#### XSS Protection
7. **Sanitize All Dashboard Outputs**
   - Use DOMPurify for all user-generated content
   - Escape player names, chat messages, error displays
   - Files: All dashboard components (`src/components/**/*.tsx`)

8. **Fix Modal/Error Display XSS**
   - Sanitize modal titles and error messages
   - Files: `src/components/Modal.tsx`, `src/components/ErrorBoundary.tsx`

#### Command Injection
9. **Fix Desktop App Command Injection**
   - Remove shell execution for firewall checks
   - Use platform-specific APIs instead of netsh/ufw
   - Validate all file paths before use
   - Files: `electron/server-process.ts`, `electron/main.ts`

10. **Fix Admin Dashboard Command Injection**
    - Parameterize all commands in command parser
    - Validate inputs before execution
    - Files: `src/services/commandParser.ts`, `src/components/console/Console.tsx`

#### Prompt Injection
11. **Fix AI Prompt Injection Vulnerabilities**
    - Sanitize template variables before prompt insertion
    - Escape user input in AI prompts
    - Validate room descriptions before Claude Vision API
    - Files: `src/main/ai/prompts/template-engine.ts`, `src/main/map-editor/ai/tile-vision.ts`

#### SQL Injection
12. **Fix Database SQL Injection**
    - Replace all string interpolation with parameterized queries
    - Validate column/table names against allowlists
    - Files: `src/main/database/sqlite.ts`

**Verification:** Attempt XSS payloads, command injection strings, prompt injection attacks, SQL injection

---

### TIER 3: API Key & Secret Exposure (HIGH PRIORITY)
**Impact:** Unauthorized API usage, cost explosion, credential theft
**Estimated Effort:** 2-3 days

13. **Encrypt Desktop App API Keys**
    - Use OS keychain/credential manager (keytar package)
    - Remove plaintext storage in config.json
    - Files: `electron/config-manager.ts`

14. **Remove API Keys from Process Environment**
    - Use secure IPC instead of env vars
    - Clear sensitive data from memory after use
    - Files: `electron/server-process.ts`

15. **Sanitize Error Messages**
    - Remove API keys and sensitive data from logs
    - Implement error sanitization layer
    - Files: All error handling across codebase

**Verification:** Check config files, process environment, error logs for exposed secrets

---

### TIER 4: Race Conditions & State Desync (MEDIUM-HIGH PRIORITY)
**Impact:** State corruption, ghost connections, data loss
**Estimated Effort:** 5-6 days

16. **Fix AI-Database State Desynchronization**
    - Implement shared transaction context for AI + world state writes
    - Use database transaction isolation properly
    - Files: `src/main/state/world-state.ts`, `src/main/ai/storage/*.ts`

17. **Fix Heartbeat Race Condition**
    - Add mutex/lock for heartbeat state updates
    - Atomic heartbeat timestamp updates
    - Files: `src/main/websocket/connection-manager.ts`

18. **Fix Rate Limiting Priority Inversion**
    - Check rate limits BEFORE queueing
    - Implement proper queue backpressure
    - Files: `src/main/rate-limiter.ts`, `src/main/ai/queue/request-queue.ts`

19. **Fix Configuration Hot-Reload Race**
    - Defer config changes to tick boundaries
    - Use atomic config swaps
    - Files: `src/main/config/config-manager.ts`, `src/main/game-server.ts`

20. **Fix World State Pending Updates Overflow**
    - Implement buffer size limits
    - Add backpressure signaling to clients
    - Batch updates intelligently
    - Files: `src/main/state/world-state.ts`

**Verification:** Concurrent connection tests, config change during gameplay, high-load stress tests

---

### TIER 5: DoS & Resource Exhaustion (MEDIUM PRIORITY)
**Impact:** Server crashes, OOM, service unavailability
**Estimated Effort:** 3-4 days

21. **Fix Unbounded Memory Growth**
    - Token tracker in-memory cache limits
    - Event history circular buffer
    - Undo history size caps
    - Connection manager sequence ID wrapping
    - Files: `src/main/ai/storage/token-tracker.ts`, `src/main/state/event-bus.ts`, `src/main/map-editor/editor.ts`, `src/main/websocket/connection-manager.ts`

22. **Fix JSON Deserialization Bomb**
    - Add payload size validation before parsing
    - Limit nested object depth
    - Files: `src/main/websocket/protocol.ts`

23. **Fix Canvas/Map Editor DoS**
    - Limit tile count per room
    - Cap canvas dimensions
    - Validate zoom levels
    - Files: `src/main/map-editor/canvas-renderer.ts`, `src/main/map-editor/export/png-exporter.ts`

24. **Add Rate Limiting to Map Editor AI**
    - Cost tracking for tile vision API calls
    - Per-user rate limits
    - Files: `src/main/map-editor/api.ts`

**Verification:** Load tests with large payloads, massive tile counts, rapid API calls

---

### TIER 6: Data Integrity & Consistency (MEDIUM PRIORITY)
**Impact:** Data corruption, inconsistent state, lost data
**Estimated Effort:** 4-5 days

25. **Fix BYOK Key Rotation Without Rekey**
    - Invalidate caches on key rotation
    - Implement transparent key refresh
    - Files: `src/main/ai/byok/key-manager.ts`, `src/main/ai/npc/router.ts`, `src/main/ai/storage/cache.ts`

26. **Fix Response Cache Hash Collision**
    - Include npc_id in cache key
    - Add cache validation
    - Files: `src/main/ai/storage/cache.ts`

27. **Fix SQLite WAL Corruption**
    - Implement proper transaction boundaries
    - Add database integrity checks
    - Graceful recovery on startup
    - Files: `src/main/database/sqlite.ts`

28. **Fix Database Transaction Deadlocks**
    - Set busy timeout on connections
    - Implement retry with exponential backoff
    - Files: `src/main/database/sqlite.ts`

29. **Fix Conversation History Unbounded Growth**
    - Implement archive deletion policy (90-day retention)
    - Add database maintenance task
    - Files: `src/main/ai/storage/conversation-store.ts`

30. **Fix Evidence/Property Ownership Validation**
    - Validate ownership before access grants
    - Audit trail for evidence tampering
    - Files: `src/main/game/evidence/evidence-tracker.ts`, `src/main/game/property/property-manager.ts`

**Verification:** Concurrent database operations, key rotation during active conversations, long-running server tests

---

### TIER 7: Monitoring & Observability (MEDIUM-LOW PRIORITY)
**Impact:** Delayed incident response, blind spots in production
**Estimated Effort:** 2-3 days

31. **Fix Health Check Lag**
    - Make health checks async with timeouts
    - Real-time health status updates
    - Files: `src/main/health/health-check.ts`

32. **Fix Map Editor Cost Tracking Desync**
    - Route tile vision through centralized token tracker
    - Unified BYOK key management
    - Files: `src/main/map-editor/ai/tile-vision.ts`, `src/main/ai/storage/token-tracker.ts`

33. **Fix Admin Dashboard Stale Metrics**
    - Switch to WebSocket for real-time updates
    - Remove HTTP polling
    - Files: Admin dashboard components

34. **Add Event Bus Error Isolation**
    - Continue publishing to remaining subscribers on error
    - Alert on handler failures
    - Files: `src/main/state/event-bus.ts`

**Verification:** Monitor dashboards during failures, trigger health check issues, observe metrics lag

---

### TIER 8: Graceful Degradation (LOW PRIORITY)
**Impact:** Improved reliability, better UX during failures
**Estimated Effort:** 2-3 days

35. **Fix Director AI Stale Snapshot**
    - Add staleness detection
    - Validate entity existence before actions
    - Files: `src/main/ai/director/engine.ts`

36. **Fix Anthropic Client Base URL Hot Swap**
    - Cancel in-flight requests on config change
    - Graceful reconnection
    - Files: `src/main/ai/anthropic-client.ts`

37. **Fix Game Server Shutdown Without AI Cancellation**
    - Cancel in-flight AI requests on shutdown
    - Drain queue gracefully
    - Files: `src/main/game-server.ts`, `src/main/ai/queue/request-queue.ts`

38. **Fix WebSocket Protocol Version Mismatch**
    - Add version negotiation in handshake
    - Backward compatibility layer
    - Files: `src/main/websocket/protocol.ts`

39. **Add Map Editor Autosave**
    - Periodic autosave to recovery file
    - Restore on crash
    - Files: `src/main/map-editor/editor.ts`

**Verification:** Version mismatches, config changes during load, server restarts under load

---

### TIER 9: Security Hardening (LOW PRIORITY)
**Impact:** Defense in depth, reduce attack surface
**Estimated Effort:** 2-3 days

40. **Add Input Validation Throughout**
    - Tile coordinates validation
    - Jail time positive validation
    - Heat system bounds checking
    - Standing modification limits
    - Files: Various game system files

41. **Add Database Indexes**
    - Index on query_hash for cache lookups
    - Other missing indexes identified
    - Files: `src/main/database/schema.sql`

42. **Fix Exponential Backoff Infinite Loop**
    - Cap retry attempts correctly
    - Validate retry configuration
    - Files: `src/main/ai/queue/request-queue.ts`

43. **Add Godot Export Validation**
    - Escape room metadata in TSCN export
    - Validate tile metadata before JSON export
    - Files: `src/main/map-editor/export/*.ts`

**Verification:** Fuzz testing with invalid inputs, performance benchmarks

---

## Implementation Strategy

### Phase 1: Block Public Access (Week 1)
- Tier 0: Authentication & Authorization
- **Goal:** No one can access the system without credentials

### Phase 2: Fix Critical Exploits (Week 2)
- Tier 1: Game economy exploits
- **Goal:** Money/item duplication impossible

### Phase 3: Prevent Code Execution (Week 3)
- Tier 2: All injection vulnerabilities
- **Goal:** No XSS, command injection, prompt injection, SQL injection

### Phase 4: Secure Secrets (Week 4)
- Tier 3: API key exposure
- **Goal:** No secrets in plaintext, logs, or process env

### Phase 5: Stabilize State Management (Week 5-6)
- Tier 4: Race conditions
- Tier 5: DoS vulnerabilities
- **Goal:** Stable under concurrent load

### Phase 6: Data Integrity (Week 7)
- Tier 6: Data consistency issues
- **Goal:** No corruption, proper transaction handling

### Phase 7: Polish (Week 8)
- Tier 7: Monitoring improvements
- Tier 8: Graceful degradation
- Tier 9: Hardening
- **Goal:** Production-ready observability and resilience

---

## Testing Requirements

After each tier:
1. **Unit tests** for fixed vulnerabilities
2. **Integration tests** for cross-system fixes
3. **Security tests** attempting the original exploit
4. **Load tests** at 25+ concurrent players
5. **Regression tests** ensuring old features still work

---

## Success Criteria

**Tier 0-3 Complete:** System is no longer critically vulnerable
**Tier 4-5 Complete:** System is stable under load
**Tier 6-9 Complete:** System is production-ready

---

**Next Steps:**
1. Review and approve this plan
2. Begin Tier 0 implementation (authentication)
3. After each tier, run full test suite
4. Deploy fixes incrementally to minimize disruption
