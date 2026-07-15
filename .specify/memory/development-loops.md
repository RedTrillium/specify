# Specify Development Loops

**Status**: Runtime development guidance. Referenced from
`.specify/memory/constitution.md` § Governance.
**Authority**: Subordinate to the constitution. Where this document and the
constitution conflict, the constitution wins and this document MUST be corrected.
**Version**: 1.0.0 | **Last Updated**: 2026-07-14

## Purpose

The constitution defines **what** must hold. This document defines **where and
when** each rule is enforced — which feedback loop owns which gate, and at what
latency. It exists so that gates are placed deliberately rather than defaulting
to "run everything at merge" (too late, expensive rework) or "run everything
locally" (destroys flow).

## How commands use this document

| Command | Directive |
|---|---|
| `/speckit-plan` | When filling Technical Context, MUST state which loop enforces each declared target (reliability, security, cost, performance). A target with no owning loop is not a target. |
| `/speckit-tasks` | MUST place each task in a loop-appropriate phase. Setup/Foundational are L2-owned prerequisites; user-story tasks are L1 work; Polish is L2. |
| `/speckit-checklist` | SHOULD generate checklist items grouped by loop, so L1 items are runnable locally in seconds. |
| `/speckit-analyze` | SHOULD flag any constitution gate that no loop owns as a CRITICAL coverage gap. |
| `/speckit-implement` | Operates in L1. MUST honor L1 gates on every task and MUST stop at each story checkpoint (the L1→L2 seam). |
| `/speckit-converge` | Is the L3→L0 feedback path. MUST append production-discovered gaps to `tasks.md`. |

## The loop model

Four loops. Each has a cadence, an owner, and a hard latency budget. The budget
is the constraint that decides gate placement.

| ID | Loop | Cadence | Scope | Latency budget | Owner |
|---|---|---|---|---|---|
| **L0** | Spec | Per feature | `constitution` → `specify` → `clarify` → `plan` → `tasks` → `analyze` | Hours | Feature author |
| **L1** | Inner | Per task | Implement one task → test → lint | **< 10s per iteration** | Single developer / `/speckit-implement` |
| **L2** | Outer | Per user story | PR → CI → review → merge → deploy | Minutes to hours | Team + CI |
| **L3** | Production | Continuous | Monitor → alert → incident review → converge | Days | On-call / operators |

```text
L0  SPEC ────────► emits tasks.md ──┐
     ▲                              │
     │ plan wrong? amend plan.md    ▼
     │                        L1  INNER  (per task, <10s)
     │                              │  rolls up at story checkpoint
     │                              ▼
     │                        L2  OUTER  (per story)
     │                              │
     │                              ▼
     └──── /speckit-converge ── L3  PRODUCTION
```

**L0 is not a loop the code passes through.** It is the phase that *feeds* L1
with `tasks.md`. Never run L0 commands inside L1.

## Loop membership rules

- A gate MUST be owned by exactly one loop as its **enforcement point**. Inner
  loops MAY run a cheaper subset of an outer gate as early warning, but the
  outer loop remains authoritative.
- Constitution Articles **I (Code Quality)** and **II (Testing Standards)**
  are enforced in **L1**. They are worthless at L2-only latency: test-first
  requires the test to run in seconds.
- Constitution Articles **IV (Reliability)**, **VI (Cost Optimization)**, and
  **VII (Operational Excellence)** are enforced in **L2/L3**. They cannot be
  measured on a developer machine and MUST NOT be faked locally.
- Constitution Articles **III (UX Consistency)** and **VIII (Performance
  Efficiency)** straddle: mechanical checks in L1, judgment and real
  measurement in L2.
- Article **V (Security)** deliberately splits: secret detection is L1 (cheap,
  and a pushed secret is unrecoverable); dependency and boundary analysis is L2.

## Gate placement matrix

The nine constitution Quality Gates, plus the L1 checks that feed them:

| Gate | Article | Loop | Mechanism | Budget |
|---|---|---|---|---|
| Format & lint | I | **L1** | format-on-save, pre-commit | < 1s |
| Unit tests (Red-Green-Refactor) | II | **L1** | test watcher, scoped to task | < 10s |
| Secret detection | V | **L1** | pre-commit hook | < 2s |
| Type check | I | **L1** | editor / watch | < 5s |
| **Story checkpoint** | II, III | **L1→L2 seam** | `quickstart.md` smoke run | Minutes |
| Full suite + contract tests | II | **L2** | CI | Minutes |
| Peer review | I | **L2** | PR — human judgment | Hours |
| UX consistency & accessibility | III | **L2** | PR review | Hours |
| Dependency scan | V | **L2** | CI — needs full graph | Minutes |
| Performance vs declared targets | VIII | **L2** | CI perf job — local numbers lie | Minutes |
| Reliability: failure injection, restore drill | IV | **L2/L3** | staging, scheduled drill | Hours |
| Cost impact | VI | **L2/L3** | plan estimate + cost monitoring | Days |
| Deploy automated / reversible / observable | VII | **L2** | pipeline — it *is* L2 | Minutes |
| Health signals & alerting | IV, VII | **L3** | production monitoring | Continuous |

## Enforcement status

A gate is only real when something executes it. Current wiring:

| Gate | Wired? | Mechanism |
|---|---|---|
| Secret detection | **Yes — enforced** | `.githooks/pre-commit` → `run-l1-gates.ps1 -Staged`. Blocks the commit. |
| Format | **No — unbound** | Awaiting `/speckit-plan` to bind a command in `.specify/loops.json`. |
| Typecheck | **No — unbound** | Same. |
| Test | **No — unbound** | Same. |
| Per-edit gate run | **Not wired** | Requires a `PostToolUse` hook in `.claude/settings.json` (see below). |

**The runner is a mechanism, not a stack decision.**
`.specify/scripts/powershell/run-l1-gates.ps1` never chooses a formatter or test
runner — it executes whatever `.specify/loops.json` declares, using `{file}` as
the changed-file placeholder. This preserves the constitution's rule that
technology is bound only in `plan.md` § Technical Context.

An unbound gate is **skipped with a notice, never silently passed** — consistent
with the anti-pattern below. `/speckit-plan` MUST populate `l1.format`,
`l1.typecheck`, and `l1.test` when it fixes the stack.

Setup required per clone (git does not version `core.hooksPath`):

```sh
git config core.hooksPath .githooks
```

Optional per-edit enforcement — add to `.claude/settings.json`, which makes the
L1 gates run on every agent Write/Edit rather than only at commit:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -NoProfile -ExecutionPolicy Bypass -File .specify/scripts/powershell/run-l1-gates.ps1 -FromHook",
            "timeout": 30,
            "statusMessage": "Running L1 gates..."
          }
        ]
      }
    ]
  }
}
```

Environment note: this machine has Windows PowerShell 5.1 only (no `pwsh`) and no
`jq`, so the runner parses hook stdin itself and is written for 5.1.

## The L1→L2 seam

The seam is already defined in `.specify/templates/tasks-template.md`:

> **Checkpoint**: User Story N should be fully functional and testable independently.

Rules:

- Each story checkpoint IS the L1→L2 handoff. L2 MUST turn once per story, not
  once per feature — this is what makes MVP-first (P1 alone) deliverable.
- A story MUST NOT cross the seam until its L1 gates are green.
- Tasks marked `[P]` MAY be executed in parallel within L1; they still converge
  at the story checkpoint.
- Foundational (Phase 2) blocks all stories and therefore crosses the seam once,
  before any story begins.

## Feedback paths (mandatory)

Skipping these is how spec-driven development decays into documentation theater.
All three MUST be honored:

1. **L1 → L0**: When implementation reveals the plan is wrong, `plan.md` MUST be
   amended. Code MUST NOT silently diverge from the plan; `/speckit-analyze`
   traceability is what detects this.
2. **L3 → L0**: `/speckit-converge` measures the built codebase against
   spec/plan/tasks and appends the gap to `tasks.md`. This is the designed
   closing arrow, not an optional cleanup.
3. **L3 → Constitution**: Repeated incidents of the same class mean a principle
   is missing or wrong. Per Article VII, blameless review produces tracked
   actions; if the action is a principle change, it MUST go through
   `/speckit-constitution` as an explicit MINOR/MAJOR amendment — never as a
   silent reinterpretation.

## Placement decision rule

When introducing any new check, apply in order:

1. Determine the check's **runtime cost** and whether it needs shared
   infrastructure, a full dependency graph, a realistic environment, or a human.
2. Place it in the **innermost loop whose latency budget it fits** while still
   producing a trustworthy signal.
3. If it does not fit L1 but a cheaper approximation does, put the approximation
   in L1 as early warning and keep the authoritative check at L2.
4. Record the owning loop in `plan.md`. A check with no owning loop MUST NOT be
   claimed as enforced.

## Anti-patterns

- **Gate hoarding at L2** — deferring all nine gates to merge. Contradicts the
  constitution's own rationale that problems are cheapest to prevent early.
- **L0 inside L1** — running `/speckit-plan` or `/speckit-analyze` per task.
  Wrong altitude and far too slow.
- **Faking L2 signals in L1** — asserting reliability, cost, or performance from
  a laptop. Article VIII requires data, not intuition; a local number is not data.
- **Seam skipping** — merging a story whose checkpoint was never demonstrated.
- **Silent divergence** — implementing something the plan does not describe
  rather than amending the plan.
- **Unowned gates** — a constitution gate that no loop enforces. It is
  aspiration, not governance.

## Command → loop map

| Loop | Commands |
|---|---|
| **L0** | `/speckit-constitution`, `/speckit-specify`, `/speckit-clarify`, `/speckit-plan`, `/speckit-tasks`, `/speckit-checklist`, `/speckit-analyze` |
| **L1** | `/speckit-implement` |
| **L1→L2** | `/speckit-taskstoissues` (fans tasks out to the shared loop) |
| **L3→L0** | `/speckit-converge` |
