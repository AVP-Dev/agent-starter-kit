# Application Lifecycle and Evolution Policy

> **Purpose:** controlled evolution without breaking contracts, losing data, or allowing uncontrolled technical debt.
> **Boundary:** requirements are determined by actual operational risks, not release names or task size. This policy complements AGENTS.md and the project architecture.

## 1. Stable Contracts and Mutable Implementation

Stable contracts include data ownership, public APIs and events, access and isolation, business invariants, persisted schemas, and consumer-facing configuration. Changing an agreed contract requires passing the Confirmation Gate in AGENTS.md.

Internal algorithms, private components, adapters, and queries may be replaced within accepted boundaries as long as behavior and verification are preserved. Do not turn incidental implementation details into public contracts.

## 2. Operational Stages

| Requirement | Prototype / MVP | Production / Real Data | Scale / Measurable Growth |
|---|---|---|---|
| Architecture | Minimum sufficient | Stable contracts | Measurement-driven optimization |
| Migrations | Simplified only without valuable data or consumers | Versioned and verifiable | Staged compatibility |
| Recovery | Risk-based | Backups and recovery testing for valuable data | Target RPO/RTO |
| Tests | Critical scenarios | Contract and regression tests | Load and resilience tests based on risk |
| External calls | Bounded timeouts | Timeouts and controlled retries | Budgets, backpressure, degradation |
| Observability | Basic errors | Logs and key metrics | SLOs and alerting according to requirements |

Security, data integrity, access permissions, and transactional invariants are mandatory at every stage. Real data, money, external consumers, or critical business processes activate Production requirements for the affected system boundary, even in a small PR. Scale requirements are activated by measurable constraints and goals, not by an arbitrary user count.

## 3. Contracts and Migrations

- Identify consumers, versions, and the impact of changes to APIs, events, schemas, and configuration.
- Prefer compatible changes. A breaking change requires explicit approval, a transition plan, and consumer verification.
- Do not edit previously applied migrations; make corrections with a new migration.
- For real data, prepare a backup, recovery verification, migration testing on an isolated copy, and stop criteria. Rolling back code does not guarantee data rollback; plan a forward fix or restore as appropriate.
- When multiple versions coexist, consider expand → migrate → contract. Removing the old schema is acceptable after confirming that consumers have transitioned.
- Preparing a migration does not authorize executing it in production.

## 4. Technical Debt

A temporary solution is acceptable within established red lines if its reason, scope, risk, owner, and review date or measurable review condition are recorded in [state.md](state.md) or the adopted tracker.

Without a review date or condition, it is a forgotten workaround rather than managed technical debt. When the review condition is met, evaluate fixing it, extending it with justification, or removing it.

## 5. Deprecation and Decommissioning

1. Identify all known consumers, including external clients, background jobs, and configurations.
2. Record the replacement, deprecated status, transition period, and completion criterion.
3. Confirm that consumers have transitioned or that the contract is unused; if this is unknown, do not remove a stable contract.
4. After obtaining approval where necessary, remove the old implementation, dependencies, configuration, and obsolete documentation.
5. Check for regressions and verify data preservation.

Remove non-public dead code after checking its usage and affected tests, without requiring a transition period.

## 6. Transitioning Between Stages

Conduct a targeted lifecycle review covering data, compatibility, access, recovery, operational constraints, required checks, and known debt. Record the actual stage and review triggers in AGENTS.md, accepted architectural decisions in [decisions.md](decisions.md), and the current outcome in state.md.
