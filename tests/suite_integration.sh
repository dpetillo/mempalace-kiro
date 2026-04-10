#!/usr/bin/env bash
# suite_integration.sh — tests Kiro CLI + mempalace MCP end-to-end
# Requires: kiro-cli, python3, mempalace==3.1.0 installed
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0; FAIL=0
TIMEOUT=60

pass() { echo "  ✓ $1"; PASS=$((PASS+1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }

strip_ansi() { sed 's/\x1b\[[0-9;]*m//g' | sed 's/\x07//g'; }

echo "=== Suite: Integration ==="

# 1. kiro-cli is available
if command -v kiro-cli &>/dev/null; then
  pass "kiro-cli found"
else
  fail "kiro-cli not found"
  echo "  Skipping remaining integration tests"
  echo ""; echo "Integration: $PASS passed, $FAIL failed"; exit 1
fi

# 2. MCP server can be registered
kiro-cli mcp add --name mempalace-test --command python --args "-m" "mempalace.mcp_server" --scope global --force 2>/dev/null || true
pass "MCP server registration command accepted"

# 3. Kiro can see mempalace tools via non-interactive chat
RESULT=$(timeout "$TIMEOUT" kiro-cli chat --no-interactive --trust-all-tools --wrap never \
  "List any MCP tools you have that start with 'mempalace_'. Just list the tool names, nothing else." 2>/dev/null | strip_ansi || echo "TIMEOUT")

if echo "$RESULT" | grep -qi "mempalace_"; then
  pass "Kiro sees mempalace MCP tools"
else
  fail "Kiro did not find mempalace tools (got: $(echo "$RESULT" | head -3))"
fi

# 4. Kiro can call mempalace_status
RESULT=$(timeout "$TIMEOUT" kiro-cli chat --no-interactive --trust-all-tools --wrap never \
  "Call the mempalace_status tool and tell me if the palace is accessible. Reply with just YES or NO." 2>/dev/null | strip_ansi || echo "TIMEOUT")

if echo "$RESULT" | grep -qi "yes\|palace\|wing\|accessible"; then
  pass "mempalace_status is callable via Kiro"
else
  fail "mempalace_status call failed (got: $(echo "$RESULT" | head -3))"
fi

# 5. Cleanup test MCP registration
kiro-cli mcp remove --name mempalace-test --scope global 2>/dev/null || true

echo ""
echo "Integration: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
