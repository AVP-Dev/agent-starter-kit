#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

for path in .gitignore AGENTS.md CLAUDE.md README.md README.ru.md docs/architecture.md docs/theme-tokens.md docs/verification.md scripts/init-project.sh scripts/verify-project.sh scripts/security-scan.sh; do
  [ -e "$ROOT/$path" ] || fail "missing required file: $path"
done

[ -L "$ROOT/CLAUDE.md" ] || fail 'CLAUDE.md is not a symlink'
[ "$(readlink "$ROOT/CLAUDE.md")" = 'AGENTS.md' ] || fail 'CLAUDE.md points to the wrong file'

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
