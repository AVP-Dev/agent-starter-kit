#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

for path in .gitignore .github/workflows/verification.yml AGENTS.md README.md docs/architecture.md docs/lifecycle.md docs/theme-tokens.md docs/verification.md scripts/init-project.sh scripts/verify-project.sh scripts/security-scan.sh; do
  [ -e "$ROOT/$path" ] || fail "missing required file: $path"
done

[ ! -e "$ROOT/README.ru.md" ] && [ ! -L "$ROOT/README.ru.md" ] || fail 'obsolete Russian README is present'

# Check UTF-8 Cyrillic (U+0400–U+052F) in the C locale so the result does not
# depend on the UTF-8 locales available on the machine or CI runner.
cyrillic_pattern=$'[\xD0-\xD3][\x80-\xBF]|\xD4[\x80-\xAF]'
while IFS= read -r -d '' path; do
  if LC_ALL=C grep -qE "$cyrillic_pattern" "$path"; then
    fail "Cyrillic text in English-only file: ${path#"$ROOT/"}"
  else
    [ "$?" -eq 1 ] || fail "could not check language: $path"
  fi
done < <(
  printf '%s\0' "$ROOT/AGENTS.md" "$ROOT/README.md" "$ROOT/CHANGELOG.md"
  find "$ROOT/docs" "$ROOT/scripts" "$ROOT/tests" -type f \( -name '*.md' -o -name '*.tsv' -o -name '*.sh' \) -print0
)

for zone in 1 2 3; do
  grep -q "^| Zone $zone |" "$ROOT/AGENTS.md" || fail "missing delegation zone: $zone"
done


workflow="$ROOT/.github/workflows/verification.yml"
grep -q '^  pull_request:$' "$workflow" || fail 'CI does not run for pull requests'
grep -q '^  contents: read$' "$workflow" || fail 'CI permissions are not read-only'
grep -q 'actions/checkout@v7' "$workflow" || fail 'CI checkout action is not pinned'
grep -q 'persist-credentials: false' "$workflow" || fail 'CI checkout persists credentials'

for ignored in .env .env.local node_modules/example dist/example build/example coverage/example __pycache__/example.py target/example; do
  git -C "$ROOT" check-ignore --no-index -q "$ignored" || fail "not ignored: $ignored"
done

for token in background foreground card card-foreground popover popover-foreground primary primary-foreground secondary secondary-foreground accent accent-foreground muted muted-foreground border input ring destructive destructive-foreground radius; do
  count="$(grep -c -- "^[[:space:]]*--$token:" "$ROOT/docs/theme-tokens.md" || true)"
  [ "$count" -ge 2 ] || fail "theme token is not defined in base and example themes: $token"
done

while IFS= read -r path; do
  case "$path" in
    .DS_Store|*.log|.env|.env.*|node_modules/*|dist/*|build/*|coverage/*|tmp/*|scratch/*) fail "internal artifact is tracked: $path" ;;
  esac
done < <(git -C "$ROOT" ls-files)

printf 'template hygiene: PASS\n'
