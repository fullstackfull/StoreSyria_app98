#!/usr/bin/env bash
#
# A ratchet on analyzer SUPPRESSION, not on analyzer output.
#
# WHY THIS IS SEPARATE FROM THE ANALYZE GATE. `flutter analyze` can be made to
# pass two ways: by fixing code, or by hiding it. Both look identical in the
# job summary. This script measures the hiding, so the analyze gate can only be
# satisfied the honest way.
#
# Two hiding mechanisms exist and both are covered:
#
#   1. `// ignore:` / `// ignore_for_file:` comments in lib/. There are 43 of
#      these already, all pre-existing style lints (prefer_const_constructors,
#      unnecessary_this, prefer_collection_literals, must_be_immutable,
#      constant_identifier_names). A few are inert double-comments (`// //
#      ignore_for_file:`) and are counted anyway -- the point is the direction
#      of travel, and counting them costs nothing. The count may FALL and never
#      RISE.
#
#   2. An `analyzer: exclude:` entry in analysis_options.yaml that removes lib/
#      from analysis. That is the nuclear version: it would silence a whole
#      directory at once.
#
# ON analysis_options.yaml AND THE FLUTTER SDK. The committed file has no
# `analyzer:` block, but `flutter analyze` ADDS ONE ITSELF and leaves the file
# dirty. That is not a developer suppressing anything -- it is the SDK's own
# AnalysisOptionsMigration (flutter_tools/lib/src/migrations/
# analysis_options_migration.dart:14-77) excluding the generated platform
# scaffold directories, and it logs "Upgrading analysis_options.yaml to exclude
# build and platform directories" when it fires.
#
# MEASURED on Flutter 3.47.7: the project reports 552 issues with that block
# present and 552 without it, because android/, ios/, web/, windows/, macos/
# and linux/ contain no Dart at all here. So the SDK's block hides NOTHING in
# this repository and is tolerated. An exclude that reaches lib/ is a different
# thing entirely and fails below.

set -euo pipefail

cd "$(dirname "$0")/../.."

# The count may fall and never rise. When it falls, lower this and say so in
# the commit message, the same ratchet the PHP side uses for composer audit.
IGNORE_CEILING="${IGNORE_CEILING:-43}"

fail=0
note() { printf '%s\n' "$*"; }
err() { printf '::error::%s\n' "$*"; fail=1; }

# ---------------------------------------------------------------------------
# 1. The ignore-comment ratchet.
# ---------------------------------------------------------------------------

found="$(grep -rn --include='*.dart' -e '// *ignore\(_for_file\)\?:' lib/ | wc -l | tr -d ' ')"

note "analyzer ignore directives in lib/: $found (ceiling $IGNORE_CEILING)"

if [ "$found" -gt "$IGNORE_CEILING" ]; then
  err "Suppression count rose from $IGNORE_CEILING to $found. An analyzer finding was hidden instead of fixed."
  note "The new ones are among these:"
  grep -rn --include='*.dart' -e '// *ignore\(_for_file\)\?:' lib/ || true
  note ""
  note "If a suppression is genuinely correct, raise IGNORE_CEILING in this"
  note "script IN THE SAME COMMIT and justify it in the commit message."
fi

if [ "$found" -lt "$IGNORE_CEILING" ]; then
  note "::notice::Suppression count fell to $found. Lower IGNORE_CEILING to $found so the ratchet keeps holding."
fi

# ---------------------------------------------------------------------------
# 2. No exclude may reach lib/.
# ---------------------------------------------------------------------------
# Read from the INDEX, not the working tree, so the SDK's runtime rewrite of
# the on-disk file cannot influence the verdict either way.

if git cat-file -e HEAD:analysis_options.yaml 2>/dev/null; then
  committed="$(git show HEAD:analysis_options.yaml)"
else
  committed=""
fi

if printf '%s' "$committed" | grep -qE '^[[:space:]]*-[[:space:]]*(\./)?lib(/|\b)'; then
  err "analysis_options.yaml excludes lib/ from analysis. That hides scope rather than fixing code."
  printf '%s' "$committed" | grep -nE '^[[:space:]]*-' || true
else
  note "ok: no analysis_options exclude reaches lib/"
fi

# ---------------------------------------------------------------------------
# 3. No blanket rule disabling.
# ---------------------------------------------------------------------------
# `errors: { unused_import: ignore }` demotes a diagnostic globally, which is
# the same hiding as an ignore comment but invisible at the call site.

if printf '%s' "$committed" | grep -qE '^[[:space:]]*(unused_|dead_|invalid_|unnecessary_|unreachable_)[a-z_]*:[[:space:]]*ignore'; then
  err "analysis_options.yaml demotes a real diagnostic to 'ignore'."
  printf '%s' "$committed" | grep -nE ':[[:space:]]*ignore' || true
else
  note "ok: no diagnostic is globally demoted to 'ignore'"
fi

if [ "$fail" -ne 0 ]; then
  note ""
  note "Suppression check FAILED."
  exit 1
fi

note ""
note "Suppression check passed."
