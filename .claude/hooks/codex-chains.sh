#!/usr/bin/env bash
# Shared helper. Prints the pid of every live codex side-process (app-server broker +
# `codex app-server`). These chains are never reclaimed automatically; accumulated chains
# are the documented cause of OOM waves in small containers.
#
# `pgrep -f 'app-server-broker|codex app-server'` alone is wrong: Claude Code runs each
# Bash tool call through a shell whose argv is the literal command text, so any command
# that merely MENTIONS the pattern matches itself. Filter on /proc/<pid>/comm so only the
# real processes (node running the broker, the codex binary) survive.
codex_chain_pids() {
  local pid comm
  for pid in $(pgrep -f 'app-server-broker\.mjs|codex app-server' 2>/dev/null); do
    comm="$(cat "/proc/$pid/comm" 2>/dev/null || true)"
    case "$comm" in node|codex|codex-*) printf '%s\n' "$pid" ;; esac
  done
}
