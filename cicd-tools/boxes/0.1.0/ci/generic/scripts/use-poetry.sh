#!/bin/bash

# Centralized management of poetry installs.

# 1:  A managed poetry command: check-version, install-poetry, or install-project.
# 2:  A semantic version string to validate with the check-version command.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

main() {
  local PREFIX
  local COMMAND

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  PREFIX="_use_poetry"
  COMMAND="${PREFIX}_${1}"
  if [[ $(type -t "${COMMAND}") == function ]]; then
    shift
    "${COMMAND}" "$@"
  else
    "${PREFIX}_usage"
  fi
}

_use_poetry_check-version() {
  log "DEBUG" "POETRY > Validating 'pyproject.toml' version matches '${1}'."
  if [[ "$(poetry version -s)" != "${1}" ]]; then
    log "ERROR" "POETRY > The 'pyproject.toml' file does not match version '${1}'."
    exit 127
  fi
  log "INFO" "POETRY > 'pyproject.toml' version matches '${1}'."
}

_use_poetry_install-poetry() {
  log "DEBUG" "POETRY > Installing poetry."
  python -m pip install poetry --verbose
}

_use_poetry_install-project() {
  log "DEBUG" "POETRY > Installing project requirements."
  poetry install --verbose
}

_use_poetry_usage() {
  log "ERROR" "use-poetry.sh -- interface for using the Python package."
  log "ERROR" "USAGE: poetry.sh [COMMAND]"
  log "ERROR" "  COMMANDS:"
  log "ERROR" "  check-version [VERSION]  - Compare the given semantic version to the 'pyproject.toml' file."
  log "ERROR" "  install-poetry           - Install poetry."
  log "ERROR" "  install-project          - Install the 'pyproject.toml' file with poetry."
  exit 127
}

main "$@"
