#!/bin/bash

# Centralized management of poetry installs.

# 1:                  A managed poetry command: check-version, install-poetry, or install-project.
# 2:                  A semantic version string to validate with the check-version command.
# REMOTE_SCRIPT_NAME: The script name as set by the cicd-tools remote executor (remote-script.sh).

# CI only script.

set -eo pipefail

use_poetry() {

  check-version() {
    echo "DEBUG: validating 'pyproject.toml' version matches '${1}'." >> /dev/stderr
    if [[ "$(poetry version -s)" != "${1}" ]]; then
      echo "ERROR: the 'pyproject.toml' file does not match version '${1}' !" >> /dev/stderr
      exit 127
    fi
  }

  install-poetry() {
    echo "DEBUG: installing poetry." >> /dev/stderr
    python -m pip install poetry --verbose
  }

  install-project() {
    echo "DEBUG: installing the project requirements." >> /dev/stderr
    poetry install --verbose
  }

  "$@"

}

main() {

  echo "DEBUG: -- ${REMOTE_SCRIPT_NAME} --" >> /dev/stderr

  use_poetry "$@"

}

main "$@"
