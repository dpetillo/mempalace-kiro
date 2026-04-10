#!/usr/bin/env bash
# mempalace-stop-hook.sh — Kiro CLI stop hook for MemPalace auto-save
#
# Kiro stop hook: exit 0, STDOUT added to agent context.
# We count stop events and inject a save instruction every SAVE_INTERVAL.
set -euo pipefail

SAVE_INTERVAL="${MEMPALACE_SAVE_INTERVAL:-10}"
STATE_DIR="$HOME/.mempalace/hook_state"
COUNTER_FILE="$STATE_DIR/kiro_stop_count"

mkdir -p "$STATE_DIR"

# Read stdin (Kiro hook event)
cat > /dev/null

# Get or init counter
COUNT=0
if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
fi
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Log
TIMESTAMP=$(date +%H:%M:%S)
echo "[$TIMESTAMP] Kiro stop hook: count=$COUNT, interval=$SAVE_INTERVAL" >> "$STATE_DIR/hook.log"

# Check threshold — inject save instruction via STDOUT (added to agent context)
if [ "$COUNT" -ge "$SAVE_INTERVAL" ]; then
  echo "0" > "$COUNTER_FILE"
  echo "[$TIMESTAMP] TRIGGERING SAVE at count $COUNT" >> "$STATE_DIR/hook.log"
  echo "[MemPalace Auto-Save] Review the recent conversation and save important decisions, discoveries, preferences, and facts to the memory palace using mempalace_add_drawer. Classify into appropriate wing and hall. Be selective — save things worth remembering, not routine exchanges."
fi

exit 0
