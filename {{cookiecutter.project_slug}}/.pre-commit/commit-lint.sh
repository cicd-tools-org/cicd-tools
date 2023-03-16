#!/bin/bash

# Runs commitizen on the passed commit message file.

# 1:  The path to the commit message file.

# pre-commit script.

set -eo pipefail

main() {

  # shellcheck source=./.pre-commit/.poetry-compatible.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/.poetry-compatible.sh"

  run_command cz check --allow-abort --commit-msg-file "$1"

}

main "$@"
