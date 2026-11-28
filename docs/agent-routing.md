# Agent Routing and Context Control

> **Status:** living documentation policy for the starter kit.
> **Purpose:** select an appropriate execution approach and transfer context during extended or distributed work.
> **Boundary:** this is a declarative protocol for agents, not an executable runtime orchestrator.

## 1. Two Independent Axes

### Delegation Zone

Use the existing responsibility matrix in `AGENTS.md`:

- **Zone 1** — the task is delegated to the agent;
- **Zone 2** — the human approves the contract and the agent implements it;
- **Zone 3** — the decision and change remain under human control.

This axis answers the question: **who is responsible for the outcome and where confirmation is required**.

### Topology

Topology answers a separate question: **how to organize task execution**.

| Topology | When to Select | Constraint |
|---|---|---|
| `orchestrated` | Several workstreams require coordination | The primary agent is responsible for task definition, integration, and acceptance |
| `single` | A cohesive task or work without available delegation | One agent implements and verifies the result |
| `fixed-pipeline` | The process is known in advance and repeatable | Use an LLM only at non-deterministic steps |
| `side-research` | A focused answer is needed without polluting the primary context | The researcher is read-only and returns evidence only |
| `parallel` | Independent workstreams have non-overlapping scopes | Assign an owner for each result and its integration |
| `hierarchical` | A large task requires a shared plan and multiple scoped workers | The primary agent retains responsibility for synthesis and final verification |

The `T0–T6` numbering and a separate autonomy scale are not introduced. They would duplicate the Delegation Zone and create a second vocabulary of responsibility.

## 2. Choosing an Execution Approach

First, determine whether the task can be solved with an ordinary command or code. Split the work if its parts are independent, separate expertise is required, or independent verification would help. Consider the environment's capabilities and the cost of transferring context.

When delegating, the primary agent defines the contract, change scope, and verification for each worker. It integrates the results and is responsible for the outcome.

## 3. When to Select Each Topology

### `single`

Choose this for a cohesive task with shared context when handing off work would add more coordination than value. Independent review can be added separately.

### `fixed-pipeline`

Use this when the steps are known in advance and repeatable. Deterministic steps must be performed with ordinary commands or scripts. An LLM is needed only where interpretation or generation is required.

### `side-research`

Use this for a focused question that might distract the primary context with irrelevant details. Side research has no authority to modify canonical documents and returns:

- verified facts;
- references to files or sources;
- the conclusion;
- unknowns and risks;
- a recommended next action.

### `parallel`

Use this only for genuinely independent tasks. Before starting, define:

- non-overlapping change scopes;
- the owner of each result;
- the integration order;
- the completion criterion for each workstream.

### `hierarchical`

Use this when the task is too large for one context but can be decomposed. The planning agent is responsible for the overall picture and contracts, scoped agents for bounded areas, and the final agent for synthesis and verification.

## 4. Deterministic-First

First, express a rule in ordinary code if it is stable. Use an LLM for the non-deterministic part: interpretation, research, generation, or handling ambiguous input.

If extending LLM logic starts to introduce new exceptions and inconsistent branches, this is a signal to reconsider the boundary between deterministic code and AI, rather than simply adding another branch.

After a plan is approved, reasoning effort can be reduced for mechanical implementation. Increase reasoning effort when encountering conflicts, new errors, ambiguous requirements, or unexpected state, and record the reason for escalation.

## 5. Hypotheses and Declaring a Task Unsolvable

A hypothesis must not be presented as a proven fact. Before declaring a task impossible, the agent must verify the actual state of the project:

- read relevant files and configuration;
- check actual types, dependencies, and commands;
- consult current library documentation through Context7 if an integration is affected;
- perform a minimal safe probe if it does not modify the system.

The number of actions is not fixed. The report must retain verified facts, the command, the result, and the reason for the blocker.

## 6. Lightweight and Full Task Envelope

### Lightweight

For a scoped task, the message or manifest only needs to specify:

- the goal;
- the invariant that must not be violated;
- the verification command.

### Full

For a contract change, multiple related components, or high-risk work, use the applicable sections of the [DESIGN manifest](design-manifest-template.md).

## 7. Handoff Package

Transfer a concise package between agents rather than the entire chat:

- the scoped goal;
- verified facts;
- evidence and file references;
- write boundaries;
- acceptance invariants;
- the expected result;
- completed verification;
- unknowns and risks;
- escalation conditions.

Exclude raw logs, secrets, and irrelevant conversation history from the package.

## 8. Context Isolation

- The primary agent is responsible for final synthesis.
- Side research does not receive access to neighboring sessions by default.
- Only the primary agent or integrator updates canonical `AGENTS.md`, `docs/state.md`, `docs/decisions.md`, and architecture documents.
- Temporary results are stored in the project's or tool's scratch area and do not become long-term documentation without review.

## 9. Fallback

The default agent work budget is a maximum of 3 implementation/fix cycles per task and a maximum of 2 reruns after a failure with the same cause. The project or human may define other finite time, token, cost, and attempt limits in advance. Do not reset counters during handoff or topology changes.

If work stalls, shows no measurable progress, or reaches a limit, stop the affected work, save a checkpoint with evidence, and propose a specific next step. Extending the budget requires confirmation; a retry without new facts or a changed approach is not justified.

A fallback is acceptable if it preserves:

- the same access permissions;
- the same risk class;
- the same acceptance invariants;
- compatibility with the original contract.

When the selected work budget is exhausted, change the execution approach or report the completed result and the specific limitation. A retry is justified by new data, a temporary failure, or a changed approach. When an agreed hard limit is reached, stop the affected operation. Changing permissions, risk class, data access, or the meaning of the result requires a separate decision.

## 10. Test Protection

Existing tests must not be removed, weakened, or replaced simply to obtain a passing result. If the expected behavior has genuinely changed, first record the specification change and agree on the new contract.

## 11. Five Basic Scenarios for Initial Verification

1. A localized bug.
2. A small multi-file refactoring.
3. A large refactoring with independent scopes.
4. A known, repeatable pipeline.
5. Ambiguous research or a task known to be unsolvable.

For each scenario, compare only relevant strategies. Record the accepted result, verification, time, tokens, manual interventions, and identified risks.

## 12. Long Sessions and Recovery

- At the start of a new or resumed session, read `AGENTS.md`, `docs/state.md`, the active DESIGN manifest, the latest checkpoint, and `git status` rather than relying on the entire chat history.
- Save a short checkpoint after a significant stage, before transferring work, or before a long pause. Status, decisions, verification, and the next step are sufficient. Include the Run ID if the project uses one.
- Keep only the task ledger and artifact references in the primary context; leave long logs, raw transcripts, and intermediate reasoning in scratch or separate artifacts.
- Do not launch background workstreams without an owner, scope, completion criterion, and integration point.
- Do not allow multiple worker agents to edit the same files concurrently; only one integrator or the primary agent may write canonical documents.
- When recovering, first check unfinished workstreams, then resume from the last checkpoint without repeating already verified work.
- If the context has become noisy or the task ledger contradicts the facts, stop execution, rebuild the checkpoint, and request a decision if necessary.

## 13. Checkpoint and Commit

Checkpoints and Git commits are intentionally separate:

1. A checkpoint records status, evidence, Run ID, and the next step in the task ledger.
2. When creating a commit, follow the adopted project process, verify the result, and include one task or vertical slice.
3. Check the working tree and index. Stage only an explicit list of files within your task.
4. Fix new failures of required checks before committing. Report baseline failures and environment limitations based on comparison with the baseline.
5. Push and pull request are separate actions after review of the accepted commit.

Detailed commands and safe Git constraints are in `AGENTS.md`.

## 14. What Is Outside the Standard

- a runtime orchestrator;
- automatic selection of specific models;
- separate `T0–T6` and `L0–L4` scales;
- vendor-specific APIs;
- mandatory Prewalk;
- a universal runtime state machine for agent runs.

These constraints keep the starter kit universal and portable.
