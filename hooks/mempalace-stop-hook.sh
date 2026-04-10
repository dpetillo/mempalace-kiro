#!/usr/bin/env bash
# mempalace-stop-hook.sh — Kiro CLI stop hook for MemPalace auto-save
#
# Kiro sends JSON on stdin: {"hook_event_name":"stop","cwd":"...","assistant_response":"..."}
# We count calls and block every SAVE_INTERVAL to force a save.
# Exit 0 = let AI stop. Exit 2 = block, STDERR returned to LLM.
set -euo pipefail

SAVE_INTERVAL="${MEMPALACE_SAVE_INTERVAL:-10}"
STATE_DIR="$HOME/.mempalace/hook_state"
COUNTER_FILE="$STATE_DIR/kiro_stop_count"

mkdir -p "$STATE_DIR"

# Read stdin (Kiro hook event)
INPUT=$(cat)

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

# Check threshold
if [ "$COUNT" -ge "$SAVE_INTERVAL" ]; then
  # Reset counter
  echo "0" > "$COUNTER_FILE"
  echo "[$TIMESTAMP] TRIGGERING SAVE at count $COUNT" >> "$STATE_DIR/hook.log"
  # Exit 2 = block, STDERR goes to LLM as instruction
  echo "AUTO-SAVE checkpoint. Review the recent conversation and save important decisions, discoveries, preferences, and facts to the memory palace using mempalace_add_drawer. Classify into appropriate wing and hall. Be selective — save things worth remembering, not routine exchanges. Then continue." >&2
  exit 2
fi

# Under threshold — let AI stop normally
exit 0
