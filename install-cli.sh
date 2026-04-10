#!/usr/bin/env bash
set -euo pipefail

MEMPALACE_VERSION="3.1.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

# 3. Install mempalace
echo "Installing mempalace==$MEMPALACE_VERSION..."
pip install "mempalace==$MEMPALACE_VERSION" --quiet
echo "✓ mempalace installed"

# 4. Init palace if needed
if [ ! -d "$HOME/.mempalace" ]; then
  echo "Initializing palace..."
  mempalace init --yes
  echo "✓ Palace initialized"
else
  echo "✓ Palace already exists"
fi

# 5. Copy steering files
mkdir -p "$HOME/.kiro/steering"
for f in "$SCRIPT_DIR"/steering/*.md; do
  cp "$f" "$HOME/.kiro/steering/"
done
echo "✓ Steering files installed to ~/.kiro/steering/"

# 6. Register MCP server
kiro-cli mcp add --name mempalace --command python --args "-m" "mempalace.mcp_server" --scope global --force 2>/dev/null || true
echo "✓ MCP server registered"

echo ""
echo "Done! Start kiro-cli and the mempalace MCP tools will be available."
echo "Run 'mempalace status' to verify your palace."
