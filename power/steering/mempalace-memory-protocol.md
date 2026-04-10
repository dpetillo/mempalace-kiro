# MemPalace Memory Protocol

## On Session Start

Call `mempalace_status` to load the palace overview, AAAK spec, and memory protocol. This gives you awareness of what wings, rooms, and memories exist.

## When to Search

Search the palace BEFORE answering questions about past work, decisions, or context:

- User asks "what did we decide about X?" → `mempalace_search` with relevant query
- User references a past conversation or decision → search first, then respond
- User asks about a person, project, or topic that may have history → search the relevant wing
- Before making a recommendation that might contradict a past decision → search for prior context

Use wing and room filters to narrow results:
- Know the project? Add `--wing <project-name>`
- Know the topic? Add `--room <topic-name>`
- Broad question? Search without filters

## When to Save

Save to the palace after meaningful exchanges — not every message, but anything worth remembering:

- **Decisions**: "We chose Postgres over MongoDB because..." → `hall_facts`
- **Architecture discussions**: Design tradeoffs, API contracts → `hall_facts`
- **Debugging sessions**: Root cause found, fix applied → `hall_discoveries`
- **Milestones**: Sprint completed, feature shipped → `hall_events`
- **Preferences**: User likes/dislikes, coding style → `hall_preferences`
- **Recommendations**: "Next time, try X approach" → `hall_advice`

Use `mempalace_add_drawer` with:
- Appropriate wing (project or person)
- Appropriate hall (facts, events, discoveries, preferences, advice)
- Verbatim content — do not summarize, store the actual exchange

## When to Use the Knowledge Graph

Use `mempalace_kg_add` to record entity relationships with temporal validity:
- Team assignments: who works on what, when they started
- Technology choices: what stack, when adopted
- Project status changes: started, paused, completed

Use `mempalace_kg_query` to check current state before making assumptions about team composition, project status, or technology choices.

Use `mempalace_kg_invalidate` when facts change — don't delete, mark as ended.

## Save Hook Behavior

A Kiro stop hook injects a save instruction into your context every 10 responses. When you see `[MemPalace Auto-Save]` in your context:

1. **YOU MUST ACT ON THIS IMMEDIATELY** — this is not optional
2. Review the recent conversation for saveable content
3. Call `mempalace_check_duplicate` before filing
4. Call `mempalace_add_drawer` for each distinct memory with:
   - `wing`: the project or person name
   - `hall`: one of facts, events, discoveries, preferences, advice
   - `room`: the specific topic
   - `content`: verbatim text from the conversation
5. Call `mempalace_kg_add` for any entity relationships discovered
6. Be selective — save decisions, discoveries, and facts, not routine exchanges
7. After saving, confirm what you saved to the user

## Available MCP Tools

### Palace (read)
- `mempalace_status` — Palace overview + AAAK spec + memory protocol
- `mempalace_list_wings` — Wings with counts
- `mempalace_list_rooms` — Rooms within a wing
- `mempalace_get_taxonomy` — Full wing → room → count tree
- `mempalace_search` — Semantic search with wing/room filters
- `mempalace_check_duplicate` — Check before filing
- `mempalace_get_aaak_spec` — AAAK dialect reference

### Palace (write)
- `mempalace_add_drawer` — File verbatim content
- `mempalace_delete_drawer` — Remove by ID

### Knowledge Graph
- `mempalace_kg_query` — Entity relationships with time filtering
- `mempalace_kg_add` — Add facts
- `mempalace_kg_invalidate` — Mark facts as ended
- `mempalace_kg_timeline` — Chronological entity story
- `mempalace_kg_stats` — Graph overview

### Navigation
- `mempalace_traverse` — Walk the graph from a room across wings
- `mempalace_find_tunnels` — Find rooms bridging two wings
- `mempalace_graph_stats` — Graph connectivity overview

### Agent Diary
- `mempalace_diary_write` — Write AAAK diary entry
- `mempalace_diary_read` — Read recent diary entries
