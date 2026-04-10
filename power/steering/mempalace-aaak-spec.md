# AAAK Compression Spec

AAAK is an experimental lossy abbreviation dialect for packing repeated entities into fewer tokens at scale. Any LLM reads it natively — no decoder needed.

## When to Use AAAK

- **Use raw mode** (default) for storage — verbatim text in drawers gives 96.6% recall
- **Use AAAK** only for context loading at scale — when injecting many memories into a prompt and token budget is tight
- AAAK currently regresses recall vs raw (84.2% vs 96.6%) — it trades fidelity for density

## Format Rules

### Entity Codes
Assign 3-letter uppercase codes to repeated entities:
- People: `KAI`, `PRI` (Priya), `SOR` (Soren), `MAY` (Maya)
- Projects: `DFT` (Driftwood), `ORI` (Orion)
- Concepts: `AUTH`, `GQL` (GraphQL)

### Structural Markers
- `|` separates fields within a line
- `.` replaces spaces within compound terms: `auth.migration`, `saas.analytics`
- `→` indicates transitions or choices: `clerk>auth0`
- `★` rating (1-5 stars) for importance
- `()` for attributes: `KAI(backend,3yr)`

### Example

Original (~66 tokens):
```
Priya manages Driftwood team: Kai (backend, 3 years), Soren (frontend),
Maya (infrastructure), Leo (junior, started last month). Building SaaS
analytics platform. Current sprint: auth migration to Clerk.
```

AAAK (~73 tokens at small scale, saves at scale with repeated entities):
```
TEAM: PRI(lead) | KAI(backend,3yr) SOR(frontend) MAY(infra) LEO(junior,new)
PROJ: DRIFTWOOD(saas.analytics) | SPRINT: auth.migration→clerk
DECISION: KAI.rec:clerk>auth0(pricing+dx) | ★★★★
```

## Honest Status

- AAAK is lossy, not lossless — uses regex-based abbreviation
- Does NOT save tokens at small scales — overhead costs more than it saves on short text
- CAN save tokens at scale — repeated entities across thousands of sessions amortize
- Storage default is raw verbatim text — AAAK is a separate compression layer for context loading
- The 96.6% benchmark score is from raw mode, not AAAK mode

## Diary Format

Agent diaries use AAAK for compact session logs:
```
PR#42|auth.bypass.found|missing.middleware.check|pattern:3rd.time.this.quarter|★★★★
```
