#!/usr/bin/env bash
set -euo pipefail

MEMPALACE_VERSION="3.1.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_PATH="$SCRIPT_DIR/hooks/mempalace-stop-hook.sh"

echo "=== MemPalace Kiro Power — CLI Install ==="

# 1. Check Python
if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 not found. Install Python 3.9+ first." >&2
  exit 1
fi
PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PY_MAJOR=$(echo "$PY_VER" | cut -d. -f1)
PY_MINOR=$(echo "$PY_VER" | cut -d. -f2)
if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 9 ]; }; then
  echo "ERROR: Python 3.9+ required, found $PY_VER" >&2
  exit 1
fi
echo "✓ Python $PY_VER"

# 2. Check kiro-cli
if ! command -v kiro-cli &>/dev/null; then
  echo "ERROR: kiro-cli not found. Install Kiro CLI first." >&2
  exit 1
fi
echo "✓ kiro-cli found"

# 3. Install mempalace via pipx (preferred) or pip
if command -v pipx &>/dev/null; then
  echo "Installing mempalace==$MEMPALACE_VERSION via pipx..."
  pipx install "mempalace==$MEMPALACE_VERSION" 2>/dev/null || pipx upgrade "mempalace==$MEMPALACE_VERSION" 2>/dev/null || true
  MP_PYTHON="$HOME/.local/share/pipx/venvs/mempalace/bin/python3"
  echo "✓ mempalace installed via pipx"
else
  echo "Installing mempalace==$MEMPALACE_VERSION via pip..."
  pip install "mempalace==$MEMPALACE_VERSION" --quiet 2>/dev/null || \
    pip install "mempalace==$MEMPALACE_VERSION" --break-system-packages --quiet
  MP_PYTHON="python3"
  echo "✓ mempalace installed via pip"
fi

# 4. Init palace if needed
if [ ! -d "$HOME/.mempalace" ]; then
  echo "Initializing palace..."
  mempalace init --yes 2>/dev/null || true
  echo "✓ Palace initialized"
else
  echo "✓ Palace already exists"
fi

# 5. Copy steering files globally
mkdir -p "$HOME/.kiro/steering"
for f in "$SCRIPT_DIR"/power/steering/*.md; do
  cp "$f" "$HOME/.kiro/steering/"
done
echo "✓ Steering files installed to ~/.kiro/steering/"

# 6. Register MCP server globally
kiro-cli mcp add --name mempalace --command "$MP_PYTHON" --args "-m" "mempalace.mcp_server" --scope global --force 2>/dev/null || true
echo "✓ MCP server registered globally (available to all agents)"

# 7. Install example mempalace agent
mkdir -p "$HOME/.kiro/agents"
cat > "$HOME/.kiro/agents/mempalace.json" << AGENT
{
  "name": "mempalace",
  "description": "Example agent with MemPalace persistent memory",
  "prompt": "You have access to MemPalace persistent memory. On startup, call mempalace_status. Search the palace before answering questions about past work. Save important decisions and discoveries using mempalace_add_drawer.",
  "tools": ["@builtin", "@mempalace"],
  "allowedTools": ["@mempalace"],
  "hooks": {
    "stop": [{
      "command": "$HOOK_PATH",
      "description": "MemPalace auto-save checkpoint"
    }]
  },
  "welcomeMessage": "MemPalace memory is active."
}
AGENT
echo "✓ Example agent installed to ~/.kiro/agents/mempalace.json"

echo ""
echo "=== Done! ==="
echo ""
echo "Usage:"
echo "  kiro-cli --agent mempalace    # Use the example mempalace agent"
echo ""
echo "To add memory to ANY existing agent, add this to its hooks:"
echo "  \"stop\": [{\"command\": \"$HOOK_PATH\", \"description\": \"MemPalace auto-save\"}]"
echo ""
echo "The MCP server and steering files are global — all agents can"
echo "use mempalace_search, mempalace_add_drawer, etc. The stop hook"
echo "is the only piece that needs to be per-agent."
