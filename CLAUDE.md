# Specify

Spec-driven development project using Spec Kit v0.12.4.

## Governing documents

Read these before planning or implementing. They are authoritative, in this order:

1. **`.specify/memory/constitution.md`** — the project constitution. Eight
   articles (Code Quality, Testing Standards, UX Consistency, plus five
   architectural pillars: Reliability, Security, Cost Optimization, Operational
   Excellence, Performance Efficiency) and nine Quality Gates. Non-negotiable: a
   conflict is resolved by changing the spec/plan/tasks, never by diluting a
   principle.
2. **`.specify/memory/development-loops.md`** — runtime guidance on which
   feedback loop (L0 spec / L1 inner / L2 outer / L3 production) enforces each
   gate, and the latency budget that decides placement.

## The technology-agnostic boundary

- **Constitution and `spec.md` are technology- and provider-agnostic.**
  Principles are rules that survive a change of language, framework, cloud, or
  vendor; specs state what and why. No stack, libraries, schemas, or product
  names belong in either. Never name a vendor or service in governance — if a
  rule cannot be stated without one, it is a plan decision, not a principle.
- **`plan.md` § Technical Context is the only place technology is bound.**
  Everything downstream inherits it.
- The Constitution Check gate in `/speckit-plan` is where the agnostic rules are
  enforced against that concrete binding. It runs twice: before Phase 0 research
  and again after Phase 1 design.

## Loop discipline

- `/speckit-implement` operates in the inner loop (L1): honor L1 gates on every
  task, and stop at each story checkpoint — that checkpoint is the L1→L2 seam.
- Never run L0 commands (`/speckit-plan`, `/speckit-analyze`) inside the inner
  loop; they turn once per feature.
- If implementation reveals the plan is wrong, amend `plan.md`. Never let code
  silently diverge from the plan.
- Do not claim reliability, cost, or performance conformance from local runs —
  those are L2/L3 signals. Article VIII requires data, not intuition.

## Workflow

`constitution` → `specify` → `clarify` → `plan` → `tasks` → `checklist` →
`analyze` → `implement` → `converge` (loops back into `tasks.md`).
