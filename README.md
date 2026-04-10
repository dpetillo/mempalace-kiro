# mempalace-kiro

A [Kiro Power](https://kiro.dev/powers/) that gives your AI agent persistent long-term memory using [MemPalace](https://github.com/milla-jovovich/mempalace).

MemPalace stores your conversations verbatim in a local palace architecture (wings, rooms, halls) backed by ChromaDB and SQLite. This Power wraps the upstream `mempalace` PyPI package and replaces the Claude Code integration with Kiro's Power system.

## Quick Start (Kiro IDE)

1. Open Kiro IDE (0.7+)
2. Go to Powers panel → **Add power from GitHub**
3. Enter: `https://github.com/dpetillo/mempalace-kiro/tree/main/power`
4. The Power installs and onboarding runs automatically

## Quick Start (Kiro CLI)

```bash
git clone https://github.com/dpetillo/mempalace-kiro.git
cd mempalace-kiro
./install-cli.sh
```

This installs:
- `mempalace==3.1.0` via pipx (or pip fallback)
- MCP server registered globally (available to all agents)
- Steering files in `~/.kiro/steering/` (available to all agents)
- Example `mempalace` agent in `~/.kiro/agents/`

Then: `kiro-cli --agent mempalace`

## Adding Memory to Any Agent

The MCP server and steering files are global — every agent can use mempalace tools. The only per-agent piece is the stop hook for auto-save.

Add this to any agent's config (`~/.kiro/agents/your-agent.json`):

```json
{
  "hooks": {
    "stop": [{
      "command": "/path/to/mempalace-kiro/hooks/mempalace-stop-hook.sh",
      "description": "MemPalace auto-save checkpoint"
    }]
  }
}
```

The hook counts responses and every 10th one (configurable via `MEMPALACE_SAVE_INTERVAL` env var) blocks the AI and tells it to save important context to the palace.

### What's global vs per-agent

| Component | Scope | How |
|-----------|-------|-----|
| MCP server (19 tools) | Global | `~/.kiro/settings/mcp.json` |
| Steering files | Global | `~/.kiro/steering/mempalace-*.md` |
| Stop hook (auto-save) | Per-agent | `hooks.stop` in agent JSON |

## How It Works

| Component | What it does |
|-----------|-------------|
| `power/POWER.md` | IDE Power: onboarding + steering map |
| `power/mcp.json` | MCP server config |
| `power/steering/` | Memory protocol, AAAK spec, palace architecture |
| `hooks/mempalace-stop-hook.sh` | CLI stop hook: blocks every N responses to force save |
| `agents/mempalace.json` | Example standalone agent with everything wired |

## Architecture: Claude Code → Kiro Mapping

| MemPalace (Claude Code) | mempalace-kiro (Kiro) |
|---|---|
| `.claude-plugin/plugin.json` | `power/POWER.md` frontmatter |
| `.claude-plugin/.mcp.json` | `power/mcp.json` + global `~/.kiro/settings/mcp.json` |
| `.claude-plugin/skills/` | `power/steering/` + global `~/.kiro/steering/` |
| `.claude-plugin/hooks/` (Stop) | `hooks/mempalace-stop-hook.sh` in agent `hooks.stop` |
| `.claude-plugin/hooks/` (PreCompact) | No Kiro equivalent — compensated by lower save interval |
| `CLAUDE.md` one-liner | Steering files auto-loaded globally |

## Test Suites

```bash
./tests/run_tests.sh static       # Validates repo structure (no deps)
./tests/run_tests.sh unit         # Tests mempalace package (needs Python)
./tests/run_tests.sh integration  # Tests Kiro CLI E2E (needs kiro-cli, run outside kiro-cli)
./tests/run_tests.sh all
```

## Monitoring the Save Hook

```bash
# Watch saves in real-time
tail -f ~/.mempalace/hook_state/hook.log

# Check current counter
cat ~/.mempalace/hook_state/kiro_stop_count

# Lower the interval for testing
MEMPALACE_SAVE_INTERVAL=3 kiro-cli --agent mempalace
```

## Upstream

Depends on [mempalace](https://pypi.org/project/mempalace/) PyPI package (pinned to 3.1.0).
Fork at [dpetillo/mempalace](https://github.com/dpetillo/mempalace) for upstream contributions.

## License

MIT — see [LICENSE](LICENSE).
