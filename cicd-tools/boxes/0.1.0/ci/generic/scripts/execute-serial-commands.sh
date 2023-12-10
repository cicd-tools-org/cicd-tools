#!/bin/bash

# Serially execute a JSON array of commands.
# Requires the jq binary: https://stedolan.github.io/jq/download/

# CI only script

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

main() {
  local SERIAL_COMMANDS_INPUT
  local SERIAL_COMMANDS_PATH
  local SERIAL_COMMAND_SUFFIX=""

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  _execute_serial_commands_args "$@"
  _execute_serial_commands_start
}

_execute_serial_commands_args() {
  while getopts "c:p:s:" OPTION; do
    case "$OPTION" in
      c)
        SERIAL_COMMANDS_INPUT="${OPTARG}"
        ;;
      p)
        SERIAL_COMMANDS_PATH="${OPTARG}"
        ;;
      s)
        SERIAL_COMMAND_SUFFIX="${OPTARG}"
        ;;
      \?)
        _execute_serial_commands_usage
        ;;
      :)
        _execute_serial_commands_usage
        ;;
      *)
        _execute_serial_commands_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))
  if [[ -z "${SERIAL_COMMANDS_INPUT}" ]] ||
    [[ -z "${SERIAL_COMMANDS_PATH}" ]]; then
    _execute_serial_commands_usage
  fi
}

_execute_serial_commands_start() {
  local SERIAL_COMMAND
  local SERIAL_SYSTEM_CALL

  log "DEBUG" "Parsing newline separated string into array ..."
  IFS=$'\n' read -r -d '' -a SERIAL_COMMANDS_ARRAY <<< "${SERIAL_COMMANDS_INPUT}" || true

  log "DEBUG" "Changing Execution Path: '${SERIAL_COMMANDS_PATH}'"
  pushd "${SERIAL_COMMANDS_PATH}" >> /dev/null
  log "DEBUG" "Current Path: '$(pwd)'"

  for SERIAL_COMMAND in "${SERIAL_COMMANDS_ARRAY[@]}"; do
    if [[ -z "${SERIAL_COMMAND_SUFFIX}" ]]; then
      SERIAL_SYSTEM_CALL="${SERIAL_COMMAND}"
    else
      SERIAL_SYSTEM_CALL="${SERIAL_COMMAND_SUFFIX} ${SERIAL_COMMAND}"
    fi
    log "INFO" "Execute Command: '${SERIAL_SYSTEM_CALL}'"
    if ! eval "${SERIAL_SYSTEM_CALL}"; then
      log "ERROR" "Could not execute: '${SERIAL_SYSTEM_CALL}'"
      exit 127
    fi
  done

  popd >> /dev/null
  log "INFO" "Execution of all commands complete!"
}

_execute_serial_commands_usage() {
  log "ERROR" "execute-serial-commands.sh -- serially execute a newline separated list of commands."
  log "ERROR" "USAGE: execute-serial-commands.sh -c [NEWLINE SEPARATED COMMANDS] -p [EXECUTION PATH] -s [COMMAND SUFFIX TO PREPEND]"
  exit 127
}

main "$@"
