# Verification, Safety, and Impact Policy

> **Purpose:** Define what to verify before and after a change, how to identify risk before editing, and when to escalate a task for deeper verification.
>
> **Boundary:** This is a policy for the agent and a project checklist. The universal dispatcher runs only explicitly defined project-local commands; lint, typecheck, test, and security tooling commands are determined by the specific project's manifests.

## 1. What Coverage Means in the Kit

Link critical invariants to verifiable evidence: for example, import-boundary checks for module boundaries, contract tests for APIs, constraints and transaction tests for integrity, integration tests for isolation, and migration smoke tests for schemas. Automatable red lines must have required checks; if automation is impossible, specify an explicit manual verification procedure and its result. Lack of evidence does not count as a successful check. Do not change required=1 to required=0 to pass a gate.

Coverage is more than the percentage of lines. For each change, record which verification layers are covered:

- **Static:** Types, schemas, imports, formatting, and dependency boundaries.
- **Positive:** The main successful scenario.
- **Negative:** Invalid inputs, boundaries, service failure, timeout, duplicates, and partial failure.
- **Security:** Auth, permissions, tenant isolation, secrets, untrusted input, and safe handling of external data.
- **Regression:** Existing tests and user invariants that must not be broken.
- **Integration:** Contracts, databases, queues, APIs, workers, and external adapters.
- **Acceptance:** Specific acceptance invariants from the DESIGN manifest.

## 2. Pre-change Impact Gate

Assess the impact before making a change. For a local change, reviewing the affected code or document and selecting a check is sufficient. For risky work, use the applicable steps:

1. List affected files, modules, contracts, and consumers.
2. Read the current invariants and existing tests near the change.
3. Determine whether the change may affect auth, data, APIs, queues, UI, migrations, or external integrations.
4. Record the baseline: which checks pass before the change.
5. Define the rollback or safe revert for the change.
6. Define negative and security scenarios before implementing the solution.
7. Clarify scope and risk using local verification. Request a decision if a material choice remains regarding contracts, permissions, or consequences.

The impact check must not turn into a review of the entire repository. It is limited to the affected dependency surface and risk area.

## 3. What to Verify by Task Class

| Scope | Relevant Checks |
|---|---|
| Documentation | Links and consistency between the description and actual behavior |
| Zone 1, pure function or local UI | positive, boundary/negative, regression |
| Zone 1, parser/DTO/validator | positive, malformed input, boundary, regression |
| Zone 2, endpoint/worker/integration | positive, negative, security, integration, idempotency |
| Shared contract change | all affected consumers, schema compatibility, regression |
| UI change | positive, negative states, keyboard/a11y, responsive regression |
| Zone 3 or irreversible action | human Confirmation Gate, security, rollback/stop plan, post-action evidence |

Compare results against the baseline. Fix new regressions within the task's scope. Report baseline failures, unavailable checks, and their reasons. Add tests when needed for changed behavior, regression prevention, or meeting a project requirement.

## 4. Negative and Security Scenarios

A baseline list for analyzing changes:

- Empty input, `null`, incorrect type, and boundary values;
- Malformed JSON, schema mismatch, and unexpected format;
- Duplicate requests, retries, races, and concurrent writes;
- Timeout, network failure, partial response, and unavailable dependencies;
- Stale cache, stale artifacts, and version conflicts;
- Insufficient role, another tenant/project, and access to another owner's resource;
- Untrusted documents, prompt injection, and malicious external input;
- Secrets in logs, error messages, artifacts, or checkpoints;
- Rollback after a failed migration or irreversible operation.

A check must demonstrate the invariant, not just the absence of an exception.

## 5. Safe Simulation Before a Change

If a change is difficult to verify directly, use a minimal safe probe first:

- Schema validation with a synthetic payload;
- Dry-run or plan without writes;
- Contract test with a mock/fake dependency;
- Verification on a temporary fixture or isolated database;
- Reverse diff and impact analysis;
- Verification of the rollback command without executing it.

A probe must not change production, real payments, access permissions, or user data. If a safe probe is impossible, human approval or a task split is required.

## 6. Verification Context and Budget

The agent runs deterministic and local checks first, then expands the context selectively:

1. Verify the changed scope first.
2. Verify direct consumers next.
3. Run relevant integration/regression tests next.
4. Proceed to broader scanning only when impact is confirmed.

Limit reading to the verification scope. Retry when there is new information, a temporary failure, or a different approach. If the working budget is exhausted, change the format or deliver the confirmed result while identifying the remaining gap. A hard agreed limit or environment constraint stops the affected operation.

Report, comment, and diff length are guidelines. Preserve material findings and evidence. If the platform limits comment length, include the conclusion and a link to the full report, or split the response into parts if the format permits.

## 7. When Deeper Verification Is Needed

Increase verification depth if:

- A hypothesis is not confirmed;
- A discrepancy between documentation and code is found;
- A shared contract or Skeleton changes;
- Auth, permissions, tenant isolation, or data ownership are affected;
- Concurrency, retries, partial failure, or rollback are involved;
- A test unexpectedly passes or fails;
- The agent cannot explain why the change is safe;
- A worker's result fails independent verification.

Actions: targeted probe, side research, independent reviewer, increased reasoning, DESIGN manifest update, or human gate. Do not simply repeat the same cycle.

## 8. Evidence and Results

Briefly state what was verified, the result, and what remains. For important checks, the following information is useful:

- Command or check;
- Scope and commit/revision;
- Result: `passed`, `failed`, or `blocked`;
- Negative/security scenarios;
- Link to evidence;
- Reason for failure and next step;
- For non-trivial work, `Measured outcome` with 1–2 metrics.

In `state.md` and the task ledger, keep a link to the result rather than the full test process transcript.

## 9. What to Record in the DESIGN Manifest

For a task with meaningful risk, choose applicable fields:

- `Pre-change impact check`;
- `Verification layers`;
- `Rollback / stop plan`;
- `Context budget / escalation trigger`;
- `Measured outcome`.

For a Lightweight task, three lines are enough: the goal, invariant, and verification command.

## 10. Project-local Verification Profile

The starter kit provides a universal dispatcher but does not guess the commands for a specific project. The Kit root has its own `scripts/verification-profile.tsv` for its smoke gate; it is not copied to the target project. After reading the manifests, the agent creates a separate `scripts/verification-profile.tsv` in the target project based on `docs/verification-profile.example.tsv`.

TSV format: `name<TAB>layer<TAB>required<TAB>command`.

- `name` — a unique check name without spaces;
- `layer` — `static`, `positive`, `negative`, `security`, `regression`, `integration`, or `build`;
- `required` — `1` for a blocking gate or `0` for a warning;
- `command` — a command without tabs or secrets, run from the project root.

The dispatcher runs commands from the profile through `bash -c`, does not inherit hidden arguments, and does not change access permissions:

```bash
./scripts/verify-project.sh --list
./scripts/verify-project.sh --only static,security
./scripts/verify-project.sh --dry-run
./scripts/verify-project.sh
```

`--list` and `--dry-run` show the name, layer, and command before execution so that review does not depend on assumptions.

The dispatcher validates the entire profile before running commands. If the profile is missing or invalid, it returns exit code `2`. Failure of any selected command with `required=1` results in exit code `1`, while failure of an optional check results in a warning. The summary includes the number of successful required checks.

A full Acceptance Gate runs the entire active profile without filters, includes at least one required check, and passes all required commands. If there are no required checks in the selected set, a normal run returns exit code `2`. Use `--diagnostic` for diagnostics; partial `--only` runs, diagnostics, `--list`, and `--dry-run` do not confirm full acceptance.

`scripts/security-scan.sh` is a dependency-free baseline for tracked and non-ignored untracked files, including tracked generated artifacts: private key material, AWS/GCP key patterns, likely GitHub, Anthropic, OpenAI, and Slack tokens, database URLs containing credentials, case-insensitive sensitive assignments (including compound variable names, suffixes, and quoted keys), and `.env` files. Environment references and string literals are distinguished at the individual assignment level; independent findings are not suppressed. This is a heuristic: a clean result does not prove the absence of secrets; ignored untracked files and Git history are outside the scanning scope. The scanner does not print the detected values, only `path:line` and a category; an error reading or listing files ends the scan with exit code `2`. It does not replace SAST, dependency audits, container scanning, or DAST; approved project tools are added as separate `security` rows in the profile.

The profile must not contain tokens, passwords, or private keys. If a command may expose a secret, do not include it in the verification gate until a separate decision has been made and a safe masking method is available.

## 11. Verification Profile Onboarding

1. Read manifests, lockfiles, CI, and existing scripts.
2. Choose commands already confirmed by the project; do not silently install tools.
3. Create `scripts/verification-profile.tsv` and fill in the examples for the actual stack.
4. Add the baseline secret scan and available security checks with explicit `required` settings and failure semantics.
5. Run `./scripts/verify-project.sh --dry-run`, then the full gate.
6. Record the baseline, environment constraints, and evidence in the target project's DESIGN manifest and `state.md`.

If the project cannot run a verification layer, the agent records it as `blocked` with the reason in the DESIGN manifest and `state.md`; do not add a missing command to the profile as a fictitious successful check.

## 12. CI and Release Gate

The starter kit workflow `.github/workflows/verification.yml` runs the local profile on pushes to `main`, pull requests to `main`, and manual runs. The workflow uses `contents: read`, `pull_request` without trusted-base secrets, checkout without persistent credentials, and verifies Markdown links and a clean working tree. The installer does not transfer the workflow to target projects. Integrate confirmed commands through the project's CI.

Release sequence: green Gate → Conventional Commit → push → confirmed CI check → annotated tag in the form `vYYYY.N.P` → push tag. An empty or red Gate blocks the tag; a GitHub Release is created from the already verified tag.

## 13. Final Checklist

Definition of Done: applicable invariants are confirmed, required checks are completed, affected documents are updated, and the result is recorded. A blocked required check means blocked, not accepted; unrelated baseline failures are reported separately.

- [ ] Checks were defined before the change.
- [ ] There is positive, negative, and regression coverage.
- [ ] Security risks have been explicitly considered.
- [ ] A project-local verification profile exists with confirmed commands.
- [ ] The secret baseline was run and available SAST/SCA checks were added.
- [ ] A safe probe or dry-run exists if the change is risky.
- [ ] The rollback/stop path is known.
- [ ] Verification context is limited to the impact surface.
- [ ] A targeted deep check was run when in doubt.
- [ ] The result has evidence and a measurable outcome.
- [ ] The project's established required gates have been verified for integration or release.
