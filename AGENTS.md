# [Project name]

[Project purpose, users, and primary workflows.]

This file contains the project's working agreements. Complete the fields using the [onboarding protocol](docs/onboarding-protocol.md) and consult the relevant documents for each task. The [AGENTS.md](https://agents.md/) format is supported by various tools. Check instruction loading order for the client in use.

## Project context

- Stack and versions — [confirmed by manifests and lockfiles].
- Structure and module owners — [key directories, entry points, and boundaries].
- Development and verification commands — [actual commands, working directories, and environment dependencies].
- Operational stage and review triggers — [actual risks and consumers].

For an existing project, rely on the code, accepted contracts, and working checks. For a new project, choose the minimum stack suited to the product and operating conditions. Clarify only decisions that cannot be inferred from the repository and materially affect the work. When using libraries, verify APIs against documentation for the installed version using Context7 or official sources. Do not upgrade dependencies merely to match documentation examples.

## Mandatory boundaries

| Zone | Authority |
|---|---|
| Zone 1 | The agent implements reversible changes within the accepted contract. |
| Zone 2 | The human approves a contract change; the agent implements and verifies it. |
| Zone 3 | Irreversible operations and critical decisions remain under human control; execution requires separate authorization. |

- Preserve existing data, other contributors' changes, and user instructions. Validate inputs at trust boundaries and retain error context without disclosing secrets.
- Before changing a stored-data schema, access model, agreed interservice contract, security protocol, or financial transaction rules, obtain explicit approval for the specific change. Briefly state the rationale, affected components, and plan. A reversible fix within an accepted contract can proceed after the usual impact assessment.
- Obtain approval for irreversible operations and publication. Maintain test verifiability and report actual verification results.
- Obtain approval for new external services, paid dependencies, data transfers outside the accepted boundary, significant stack changes, and weakening mandatory checks.
- Apply the [lifecycle policy](docs/lifecycle.md) according to the risk of the affected subsystem, including small changes involving real data and financial operations. Security, data integrity, and isolation are mandatory at every stage.
- Before committing, inspect status and diff and stage only task-related files. Follow Conventional Commits if the project uses them. Pushes, PRs, and releases are separate actions performed on request or under the accepted process.

## Working guidance

- Make the smallest coherent change. For substantial decision points, record invariants, failure conditions, and acceptance criteria. Add state machines and idempotency when the workflow requires them. See the [DESIGN template](docs/design-manifest-template.md).
- Choose the working approach based on risk, task coupling, and available tools. Delegate independent parts if doing so accelerates work or improves verification. For long tasks, save a brief checkpoint at handoff, pause, or after a meaningful milestone. See [agent routing](docs/agent-routing.md).
- File size, diff size, and report length are guidelines. For a manually authored file, 300–500 lines are usually convenient. At 500–800 lines or more, assess cohesion and possible boundaries if size becomes a practical obstacle. A large cohesive file is acceptable. Meet hard platform limits by changing format, for example with a brief comment linking to a full report. Retry when new evidence or a new approach becomes available. See [project structure](docs/project-structure.md).
- Apply the [architecture guidance](docs/architecture.md) and [design tokens](docs/theme-tokens.md) according to the project type. Use the existing design system and verify accessibility of the affected interface.
- Check the local Git baseline. Check the remote branch when integration depends on it being current. If the network is unavailable or the branch is behind, report it and continue independent work. Synchronize branches deliberately, accounting for local changes.

## Result verification

1. Identify what is affected and record baseline verification results when necessary.
2. Run the project checks relevant to the change. Add a regression test when behavior changes and existing coverage misses the scenario. For documentation, check links, examples, and consistency.
3. If the project has adopted `scripts/verification-profile.tsv`, use `./scripts/verify-project.sh`. The target project defines CI and release conditions.
4. Report what was completed, which failures appeared after the change, which existed in the baseline, and which checks were unavailable. Do not expand the task to fix unrelated baseline failures.
5. Do not declare the task accepted until applicable mandatory checks pass, invariants are confirmed, and affected documents are updated. Diagnostics, partial runs, and blocked checks do not constitute a full Acceptance Gate.

See [verification and impact assessment](docs/verification.md). Update the [state ledger](docs/state.md) at meaningful changes or handoff after installing the kit. Record accepted architectural decisions in the [ADR registry](docs/decisions.md).
