---
name: "mempalace"
version: "0.1.0"
displayName: "MemPalace Persistent Memory"
description: "Give your AI agent persistent long-term memory using MemPalace. Stores conversations verbatim in a local palace architecture backed by ChromaDB and SQLite. 19 MCP tools for search, storage, knowledge graph, and agent diaries."
keywords: ["memory", "remember", "recall", "context", "mempalace", "palace", "persistent memory", "conversation history", "long-term memory", "knowledge graph"]
author: "dpetillo"
---

# MemPalace Persistent Memory

## Onboarding

### Step 1: Validate Python

Verify Python 3.9+ is installed:

```bash
python3 --version
```

If Python is not installed or below 3.9, **stop and ask the user to install Python 3.9+** before proceeding.

### Step 2: Install MemPalace

On systems with externally-managed Python (Debian/Ubuntu), use pipx:

```bash
pipx install mempalace==3.1.0
```

On other systems, pip works:

```bash
pip install mempalace==3.1.0
```

After installing via pipx, the MCP server must be invoked using the pipx venv python. Find it with:

```bash
ls ~/.local/share/pipx/venvs/mempalace/bin/python3
```

If the MCP server fails to connect with `ENOENT` or `ModuleNotFoundError`, update the power's mcp.json command to use this absolute path.

### Step 3: Initialize the palace

If `~/.mempalace/` does not exist, run:

```bash
mempalace init --yes
```

This creates the palace directory structure with wings, halls, and the SQLite/ChromaDB databases.

### Step 4: Verify MCP tools

Call `mempalace_status` to confirm the MCP server is connected and the palace is accessible. This also loads the AAAK spec and memory protocol into context.

### Step 5: Add save hook

Create a stop hook at `.kiro/hooks/mempalace-save.kiro.hook` to auto-save conversation context:

```json
{
  "enabled": true,
  "name": "MemPalace Auto-Save",
  "description": "Periodically saves key topics, decisions, and discoveries to the memory palace",
  "version": "1",
  "when": {
    "type": "userTriggered"
  },
  "then": {
    "type": "askAgent",
    "prompt": "Review the recent conversation for important decisions, discoveries, preferences, and facts. Save them to the memory palace using mempalace_add_drawer with appropriate wing and hall classification. Be selective — save things worth remembering, not routine exchanges."
  }
}
```

# When to Load Steering Files

- Starting a session or needing to recall past context → `mempalace-memory-protocol.md`
- Working with AAAK compressed content or optimizing token usage → `mempalace-aaak-spec.md`
- Filing memories, organizing wings/rooms, or understanding palace structure → `mempalace-palace-architecture.md`
