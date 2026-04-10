# mempalace-kiro

A [Kiro Power](https://kiro.dev/powers/) that gives your AI agent persistent long-term memory using [MemPalace](https://github.com/milla-jovovich/mempalace).

MemPalace stores your conversations verbatim in a local palace architecture (wings, rooms, halls) backed by ChromaDB and SQLite. This Power wraps the upstream `mempalace` PyPI package and replaces the Claude Code integration with Kiro's Power system.

## Quick Start (Kiro IDE)

1. Open Kiro IDE (0.7+)
2. Go to Powers panel → **Add power from GitHub**
3. Enter: `https://github.com/dpetillo/mempalace-kiro/tree/main/power`
4. The Power installs and onboarding runs automatically

When you mention memory, recall, or past decisions in conversation, Kiro activates the Power and loads the relevant steering files.

## Quick Start (Kiro CLI)

Powers aren't in the CLI yet, so use the install script:

```bash
git clone https://github.com/dpetillo/mempalace-kiro.git
cd mempalace-kiro
./install-cli.sh
```

This installs `mempalace==3.1.0`, initializes the palace, copies steering files to `~/.kiro/steering/`, and registers the MCP server.

To uninstall: `./uninstall-cli.sh`

## How It Works

MemPalace provides 19 MCP tools for search, storage, knowledge graph, and agent diaries. This Power tells Kiro when and how to use them.

| Component | What it does |
|-----------|-------------|
| `POWER.md` | Onboarding (pip install, init, hook setup) + steering map |
| `mcp.json` | Registers `python -m mempalace.mcp_server` as MCP server |
| `steering/mempalace-memory-protocol.md` | When to search, save, and use the knowledge graph |
| `steering/mempalace-aaak-spec.md` | AAAK compression dialect reference |
| `steering/mempalace-palace-architecture.md` | Wings/rooms/halls structure and filing guide |

## Architecture: Claude Code → Kiro Mapping

| MemPalace (Claude Code) | mempalace-kiro (Kiro) |
|---|---|
| `.claude-plugin/plugin.json` | `POWER.md` frontmatter |
| `.claude-plugin/.mcp.json` | `mcp.json` |
| `.claude-plugin/skills/` | `steering/` files |
| `.claude-plugin/hooks/` (Stop, PreCompact) | Kiro stop hook (defined in POWER.md onboarding) |
| `.claude-plugin/commands/` (slash commands) | Steering guidance (AI discovers tools via `mempalace_status`) |
| `CLAUDE.md` one-liner | `POWER.md` keywords trigger auto-activation |

## Test Suites

```bash
# Static — validates repo structure (no dependencies)
./tests/run_tests.sh static

# Unit — tests mempalace package (needs Python 3.9+)
./tests/run_tests.sh unit

# Integration — tests Kiro CLI + MCP end-to-end (needs kiro-cli + Python)
./tests/run_tests.sh integration

# All suites
./tests/run_tests.sh all
```

## Upstream

This Power depends on the [mempalace](https://pypi.org/project/mempalace/) PyPI package (pinned to 3.1.0). The upstream repo is at [milla-jovovich/mempalace](https://github.com/milla-jovovich/mempalace). A fork is maintained at [dpetillo/mempalace](https://github.com/dpetillo/mempalace) for potential upstream contributions.

## License

MIT — see [LICENSE](LICENSE).
