# Current Project State (Session Ledger)

> This file saves context and tokens by capturing the current state at the end of each working session: "What is done, what is in progress, what is broken, and what comes next."
> In a new project, the agent fills in this template after onboarding; in an existing project, it updates the file without deleting project records.

---

###### Last updated
Date: [YYYY-MM-DD] (Status: Initialization / Active development)

**Key results of the last session:**
1. [Result 1]
2. [Result 2]
3. [Session achievements]

**Work in progress:**
- [ ] [Current task, component, or module under development]

## Active Runs

> For long-running tasks and multi-agent work. Update after each checkpoint or quality gate. Do not record secrets or raw transcripts.

| Run ID | Task / Topology | Owner | Scope | Status | Evidence | Last good commit | Next step |
|---|---|---|---|---|---|---|---|
| [run-id] | [task / topology] | [worker or orchestrator] | [files/modules] | [planned / running / verified / accepted / blocked] | [link to evidence] | [commit or `—`] | [one action] |

**What is broken / Known technical debt:**
- None (or a specific list of known issues and tradeoffs requiring resolution).
- For each entry, record the reason, scope, risk, owner, and date or measurable condition for reconsideration. See the [lifecycle policy](lifecycle.md).

**Next steps:**
1. [Next priority task on the plan]
2. [Check available project commands: typecheck, lint, test]
