#!/bin/bash

# Library for working with the CICD-Tools projects.

set -eo pipefail

# shellcheck source=./logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/logging.sh"

cicd_tools() {
  local PREFIX
  local COMMAND

  PREFIX="_cicd_tools"
  COMMAND="${PREFIX}_${1}"
  if [[ $(type -t "${COMMAND}") == function ]]; then
    shift
    "${COMMAND}" "$@"
  else
    "${PREFIX}_usage"
  fi
}

_cicd_tools_is_template() {
  [[ -f "cookiecutter.json" ]]
}

_cicd_tools_config_value() {
  # 1:  The config file to parse.
  # 2:  The key of the value to extract.

  local CICD_TOOLS_CONFIG_FILE="${1}"
  local CICD_TOOLS_KEY="${2}"

  log "DEBUG" "CONFIGURATION > extracting key: '${CICD_TOOLS_KEY}' from: '${CICD_TOOLS_CONFIG_FILE}'."

  REGEX="\"${2}\": \"([^\"]+)\""
  if [[ "$(cat "${CICD_TOOLS_CONFIG_FILE}")" =~ ${REGEX} ]]; then
    log "DEBUG" "CONFIGURATION > found value: '${BASH_REMATCH[1]}'."
    echo "${BASH_REMATCH[1]}"
  else
    log "ERROR" "CONFIGURATION > key: '${CICD_TOOLS_KEY}' not found in '${CICD_TOOLS_CONFIG_FILE}'."
    return 127
  fi
}

_cicd_tools_poetry() {
  # @: A command and arguments to run in either directly, or through Poetry.

  if [[ "${POETRY_ACTIVE}" == "1" ]]; then
    "$@"
  else
    poetry run "$@"
  fi
}

_cicd_tools_usage() {
  log "ERROR" "tools.sh -- CICD-Tools project helpers."
  log "ERROR" "-----------------------------------------------------------------------------"
  log "ERROR" "tools.sh is_template  < Check if the current path is a cookiecutter project."
  log "ERROR" "-----------------------------------------------------------------------------"
  log "ERROR" "tools.sh config_value < Extract a value from a JSON file with a specific key."
  log "ERROR" "               [JSON FILE PATH]"
  log "ERROR" "               [KEY NAME]"
}
