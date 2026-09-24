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

printf 'bad\tunknown\t1\ttrue\n' >"$TMP_ROOT/runner/scripts/verification-profile.tsv"
assert_status 2 "$TMP_ROOT/runner/scripts/verify-project.sh" --only static

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

make_project "$TMP_ROOT/bootstrap"
"$ROOT/scripts/init-project.sh" --yes "$TMP_ROOT/bootstrap" >"$TMP_ROOT/bootstrap-output" 2>&1
[ -x "$TMP_ROOT/bootstrap/scripts/verify-project.sh" ] || fail 'verify-project.sh was not copied'
[ -x "$TMP_ROOT/bootstrap/scripts/security-scan.sh" ] || fail 'security-scan.sh was not copied'
[ -f "$TMP_ROOT/bootstrap/docs/verification-profile.example.tsv" ] || fail 'profile example was not copied'
[ ! -f "$TMP_ROOT/bootstrap/scripts/verification-profile.tsv" ] || fail 'starter-kit profile was copied into target'

printf 'verification tools: PASS\n'
