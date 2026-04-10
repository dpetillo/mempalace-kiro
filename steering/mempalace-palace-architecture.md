# MemPalace Architecture

## The Palace Metaphor

MemPalace organizes AI memory using the ancient Greek method of loci. Every piece of information has a physical location in the palace.

## Structure

### Wings
Top-level containers — one per project, person, or domain.
- `wing_kai` — everything about Kai
- `wing_driftwood` — everything about the Driftwood project
- `wing_general` — default wing for unclassified content

### Rooms
Specific topics within a wing: `auth-migration`, `graphql-switch`, `ci-pipeline`.

When the same room appears in different wings, a **tunnel** connects them automatically — cross-referencing the same topic across domains.

### Halls
Memory-type corridors, the same in every wing:
- `hall_facts` — decisions made, choices locked in
- `hall_events` — sessions, milestones, debugging
- `hall_discoveries` — breakthroughs, new insights
- `hall_preferences` — habits, likes, opinions
- `hall_advice` — recommendations and solutions

### Closets
Compressed summaries pointing to original content. Currently plain-text summaries; AAAK-encoded closets planned for future.

### Drawers
The original verbatim files. Exact words, never summarized. This is where the 96.6% recall comes from.

### Tunnels
Cross-wing connections. When `auth-migration` exists in both `wing_kai` and `wing_driftwood`, a tunnel links them:
```
wing_kai       / hall_events / auth-migration  → "Kai debugged the OAuth token refresh"
wing_driftwood / hall_facts  / auth-migration  → "team decided to migrate auth to Clerk"
```

## Filing Memories

When saving to the palace:
1. Identify the wing (which project or person?)
2. Identify the hall (what type of memory?)
3. Identify or create the room (what specific topic?)
4. Use `mempalace_check_duplicate` before filing
5. Use `mempalace_add_drawer` with wing, hall, and room metadata

## 4-Layer Memory Stack

| Layer | Content | Size | When Loaded |
|-------|---------|------|-------------|
| L0 | Identity — who is this AI | ~50 tokens | Always |
| L1 | Critical facts — team, projects, preferences | ~120 tokens (AAAK) | Always |
| L2 | Room recall — recent sessions, current project | On demand | When topic surfaces |
| L3 | Deep search — semantic query across all closets | On demand | When explicitly asked |

Startup loads L0 + L1 (~170 tokens). L2 and L3 fire only when needed.

## Structure Improves Search

Tested on 22,000+ real conversation memories:
- Search all closets: 60.9% R@10
- Search within wing: 73.1% (+12%)
- Search wing + hall: 84.8% (+24%)
- Search wing + room: 94.8% (+34%)

Always use wing/room filters when you know the context — it's a 34% retrieval improvement.

## Knowledge Graph

Temporal entity-relationship triples stored in SQLite:
- Every fact has a `valid_from` date
- Invalidated facts get an `ended` date (not deleted)
- Query with `as_of` for historical state
- Use `mempalace_kg_timeline` for chronological entity stories

## Specialist Agents

Agents with independent memory stored in `~/.mempalace/agents/`:
- Each agent gets its own wing and AAAK diary
- Use `mempalace_diary_write` / `mempalace_diary_read` for agent-specific logs
- Use `mempalace_list_agents` to discover available agents
