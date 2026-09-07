#!/usr/bin/env bash
# SessionStart hook — wired by .claude/settings.json. Two jobs the recorded OOM incidents
# show must not depend on recall:
#   1. reap codex side-process chains whose cwd no longer exists (removed/merged worktrees);
#   2. print the live resource state and the initialisation status, so every session opens
#      knowing its actual headroom and whether preflight has run.
# stdout is injected into the session as context.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$HERE/../.." && pwd)}"
. "$HERE/codex-chains.sh"

reaped=0
for pid in $(codex_chain_pids); do
  cwd="$(readlink "/proc/$pid/cwd" 2>/dev/null || true)"
  # A removed worktree reads as "<path> (deleted)". SIGTERM, never SIGKILL (core dumps).
  case "$cwd" in
    *'(deleted)') kill "$pid" 2>/dev/null && reaped=$((reaped + 1)) ;;
  esac
done

avail_mib=$(( $(awk '/^MemAvailable:/{print $2}' /proc/meminfo 2>/dev/null || echo 0) / 1024 ))
cg_max="$(cat /sys/fs/cgroup/memory.max 2>/dev/null || echo max)"
if [ "$cg_max" = "max" ]; then cg_desc="no cgroup cap"; else cg_desc="$(awk -v b="$cg_max" 'BEGIN{printf "%.2f GiB cgroup cap", b / 1073741824}')"; fi
oom="$(awk '/^oom_kill /{print $2}' /sys/fs/cgroup/memory.events 2>/dev/null || echo '?')"
chains="$(codex_chain_pids | wc -l)"
oleans="$(find "$ROOT/.lake/packages/mathlib/.lake/build/lib" -name '*.olean' 2>/dev/null | wc -l)"
libname="$(sed -n 's/^name = "\(.*\)"$/\1/p' "$ROOT/lakefile.toml" 2>/dev/null | head -1)"

if [ "$libname" = "LeanScaffold" ]; then
  init_state="NOT INITIALISED — this is a fresh scaffold. Do not start mathematical work; run the Init phase of .claude/skills/loop-orchestration-scaffold/SKILL.md first."
else
  contract=""
  for f in "$ROOT"/.claude/skills/*-orchestration/SKILL.md; do
    if [ -f "$f" ]; then
      contract="${f#"$ROOT"/}"
      break
    fi
  done
  if [ -n "$contract" ]; then
    init_state="initialised as ${libname}; the container contract is ${contract}."
  else
    init_state="initialised as ${libname}; no container contract found."
  fi
fi

cat <<EOF
$(basename "$ROOT") session brief (.claude/hooks/session-brief.sh):
- state: ${init_state}
- memory: ${avail_mib} MiB available (${cg_desc}); oom_kill counter = ${oom}
- codex side-process chains alive: ${chains}$( [ "$reaped" -gt 0 ] && printf ' (reaped %s whose worktree was deleted)' "$reaped" )
- mathlib oleans present: ${oleans}. Near zero means \`scripts/bootstrap.sh\` has not run; never
  let \`lake build\` cold-compile mathlib in a small container (hours, and it will OOM).
- Every Lean invocation is gated by the PreToolUse hook .claude/hooks/lean-guard.sh: it must
  hold flock /tmp/lean-build.lock, carry no -M/-j, and start with >= ${LEAN_GUARD_MIN_AVAIL_MIB:-1536} MiB free.
EOF
