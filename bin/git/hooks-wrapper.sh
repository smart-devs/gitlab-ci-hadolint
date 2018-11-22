#!/usr/bin/env bash

# Runs all executable git hooks and exits after if any of them was not successful.
# it asumes all your scripts are located at <repo-root>/bin/git/hooks

exitcodes=()
hookname=`basename $0`
# our special hooks folder
CUSTOM_HOOKS_DIR=$(git rev-parse --show-toplevel)/bin/git/hooks
# find gits native hooks folder
NATIVE_HOOKS_DIR=$(git rev-parse --show-toplevel)/.git/hooks

# Run each hook, passing through STDIN and storing the exit code.
# We don't want to bail at the first failure, as the user might
# then bypass the hooks without knowing about additional issues.

for hook in $CUSTOM_HOOKS_DIR/$(basename $0)-*; do
  test -x "$hook" || continue
  out=`$hook "$@"`
  exitcodes+=($?)
  echo "$out"
done

# check if there was a local hook that was moved previously
if [ -f "$NATIVE_HOOKS_DIR/$hookname.local" ]; then
    out=`$NATIVE_HOOKS_DIR/$hookname.local "$@"`
    exitcodes+=($?)
    echo "$out"
fi

# If any exit code isn't 0, bail.
for i in "${exitcodes[@]}"; do
  [ "$i" == 0 ] || exit $i
done