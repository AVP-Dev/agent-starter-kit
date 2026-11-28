#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' "Usage: $0 [--dry-run] [--yes] [--update] [--with-claude] <project-path>" \
    "  --dry-run  show changes without applying them" \
    "  --yes      create a missing directory without prompting" \
    "  --update   update an existing project by adding only missing files" \
    "  --with-claude  add CLAUDE.md importing AGENTS.md for compatibility"
}

DRY_RUN=0
ASSUME_YES=0
UPDATE_MODE=0
WITH_CLAUDE=0
TARGET_DIR=""
CREATED_PATHS=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    --update)
      UPDATE_MODE=1
      shift
      ;;
    --with-claude)
      WITH_CLAUDE=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ -n "$TARGET_DIR" ]; then
        printf 'More than one path specified: %s\n' "$1" >&2
        exit 1
      fi
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

if [ "$#" -gt 0 ]; then
  if [ -n "$TARGET_DIR" ]; then
    printf 'More than one path specified: %s\n' "$1" >&2
    exit 1
  fi
  TARGET_DIR="$1"
fi

if [ -z "$TARGET_DIR" ]; then
  usage >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
STARTER_KIT_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$STARTER_KIT_DIR/AGENTS.md" ]; then
  printf 'Starter Kit AGENTS.md not found: %s\n' "$STARTER_KIT_DIR" >&2
  exit 1
fi

if [ -e "$TARGET_DIR" ] && [ ! -d "$TARGET_DIR" ]; then
  printf 'Path exists and is not a directory: %s\n' "$TARGET_DIR" >&2
  exit 1
fi

if [ "$UPDATE_MODE" -eq 1 ] && [ ! -d "$TARGET_DIR" ]; then
  printf 'The --update mode requires an existing project directory: %s\n' "$TARGET_DIR" >&2
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Dry-run: would create directory %s\n' "$TARGET_DIR"
  elif [ "$ASSUME_YES" -eq 1 ]; then
    mkdir -p "$TARGET_DIR"
  elif [ -t 0 ]; then
    printf 'Directory "%s" does not exist. Create it? (y/n) ' "$TARGET_DIR"
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      mkdir -p "$TARGET_DIR"
    else
      printf 'Cancelled.\n'
      exit 0
    fi
  else
    printf 'Directory does not exist. Use --yes to create it non-interactively.\n' >&2
    exit 1
  fi
fi

if [ "$DRY_RUN" -eq 0 ]; then
  TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"
fi

cleanup_on_exit() {
  status=$?
  trap - EXIT
  if [ "$status" -ne 0 ] && [ "$DRY_RUN" -eq 0 ]; then
    index=$((${#CREATED_PATHS[@]} - 1))
    while [ "$index" -ge 0 ]; do
      created_path="${CREATED_PATHS[$index]}"
      if [ -L "$created_path" ]; then
        rm -f "$created_path" || true
      elif [ -d "$created_path" ]; then
        rmdir "$created_path" 2>/dev/null || true
      elif [ -e "$created_path" ]; then
        rm -f "$created_path" || true
      fi
      index=$((index - 1))
    done
  fi
  exit "$status"
}

trap cleanup_on_exit EXIT

if [ -e "$TARGET_DIR/AGENTS.md" ] || [ -L "$TARGET_DIR/AGENTS.md" ]; then
  if [ ! -f "$TARGET_DIR/AGENTS.md" ] && [ ! -L "$TARGET_DIR/AGENTS.md" ]; then
    printf 'AGENTS.md path exists and is not a file: %s\n' "$TARGET_DIR/AGENTS.md" >&2
    exit 1
  fi
fi

if [ -e "$TARGET_DIR/.gitignore" ] || [ -L "$TARGET_DIR/.gitignore" ]; then
  if [ ! -f "$TARGET_DIR/.gitignore" ] && [ ! -L "$TARGET_DIR/.gitignore" ]; then
    printf '.gitignore path exists and is not a file: %s\n' "$TARGET_DIR/.gitignore" >&2
    exit 1
  fi
fi

if [ -L "$TARGET_DIR/docs" ]; then
  printf 'A symlinked docs directory is not supported: %s\n' "$TARGET_DIR/docs" >&2
  exit 1
fi

if [ -e "$TARGET_DIR/docs" ] || [ -L "$TARGET_DIR/docs" ]; then
  if [ ! -d "$TARGET_DIR/docs" ]; then
    printf 'docs path exists and is not a directory: %s\n' "$TARGET_DIR/docs" >&2
    exit 1
  fi
fi

if [ -L "$TARGET_DIR/scripts" ]; then
  printf 'A symlinked scripts directory is not supported: %s\n' "$TARGET_DIR/scripts" >&2
  exit 1
fi

if [ -e "$TARGET_DIR/scripts" ] || [ -L "$TARGET_DIR/scripts" ]; then
  if [ ! -d "$TARGET_DIR/scripts" ]; then
    printf 'scripts path exists and is not a directory: %s\n' "$TARGET_DIR/scripts" >&2
    exit 1
  fi
fi

for doc in "$STARTER_KIT_DIR/docs/"*; do
  [ -f "$doc" ] || continue
  destination="$TARGET_DIR/docs/$(basename "$doc")"
  if [ -e "$destination" ] || [ -L "$destination" ]; then
    if [ ! -f "$destination" ] && [ ! -L "$destination" ]; then
      printf 'Document path exists and is not a file: %s\n' "$destination" >&2
      exit 1
    fi
  fi
done

for tool in verify-project.sh security-scan.sh; do
  destination="$TARGET_DIR/scripts/$tool"
  if [ -e "$destination" ] || [ -L "$destination" ]; then
    if [ ! -f "$destination" ] && [ ! -L "$destination" ]; then
      printf 'Tool path exists and is not a file: %s\n' "$destination" >&2
      exit 1
    fi
  fi
done

PROJECT_KIND="greenfield"
for marker in AGENTS.md CLAUDE.md docs scripts .github/workflows .gitlab-ci.yml package.json pnpm-lock.yaml package-lock.json yarn.lock bun.lock bun.lockb pyproject.toml requirements.txt go.mod Cargo.toml Dockerfile Makefile src app apps lib packages tests; do
  if [ -e "$TARGET_DIR/$marker" ] || [ -L "$TARGET_DIR/$marker" ]; then
    PROJECT_KIND="brownfield"
    break
  fi
done

printf 'Mode: %s\n' "$([ "$UPDATE_MODE" -eq 1 ] && printf 'update' || printf 'initialization')"
printf 'Candidate track: %s\n' "$PROJECT_KIND"
printf 'Target project: %s\n' "$TARGET_DIR"

copy_if_missing() {
  source_path="$1"
  destination_path="$2"
  destination_name="$(basename "$destination_path")"

  if [ -e "$destination_path" ] || [ -L "$destination_path" ]; then
    printf 'Preserved: %s\n' "$destination_name"
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Would add: %s\n' "$destination_name"
    return 0
  fi

  CREATED_PATHS+=("$destination_path")
  cp "$source_path" "$destination_path"
  printf 'Added: %s\n' "$destination_name"
}

if [ ! -d "$TARGET_DIR/docs" ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Would create: docs/\n'
  else
    CREATED_PATHS+=("$TARGET_DIR/docs")
    mkdir -p "$TARGET_DIR/docs"
    printf 'Created: docs/\n'
  fi
else
  printf 'Preserved: docs/\n'
fi

copy_if_missing "$STARTER_KIT_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
copy_if_missing "$STARTER_KIT_DIR/.gitignore" "$TARGET_DIR/.gitignore"

if [ -e "$TARGET_DIR/CLAUDE.md" ] || [ -L "$TARGET_DIR/CLAUDE.md" ]; then
  printf 'Preserved existing CLAUDE.md unchanged\n'
elif [ "$WITH_CLAUDE" -eq 1 ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Would add: CLAUDE.md importing AGENTS.md\n'
  else
    (set -o noclobber; printf '@AGENTS.md\n' >"$TARGET_DIR/CLAUDE.md")
    CREATED_PATHS+=("$TARGET_DIR/CLAUDE.md")
    printf 'Added: CLAUDE.md importing AGENTS.md\n'
  fi
fi

if [ ! -d "$TARGET_DIR/scripts" ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'Would create: scripts/\n'
  else
    CREATED_PATHS+=("$TARGET_DIR/scripts")
    mkdir -p "$TARGET_DIR/scripts"
    printf 'Created: scripts/\n'
  fi
else
  printf 'Preserved: scripts/\n'
fi

for tool in verify-project.sh security-scan.sh; do
  copy_if_missing "$STARTER_KIT_DIR/scripts/$tool" "$TARGET_DIR/scripts/$tool"
done

for doc in "$STARTER_KIT_DIR/docs/"*; do
  [ -f "$doc" ] || continue
  copy_if_missing "$doc" "$TARGET_DIR/docs/$(basename "$doc")"
done

printf '\nReview the result and have an agent run the onboarding protocol:\n'
printf '  1. Read docs/onboarding-protocol.md.\n'
printf '  2. For Brownfield projects, inspect manifests, lockfiles, tests, and documentation.\n'
printf '  3. For Greenfield projects, answer only questions that cannot be resolved from files.\n'
printf '  4. Create scripts/verification-profile.tsv based on docs/verification-profile.example.tsv.\n'
printf '  5. Ask the agent to complete AGENTS.md and present a report before approval.\n'
printf '\nExisting project files are not overwritten.\n'
