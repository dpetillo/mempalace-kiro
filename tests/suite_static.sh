#!/usr/bin/env bash
# suite_static.sh — validates repo structure, no external dependencies needed
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
POWER_DIR="$REPO_DIR/power"
PASS=0; FAIL=0

pass() { echo "  ✓ $1"; PASS=$((PASS+1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }

echo "=== Suite: Static ==="

# 1. POWER.md exists and has frontmatter
if [ -f "$POWER_DIR/POWER.md" ]; then
  if head -1 "$POWER_DIR/POWER.md" | grep -q '^---$'; then
    pass "POWER.md has YAML frontmatter"
  else
    fail "POWER.md missing frontmatter delimiter"
  fi
else
  fail "POWER.md not found"
fi

# 2. Frontmatter has required fields
for field in name displayName description keywords; do
  if grep -q "^${field}:" "$POWER_DIR/POWER.md" 2>/dev/null; then
    pass "POWER.md has '$field' field"
  else
    fail "POWER.md missing '$field' field"
  fi
done

# 3. mcp.json is valid JSON with mcpServers key
if [ -f "$POWER_DIR/mcp.json" ]; then
  if python3 -c "import json; d=json.load(open('$POWER_DIR/mcp.json')); assert 'mcpServers' in d" 2>/dev/null; then
    pass "mcp.json is valid JSON with mcpServers"
  else
    fail "mcp.json invalid or missing mcpServers key"
  fi
else
  fail "mcp.json not found"
fi

# 4. Steering files referenced in POWER.md exist
for f in mempalace-memory-protocol.md mempalace-aaak-spec.md mempalace-palace-architecture.md; do
  if [ -f "$POWER_DIR/steering/$f" ]; then
    if [ -s "$POWER_DIR/steering/$f" ]; then
      pass "steering/$f exists and is non-empty"
    else
      fail "steering/$f is empty"
    fi
  else
    fail "steering/$f not found"
  fi
done

# 5. Install script is executable
if [ -x "$REPO_DIR/install-cli.sh" ]; then
  pass "install-cli.sh is executable"
else
  fail "install-cli.sh is not executable"
fi

if [ -x "$REPO_DIR/uninstall-cli.sh" ]; then
  pass "uninstall-cli.sh is executable"
else
  fail "uninstall-cli.sh is not executable"
fi

# 6. Install scripts have bash shebang
for script in install-cli.sh uninstall-cli.sh; do
  if head -1 "$REPO_DIR/$script" | grep -q '#!/usr/bin/env bash\|#!/bin/bash'; then
    pass "$script has bash shebang"
  else
    fail "$script missing bash shebang"
  fi
done

echo ""
echo "Static: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
