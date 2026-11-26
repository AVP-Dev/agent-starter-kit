#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agent-starter-kit-tests.XXXXXX")"
trap 'rm -rf "$TMP_ROOT"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_status() {
  expected="$1"
  shift
  set +e
  "$@" >"$TMP_ROOT/command-output" 2>&1
  actual=$?
  set -e
  [ "$actual" -eq "$expected" ] || {
    printf 'Expected exit %s, got %s\n' "$expected" "$actual" >&2
    printf '%s\n' '--- output ---' >&2
    printf '%s\n' "$(<"$TMP_ROOT/command-output")" >&2
    exit 1
  }
}

assert_contains() {
  file="$1"
  text="$2"
  contents="$(<"$file")"
  case "$contents" in
    *"$text"*) ;;
    *) fail "Expected '$text' in $file" ;;
  esac
}

assert_not_contains() {
  file="$1"
  text="$2"
  contents="$(<"$file")"
  case "$contents" in
    *"$text"*) fail "Did not expect '$text' in $file" ;;
  esac
}

make_project() {
  destination="$1"
  mkdir -p "$destination/scripts" "$destination/docs"
  cp "$ROOT/scripts/verify-project.sh" "$destination/scripts/verify-project.sh"
  cp "$ROOT/scripts/security-scan.sh" "$destination/scripts/security-scan.sh"
  chmod +x "$destination/scripts/verify-project.sh" "$destination/scripts/security-scan.sh"
}

make_project "$TMP_ROOT/runner"
printf 'syntax\tstatic\t1\tbash -n scripts/verify-project.sh\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 0 "$TMP_ROOT/runner/scripts/verify-project.sh" --only static
assert_status 0 "$TMP_ROOT/runner/scripts/verify-project.sh" --list
assert_contains "$TMP_ROOT/command-output" 'syntax'

printf 'syntax\tstatic\t1\tbash -n scripts/verify-project.sh\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 0 "$TMP_ROOT/runner/scripts/verify-project.sh" --dry-run

printf 'marker\tstatic\t1\ttouch marker\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 0 "$TMP_ROOT/runner/scripts/verify-project.sh" --dry-run
[ ! -e "$TMP_ROOT/runner/marker" ] || fail 'Dry-run executed a command'

printf 'failing\tstatic\t1\texit 7\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 1 "$TMP_ROOT/runner/scripts/verify-project.sh" --only static

printf 'optional\tstatic\t0\texit 9\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh" --only static
assert_status 0 "$TMP_ROOT/runner/scripts/verify-project.sh" --diagnostic --only static
assert_contains "$TMP_ROOT/command-output" 'warning'

assert_contains "$TMP_ROOT/command-output" 'no required checks executed'
printf 'optional\tstatic\t0\ttrue\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh"
assert_status 0 "$TMP_ROOT/runner/scripts/verify-project.sh" --diagnostic
printf 'required\tstatic\t1\ttrue\noptional\tpositive\t0\ttrue\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh" --only positive
assert_status 0 "$TMP_ROOT/runner/scripts/verify-project.sh"
assert_status 0 "$TMP_ROOT/runner/scripts/verify-project.sh" --only static
assert_contains "$TMP_ROOT/command-output" 'partial/diagnostic'

printf 'marker\tstatic\t1\ttouch marker\ninvalid\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh"
[ ! -e "$TMP_ROOT/runner/marker" ] || fail 'Malformed profile executed a command'

printf '\tstatic\t1\ttrue\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh"

printf 'same\tstatic\t1\ttrue\nsame\tstatic\t1\ttrue\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh" --only static

printf 'extra\tstatic\t1\ttrue\textra\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh" --only static

printf 'bad\tunknown\t1\ttrue\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh" --only static

printf 'valid\tstatic\t1\ttrue\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh" --only static,

rm "$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh" --only static

make_project "$TMP_ROOT/security-clean"
git -C "$TMP_ROOT/security-clean" init -q
printf 'safe documentation\n' >"$TMP_ROOT/security-clean/README.md"
printf 'security-baseline\tsecurity\t1\t./scripts/security-scan.sh\n' >"$TMP_ROOT/security-clean/scripts/verification-profile.tsv"
assert_status 0 "$TMP_ROOT/security-clean/scripts/verify-project.sh" --only security
assert_status 0 "$TMP_ROOT/security-clean/scripts/security-scan.sh"

printf 'password = "%s%s"\n' 'super-' 'secret-value-123456' >"$TMP_ROOT/security-clean/leaked.txt"
assert_status 1 "$TMP_ROOT/security-clean/scripts/security-scan.sh"
assert_contains "$TMP_ROOT/command-output" 'SECURITY_FINDING'
assert_not_contains "$TMP_ROOT/command-output" 'super-secret-value-123456'

printf '%s%s\n' 'AKIA' 'ABCDEFGHIJKLMNOP' >"$TMP_ROOT/security-clean/aws-key.txt"
assert_status 1 "$TMP_ROOT/security-clean/scripts/security-scan.sh"
assert_contains "$TMP_ROOT/command-output" 'aws-access-key'

printf 'temporary\n' >"$TMP_ROOT/security-clean/.env"
assert_status 1 "$TMP_ROOT/security-clean/scripts/security-scan.sh"
assert_contains "$TMP_ROOT/command-output" 'environment-file'

mkdir -p "$TMP_ROOT/security-clean/dist"
printf 'password = "%s%s"\n' 'generated-' 'secret-value-123456' >"$TMP_ROOT/security-clean/dist/generated.txt"
git -C "$TMP_ROOT/security-clean" add -f dist/generated.txt
assert_status 1 "$TMP_ROOT/security-clean/scripts/security-scan.sh"
assert_contains "$TMP_ROOT/command-output" 'dist/generated.txt'

mkdir "$TMP_ROOT/failing-git"
cat >"$TMP_ROOT/failing-git/git" <<'EOF'
#!/usr/bin/env bash
case "$3" in
  rev-parse) exit 0 ;;
  ls-files) exit 7 ;;
esac
exit 1
EOF
chmod +x "$TMP_ROOT/failing-git/git"
assert_status 2 env PATH="$TMP_ROOT/failing-git:$PATH" "$TMP_ROOT/security-clean/scripts/security-scan.sh"
assert_not_contains "$TMP_ROOT/command-output" 'security-scan: clean'

make_project "$TMP_ROOT/bootstrap"
"$ROOT/scripts/init-project.sh" --yes "$TMP_ROOT/bootstrap" >"$TMP_ROOT/bootstrap-output" 2>&1
[ -x "$TMP_ROOT/bootstrap/scripts/verify-project.sh" ] || fail 'verify-project.sh was not copied'
[ -x "$TMP_ROOT/bootstrap/scripts/security-scan.sh" ] || fail 'security-scan.sh was not copied'
[ -f "$TMP_ROOT/bootstrap/docs/verification-profile.example.tsv" ] || fail 'profile example was not copied'
[ -f "$TMP_ROOT/bootstrap/docs/lifecycle.md" ] || fail 'lifecycle policy was not copied'
[ -f "$TMP_ROOT/bootstrap/.gitignore" ] || fail '.gitignore was not copied'
[ ! -f "$TMP_ROOT/bootstrap/scripts/verification-profile.tsv" ] || fail 'starter-kit profile was copied into target'
[ ! -e "$TMP_ROOT/bootstrap/.github/workflows/verification.yml" ] || fail 'starter-kit workflow was copied into target'
git -C "$TMP_ROOT/bootstrap" init -q
git -C "$TMP_ROOT/bootstrap" check-ignore --no-index -q .env || fail '.env is not ignored'
git -C "$TMP_ROOT/bootstrap" check-ignore --no-index -q node_modules/example || fail 'node_modules is not ignored'
git -C "$TMP_ROOT/bootstrap" check-ignore --no-index -q dist/example || fail 'dist is not ignored'

mkdir -p "$TMP_ROOT/existing-ignore"
printf 'custom-project-rule\n' >"$TMP_ROOT/existing-ignore/.gitignore"
"$ROOT/scripts/init-project.sh" --yes "$TMP_ROOT/existing-ignore" >"$TMP_ROOT/existing-ignore-output" 2>&1
assert_contains "$TMP_ROOT/existing-ignore/.gitignore" 'custom-project-rule'

mkdir "$TMP_ROOT/greenfield"
git -C "$TMP_ROOT/greenfield" init -q
printf '# Fresh repository\n' >"$TMP_ROOT/greenfield/README.md"
assert_status 0 "$ROOT/scripts/init-project.sh" --dry-run --with-claude "$TMP_ROOT/greenfield"
assert_contains "$TMP_ROOT/command-output" 'Трек-кандидат: greenfield'
assert_contains "$TMP_ROOT/command-output" 'CLAUDE.md с импортом AGENTS.md'
[ ! -e "$TMP_ROOT/greenfield/CLAUDE.md" ] || fail 'Dry-run created CLAUDE.md'
assert_status 0 "$ROOT/scripts/init-project.sh" "$TMP_ROOT/greenfield"
[ ! -e "$TMP_ROOT/greenfield/CLAUDE.md" ] && [ ! -L "$TMP_ROOT/greenfield/CLAUDE.md" ] || fail 'Default install added CLAUDE.md'
assert_status 0 "$ROOT/scripts/init-project.sh" --update --with-claude "$TMP_ROOT/greenfield"
[ ! -L "$TMP_ROOT/greenfield/CLAUDE.md" ] && [ "$(<"$TMP_ROOT/greenfield/CLAUDE.md")" = '@AGENTS.md' ] || fail 'Wrong Claude adapter'

mkdir -p "$TMP_ROOT/brownfield/docs" "$TMP_ROOT/brownfield/.github/workflows"
for path in AGENTS.md CLAUDE.md docs/architecture.md .github/workflows/verification.yml; do
  printf 'existing %s\n' "$path" >"$TMP_ROOT/brownfield/$path"
done
assert_status 0 "$ROOT/scripts/init-project.sh" --update --with-claude "$TMP_ROOT/brownfield"
assert_contains "$TMP_ROOT/command-output" 'Трек-кандидат: brownfield'
for path in AGENTS.md CLAUDE.md docs/architecture.md .github/workflows/verification.yml; do
  [ "$(<"$TMP_ROOT/brownfield/$path")" = "existing $path" ] || fail "Modified existing $path"
done

mkdir "$TMP_ROOT/legacy-claude"
ln -s AGENTS.md "$TMP_ROOT/legacy-claude/CLAUDE.md"
assert_status 0 "$ROOT/scripts/init-project.sh" --update --with-claude "$TMP_ROOT/legacy-claude"
[ -L "$TMP_ROOT/legacy-claude/CLAUDE.md" ] && [ "$(readlink "$TMP_ROOT/legacy-claude/CLAUDE.md")" = AGENTS.md ] || fail 'Modified existing Claude symlink'

DRY_TARGET="$TMP_ROOT/dry-target"
assert_status 0 "$ROOT/scripts/init-project.sh" --dry-run "$DRY_TARGET"
[ ! -e "$DRY_TARGET" ] || fail 'dry-run created a target'

mkdir -p "$TMP_ROOT/symlink-target" "$TMP_ROOT/external-docs"
ln -s "$TMP_ROOT/external-docs" "$TMP_ROOT/symlink-target/docs"
assert_status 1 "$ROOT/scripts/init-project.sh" --yes "$TMP_ROOT/symlink-target"
[ ! -e "$TMP_ROOT/symlink-target/AGENTS.md" ] || fail 'init wrote through symlinked docs'

printf 'verification tools: PASS\n'
