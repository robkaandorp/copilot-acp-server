#!/bin/bash
set -e

MODE="${COPILOT_MODE:-acp}"
PORT="${COPILOT_PORT:-8000}"
LOG_LEVEL="${COPILOT_LOG_LEVEL:-info}"
LOG_DIR="/root/.copilot/logs"

mkdir -p "$LOG_DIR"

case "$MODE" in
  acp)
    CMD="copilot --add-dir /copilot-home --acp --port $PORT --log-level $LOG_LEVEL --log-dir $LOG_DIR"
    ;;
  headless)
    CMD="copilot --add-dir /copilot-home --headless --port $PORT --log-level $LOG_LEVEL --log-dir $LOG_DIR"
    ;;
  *)
    echo "Unknown COPILOT_MODE: $MODE (expected 'acp' or 'headless')" >&2
    exit 1
    ;;
esac

# Start copilot in the background
$CMD &
COPILOT_PID=$!

# Wait briefly for the log file to appear, then tail it to stdout
sleep 1
LOG_FILE=$(ls -t "$LOG_DIR"/*.log 2>/dev/null | head -1)
if [ -n "$LOG_FILE" ]; then
  tail -f "$LOG_FILE" &
  TAIL_PID=$!
fi

# Forward signals to copilot process
trap 'kill $COPILOT_PID 2>/dev/null; [ -n "$TAIL_PID" ] && kill $TAIL_PID 2>/dev/null; wait' SIGTERM SIGINT

# Wait for copilot to exit
wait $COPILOT_PID
EXIT_CODE=$?
[ -n "$TAIL_PID" ] && kill $TAIL_PID 2>/dev/null
exit $EXIT_CODE
