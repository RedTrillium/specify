<!--
Sync Impact Report
==================
Version change: 2.1.0 → 2.1.1
Bump rationale: PATCH. No principle added, removed, or redefined; every
  obligation is byte-for-byte unchanged in substance. This removes vendor and
  provider attribution from Articles IV–VIII so the constitution complies with
  its own rule: governance states rules that survive a stack or provider
  migration, and technology is bound only in plan.md § Technical Context.
  Naming one cloud vendor in five of eight articles violated that rule.

Changed in 2.1.1:
  - Articles IV–VIII: provider attribution removed from each article's opening.
    The pillars themselves are unchanged — they are an industry-standard set,
    common to every major cloud architecture framework, and belong to no vendor.
  - Quality Gates + Governance: "the <vendor> pillars" → "the architectural
    pillars (IV–VIII)". The balancing rule and its force are unchanged.
  - Source citation removed. The principles stand on their own rationale, not
    on a vendor's endorsement.

Deliberately NOT changed:
  - The five pillars remain Articles IV–VIII with identical rules.
  - No gate, waiver rule, or loop ownership is affected.

Templates: no change required — none reference the pillars by provider.
Dependent views updated outside this file: CLAUDE.md, docs/slides/.

--- History ---

Version change: 2.0.0 → 2.1.0
Bump rationale: MINOR. No principle added, removed, or redefined. Governance
  materially expanded: a runtime guidance document is referenced and made
  binding on gate placement (every Quality Gate MUST have exactly one owning
  loop). Added Governance § Runtime development guidance →
  .specify/memory/development-loops.md, plus CLAUDE.md as a session-loaded
  pointer to both documents.

Version change: 1.0.0 → 2.0.0
Bump rationale: MAJOR. A principle was removed/redefined (IV. Performance
  Requirements is absorbed into the new Performance Efficiency pillar) and five
  new governing articles were added, changing the constitution's structure in a
  backward-incompatible way.

Principles:
  - I. Code Quality (NON-NEGOTIABLE) — unchanged
  - II. Testing Standards (NON-NEGOTIABLE) — unchanged
  - III. User Experience Consistency — unchanged (no pillar equivalent)
  - IV. Performance Requirements — REMOVED (conflicts with / subsumed by
        VIII. Performance Efficiency)
  - IV. Reliability — ADDED (architectural pillar)
  - V. Security — ADDED (architectural pillar)
  - VI. Cost Optimization — ADDED (architectural pillar)
  - VII. Operational Excellence — ADDED (architectural pillar)
  - VIII. Performance Efficiency — ADDED (architectural pillar; replaces prior
        Principle IV)

Added sections: five pillar articles (IV–VIII); Quality Gates expanded to
  cover reliability, security, cost, and operations.
Removed sections: former Principle IV (Performance Requirements) as a standalone
  article; its intent is preserved under VIII. Performance Efficiency.

Templates requiring updates:
  - .specify/templates/plan-template.md ✅ compatible (Constitution Check gate
    resolves dynamically; Technical Context already captures performance goals
    and constraints — now also read as reliability/security/cost inputs)
  - .specify/templates/spec-template.md ✅ compatible (no principle-specific
    sections to reconcile)
  - .specify/templates/tasks-template.md ✅ compatible (generic performance task
    remains valid; operational/security tasks fit existing categories)
  - .specify/templates/checklist-template.md ✅ compatible (generic)

Follow-up TODOs: None. Ratification date retained from v1.0.0.
-->

# Specify Constitution

## Core Principles

### I. Code Quality (NON-NEGOTIABLE)

Code MUST be readable, consistent, and maintainable before it is considered
complete. The following rules are non-negotiable:

- All code MUST pass the project's configured linter and formatter with zero
  errors before merge; formatting is automated, never argued in review.
- Public functions, modules, and exported types MUST have documented intent
  (purpose, inputs, outputs, and failure modes).
- Functions and modules MUST have a single, clear responsibility; duplicated
  logic MUST be refactored into a shared unit rather than copied.
- Every change MUST be reviewed and approved by at least one other engineer
  before merge. Reviewers MUST verify readability and adherence to this
  constitution, not only correctness.
- Dead code, commented-out blocks, and unexplained TODOs MUST NOT be merged.

**Rationale**: Most engineering cost is spent reading and modifying existing
code. Enforcing quality at merge time keeps that cost bounded and prevents
erosion that compounds into unmaintainable systems.

### II. Testing Standards (NON-NEGOTIABLE)

Tests are a required deliverable of every change, not an optional follow-up:

- Test-first is mandatory for new behavior: write the failing test, confirm it
  fails for the right reason, then implement until it passes (Red-Green-Refactor).
- Every bug fix MUST include a regression test that fails without the fix.
- New public contracts (APIs, library interfaces, shared schemas) and changes to
  existing ones MUST have integration or contract tests.
- The full test suite MUST pass in CI before merge; a failing or skipped test
  MUST NOT be merged without an explicit, documented waiver.
- Tests MUST be deterministic. Flaky tests MUST be fixed or quarantined with a
  tracked issue, never ignored.

**Rationale**: Tests written first define the contract and catch regressions
early, when they are cheapest to fix. A green suite is the shared source of
truth that lets the team change code with confidence.

### III. User Experience Consistency

User-facing surfaces MUST feel like one coherent product:

- Interaction patterns, terminology, and visual/CLI conventions MUST follow the
  project's established patterns; new patterns require justification and, once
  accepted, MUST be applied consistently.
- Error messages MUST be actionable: state what happened and what the user can
  do next. Both human-readable and machine-readable (e.g., JSON) output MUST be
  supported where the interface serves both audiences.
- Accessibility MUST be treated as a baseline requirement, not an enhancement,
  for any graphical or web surface.
- Breaking changes to user-facing behavior MUST be versioned, documented, and
  accompanied by a migration path.

**Rationale**: Consistency reduces the cognitive load of learning and using the
product, builds trust, and lowers support burden. Inconsistency is experienced
by users as defects.

### IV. Reliability

The workload MUST be resilient, available, and recoverable to the degree its
business requirements demand:

- Every feature MUST define its reliability targets (e.g., availability SLO,
  RTO, RPO) before implementation; targets MUST be proportionate to business
  criticality, not maximal by default.
- Failure MUST be designed for: critical paths MUST handle dependency failures
  gracefully via timeouts, retries with backoff, and well-defined fallback or
  degraded modes. Single points of failure on critical paths MUST be justified.
- Data durability and recovery MUST be tested, not assumed; backup and restore
  paths for critical state MUST be exercised on a defined cadence.
- Reliability MUST be observed in production through health signals and alerting
  so that failures are detected before users report them.

**Rationale**: Users experience an unavailable or unrecoverable system as a
total failure regardless of feature quality. Designing for failure and proving
recovery keeps the product trustworthy under real-world conditions.

### V. Security

Security MUST be built in, proportionate to the sensitivity of the data and
operations involved:

- Confidentiality, integrity, and availability of data MUST be protected. Secrets
  MUST NOT be committed to source; they MUST be stored in a managed secret store.
- Access MUST follow least privilege and defense in depth; authentication and
  authorization MUST be enforced on every trust boundary, never assumed from
  network location alone.
- Data MUST be encrypted in transit and, where sensitivity requires, at rest.
- Dependencies MUST be tracked and scanned; known-exploitable vulnerabilities on
  shipped paths MUST be remediated or explicitly risk-accepted by maintainers.
- Security-relevant events MUST be logged in a way that supports auditing and
  incident response without leaking secrets or personal data.

**Rationale**: A single breach can negate all other value delivered. Building
security in from design — rather than bolting it on — is both cheaper and far
more effective than remediation after an incident.

### VI. Cost Optimization

The workload MUST deliver a sufficient return on investment and MUST NOT waste
resources:

- Designs MUST consider cost as a first-class constraint; significant
  architectural choices MUST include an estimate of their ongoing cost impact.
- Resources MUST be right-sized to actual demand; provisioning MUST avoid
  speculative over-allocation, and idle or orphaned resources MUST be reclaimed.
- Cost MUST be attributable and monitored; meaningful cost signals MUST be
  visible to the team, and material regressions MUST be investigated.
- Spend MUST be evaluated against value delivered; optimizations whose operating
  cost exceeds their benefit MUST be reconsidered.

**Rationale**: Unmanaged cost quietly erodes the viability of a workload.
Treating cost as a design constraint keeps the product economically sustainable
and forces trade-offs to be explicit rather than accidental.

### VII. Operational Excellence

The team MUST support responsible development and operations through disciplined,
repeatable practices:

- Deployments MUST be automated and repeatable; manual, undocumented production
  changes MUST NOT be the norm. Infrastructure and configuration MUST be defined
  as code and version-controlled.
- Changes MUST flow through CI/CD with the gates in this constitution enforced;
  releases MUST be reversible via a documented rollback or roll-forward path.
- Systems MUST be observable: structured logs, metrics, and traces sufficient to
  diagnose issues in production MUST be in place for every service.
- Operational knowledge MUST be captured (runbooks, on-call guidance) and
  incidents MUST be followed by blameless review that produces tracked actions.

**Rationale**: Most outages originate in change and operations, not code in
isolation. Automation, observability, and disciplined process make operations
predictable and turn incidents into durable improvements.

### VIII. Performance Efficiency

The workload MUST accomplish its purpose within acceptable timeframes and MUST
scale efficiently with demand (supersedes the former Performance Requirements
article):

- Every feature with user-facing latency or throughput impact MUST declare
  measurable performance targets (e.g., p95 latency, throughput, resource
  ceilings) in its plan before implementation.
- Performance-sensitive paths MUST be measured against those targets before
  release; claims of "fast enough" MUST be backed by data, not intuition.
- The system MUST scale to meet expected demand using capacity that matches load;
  scaling strategy MUST be defined for paths with variable or growing demand.
- Regressions beyond agreed thresholds MUST block release until resolved or
  explicitly waived by maintainers with recorded justification. Optimization MUST
  be driven by profiling actual bottlenecks, never speculative micro-tuning that
  harms readability (Principle I).

**Rationale**: Performance problems are cheapest to prevent at design time and
most expensive to retrofit. Explicit, measured targets and an intentional
scaling strategy keep the product responsive and cost-effective as it grows.

## Quality Gates

The following gates apply to every change and MUST be satisfied before merge.
Each maps to the principle(s) it enforces:

- **Lint & format**: automated checks pass with zero errors (Principle I).
- **Tests**: full suite green in CI, new behavior covered test-first, bug fixes
  carry regression tests (Principle II).
- **Review**: at least one peer approval confirming constitution compliance
  (Principle I).
- **UX review**: user-facing changes confirmed consistent and accessible
  (Principle III).
- **Reliability check**: reliability targets declared for new features; failure
  handling and recovery for critical paths verified (Principle IV).
- **Security check**: no secrets in source, dependency scan clean or risk-
  accepted, trust boundaries authorized, sensitive data encrypted (Principle V).
- **Cost check**: cost impact of significant architectural changes estimated;
  no unexplained material cost regression (Principle VI).
- **Operations check**: change is automated, reversible, and observable
  (Principle VII).
- **Performance check**: declared targets measured for performance-sensitive
  changes; no unresolved regression beyond threshold (Principle VIII).

The architectural pillars (IV–VIII) require balancing decisions across pillars
against business requirements. Where two pillars pull in opposite directions
(for example, reliability versus cost), the trade-off MUST be made deliberately
and recorded in the change's plan.

Any gate may be waived only with an explicit, recorded justification approved by
the maintainers. Waivers MUST reference the specific principle and include a plan
to remediate.

## Governance

This constitution supersedes other development practices where they conflict.
It exists to guide technical decisions and implementation choices: when a design
or implementation option is evaluated, the option that better upholds these
principles MUST be preferred, and any deviation MUST be justified in writing
against the principle it strains. For the architectural pillars (IV–VIII),
"better" is judged as the balanced outcome across pillars given business
requirements, not maximizing any single pillar in isolation.

**Provider and technology neutrality**: This constitution states rules that
survive a change of language, framework, cloud, or vendor. It MUST NOT name a
specific product, service, or provider — that is a design decision belonging to
`plan.md` § Technical Context (see Runtime development guidance below). A rule
that cannot be stated without naming a vendor is a plan decision wearing a
principle's clothes, and MUST be rejected here. The sole exception is a genuine
project-wide mandate (for example, a data-residency obligation), which is
governance rather than design.

**Amendment procedure**: Amendments MUST be proposed via pull request that states
the change, its rationale, and its impact on dependent templates and workflows.
Amendments require maintainer approval before merge. On merge, the version and
amendment date below MUST be updated and any affected templates
(`.specify/templates/`) reconciled in the same change.

**Versioning policy**: This constitution is versioned with semantic versioning:

- **MAJOR**: backward-incompatible governance changes, or removal or redefinition
  of a principle.
- **MINOR**: a new principle or section, or materially expanded guidance.
- **PATCH**: clarifications, wording, and non-semantic refinements.

**Compliance review**: Every pull request and review MUST verify compliance with
this constitution. Complexity or deviation MUST be justified in the change's plan
(see the plan template's Constitution Check and Complexity Tracking sections).
Persistent or unjustified violations block merge until resolved.

**Runtime development guidance**: This constitution defines *what* must hold.
`.specify/memory/development-loops.md` defines *where and when* each gate is
enforced — the loop model (L0 spec, L1 inner, L2 outer, L3 production), the gate
placement matrix, and the mandatory feedback paths. That document is subordinate
to this one: where they conflict, this constitution wins and the guidance MUST be
corrected. Every Quality Gate above MUST have exactly one owning loop recorded
there; a gate that no loop enforces is aspiration, not governance.

**Version**: 2.1.1 | **Ratified**: 2026-07-14 | **Last Amended**: 2026-07-14
