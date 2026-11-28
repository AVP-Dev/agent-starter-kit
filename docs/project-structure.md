# Project Structure and File Hygiene

> **Purpose:** Keep projects readable, localized, and predictable, regardless of language, framework, or team size.
>
> **Boundary:** This document defines principles and flexible guidelines. A project may define its own conventions in `AGENTS.md` or its DESIGN manifest.

## 1. Core Principle

Small files with a single responsibility, explicit names, implementation kept within its owner, and centralization only for genuinely shared contracts.

A large project does not become clean simply by accumulating documentation. Cleanliness comes from file, directory, and dependency boundaries that can be explained without reading the entire codebase.

## 2. File Size

For handwritten source code, 300–500 lines is a guideline. At 500–800 lines or more, assess whether a distinct responsibility can be extracted. Keep a cohesive file intact if splitting it would spread one use case across several files or complicate verification. Line count alone does not require an exception, a report, or a refactoring plan.

For generated files, lockfiles, migrations, schemas, snapshots, and test data, their format and purpose determine their size. In an existing project, respect its conventions and the scope of the current task.

## 3. One Responsibility per File

A file should not become a container for everything that "relates to the project."

Avoid:

- `utils.ts` and `helpers.ts` without a specific scope;
- `misc/`, `stuff/`, `common/`, `final/`, `new/`;
- Mixing APIs, validation, databases, UI, and business logic;
- Multiple unrelated responsibilities in a single diff;
- Files that simultaneously serve as registries, implementations, and documentation.

If a file is hard to describe in one phrase, split it by responsibility, not mechanically by line count.

## 4. Naming

The name of a file, directory, type, or function should answer "what does this do," not "who created it or when."

Good examples:

- `invoice-validation.ts` — validates the invoice contract;
- `tenant-scope.ts` — manages tenant boundaries;
- `payment-provider.ts` — isolates an external provider;
- `billing-invoice-service.ts` — owns the invoice use case.

Do not use `new`, `final`, `latest`, `common`, `misc`, or temporary names in permanent code. The project's language determines casing and separator conventions; define them once.

## 5. Directories and Ownership

A directory should have a single clear responsibility and owner. Recommended neutral layout:

```text
src/
├── app/                 # composition, routes, application entrypoints
├── modules/             # isolated domain modules
├── shared/              # stable shared contracts and schemas
├── workers/             # background processes
├── infrastructure/      # external adapters and infrastructure
└── generated/           # generated code, if permitted by the project

tests/
docs/
scripts/
migrations/
```

This structure is not a mandatory template: a Brownfield project first documents its actual layout and then adds missing areas if needed.

## 6. Centralization

Centralize stable contracts:

- DTOs and API/worker contracts;
- Validation schemas;
- Error codes and event contracts;
- Configuration schemas;
- Shared types;
- Test fixtures, if genuinely shared.

Local details stay within their module:

- Private SQL queries;
- UI components;
- Domain exceptions;
- Local utility functions;
- Configuration for a single module.

Move code to `shared` only when it has at least two independent, stable consumers. Do not create `shared` as a dumping ground for code that has not yet been classified.

## 7. Dependency Direction

Preferred direction:

```text
app → modules → shared contracts
app → infrastructure
workers → modules/contracts
```

A module does not import another module's private tables, internal files, or state. Cross-module communication flows through contracts, services, or Skeleton events.

Use project linters or import-boundary checks to detect cycles and implicit dependencies. Large-scale refactoring to correct the structure requires a DESIGN manifest first.

## 8. Tests and Artifacts

- Tests follow logical module boundaries rather than mixing unit, integration, and end-to-end tests in one file.
- Fixtures and factories have an explicit owner.
- Generated code, snapshots, and lockfiles are not edited manually.
- Temporary files and scratch artifacts are excluded from the canonical source scope.
- A single file should not contain unrelated test suites solely to reduce the number of files.

## 9. When Refactoring Is Needed

Consider structural refactoring if:

- A file spans multiple responsibilities;
- One module depends on another module's internals;
- The same logic is duplicated across multiple independent branches;
- File size or imports prevent safe work;
- Directory ownership can no longer be explained.

For a major structural change, document the boundaries, impact, and verification method. Approve large-scale cleanup as a separate task.

## 10. Onboarding and Updates

When integrating the Kit, the agent:

1. Builds an accurate directory and ownership map;
2. Identifies large and duplicate files if their structure impedes work;
3. Reviews shared code and dependency directions;
4. Preserves established boundaries and names;
5. Proposes separate, small refactoring tasks;
6. Records project conventions in `AGENTS.md` or the DESIGN manifest.

## 11. Review Checklist

- [ ] Each substantial file has one clear responsibility.
- [ ] Names describe purpose, not temporary history.
- [ ] Shared code has at least two independent consumers.
- [ ] There are no circular or hidden cross-module dependencies.
- [ ] One owner is responsible for each module's canonical documents.
- [ ] Boundaries and size of the affected files allow safe reading, editing, and verification.
- [ ] Generated, test, and production artifacts are not mixed.
- [ ] Structural refactoring is separate from functional changes.
