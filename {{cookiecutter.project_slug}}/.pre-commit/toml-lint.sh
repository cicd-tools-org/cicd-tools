#!/bin/bash

# Runs tomll on the specified files and then runs diff to detect changes.

# @:  An array of toml files to lint.

# pre-commit script.

set -eo pipefail

main() {

  for TOML_FILE in "$@"; do

    # shellcheck disable=SC2002
    diff "${TOML_FILE}" <(cat "${TOML_FILE}" | tomll)

  done

}

main "$@"
