#!/bin/bash
set -e

MODE="${COPILOT_MODE:-acp}"
PORT="${COPILOT_PORT:-8000}"

case "$MODE" in
  acp)
    exec copilot --add-dir /copilot-home --acp --port "$PORT"
    ;;
  headless)
    exec copilot --add-dir /copilot-home --headless --port "$PORT"
    ;;
  *)
    echo "Unknown COPILOT_MODE: $MODE (expected 'acp' or 'headless')" >&2
    exit 1
    ;;
esac
