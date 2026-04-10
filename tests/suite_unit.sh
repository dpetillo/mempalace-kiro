#!/usr/bin/env bash
# suite_unit.sh — tests mempalace package and hook logic (needs Python 3.9+)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_PALACE="/tmp/mempalace-test-$$"
PASS=0; FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS+1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }
cleanup() { rm -rf "$TEST_PALACE"; }
trap cleanup EXIT

echo "=== Suite: Unit ==="

# 1. mempalace is importable
if python3 -c "import mempalace" 2>/dev/null; then
  pass "mempalace is importable"
else
  fail "mempalace not importable (run: pip install mempalace==3.1.0)"
  echo "  Skipping remaining unit tests"
  echo ""; echo "Unit: $PASS passed, $FAIL failed"; exit 1
fi

# 2. mempalace version check
INSTALLED=$(python3 -c "import importlib.metadata; print(importlib.metadata.version('mempalace'))" 2>/dev/null || echo "unknown")
if [ "$INSTALLED" = "3.1.0" ]; then
  pass "mempalace version is 3.1.0"
else
  fail "mempalace version is $INSTALLED, expected 3.1.0"
fi

# 3. mempalace init creates expected structure
mkdir -p "$TEST_PALACE"
cp "$REPO_DIR/tests/fixtures/test-content.md" "$TEST_PALACE/"
if timeout 30 mempalace init "$TEST_PALACE" --yes &>/dev/null; then
  pass "mempalace init succeeded"
else
  fail "mempalace init failed"
fi

# 4. Mine test fixture
if timeout 30 mempalace --palace "$TEST_PALACE" mine "$TEST_PALACE" &>/dev/null; then
  pass "mempalace mine succeeded on test fixtures"
else
  fail "mempalace mine failed"
fi

# 5. Search round-trip
SEARCH_RESULT=$(timeout 30 mempalace --palace "$TEST_PALACE" search "MEMPALACE_TEST_CONTENT_XYZ" 2>/dev/null || echo "")
if echo "$SEARCH_RESULT" | grep -qi "test\|content\|driftwood\|auth\|clerk"; then
  pass "mempalace search found test content"
else
  fail "mempalace search did not find test content"
fi

# 6. MCP server module is importable
if python3 -c "import mempalace.mcp_server" 2>/dev/null; then
  pass "mempalace.mcp_server is importable"
else
  fail "mempalace.mcp_server not importable"
fi

echo ""
echo "Unit: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
