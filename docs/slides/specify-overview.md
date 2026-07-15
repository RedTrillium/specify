---
marp: true
paginate: true
theme: specify
title: Specify — Spec-Driven Development
description: Constitution, the tech-agnostic boundary, the flow and gates, and the four development loops.
author: Specify
---

<!--
Specify overview deck.

Render (no install needed — uses npx):
  npx @marp-team/marp-cli@latest docs/slides/specify-overview.md --pdf
  npx @marp-team/marp-cli@latest docs/slides/specify-overview.md --html
  npx @marp-team/marp-cli@latest docs/slides/specify-overview.md --pptx
  npx @marp-team/marp-cli@latest docs/slides/specify-overview.md --watch   # live preview

Source of truth for this content:
  .specify/memory/constitution.md        (v2.1.1 — 8 articles, 9 quality gates)
  .specify/memory/development-loops.md   (v1.0.0 — L0..L3, gate placement)
  .specify/templates/plan-template.md    (the Constitution Check gate)

If those change, this deck is stale. It is a view, not a source.

External reference — Part zero, the Agent/Harness/Loop/Factory vocabulary, and
the CapEx/OpEx framing are drawn from, and credited to:

  Addy Osmani, Shubham Saboo & Sokratis Kartakis,
  "The New SDLC With Vibe Coding: From ad-hoc prompting to Agentic Engineering",
  May 2026.
  https://drive.google.com/file/d/1IR7CddF_2FyQo_PdfBNTaEA50EGiVt2r/view

  Dated by its authors: they note the phase boundaries "may look different in
  12 months". Statistics cited are as of early 2026. Re-check before reuse.
-->

<style>
/* @theme specify */
@import 'default';

:root {
  --ground: #F5F6F8;
  --surface: #FFFFFF;
  --ink: #1B2130;
  --muted: #5C6678;
  --faint: #8892A4;
  --line: #DDE1E8;
  --l0: #5C6678;
  --l1: #0E7C86;
  --l2: #B4791F;
  --l3: #A2434B;
  --pass: #2E7D57;
  --mono: "Cascadia Code", Consolas, ui-monospace, monospace;
}

section {
  background: var(--ground);
  color: var(--ink);
  font-family: "Segoe UI", system-ui, sans-serif;
  font-size: 24px;
  padding: 60px 70px;
  line-height: 1.55;
}

section h1 {
  font-size: 1.9em;
  font-weight: 650;
  letter-spacing: -0.02em;
  color: var(--ink);
  margin-bottom: 0.3em;
}
section h2 {
  font-size: 1.35em;
  font-weight: 620;
  letter-spacing: -0.01em;
  border-bottom: 2px solid var(--ink);
  padding-bottom: 0.25em;
  margin-bottom: 0.6em;
}
section h3 {
  font-size: 1em;
  font-weight: 620;
  color: var(--l1);
  margin-bottom: 0.2em;
}

section code {
  font-family: var(--mono);
  background: #0E7C8618;
  color: var(--l1);
  padding: 0.08em 0.3em;
  border-radius: 3px;
  font-size: 0.85em;
}
section pre {
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 5px;
  font-size: 0.62em;
  line-height: 1.5;
}
section pre code { background: transparent; color: var(--ink); }

section table {
  font-size: 0.68em;
  border-collapse: collapse;
  margin: 0.4em 0;
}
section th {
  font-family: var(--mono);
  font-size: 0.82em;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--faint);
  background: #EDEFF3;
  border-bottom: 1px solid var(--line);
  text-align: left;
}
section td { border-bottom: 1px solid var(--line); vertical-align: top; }

section strong { color: var(--ink); font-weight: 650; }
section em { color: var(--muted); font-style: normal; }

section footer { font-family: var(--mono); font-size: 11px; color: var(--faint); }
section::after {
  font-family: var(--mono);
  font-size: 13px;
  color: var(--faint);
}

/* lead / title slides */
section.lead {
  background: var(--ink);
  color: #E6E9EF;
}
section.lead h1 { color: #FFFFFF; font-size: 2.4em; }
section.lead h2 { border: none; color: var(--l1); font-size: 1em; letter-spacing: 0.12em; text-transform: uppercase; font-family: var(--mono); }
section.lead p { color: #99A2B4; }
section.lead strong { color: #FFFFFF; }
section.lead code { background: #34B3BE1F; color: #34B3BE; }

/* section dividers */
section.divider {
  background: var(--ink);
  color: #E6E9EF;
  justify-content: center;
}
section.divider h1 { color: #FFFFFF; border: none; }
section.divider p { color: #99A2B4; font-size: 0.85em; }
section.divider .num {
  font-family: var(--mono);
  color: var(--l1);
  letter-spacing: 0.14em;
  text-transform: uppercase;
  font-size: 0.6em;
}

.tag {
  font-family: var(--mono);
  font-size: 0.62em;
  letter-spacing: 0.06em;
  padding: 0.15em 0.45em;
  border-radius: 3px;
  border: 1px solid;
}
.l1 { color: var(--l1); border-color: var(--l1); background: #0E7C8618; }
.l2 { color: var(--l2); border-color: var(--l2); background: #B4791F18; }
.l3 { color: var(--l3); border-color: var(--l3); background: #A2434B18; }
.ok { color: var(--pass); border-color: var(--pass); background: #2E7D5718; }

.small { font-size: 0.72em; color: var(--muted); }
.cols { display: flex; gap: 1.5em; }
.cols > * { flex: 1; }
</style>

<!-- _class: lead -->
<!-- _paginate: false -->

## Spec-Driven Development

# Specify

An agent will build what you ask — quickly, tirelessly,
and never quite the same way twice.

**Rules → enforced by the harness → checked at gates → run in loops.**

<span class="small">Spec Kit v0.12.4 · constitution v2.1.1 · loops v1.0.0 · 2026-07-14</span>

---

## The argument

Six parts. Each one answers the question the part before it raises.

| | The question | The answer | Part |
|---|---|---|---|
| **0** | Why is any of this suddenly urgent? | AI compressed the SDLC — but **unevenly**. | Why Now |
| **1** | An agent is fast but never predictable. So how can you trust what it builds? | You can't review every path. Constrain **outcomes** instead. | The Vocabulary |
| **2** | Fine — what are the rules? | Eight articles. Nine quality gates. | The Constitution |
| **3** | Rules must outlive the stack. So where is technology allowed to live? | In the plan. Nowhere else. | The Boundary |
| **4** | Who checks the rules against the plan? | Gates — and there are three different kinds. | The Flow |
| **5** | *When* does each gate run? | Latency decides. | The Loops |

<span class="small">The through-line: **you cannot inspect an agent's reasoning, so you inspect its output — at a place, at a time, by a machine.** Everything else is detail.</span>

---

<!-- _class: divider -->

<span class="num">Part zero · why now</span>

# The SDLC Is Changing

*Not into a faster version of itself. Into a different shape.*

---

## Compressed — but unevenly

Software already survived one transformation: waterfall → Agile, CI, DevOps. Feedback loops shortened; deployment became continuous.

AI is doing it again. **Not evenly.**

> "AI compresses this cycle dramatically, but **unevenly**: implementation that once took weeks can now be done in hours, while requirements, architecture, and verification remain **stubbornly human-paced**."

<div class="cols">
<div>

| As of early 2026 | |
|---|---|
| Professional devs using AI coding agents | **85%** |
| Using them **daily** | **51%** |
| Of all new code that is AI-generated | **~41%** |

</div>
<div>

**So the result is not a faster old SDLC. It is a different workflow.**

Phase boundaries blur. Iteration drops from weeks to minutes. The developer moves from primary implementor to **system designer and quality arbiter**.

</div>
</div>

<span class="small">Osmani, Saboo & Kartakis, *The New SDLC With Vibe Coding: From ad-hoc prompting to Agentic Engineering*, May 2026. **That one word — unevenly — is the seed of this entire deck.**</span>

---

## Vibe coding → agentic engineering

Not a binary. A spectrum. The differentiator is **not whether you use AI** — it is how much structure, verification, and judgment surrounds its output.

| Dimension | Vibe coding | Structured AI-assisted | **Agentic engineering** |
|---|---|---|---|
| Intent | Casual prompts | Detailed prompts + constraints | **Formal specs, architecture docs, memory files** |
| Verification | *"Does it seem to work?"* | Manual spot-checking | **Automated suites, CI/CD gates** |
| Error handling | Paste the error back | Dev diagnoses, AI fixes | **Agents self-diagnose within bounds** |
| Scope | Prototypes, hackathons | Features in known codebases | **Production, team-scale** |
| Risk | High | Moderate | **Low — systematic verification** |

**Specify is the right-hand column.** Constitution = the memory file. Gates = the verification. Loops = the feedback.

<span class="small">**And that is a cost, not a virtue.** A weekend prototype *should* be vibe-coded — the ceremony would be pure waste. The skill is knowing where to draw the line per task. This deck is for the right-hand end: *"telling a CTO your team is vibe coding the payment system will, and should, raise alarm bells."*</span>

---

<!-- _class: divider -->

<span class="num">Part one · the problem</span>

# The Vocabulary

Agent · Harness · Loop · Factory

*Four words that explain why a folder full of governance exists at all.*

---

## Four words, one ladder

Each layer adds something the one below it cannot do alone.

| Layer | What it is | What it adds | Here |
|---|---|---|---|
| Model | Predicts the next token | Capability | Claude |
| **Agent** | Model + goal + tools + a loop | **Agency** — it acts, not just answers | `/speckit-implement` |
| **Harness** | The runtime that lets it act | **Enforcement** — deterministic rules | Claude Code |
| **Loop** | act → observe → correct | **Self-correction** — via a signal | L0 · L1 · L2 · L3 |
| **Factory** | Governed, repeatable production | **Consistency at scale** | **Specify** |

### The equation worth memorising

# Agent = Model + Harness

<span class="small">Vocabulary and framing throughout this part follow Osmani, Saboo & Kartakis, May 2026. A model alone is autocomplete. An agent without a harness is a demo. A harness without a factory is a fast way to make a mess — consistently, at volume.</span>

---

## Agent

**A model in a loop, with tools and a goal.** It reads, decides, acts, observes the result, and repeats — until the goal is met or it gives up.

<div class="cols">
<div>

### What makes it an agent
- A **goal** that persists across steps
- **Tools** — it changes the world, not just the transcript
- A **loop** — it sees the result of its last action
- **Autonomy** over the path taken

</div>
<div>

### The property that matters
It is **non-deterministic**.

Same task, same repo, different route — and sometimes a different answer.

*This is the entire reason governance and gates exist. You cannot review every path. You can only constrain the outcomes.*

</div>
</div>

**Here:** `/speckit-implement` working through `tasks.md` is the agent. It is fast, tireless, and confidently wrong at a rate greater than zero.

---

## Harness

**The runtime that turns a model into an agent** — tool definitions, permissions, context loading, sandbox, and hooks.

**The model proposes. The harness disposes.**

| The harness controls | In Claude Code |
|---|---|
| What tools exist | Read, Edit, Bash, … |
| What is allowed without asking | permission modes, allow/deny rules |
| What context loads every session | `CLAUDE.md` |
| What runs automatically on an event | **hooks** (`settings.json`) |

### The insight that shapes everything downstream

A rule in a **prompt** is a suggestion — the model may forget it.
A rule in the **harness** is a law — it executes whether the model cooperates or not.

> "Guardrails or Hooks: deterministic code that runs at specific lifecycle points: before a tool call, **after a file edit, before a commit**. Hooks are the place for **things the agent should never forget but often does**."

**That is why the L1 gates are a pre-commit hook and a `PostToolUse` hook — not a paragraph asking nicely.** The paper names our two hooks exactly.

<span class="small">And note whose problem this is: *"If that sounds like a lot of surface area, it is. And it is the team's surface area, not the model provider's."*</span>

---

## Context engineering

> "The quality of AI-generated code depends **less on the cleverness of your prompts** and more on the quality of the context provided."

The harness decides what the agent *knows*. That decision splits in two:

| | Loaded | What it costs | Here |
|---|---|---|---|
| **Static** | Always — every turn | **Every token, every interaction**, relevant or not | `CLAUDE.md` |
| **Dynamic** | On demand, when the task matches | Paid only when actually needed | `.claude/skills/speckit-*`, `constitution.md`, `development-loops.md` |

### Which is why `CLAUDE.md` is a pointer, not a copy

Too much static context burns tokens and **dilutes the signal**. Too little and the agent forgets the rules.

So `CLAUDE.md` stays small and *points at* the constitution instead of pasting it. The speckit commands load `constitution.md` by name when they run; the constitution points on to the loops doc. **Static index, dynamic detail.**

> "The best systems treat this boundary as a **first-class architectural decision**, reviewed and versioned like any other configuration."

<span class="small">This is also a money decision, not just a design one — the paper calls context engineering "a financial lever": passing a 100,000-token repository into every prompt is financially unviable at scale. Hold that thought until the economics slide.</span>

---

## Loop

**act → observe → correct.** The unit of self-correction. Without a signal coming back, it is not a loop — it is just a sequence.

Two nested senses, and the deck uses both:

```text
  ┌─ THE AGENT LOOP ── seconds ─────────────────────┐
  │  tool call → result → next decision → …         │
  └─────────────────────────────────────────────────┘
        nests inside ▼
  ┌─ THE DEVELOPMENT LOOPS ─────────────────────────┐
  │  L0 spec · L1 inner · L2 outer · L3 production   │
  └─────────────────────────────────────────────────┘
```

The agent's own loop lives **inside** L1. Its signal is a tool result.
L1's signal is a test. L2's is CI and review. L3's is production.

**A gate is just a loop's signal made mandatory.**

---

## Factory

> "The developer's primary output is **not code — it's the system that produces code**: specifications, agents, tests and quality gates, feedback loops, and guardrails."

**A factory manager does not assemble every widget by hand.** They design the assembly line and ensure quality control.

<span class="small">The factory model is Osmani, Saboo & Kartakis's framing (May 2026), not ours — a pattern, not a spec.</span>

Specify **is** the factory. The metaphor is load-bearing:

| Factory | Specify |
|---|---|
| Standards manual | `constitution.md` — 8 articles |
| Jigs & fixtures | `.specify/templates/` |
| Stations on the line | `/speckit-specify` → `plan` → `tasks` → `implement` |
| QA stations | Gates A–E, the nine quality gates |
| Andon cord — stop the line | A failing gate blocks the merge |
| Field returns | `/speckit-converge` |

**Why it matters with agents:** they are cheap, fast, and tireless — so they multiply throughput **and** defects. A factory is what makes volume safe.

---

## So the factory needs a rulebook

The chain so far:

**Agent** acts on its own → you cannot review every path
→ so you constrain **outcomes**, not paths
→ outcomes are constrained by **rules**
→ rules only bind if the **harness** enforces them
→ and the whole system that makes this repeatable is the **factory**.

### Which leaves exactly one question

**What are the rules?**

That is the constitution — and it is the next part.

---

<!-- _class: divider -->

<span class="num">Part two · the rules</span>

# The Constitution

Rules that outlive the stack.

*A factory needs a rulebook. Here it is — eight articles, nine gates.*

---

## Eight articles

<div class="cols">
<div>

**Craft — enforced locally**

1. **Code Quality** *(non-negotiable)*
2. **Testing Standards** *(non-negotiable)*
3. **User Experience Consistency**

</div>
<div>

**Architectural pillars**

4. **Reliability**
5. **Security**
6. **Cost Optimization**
7. **Operational Excellence**
8. **Performance Efficiency**

</div>
</div>

<span class="small">Articles IV–VIII are the five pillars of architectural excellence — an industry-standard set common to every major cloud architecture framework, and deliberately stated here without vendor attribution. Adding them removed the old standalone "Performance Requirements" article, which conflicted with and is now absorbed by Performance Efficiency; that removal is why the bump to v2.0.0 was MAJOR.</span>

---

## Nine quality gates

Every change must pass all nine before merge:

| Gate | Article | Gate | Article |
|---|---|---|---|
| Lint & format | I | Reliability | IV |
| Tests | II | Security | V |
| Review | I | Cost | VI |
| UX | III | Operations | VII |
| Performance | VIII | | |

**Waivers** must be recorded, cite the specific principle, and include a remediation plan.

**Cross-pillar trade-offs** (reliability vs. cost) must be made deliberately and recorded in the plan — "better" means the balanced outcome, not maximizing one pillar.

---

<!-- _class: divider -->

<span class="num">Part three · the constraint</span>

# The Boundary

Where technology is allowed to exist.

*A rule that names a vendor dies at the next migration. So rules name none.*

---

## Constitution and spec are technology-agnostic

The constitution holds **rules**. The plan holds **realizations**.

<div class="cols">
<div>

### Rule — survives a migration

> "Every feature MUST declare measurable performance targets before implementation."

*Lives in `constitution.md`. Still true after you change database.*

</div>
<div>

### Realization — rewritten per feature

> "p95 < 200 ms on Postgres 16"

*Lives in `plan.md` § Technical Context.*

</div>
</div>

The constitution says *"MUST pass the project's configured linter"* — **not** a named linter.
It says *"secrets in a managed secret store"* — **not** a named vault product.

**Provider neutrality is a rule, not a preference.** Governance never names a vendor, cloud, or service. A rule that cannot be stated without one is a plan decision wearing a principle's clothes.

---

## Where technology binds

| Artifact | Command | Tech-agnostic? |
|---|---|---|
| Constitution | `/speckit-constitution` | **Yes** |
| Spec — what & why | `/speckit-specify` | **Yes** — *template: "must be technology-agnostic"* |
| Clarifications | `/speckit-clarify` | **Yes** |
| **Plan § Technical Context** | `/speckit-plan` | **No — the only place tech binds** |
| Research, data model, contracts | `/speckit-plan` | No |
| Tasks | `/speckit-tasks` | No |
| Source & tests | `/speckit-implement` | No |

**The one exception:** a genuine project-wide mandate ("all data MUST reside in the EU") is *governance* and belongs in the constitution's constraints. That's a rule, not a design choice.

---

<!-- _class: divider -->

<span class="num">Part four · the checks</span>

# The Flow

Stages, gates, and what each gate leaves behind.

*Now there are rules, and a plan that binds them to a stack.
Something has to check one against the other.*

---

## Three different things are called "gate"

Conflating them is the fastest way to get lost in this deck. They are not the same.

| Kind | Count | Asks | Fires |
|---|---|---|---|
| **Pipeline gates** A–E | 5 | *"Is this stage's work fit to move on?"* | Between stages |
| **Quality gates** | 9 | *"Is this change fit to merge?"* | All at Gate E |
| **Loops** L0–L3 | 4 | *"**Where** does each of the above actually run?"* | Part five |

### How they compose

- The **nine quality gates *are* Gate E**. One gate, nine checks.
- **Gate C is a different animal** — it checks the *plan*, before any code exists. It is the only gate the templates name formally.
- Every gate, of either kind, **must be owned by exactly one loop** — or it is aspiration, not governance.

---

## The pipeline

Eight stages. Gates between them. The loop back from converge is the point — this is a cycle, not a line.

```text
  0  /speckit-constitution   →  constitution.md            ┐ once per project
     ── GATE A · ratified                                  ┘

  1  /speckit-specify        →  spec.md          (agnostic)
  2  /speckit-clarify        →  § Clarifications (agnostic)
     ── GATE B · clarity

  3  /speckit-plan           →  plan.md, research, data-model, contracts
     ── GATE C · CONSTITUTION CHECK  ◄── runs twice

  4  /speckit-tasks          →  tasks.md
  5  /speckit-checklist      →  checklists/
  6  /speckit-analyze        →  report (read-only)
     ── GATE D · consistency

  7  /speckit-implement      →  source + tests
  8  /speckit-converge       →  appends gaps back to tasks.md ──┐
     ── GATE E · merge (the nine gates)                         │
        └───────────────────────────────────────────────────────┘
```

---

## Gate C — the only formal gate in the templates

`plan-template.md:41` — *"Must pass before Phase 0 research. Re-check after Phase 1 design."*

**It runs twice.** Once on the proposed stack, once on the resulting design.

| Article | What Gate C checks |
|---|---|
| I / II | Test-first and review viable for the chosen stack |
| IV | Reliability targets declared — SLO / RTO / RPO |
| V | Trust boundaries, secret storage, encryption identified |
| VI | Ongoing cost impact of the architecture estimated |
| VII | Deploy automated, reversible, observable |
| VIII | Performance goals are **numbers, not adjectives** |

Violations go in **Complexity Tracking** with justification — or the plan is blocked.

---

## Gate C is where the boundary is enforced

Gate C sits exactly on the seam between agnostic and bound.

That is its whole job: **enforcing technology-agnostic rules against a concrete technology binding.**

```text
   agnostic ─────────────────►│◄───────────────── bound
   constitution · spec        │  plan · tasks · code
                          GATE C
```

Everything upstream is rules. Everything downstream inherits the stack the plan chose.

---

<!-- _class: divider -->

<span class="num">Part five · the placement</span>

# The Loops

Latency decides placement.

*Gates say **what** must be checked. Loops say **when** — and a gate
that runs too late is worth a fraction of the same gate run early.*

---

## Four loops

| ID | Loop | Cadence | Budget | Owner |
|---|---|---|---|---|
| **L0** | Spec | Per feature | Hours | Feature author |
| **L1** | Inner | Per task | **< 10s** | `/speckit-implement` |
| **L2** | Outer | Per user story | Minutes–hours | Team + CI |
| **L3** | Production | Continuous | Days | On-call |

**L0 is not a loop the code passes through.** It is the phase that *feeds* L1 with `tasks.md`.

Never run L0 commands inside L1 — wrong altitude, far too slow.

---

## Latency decides placement

Every gate has a runtime cost. Plot it against the 10s budget and the argument settles itself.

```text
  0.1s      1s       10s      100s     ~17min    ~3hr     ~1day
   │         │        │         │         │        │        │
   ●format   ●secrets │                                            L1
      ●typecheck   ●unit tests                                     L1
                     │        ○ story checkpoint                   seam
                     │        ●dep scan ●full suite                L2
                     │              ●perf  ●reliability drill      L2
                     │                       ●review ●UX           L2
                     │                                  ●cost      L3
                     │                                      ●alerts
                     ▲
                  L1 BUDGET
```

Left of the line: **can** be inner-loop. Right of it: **cannot** — needs shared infra, a full dependency graph, a realistic environment, or a human.

---

## And agents move the line

Back to Part one: an agent collapses the inner loop. Writing the code stops being the bottleneck.

```text
  BEFORE agents          WITH agents
  ─────────────          ───────────
  L1  write code  ████   L1  ▌            ← collapses toward zero
  L2  review/CI   ██     L2  ██           ← unchanged — humans, CI, real
                                             environments. Now the bottleneck.
```

- **You can parallelize L1.** Ten agents, ten tasks, `[P]` markers.
- **You cannot parallelize judgment.** One reviewer. One production incident. One cost decision.

This is Part zero's *uneven compression*, measured in seconds:

> "Implementation that once took weeks can now be done in hours, while requirements, architecture, and verification remain **stubbornly human-paced**."

### So gate placement matters *more* with agents, not less

If L1 is nearly free, push every gate that fits into it — the agent runs them at no human cost. What remains in L2 is then exactly what genuinely *needs* a human or a real environment.

**That is why the L1 budget is 10 seconds, and why it is worth defending.**

---

## Which article owns which loop

| Article | Loop | Why |
|---|---|---|
| I · Code Quality | <span class="tag l1">L1</span> | Worthless at outer-loop latency |
| II · Testing | <span class="tag l1">L1</span> | Test-first needs seconds, not minutes |
| III · UX | <span class="tag l1">L1</span> <span class="tag l2">L2</span> | Mechanical local; judgment at review |
| IV · Reliability | <span class="tag l2">L2</span> <span class="tag l3">L3</span> | Cannot be measured on a laptop |
| V · Security | <span class="tag l1">L1</span> <span class="tag l2">L2</span> | **Split:** secrets local; dep graph at CI |
| VI · Cost | <span class="tag l2">L2</span> <span class="tag l3">L3</span> | A laptop cannot price an architecture |
| VII · Operations | <span class="tag l2">L2</span> | It *is* the outer loop |
| VIII · Performance | <span class="tag l1">L1</span> <span class="tag l2">L2</span> | Local numbers lie |

**Note the Article V split:** secret detection runs at ~2s and belongs in L1 — cheap, and a pushed secret is unrecoverable.

---

## The L1 → L2 seam

Already written into `tasks-template.md`:

> **Checkpoint**: User Story N should be fully functional and testable independently.

- That checkpoint **is** the handoff.
- L2 turns once per **story**, not once per feature.
- That is what makes MVP-first (P1 alone) deliverable rather than theoretical.
- Tasks marked `[P]` run in parallel inside L1 — they still converge at the checkpoint.
- Foundational (Phase 2) blocks every story and crosses the seam once, first.

---

## Three feedback paths — all mandatory

Skipping these is how spec-driven development decays into documentation theater.

### L1 → L0 · the plan was wrong
Amend `plan.md`. Code must **not** silently diverge — Gate D traceability detects it.

### L3 → L0 · reality vs. intent
`/speckit-converge` measures the codebase against spec/plan/tasks, appends the gap to `tasks.md`.

### L3 → Constitution · the same incident twice
A principle is missing or wrong. Goes through `/speckit-constitution` as an explicit amendment — never a silent reinterpretation.

---

## What is actually enforced today

A gate is only real when something executes it.

| Gate | Status | Mechanism |
|---|---|---|
| Secret detection | <span class="tag ok">ENFORCED</span> | `.githooks/pre-commit` — verified blocking a real commit |
| Format | <span class="tag l2">UNBOUND</span> | No stack chosen yet |
| Type check | <span class="tag l2">UNBOUND</span> | No stack chosen yet |
| Test | <span class="tag l2">UNBOUND</span> | No stack chosen yet |
| Per-edit run | <span class="tag l3">NOT WIRED</span> | Needs `PostToolUse` hook in `.claude/settings.json` |

**Unbound is correct, not an omission.** There is no stack yet — picking Prettier or ruff now would bind technology outside `plan.md`. The runner is a *mechanism*: it executes whatever `.specify/loops.json` declares.

An unbound gate is **skipped with a notice, never silently passed**.

---

## Anti-patterns

<div class="cols">
<div>

**Gate hoarding at L2**
Deferring all nine gates to merge. Contradicts the rationale that problems are cheapest to prevent early.

**L0 inside L1**
Running `/speckit-plan` per task. Wrong altitude.

**Faking L2 signals in L1**
Asserting reliability, cost, or performance from a laptop. A local number is not data.

</div>
<div>

**Seam skipping**
Merging a story whose checkpoint was never demonstrated.

**Silent divergence**
Implementing what the plan does not describe instead of amending it.

**Unowned gates**
A gate no loop enforces. That is aspiration, not governance.

</div>
</div>

---

## Why it is worth the ceremony

A repository with a constitution, templates, gates — and not one line of code — invites a fair question: **why bother?**

| | CapEx | OpEx |
|---|---|---|
| **Vibe coding** | ≈ zero — lean on the model's baseline | **High** — token burn re-prompting the model to fix its own unverified mistakes; maintenance tax reverse-engineering unstructured code; security remediation in production |
| **Agentic engineering** | **High** — schemas, deterministic test suites, structured context | **Low** — the marginal cost of shipping and maintaining a feature drops |

### Specify *is* the CapEx

The constitution, the templates, the gates, `loops.json` — that **is** the upfront investment. What it buys is a low marginal cost per feature, because the agent works inside a governed factory: output is structurally sound, pre-tested, and aligned with standards by construction.

**The bet: pay once in design, or forever in remediation.**

And the thought held from Part one: **context engineering is the lever inside that bet.** A small static `CLAUDE.md` pointing at dynamically-loaded rules is not tidiness — it is the difference between paying for the whole rulebook on every turn and paying for it only when a command needs it.

<span class="small">Osmani, Saboo & Kartakis, May 2026 — "The Economics of AI Development". Their warning is that vibe coding's near-zero CapEx hides a *compounding* OpEx: the cost of fixing a security flaw in production is exponentially higher than catching it at design time — which is Article V and Gate C, in money.</span>

---

## Where to look

Two documents are authoritative. Everything else, including this deck, is a view.

| Document | Role | Authority |
|---|---|---|
| `.specify/memory/constitution.md` | 8 articles + 9 quality gates | **Authoritative** |
| `.specify/memory/development-loops.md` | Which loop owns each gate | Subordinate — constitution wins |
| `CLAUDE.md` | Session-loaded pointer to both | View |
| `docs/slides/` | This deck | View — stale the moment they change |

**Why the pointer matters:** the speckit commands load *only* `constitution.md`, by name.
A document nothing reads enforces nothing — which is the harness lesson from Part one, applied to prose.

### Further reading

**Osmani, Saboo & Kartakis — *The New SDLC With Vibe Coding: From ad-hoc prompting to Agentic Engineering*, May 2026.** Source of Part zero, the Agent/Harness/Factory vocabulary, context engineering, and the CapEx/OpEx framing.

Read it for what this deck deliberately leaves out — each is real, none sits on this deck's spine: **conductors vs. orchestrators** (how *your* role splits between real-time direction and async delegation), **the 80% problem**, **agent skills and progressive disclosure**, and **model routing**.

---

<!-- _class: lead -->

## The through-line

# Rules outlive stacks

**Agent** acts — fast, tireless, non-deterministic.
**Harness** enforces — a rule in a hook beats a rule in a prompt.
**Factory** governs — the constitution says what must hold, agnostic of stack or vendor.
**Loops** correct — latency decides where each gate lives.
**Plan** binds — the one place technology is allowed to exist.

<span class="small">A gate no loop owns is aspiration, not governance.
Three of four L1 gates are currently unbound — by design, until a plan binds the stack.</span>
