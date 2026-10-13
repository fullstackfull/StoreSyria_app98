#!/usr/bin/env bash
#
# Fails if any Android/iOS signing material is TRACKED BY GIT.
#
# THE DISTINCTION THAT MATTERS. android/key.properties legitimately EXISTS on a
# release engineer's machine -- android/RELEASE_SIGNING.md:47 tells them to
# create it. So "the file is absent" is the wrong assertion: it fails the moment
# the owner follows the documented runbook, and a check that fails when you obey
# the instructions is a check that gets deleted. A test here was already fixed
# once for exactly that mistake.
#
# What must be true is that git never CARRIES it. That is what this asserts:
# membership of the index, plus the .gitignore rule that keeps it out, plus the
# whole history for a file that was committed and later removed (the bytes stay
# reachable in the pack, so removing it from HEAD is not a fix).
#
# Exits 0 only when every one of those holds.

set -euo pipefail

cd "$(dirname "$0")/../.."

fail=0

note() { printf '%s\n' "$*"; }
err() { printf '::error::%s\n' "$*"; fail=1; }

# ---------------------------------------------------------------------------
# 1. Nothing matching a signing pattern is in the index.
# ---------------------------------------------------------------------------
# Matched against the index rather than the working tree, so an ignored file
# sitting on disk is fine and a committed one is not.

tracked="$(git ls-files -- \
  '*.jks' '*.keystore' '*.p12' '*.pfx' '*.pem' '*.key' \
  'android/key.properties' '**/key.properties' \
  '*.mobileprovision' '*.cer' 2>/dev/null || true)"

if [ -n "$tracked" ]; then
  err "Signing material is tracked by git: $(echo "$tracked" | tr '\n' ' ')"
  note "Remove it from the index AND rotate the key: once pushed, it is public."
else
  note "ok: no signing material in the git index"
fi

# ---------------------------------------------------------------------------
# 2. git itself ignores the secret paths.
# ---------------------------------------------------------------------------
# Asking git rather than grepping .gitignore: the rule may live in
# .git/info/exclude or a global ignore file, and a naive grep also matches a
# commented-out rule that does nothing.

# The iOS paths were missing from this list, and .gitignore had no rule for
# them either: `git check-ignore ios/Runner/dist.mobileprovision` answered NO,
# so an iOS provisioning profile or distribution certificate dropped into the
# tree would only have been caught by step 1 ABOVE -- i.e. after it was already
# committed, which is after the key is public. Both the rules and these probes
# were added together.
for path in \
  android/key.properties \
  android/app/release.keystore \
  android/app/upload-keystore.jks \
  ios/Runner/dummy.p12 \
  ios/Runner/dist.mobileprovision \
  ios/Runner/dist.cer \
  ios/certs/dist.pfx \
  android/app/debug.pem
do
  if git check-ignore -q "$path"; then
    note "ok: git ignores $path"
  else
    err "git does NOT ignore $path -- it can be committed by accident."
  fi
done

# ---------------------------------------------------------------------------
# 3. No signing material anywhere in history.
# ---------------------------------------------------------------------------
# A key that was committed once and deleted later is still in the pack and
# still compromised. Checked over all refs, not just HEAD.

historic="$(git log --all --pretty=format: --name-only --diff-filter=A \
  2>/dev/null \
  | sort -u \
  | grep -E '(\.jks|\.keystore|\.p12|\.pfx|\.mobileprovision)$|(^|/)key\.properties$' \
  || true)"

if [ -n "$historic" ]; then
  err "Signing material appears in git history: $(echo "$historic" | tr '\n' ' ')"
  note "Removing it from HEAD is not enough; the object is still reachable."
else
  note "ok: no signing material in any reachable history"
fi

# ---------------------------------------------------------------------------
# 4. The tracked template carries no real credential.
# ---------------------------------------------------------------------------
# A committed example file is fine and useful. A committed example with a real
# password in it is the leak this whole script exists to prevent.

for template in android/key.properties.example android/key.properties.template; do
  [ -f "$template" ] || continue

  # A placeholder is the point; a long opaque value is not.
  if grep -qE '^[[:space:]]*(storePassword|keyPassword)[[:space:]]*=[[:space:]]*[^[:space:]]{12,}' "$template"; then
    err "$template looks like it contains a real password, not a placeholder."
  else
    note "ok: $template carries no real credential"
  fi
done

if [ "$fail" -ne 0 ]; then
  note ""
  note "Signing-material check FAILED."
  exit 1
fi

note ""
note "Signing-material check passed."
