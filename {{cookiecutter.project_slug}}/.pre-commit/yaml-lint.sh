#!/bin/bash

# Runs yamllint on the specified files.

# @:  An array of yaml files to lint.

# pre-commit script.

set -eo pipefail

main() {

  # shellcheck source=./.pre-commit/.poetry-compatible.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/.poetry-compatible.sh"

  run_command yamllint -f standard "$@"

}

main "$@"
