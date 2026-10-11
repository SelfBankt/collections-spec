#!/bin/sh
# Validates every example against its schema: files under invalid/ must fail, all others must pass.
# Runs the same check as CI. Needs Node.js; npx fetches ajv-cli and ajv-formats on first use.
set -u
cd "$(dirname "$0")/.."

ajv() { npx -y -p ajv-cli@5 -p ajv-formats@3 ajv validate --spec=draft2020 -c ajv-formats "$@"; }
failed=0

expect_valid() { # <schema> <extra ajv args> <files...>
  schema=$1; extra=$2; shift 2
  for f in "$@"; do
    # shellcheck disable=SC2086
    if ajv -s "$schema" $extra -d "$f" >/dev/null 2>&1; then
      echo "ok    $f"
    else
      echo "FAIL  $f should pass $schema"
      # shellcheck disable=SC2086
      ajv -s "$schema" $extra -d "$f"
      failed=1
    fi
  done
}

expect_invalid() { # <schema> <files...>
  schema=$1; shift
  for f in "$@"; do
    if ajv -s "$schema" -d "$f" >/dev/null 2>&1; then
      echo "FAIL  $f should fail $schema"
      failed=1
    else
      echo "ok    $f (fails, as it should)"
    fi
  done
}

# Draft 0.1 (member-backlink.json is an excerpt of a member catalogue, not a collection)
expect_valid schema/collections-0.1.schema.json "" examples/0.1/event.json examples/0.1/nested-association.json examples/0.1/place-high-street.json
expect_invalid schema/collections-0.1.schema.json examples/0.1/invalid/*.json

# Draft 0.2
expect_valid schema/collections-0.2.schema.json "" examples/0.2/*.json
expect_valid schema/member-manifest-0.2.schema.json "-r schema/collections-0.2.schema.json" examples/0.2/members/*.json
expect_invalid schema/collections-0.2.schema.json examples/0.2/invalid/*.json

exit $failed
