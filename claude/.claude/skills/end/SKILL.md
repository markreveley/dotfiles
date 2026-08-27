---
name: end
description: End-of-session sweep - persist unpersisted concepts to the right cb-dag, route direction content (strategy, positioning, competitor evaluation) to the private direction repos, audit session memory, package learnings into cb-site blog drafts, graduate scratch surfaces, verify, commit, and report the desk. Use when the user invokes "/end" or says they are wrapping up the session.
---

# /end - close the session with nothing left only in the chat

Invoking this skill is the user's authorization to commit and push the
persistence artifacts it produces (per repo git policy, which otherwise
requires explicit instruction). Destructive operations still confirm.

Pull all touched repos before writing anything: other sessions write these
repos concurrently, and obligations are authored against the live graph,
never from memory (cb:a504).

## Step 1 - worktree and tree hygiene

If the session ran in a worktree, merge to main and clean up (orphans are
/merge-worktrees' job). Otherwise confirm working trees are clean or account
for every uncommitted file before proceeding.

## Step 2 - thread sweep: what exists only in this conversation?

Re-read the thread for: decisions made, conventions settled, findings and
incidents, stances argued, direction content worked through, obligations
created or discovered, tool facts learned, and agent reasoning errors the
user caught. For each, check whether it is already persisted (graph node,
plan record, position doc, operations note, direction doc). Route the
unpersisted by proportionality (cb:a496):

- **Direction content - strategy, positioning, competitor evaluation,
  audience/market analysis, monetization and distribution thinking** ->
  NEVER a public-facing surface: not a README, not docs/, not positions/,
  not chronicles/, not a public graph, not a blog draft. It routes to
  exactly one of two private repos, by subject, as a dated doc in that
  repo's `direction/`:
  - CB-the-system (its positioning, competitors, distribution) ->
    `composablebeliefs/cb-direction`
  - amieval and everything else (the broader operation, cross-system
    strategy) -> `amieval/amieval-direction`
  These two are the only categorical direction destinations; do not create
  others. When a piece mixes checkable claims with strategy, split it: the
  checkable part graduates to the public surface, the strategic part goes
  to direction. Rationale on record in cb-direction's README and
  `direction/2026-06-12-claim-the-eval-vertical.md`: publishing the
  strategic rationale undercuts the credibility the public positioning
  pursues.
- **Stance whose reasoning matters verbatim** -> position document (in the
  repo whose system it is about, per cb:a492), then extract claims into the
  dag through the write flow.
- **Finding or convention with an obvious prescription** -> directive
  straight into the dag (gap as rationale prose or a small design-gap node).
- **Obligation / future work** -> backlog directive: kind action-item,
  tag `lifecycle:discrete`, grounded in deps or a stipulation artifact.
  Verify it is not already done or already on the desk before minting.
- **Tool facts** (editor behaviors, CLI quirks) -> evidence detail on the
  relevant convention node and/or docs/operations.md. Never claims.
- **Agent reasoning errors caught by the user** -> error-pattern node or
  evidence append. Look for rejected approaches ("no, that's wrong
  because..."), missed existing patterns ("we already have X"), unverified
  assumptions, and implicit corrections (the user restating a requirement
  after a misread). Link to existing patterns first (`mix bs list
  kind:error-pattern`, `kind:reasoning-error`); a recurring shape with no
  match seeds a new node, subject `{"ref": "agent", "type": "agent"}`.
  Distinguish what happened from why: observed behavior is a primitive
  ("observed: X"); a theory about the agent's reasoning is a compound
  ("theory: X"). Evidence detail tells the specific story ("agent proposed
  concatenated location field"), never the generic one ("agent made a
  modeling error"). Don't over-assert: one-off slips that feed no future
  reasoning stay in the chat.

All graph writes go through the front door: preflight, record the
tag-overlap review in the evidence detail (overlap is necessary but never
sufficient for conflict), import, verify. Never hand-edit a graph file in a
repo that has a write flow.

## Step 3 - dag routing

Home each belief by the boundary: claims about CB-the-system land in `cb:`
(composable-beliefs); mission, domain, and field-use content lands in the
appropriate belief-collections collection (operator field observations carry
the `anecdote` tag per paradigm:a368; meta-observations about the human-agent
system go to `paradigm:`). Discover what dags exist via `collections.json`
and sibling `manifest.json` files rather than assuming.

- If content belongs to several dags and the homes are clear, write each
  piece to its home and say so.
- If the homing is ambiguous, ask the user, with a recommendation.
- If a touched repo carries **no dag**, tell the user explicitly. Distinguish
  "missing" from "no dag by design" (cb-site carries none deliberately:
  proto-content churns; settled claims graduate to positions later).

## Step 4 - session memory audit

Session memory is an ephemeral cache (cb:a509): project and work state is
banned from it. Scan the memory directory for anything load-bearing that
lives only there and promote it through the write flow (the cb:a504-a506
precedent). Then PRUNE: delete the project-state files, leaving MEMORY.md as
a one-line pointer at the graph (CLAUDE.md Session start + the desk). At
most a thin operator-preferences note survives, and only until the private
overlay collection gives preferences a graph home.

## Step 5 - transcript, chronicle, and scratch graduation

If the session did plan-scale work, persist or postscript its transcript in
the co-located plans convention (plans/<set>/transcript-execution.md).

If the session was **decision-weight** (cb:a540) - it minted or superseded
beliefs grounded in a user:/session: stipulation, settled a stance, or
adjudicated contradictory positions - also persist the thread **verbatim**.
cb:a518 is now landed, so this is a **file duplication, never a reconstruction**
of the real session log (the uuid-keyed `.jsonl` under
`~/.claude/projects/<encoded-project>/` whose name matches this session's id).

Here in step 5, only **choose the destination** and **retro-pair against it** -
do NOT copy the bytes yet. Home the `type: source` doc by subject (knowledge
rule, composable-beliefs `okf/standard/types.md`): strategy/direction threads to
the private direction repos (amieval-direction / cb-direction, by the
cb-direction routing rule), plan-scale dev threads to
`plans/<set>/sessions/<slug>.jsonl`; a continuation of an existing arc appends to
that arc's thread dir. That chosen path is what every `session:` artifact
resolves to, so retro-pair each belief minted this session (cb:a507) with a
`document:` pointer to it now. The directive stays the SSOT and
self-bootstrapping; the verbatim thread is provenance only.

**Defer the physical byte-copy to step 7.** The copy captures the log only up to
the instant it runs, so it must run as late as possible inside the close;
running it here (step 5) loses steps 6-7. The step-7 copy is the committed
record; turns after it - the closing exchange, or any work done after `/end` -
are captured only by **running `/end` again**. (We deliberately use this
in-session copy, not a post-session hook: a SessionEnd finalizer was tried and
removed - too much fragile machinery, a concurrency bug, for ~1-2 closing turns
of no decision content.)

Then write or extend the thread's **chronicle** (cb:a520): a dated prose
narrative in chronicles/ of the repo where the thread centered - where
things stood, the arc with its incidents as story beats, where things stand
now, what the next session inherits. Written for the operator's steering,
never as a dry event list: narrative carries the load, ids stay subordinate
(the inverse of the receipts register). The transcript is the record; the
chronicle is how the human keeps up.
Graduate the tmp/ glue surfaces (lap-log, transcript.md, cards): anything
they surfaced that matters moves to the transcript or the graph; the scratch
files themselves stay untracked and die. Adjudication wire records and
proposal files graduate to the proposals/ dir of the thread's
center-of-gravity plan set - the graph carries the adjudication, the file
carries the provenance.

After the chronicle and transcript exist, retro-pair: append a `document:`
pointer to any evidence minted this session that cites a bare `session:`
slug (cb:a507 - a session ref is a dead end for a fresh agent until the
persistence pipeline lands; cb:a518 is the systemic fix).

## Step 6 - blog packaging (cb-site)

Package learnings that apply to CB or amieval into dated drafts in
`cb-site/posts/drafts/` (private repo: composablebeliefs/cb-site). Instruction,
verbatim from the operator:

> these are as much for me to read to understand what the functionality now
> is as to explain how we got here and why decisions were made as they were.
> this should be less of a sequential recounting and more of an actual blog
> post. concepts should be explained, assume an audience that does not yet
> know what cb is, though is technical enough to read posts with code. do
> not worry about writerly flourishes, do not try to "write", instead focus
> on relaying what you think is consequential in a straightforward style

Separate posts by topic, never by chronology. One draft per genuinely
distinct learning; skip sessions that produced none (routine work is not a
post). Mark each as Draft with origin and audience at the top. House prose
rules apply: no emdashes; state what things are directly. Report performance
claims as anecdote until an eval says otherwise.

Drafts are publication-bound: no direction content (strategy, positioning,
competitor evaluation) in a draft - that routes to the direction repos per
step 2, even when it would make good narrative.

## Step 7 - verify, commit, report

For every touched repo, run its gates before committing: `mix test`,
`mix cb.verify.schema`, `mix cb.generate.claude_md --check` (and
`--check --beliefs okf/beliefs.json` for the okf/ CLAUDE.md),
`mix cb.verify.collection <ns>` for touched collections. Leave green or
report exactly what is red and why.

**As the last write before committing**, do the transcript byte-copy deferred
from step 5: copy the session `.jsonl` byte-for-byte (e.g.
`cp ~/.claude/projects/<encoded>/<session-id>.jsonl <dest>`) to the destination
chosen in step 5, then commit it with the rest. This is the latest-possible
in-`/end` snapshot and the committed record. It cannot capture turns that come
after it (the close, or further work) - by accepted design, that content is
captured by **running `/end` again**. So: if you keep working after a close
sweep, re-run `/end` before you actually exit.

Commit per repo with messages that say what landed and why; push. Close with
the session report:

- what was persisted where (ids, files, commits)
- the live desk: `mix bs list unlinked tag:lifecycle:discrete` per relevant
  graph (note the cross-collection gap, cb:a500, until it is built)
- anything that needs the user: ambiguous homings, red gates, decisions
  deferred

## Step 8 - the close sweeps itself

The close itself surfaces findings: calibration issues, machinery friction,
skill stumbles, observations "worth carrying forward." Persist them before
reporting them - a finding that lives only in the final chat message is the
exact failure this skill exists to prevent. Route by step 2's rules (usually
a desk directive or an evidence append on the node it concerns), then let
the report reference the id.
