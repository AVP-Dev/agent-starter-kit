# Architecture Decision Records

> Record ALL key engineering decisions made by a human or agreed with an agent in this file.
> Format: Context → Decision → Invariants → Consequences (+/-).

---

### [2026-11-26] ADR-008. Controlled Evolution and Honest Acceptance

**Status:** Accepted.

**Context:** The development rules did not define the transition to real-world operation; the zone matrix was absent from the current AGENTS.md, and an optional-only profile could finish successfully.

**Decision:** Restore Zone 1/2/3, add a lifecycle policy, connect DESIGN to the affected system's risk and evidence, and limit agent work cycles. A full gate requires at least one required check and successful execution of all required commands; diagnostics do not establish acceptance.

**Invariants:** ADR-007 remains in effect; project tools and stages adapt to facts, and security and data preservation are not weakened. No separate runtime or second permission vocabulary is introduced.

**Consequences:** More predictable contract changes and verifiable acceptance; existing optional-only profiles must be completed or used explicitly for diagnostics.

---

### [2026-11-25] ADR-007. Adapting Guidance to the Project

**Status:** Accepted. Clarifies the current process under ADR-001, ADR-002, ADR-003, and ADR-004. Historical wording is preserved below.

**Context.** Universal limits and mandatory stages created unnecessary cycles for local tasks and made the kit harder to adopt in an existing project.

**Decision.** Select the structure, design depth, execution approach, and verification according to the task's impact. Use file size and report length as guidelines. Retain strict access boundaries, data preservation, and the required checks adopted by the project. Compare verification results against the baseline. Install instructions through `AGENTS.md` by default. Add an import through `CLAUDE.md` when requested for compatibility.

---

### [2026-09-24] ADR-003: Adaptive Agent Routing and Context Control
**Status:** Accepted; default topology clarified by ADR-004
**Note:** The description of `single` as the default below is preserved for historical purposes; `orchestrated` from ADR-004 applies to non-trivial tasks.
**Context:** Agent workflows produce opposite outcomes depending on the size, independence, and repeatability of a task. A universal model scale, swarm by default, or runtime orchestrator would complicate the docs-only starter kit and would not suit projects with differing resources.
**Decision:**
1. Retain `Zone 1/2/3` as the only axis of responsibility and risk.
2. Add a separate declarative axis, `Topology`: `single`, `fixed-pipeline`, `side-research`, `parallel`, `hierarchical`.
3. Choose `single` by default; add orchestration complexity only for independent subtasks or a repeatable process.
4. Transfer concise context packages between agents rather than the entire chat; side research must be read-only and return evidence.
5. Apply deterministic-first, probe-before-refusal, test protection, and an explicit fallback rule.
6. Verify decisions on five basic scenarios before expanding the set.
**Invariants:**
- The starter kit remains documentation-based, vendor-neutral, and portable.
- Existing project files are not overwritten automatically.
- A simple handoff does not replace a verified contract.
- Changes to risk, access permissions, or the meaning of a fallback do not happen silently.
**Alternatives:** A runtime orchestrator, separate `T0–T6` and `L0–L4` scales, model profiles, and platform-specific adapters were rejected as excessive for the current format.
**Consequences:**
(+) Fewer instructions in the system context and less unexpected complexity.
(+) Decisions can be verified against the same task types and revised after actual measurements.
(+) The same protocol works with different agents, tools, and computing resources.
(-) Some optimal strategies must be chosen experimentally.
**Review triggers:** Changes to the model or harness, recurring routing failures, measurable need for a runtime, or accumulated pilot results.

---

### [2026-09-24] ADR-004: Orchestrator-First Delegation and Checkpointed Long Sessions
**Status:** Accepted
**Context:** The default `single` mode allowed the primary agent to perform substantive work without visibility, accumulate context, and lose the boundaries between independent workers. In long sessions, this increases the risk of duplicated work, conflicts, and uncontrolled context loss.
**Decision:**
1. For non-trivial tasks, the primary agent acts as an `orchestrator` and delegates research, design, implementation, and preparation of the result to worker agents.
2. `single` remains reserved for trivial, entirely deterministic tasks or an explicit fallback when delegation capability is unavailable.
3. Workers receive bounded scopes and isolated contexts; only one integrator or the primary agent writes canonical documents.
4. After each stage and quality gate, save a short checkpoint with Run ID, evidence, and the next step.
5. In long sessions, the orchestrator retains the task ledger and artifact references rather than raw logs and complete transcripts.
6. Deterministic control-plane actions — reading state, running checks, git status, and integration — may be performed by the orchestrator.
**Invariants:** Substantive work on a non-trivial task is delegated; independent agents do not receive unrestricted access to each other; results are not accepted without verification and evidence.
**Alternatives:** `single` for every task, mandatory swarm, and a full runtime orchestrator were rejected as excessive or insufficiently controllable.
**Consequences:**
(+) Less context noise and less implicit work in the primary session.
(+) Long tasks can be safely resumed from a checkpoint or in a new session.
(-) Handoff introduces overhead, so it is applied only to non-trivial tasks.
**Review triggers:** Lack of reliable delegation capability, recurring integration conflicts, an increasing number of unfinished workstreams, or measurable handoff inefficiency.

---

### [2026-09-25] ADR-006: Reproducible CI and Tag-Based Release Gate
**Status:** Accepted
**Context:** A public docs-only template must demonstrate the same Verification Gate after push and in a clean clone, rather than relying on manually run local commands. Versions must be reproducible and reversible.
**Decision:**
1. Add `.github/workflows/verification.yml` for pushes to `main`, pull requests targeting `main`, and manual runs.
2. Use `contents: read`, `pull_request` without trusted-base secrets, and checkout without persisting credentials.
3. Run the same `scripts/verify-project.sh` in CI, then check local Markdown links and checkout cleanliness.
4. Create an annotated tag `vYYYY.N.P` only after CI passes and publish a Release from the verified tag.
**Invariants:** Local and CI gates use one project-local profile; CI receives no unnecessary permissions; a failed or inconclusive result blocks the tag; a tag is not rewritten without an explicit new release.
**Alternatives:** Manual execution without CI, a workflow with `pull_request_target` and secrets, automatic tagging on every commit, and vendor-specific CI runners were rejected as less safe or less reproducible.
**Consequences:**
(+) Regressions are detected before merge and in a clean GitHub checkout.
(+) Versions can be explicitly rolled back and installed by tag.
(-) Adds a short release preparation process and a dependency on GitHub Actions availability.
**Review triggers:** Changes to the gate's composition, the need for separate deployment jobs, or a migration to another CI platform.

---

### [2026-09-25] ADR-005: Project-Local Verification Profile and Universal Dispatcher
**Status:** Accepted
**Context:** A single test runner or security toolset for all languages and package managers cannot be built into the starter kit. However, the absence of a common way to run checks results in missed typecheck, lint, regression, and security gates.
**Decision:**
1. Add the universal `scripts/verify-project.sh`, which runs only commands explicitly defined in the local TSV profile.
2. Add `scripts/security-scan.sh` as a dependency-free baseline for detecting potential secrets and environment files without printing detected values.
3. Provide a profile template during onboarding, but create the active target-project profile only after reading manifests, lockfiles, CI, and existing scripts.
4. Treat a missing or invalid profile as a blocking failure; optional checks with `required=0` must not mask a required failure.
5. Do not copy the starter kit's own profile into a target project, to avoid replacing another stack's commands and security policy.
**Invariants:** The dispatcher does not change access permissions or run commands outside the project-local profile; security findings do not expose values; the universal baseline does not replace SAST/SCA; the active profile is not created from guesswork.
**Alternatives:** A hardcoded `scripts/verify.sh` with stack autodetection, mandatory installation of gitleaks/Semgrep/trivy, and one runner for all languages were rejected as brittle and vendor-coupled.
**Consequences:**
(+) A single fail-closed entry point and a reproducible gate are available for projects with different stacks.
(+) Commands and security tools remain explicit, verifiable, and replaceable after onboarding.
(-) The project must complete its profile; the universal scanner requires regular review for false positives and is supplemented by external tools.
**Review triggers:** The emergence of a stable cross-stack standard for test/security protocols, widespread false positives, or the need for policy-as-code beyond TSV.

---

### [2026-09-11] ADR-002: Tool-Based Verification, Safe Git Synchronization, and the 2026 Stack Update
**Status:** Accepted; the outdated reference to a removed GitHub integration is clarified below
**Context:** Relying solely on text prompts without tool-based verification leads to context drift and unnoticed regressions. The stack also needed an update (Node.js 24 LTS / Node.js 26 Current, Bun 1.3+, Go 1.27+, Python 3.14, pgvector/HNSW, Docker/Coolify) and alignment across key environments: Gemini Antigravity, Claude Code, OpenAI Codex / GitHub Copilot.
**Decision:**
1. Remove outdated monolithic rules `.cursorrules` and `.windsurfrules`. Use the root `AGENTS.md` as the SSOT, with `CLAUDE.md` as a compatible symlink where supported. The file `.github/copilot-instructions.md` was removed in 2026.2.0 and is not a current standard path.
2. Introduce a mandatory **Automated Verification Gate**: an iteration is not complete without running the linter, typecheck, and tests (`exit code 0`). Every iteration must include negative and edge-case tests.
3. Introduce a safe Git synchronization protocol: check `git fetch origin && git status -uno` before starting work; stop immediately and notify the user if behind origin (blind `git pull` is prohibited); record each successful iteration in an atomic commit (Conventional Commits).
4. Introduce a rule to verify libraries through Context7 MCP / search and agree on critical breaking changes.<br>
**Invariants:**<br>
- No code that has not been verified by automated tests is considered complete.
- No implicit code changes when the local branch diverges from the remote GitHub branch.<br>
**Consequences:**<br>
(+) Assured quality and predictability of vibe coding;<br>
(+) Full compatibility with the Gemini Antigravity, Claude Code, and GitHub Copilot / Codex ecosystems;<br>
(+) Protection against loss of local changes and Git conflicts.<br>
(-) The agent must spend time running test and lint commands.

---

### [2026-09-11] ADR-001: Adoption of the "Skeleton + Pluggable Modules" Standard and Pre-Implementation Manifest
**Status:** Accepted<br>
**Context:** The system is developed with autonomous coding agents. Without a strict separation of responsibilities and documented invariants, there is a high risk of architectural degradation, spaghetti code, and loss of control over resilience.<br>
**Decision:**
1. Divide the project into a stable foundation (Skeleton: DB, Auth, event bus) and isolated, replaceable modules (Pluggable Modules).
2. Introduce the Delegation Matrix (Zone 1: 100% AI, Zone 2: Contract 50/50, Zone 3: Architect Only).
3. Require a DESIGN manifest (Invariants, State Machine, Failure Modes, Acceptance Invariants) before generating non-trivial code.
4. Establish a Confirmation Gate protocol for any modification to the DB schema, authorization, or security.<br>
**Consequences:**<br>
(+) Elimination of spaghetti code and hidden coupling;<br>
(+) Network failure and duplicate request scenarios are designed BEFORE implementing the logic;<br>
(+) Individual modules can be quickly regenerated from scratch without risking damage to the core.<br>
(-) Brief manifest approval is required before starting Zone 2 tasks.

---

### Template for a New ADR:

```markdown
### [YYYY-MM-DD] ADR-00X: [Short Decision Title]
**Status:** Proposed / Accepted / Deprecated<br>
**Context:** What problem arose, what constraints apply, and why the current solution is unsuitable.<br>
**Decision:** What specifically has been decided and which technologies/patterns to apply.<br>
**Invariants:** What the system guarantees after implementing the decision.<br>
**Alternatives:** Which options were considered and why they were rejected.<br>
**Consequences:**<br>
(+) Benefits and advantages<br>
(-) Drawbacks, trade-offs, and new technical debt
```
