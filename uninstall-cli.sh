#!/usr/bin/env bash
set -euo pipefail

echo "=== MemPalace Kiro Power — CLI Uninstall ==="

# 1. Remove MCP server
kiro-cli mcp remove --name mempalace --scope global 2>/dev/null || true
echo "✓ MCP server removed"

# 2. Remove steering files
for f in mempalace-memory-protocol.md mempalace-aaak-spec.md mempalace-palace-architecture.md; do
  rm -f "$HOME/.kiro/steering/$f"
done
echo "✓ Steering files removed"

# 3. Uninstall pip package (optional — ask first)
read -rp "Uninstall mempalace pip package? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  pip uninstall mempalace -y --quiet 2>/dev/null || true
  echo "✓ mempalace uninstalled"
else
  echo "  Skipped pip uninstall"
fi

echo ""
echo "Done. Palace data in ~/.mempalace/ was NOT removed."
echo "Delete it manually if you want to remove all memory data."
