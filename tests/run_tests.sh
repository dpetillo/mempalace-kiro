#!/usr/bin/env bash
# run_tests.sh — test runner for mempalace-kiro
# Usage: ./tests/run_tests.sh --suite static|unit|integration|all
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUITE="${1:-}"

usage() {
  echo "Usage: $0 --suite <static|unit|integration|all>"
  exit 1
}

if [ "$SUITE" = "--suite" ]; then
  SUITE="${2:-}"
fi
# Also accept: ./run_tests.sh static
case "$SUITE" in
  --suite) SUITE="${2:-}"; ;;
  static|unit|integration|all) ;; # already set
  *) usage ;;
esac

run_suite() {
  local suite="$1"
  local script="$SCRIPT_DIR/suite_${suite}.sh"
  if [ ! -f "$script" ]; then
    echo "ERROR: $script not found" >&2
    return 1
  fi
  bash "$script"
}

EXIT=0

case "$SUITE" in
  static)
    run_suite static || EXIT=1
    ;;
  unit)
    run_suite unit || EXIT=1
    ;;
  integration)
    run_suite integration || EXIT=1
    ;;
  all)
    run_suite static || EXIT=1
    echo ""
    run_suite unit || EXIT=1
    echo ""
    run_suite integration || EXIT=1
    ;;
  *)
    usage
    ;;
esac

echo ""
if [ "$EXIT" -eq 0 ]; then
  echo "=== ALL SUITES PASSED ==="
else
  echo "=== SOME SUITES FAILED ==="
fi
exit "$EXIT"
