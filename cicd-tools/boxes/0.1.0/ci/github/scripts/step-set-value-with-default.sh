#!/bin/bash

# Sets an output value for a step, with either a default or configured value.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

main() {
  local OUTPUT_NAME
  local DEFAULT_VALUE
  local SPECIFIED_VALUE

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  _default_args "$@"
  _default_output
}

_default_args() {
  local OPTARG
  local OPTIND
  local OPTION

  while getopts "d:o:s:" OPTION; do
    case "$OPTION" in
      d)
        DEFAULT_VALUE="${OPTARG}"
        ;;
      o)
        OUTPUT_NAME="${OPTARG}"
        ;;
      s)
        SPECIFIED_VALUE="${OPTARG}"
        ;;
      \?)
        _default_usage
        ;;
      :)
        _default_usage
        ;;
      *)
        _default_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))
  if [[ -z "${OUTPUT_NAME}" ]] ||
    [[ -z "${DEFAULT_VALUE}" ]]; then
    _default_usage
  fi
}

_default_output() {
  local FINAL_VALUE

  if [[ -z "${SPECIFIED_VALUE}" ]]; then
    FINAL_VALUE="${DEFAULT_VALUE}"
    log "INFO" "The default value: '${FINAL_VALUE}' is being used for step output: '${OUTPUT_NAME}'."
  else
    FINAL_VALUE="${SPECIFIED_VALUE}"
    log "INFO" "The specified value: '${FINAL_VALUE}' is being used for step output: '${OUTPUT_NAME}'."
  fi

  {
    echo "${OUTPUT_NAME}<<EOF"
    echo "${FINAL_VALUE}"
    echo "EOF"
  } >> "${GITHUB_OUTPUT}"
}

_default_usage() {
  log "ERROR" "step-set-value-with-default.sh -- set a step's output with a specified or default value."
  log "ERROR" "USAGE: step-set-value-with-default.sh -d [DEFAULT VALUE] -o [OUTPUT NAME] -s [SPECIFIED VALUE]"
  exit 127
}

main "$@"
