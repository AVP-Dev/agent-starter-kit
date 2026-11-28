# DESIGN Manifest for Development and Evolution (Zero Vibe Coding)

> **Project standard:** For a significant change to a contract, data model, or integration, document the design before implementation. For a local change, the goal, invariant, and verification are sufficient.
> The manifest is based on [AI Loves Straight Roads: Why Local Optimization Breaks Complex Systems](https://avpdev.com/en/blog/ai-loves-straight-roads/) and [The Architect of the Future: From Line Reviews to Design Reviews](https://avpdev.com/en/blog/architect-of-the-future/): locally correct code must not break system invariants or architectural boundaries.
> Complete the applicable sections during initial development and subsequent changes. Invariants are confirmed through verification. Stages and migrations are described in the [lifecycle policy](lifecycle.md).

---

## Template

````markdown
# DESIGN: [Feature / Module / Endpoint Name]

## 0. Grill-Me Frontier (Resolving Decision Points BEFORE Writing Code)
> Pocock's rule: *"Finding facts is the agent's responsibility; making decisions is the human's prerogative."*
> Check the repository and existing contract first. Seek approval for decisions that change the agreed outcome, architecture, or risk. Record and verify reversible assumptions.
- [ ] ❓ **Q1 — [Decision Point]:** [Question and boundary conditions]
  ➡️ **Agent recommendation:** [Proposed option and architectural rationale]
  *(Status: Approved by the human)*

## 1. Metadata and Scope
- **Affected modules / services:** [Directories/packages, e.g., src/modules/rag, src/workers, src/components]
- **File ownership / scope:** [Who owns the directories/files and which areas must not be changed.]
- **File structure (if relevant):** [Responsibility boundary to preserve or establish.]
- **Delegation:** Zone 1 / Zone 2 / Zone 3 according to AGENTS.md.
- **Topology:** `orchestrated` / `single` / `fixed-pipeline` / `side-research` / `parallel` / `hierarchical`
- **Working hypotheses:** [What is assumed but not yet verified. Do not present as fact.]
- **Goal:** A brief description of the task (1–2 sentences).
- **Stop / escalation conditions:** [When to stop, ask the human, or increase reasoning effort.]
- **Run ID / replay reference:** [Run identifier or reference to reproducible context.]
- **Measured outcome:** `[accepted | rejected | blocked]`; [1–2 metrics and a reference to evidence]. Complete after the Verification Gate; for Lightweight — `n/a`.
- **Pre-change impact check:** [Affected consumers, baseline, and potential consequences before making changes.]
- **Verification layers:** [static / positive / negative / security / regression / integration — specify coverage.]
- **Rollback / stop plan:** [How to stop safely or roll back the change on failure.]
- **Context budget / escalation trigger:** [Verification scope limit and conditions for a targeted deep check.]
- **SDKs / libraries used:** [Versions and verified APIs; Context7 or official documentation.]
- **Lifecycle stage:** [Prototype / Production / Scale, actual risk of the affected system boundary]. Real data, money, and external consumers require Production checks even for a small change.

## 1.1. Lifecycle & Evolution
- **Stable contracts / mutable implementation:** [What is preserved and what is replaced.]
- **Affected consumers / compatibility:** [Consumers, compatibility, approved breaking change.]
- **Migration / recovery:** [Transition sequence, backup/restore, rollback or forward fix.]
- **Deprecation / debt:** [Removal criteria, owner, and review date or condition.]

## 2. System Invariants (What MUST NEVER Happen Under Any Circumstances)
- [ ] Invariant 1 (e.g., "The user's balance must not become negative").
- [ ] Invariant 2 (e.g., "Transactional integrity: debiting and creating the record must occur in the same transaction").
- [ ] Invariant 3 (e.g., "Tenant isolation: RAG search and embeddings never return documents belonging to another projectId").
- [ ] Invariant 4 (e.g., "Vector dimensionality: vector dimensions must match the pgvector HNSW index").
- [ ] Invariant 5 (e.g., "Non-Destructive: records are not physically deleted; only soft deletion is allowed").

## 3. State Machine
- **Entity states:** `DRAFT` → `PENDING` → `PROCESSING` → `COMPLETED` | `FAILED`
- **Invalid transitions:** A transition from `FAILED` to `COMPLETED` that bypasses the queue is prohibited.
- **State owner:** Who may initiate state transitions (BullMQ worker, user, webhook).

## 4. Failure Modes & Idempotency
- **Network timeout / LLM API failure:** (what to do: fallback / exponential retry with jitter / fail-closed with a clear error).
- **Duplicate requests / repeated webhook:** (protection via Idempotency Key / unique constraint / Redis SETNX with TTL).
- **Invalid data:** (Zod/Pydantic fail-closed, return 400 Bad Request, no partial persistence).
- **Runtime limits:** [Deadline, number of attempts, backoff/jitter, request, token, and cost budgets where applicable.]
- **Retry safety:** [Retry only transient failures when the operation is idempotent or the previous attempt's outcome has been verified; each retry does not extend the overall deadline.]
- **Degradation:** [Explicit failure/partial state, compatible fallback, retry limit, observability; do not weaken access controls, integrity, or the meaning of the result.]

## 5. Data Contracts (Validation Schemas / DTO)
```typescript
export interface RequestPayload {
  // strictly typed fields (no any!)
}

export interface ResponsePayload {
  success: boolean;
  data?: unknown;
  error?: string;
}
```

## 5.1. Visual and Theme Contract (UI/UX & Design Tokens — If the Task Affects the Frontend)
- [ ] **Design system:** Use existing semantic tokens and components if the project has adopted theming. Justify a new pattern after checking existing primitives.
- [ ] **Hot-swappable themes:** If the project supports themes, switching them does not require component changes.
- [ ] **Action hierarchy:** Follow the project's action-priority patterns.
- [ ] **Element states:** Implement styles for `:hover`, `:active`, `:focus-visible` (keyboard focus outline), `:disabled`, and the `loading state`.
- [ ] **Accessibility and layout:** Semantic elements, contrast, and responsive design meet project requirements.
- [ ] **Scenario states:** Define and verify applicable Loading / Empty / Success / Error / Restricted / Partial / Degraded states.
- [ ] **Component evolution:** When patterns are duplicated or boundaries violated, evaluate refactoring instead of adding another local patch.

## 6. Acceptance Invariants & Automated Verification Gate
- [ ] Happy path automated test with valid data.
- [ ] Negative test: external service failure or connection loss.
- [ ] Negative test: invalid input data (verify the 400 error).
- [ ] Idempotency test: a repeated request with the same key does not create duplicates.
- [ ] The deterministic path is defined; an LLM does not replace working logic without an explicit reason.
- [ ] Existing checks are not weakened to pass the Automated Verification Gate.
- [ ] Interface test (if there is a UI): applicable states, project viewports, and keyboard navigation.
- [ ] Automated verification: all applicable required checks have passed; every critical invariant is linked to evidence.
- [ ] Documentation: affected contracts and state are updated, along with ADRs for architectural decisions.
- [ ] Git commit: follow the adopted project process.
````
