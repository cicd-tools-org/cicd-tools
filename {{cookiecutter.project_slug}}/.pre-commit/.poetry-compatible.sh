#!/bin/bash

# Enables running commands in or outside the Poetry virtual environment seamlessly.

# @:  An array of commands to run.

# pre-commit script.

set -eo pipefail

run_command() {

  if [[ "${POETRY_ACTIVE}" == "1" ]]; then
    "$@"
  else
    poetry run "$@"
  fi

}
