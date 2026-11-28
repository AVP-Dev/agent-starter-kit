#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf '%s\n' "Usage: $0 [--profile PATH] [--only LAYER[,LAYER...]] [--list] [--dry-run] [--diagnostic]" \
    "  --profile PATH  command profile relative to the project root" \
    "  --only LAYERS   run only the specified layers" \
    "  --list          show the profile without running checks" \
    "  --dry-run       show the selected checks without running them" \
    "  --diagnostic    allow runs without required checks (not an Acceptance Gate)"
}

fail() {
  printf 'verify-project: %s\n' "$*" >&2
  exit 2
}

PROFILE_PATH="scripts/verification-profile.tsv"
ONLY=""
LIST_ONLY=0
DRY_RUN=0
DIAGNOSTIC=0
seen_names=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      [ "$#" -ge 2 ] || fail "--profile requires a path"
      PROFILE_PATH="$2"
      shift 2
      ;;
    --only)
      [ "$#" -ge 2 ] || fail "--only requires a list of layers"
      ONLY="$2"
      shift 2
      ;;
    --list)
      LIST_ONLY=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --diagnostic)
      DIAGNOSTIC=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

case "$PROFILE_PATH" in
  /*) PROFILE_FILE="$PROFILE_PATH" ;;
  *) PROFILE_FILE="$PROJECT_ROOT/$PROFILE_PATH" ;;
esac

valid_layer() {
  case "$1" in
    static|positive|negative|security|regression|integration|build) return 0 ;;
    *) return 1 ;;
  esac
}

selected_layer() {
  [ -z "$ONLY" ] && return 0
  case ",$ONLY," in
    *",$1,"*) return 0 ;;
    *) return 1 ;;
  esac
}

if [ -n "$ONLY" ]; then
  case "$ONLY" in
    ,*|*,|*,,*) fail "empty layer in --only" ;;
  esac
  IFS=',' read -r -a requested_layers <<<"$ONLY"
  [ "${#requested_layers[@]}" -gt 0 ] || fail "empty --only"
  for layer in "${requested_layers[@]}"; do
    valid_layer "$layer" || fail "unknown layer: $layer"
  done
fi

[ -f "$PROFILE_FILE" ] || fail "profile not found: $PROFILE_FILE"
[ -r "$PROFILE_FILE" ] || fail "profile is not readable: $PROFILE_FILE"

cd "$PROJECT_ROOT"

names=()
layers=()
requirements=()
commands=()
selected=0
failures=0
warnings=0
required_passed=0
line_number=0

while IFS= read -r row || [ -n "$row" ]; do
  line_number=$((line_number + 1))
  row="${row%$'\r'}"
  case "$row" in
    ''|\#*) continue ;;
  esac

  # Bash read collapses whitespace delimiters, including empty TSV fields.
  tab=$'\t'
  case "$row" in
    *"$tab"*"$tab"*"$tab"*"$tab"*) fail "line $line_number: extra fields" ;;
    *"$tab"*"$tab"*"$tab"*) ;;
    *) fail "line $line_number: expected four fields" ;;
  esac
  name="${row%%"$tab"*}"
  row="${row#*"$tab"}"
  layer="${row%%"$tab"*}"
  row="${row#*"$tab"}"
  required="${row%%"$tab"*}"
  command="${row#*"$tab"}"
  [[ "$name" =~ ^[A-Za-z0-9._-]+$ ]] || fail "line $line_number: invalid check name"
  valid_layer "$layer" || fail "line $line_number: unknown layer '$layer'"
  case "$required" in
    0|1) ;;
    *) fail "line $line_number: required must be 0 or 1" ;;
  esac
  [ -n "$command" ] || fail "line $line_number: command cannot be empty"
  case ";$seen_names;" in
    *";$name;"*) fail "line $line_number: duplicate check name '$name'" ;;
  esac
  seen_names="$seen_names;$name"
  names+=("$name")
  layers+=("$layer")
  requirements+=("$required")
  commands+=("$command")
done <"$PROFILE_FILE"

[ "${#names[@]}" -gt 0 ] || fail "profile contains no checks"

if [ "$LIST_ONLY" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ "$DIAGNOSTIC" -eq 0 ]; then
  selected_required=0
  for index in "${!names[@]}"; do
    if selected_layer "${layers[$index]}" && [ "${requirements[$index]}" -eq 1 ]; then
      selected_required=$((selected_required + 1))
    fi
  done
  [ "$selected_required" -gt 0 ] || fail "Acceptance Gate requires at least one required check"
fi

for index in "${!names[@]}"; do
  name="${names[$index]}"
  layer="${layers[$index]}"
  required="${requirements[$index]}"
  command="${commands[$index]}"

  if [ "$LIST_ONLY" -eq 1 ]; then
    if selected_layer "$layer"; then
      printf '%s\t%s\t%s\t%s\n' "$name" "$layer" "$required" "$command"
    else
      printf '%s\t%s\t%s\t%s\tskipped\n' "$name" "$layer" "$required" "$command"
    fi
    continue
  fi

  selected_layer "$layer" || continue
  selected=1
  printf '[verify] %s (%s)\n' "$name" "$layer"

  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[verify] dry-run: %s\n' "$command"
    continue
  fi

  if bash -c "$command"; then
    if [ "$required" -eq 1 ]; then
      required_passed=$((required_passed + 1))
    fi
    printf '[verify] %s: passed\n' "$name"
  else
    status=$?
    if [ "$required" -eq 1 ]; then
      failures=$((failures + 1))
      printf '[verify] %s: failed (exit %s, required)\n' "$name" "$status" >&2
    else
      warnings=$((warnings + 1))
      printf '[verify] %s: warning (exit %s, optional)\n' "$name" "$status" >&2
    fi
  fi
done

if [ "$LIST_ONLY" -eq 1 ]; then
  exit 0
fi

[ "$selected" -eq 1 ] || fail "no checks selected to run"

if [ "$failures" -gt 0 ]; then
  printf '[verify] failed: %s required check(s), %s warning(s)\n' "$failures" "$warnings" >&2
  exit 1
fi

if [ "$DRY_RUN" -eq 1 ]; then
  printf '[verify] dry-run: no checks executed\n'
elif [ "$required_passed" -eq 0 ]; then
  printf '[verify] diagnostic: no required checks executed, %s warning(s)\n' "$warnings"
elif [ "$DIAGNOSTIC" -eq 1 ] || [ -n "$ONLY" ]; then
  printf '[verify] partial/diagnostic: %s required check(s) passed, %s warning(s)\n' "$required_passed" "$warnings"
else
  printf '[verify] passed: %s required check(s), %s warning(s)\n' "$required_passed" "$warnings"
fi
