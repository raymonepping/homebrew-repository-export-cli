#!/usr/bin/env bash
set -euo pipefail

check_dependencies() {
  local missing=()
  for tool in "$@"; do
    if ! command -v "$tool" &>/dev/null; then
      missing+=("$tool")
    fi
  done
  if (( ${#missing[@]} )); then
    echo "❌ Missing dependencies: ${missing[*]}"
    exit 1
  fi
}

start_timer() {
  TIMER_LABEL="${1:-}"
  TIMER_START=$(date +%s)
}

stop_timer() {
  TIMER_LABEL="${1:-}"
  TIMER_END=$(date +%s)
  local elapsed=$((TIMER_END - TIMER_START))
  if [[ -n "$TIMER_LABEL" ]]; then
    echo "⏱️  [$TIMER_LABEL] Done in ${elapsed}s"
  else
    echo "⏱️  Done in ${elapsed}s"
  fi
}

export -f check_dependencies
export -f start_timer
export -f stop_timer
