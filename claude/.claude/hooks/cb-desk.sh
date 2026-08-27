#!/usr/bin/env bash
# SessionStart hook: surface the live CB desk when a session opens in the amieval tree.
#
# Structural fix for the cb:a165 pattern: a memory/CLAUDE.md pointer that an agent must
# REMEMBER to act on is procedural surfacing (the cb:a386 antipattern). This injects the
# actual active obligations into context so a fresh agent sees them without having to ask.
# Scoped to the amieval tree; fail-safe and silent everywhere else.
set -uo pipefail

AMIEVAL="/Users/mark/dev/repos/mine/amieval"
proj="${CLAUDE_PROJECT_DIR:-$PWD}"
case "$proj" in
  "$AMIEVAL"|"$AMIEVAL"/*) ;;
  *) exit 0 ;;                      # not the amieval tree -> stay silent
esac

cb="$AMIEVAL/composable-beliefs"
[ -d "$cb" ] || exit 0

# mix compiles on first use; a slow/failed run exits silently rather than blocking the session.
desk="$(cd "$cb" && mix bs list unlinked tag:lifecycle:discrete 2>/dev/null)" || exit 0
[ -n "$desk" ] || exit 0

# shellcheck disable=SC2016  # backticks below are literal markdown, not command substitution
ctx="$(printf '%s\n' \
  '## CB session start (auto-surfaced from the live graph)' \
  '' \
  'You are in the Composable Beliefs ecosystem. Per composable-beliefs/CLAUDE.md "Session start": trust the graph over this prompt, memory, or any handoff. Before acting on a task, follow the relevant directives below to their deps and document:/plan: artifacts.' \
  '' \
  'Active obligations on the desk -- `mix bs list unlinked tag:lifecycle:discrete` (cb:):' \
  '' \
  "$desk")"

python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":sys.stdin.read()}}))' <<<"$ctx" 2>/dev/null || exit 0
