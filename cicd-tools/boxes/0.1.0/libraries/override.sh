#!/bin/bash

# Library for allowing environment variables to override configured settings.

set -eo pipefail

# shellcheck source=./logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/logging.sh"

override() {
  local OVERRIDES=()
  local TARGETS=()

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  _override_args "$@"
  _override_set_values
}

_override_args() {
  local OPTARG
  local OPTIND
  local OPTION

  while getopts "o:t:" OPTION; do
    case "$OPTION" in
      o)
        _override_parse_overrides "${OPTARG}"
        ;;
      t)
        _override_parse_targets "${OPTARG}"
        ;;
      \?)
        _override_usage
        ;;
      :)
        _override_usage
        ;;
    esac
  done

  if [[ "${#OVERRIDES[@]}" -ne "${#TARGETS[@]}" ]]; then
    log "ERROR" "OVERRIDE > You must specify the same number of OVERRIDE environment variables and OPTIONAL environment variables!"
    exit 127
  fi
}

_override_parse_overrides() {
  log "DEBUG" "OVERRIDE > Parsing OVERRIDE environment variable values."
  # shellcheck disable=SC2034
  IFS=' ' read -r -a OVERRIDES <<< "${1}"
}

_override_parse_targets() {
  log "DEBUG" "OVERRIDE > Parsing TARGET environment variable values."
  # shellcheck disable=SC2034
  IFS=' ' read -r -a TARGETS <<< "${1}"
}

_override_set_values() {
  local INDEX=-1
  local OVERRIDE_VARIABLE

  for OVERRIDE_VARIABLE in "${OVERRIDES[@]}"; do
    ((INDEX++)) || true
    if [[ -z "${!OVERRIDE_VARIABLE}" ]]; then
      log "DEBUG" "OVERRIDE > No override specified for '${OVERRIDE_VARIABLE}' ..."
    else
      eval "${TARGETS[${INDEX}]}"="${!OVERRIDE_VARIABLE}"
      log "WARNING" "OVERRIDE > Variable '${TARGETS[${INDEX}]}' now overridden with '${!OVERRIDE_VARIABLE}' ..."
    fi
  done
}

_override_usage() {
  log "ERROR" "override.sh -- an interface to override internal values with environment variables."
  log "ERROR" "-----------------------------------------------------------------------------------"
  log "ERROR" "override.sh"
  log "ERROR" "           -o (SPACE SEPARATED LIST OF OVERRIDE ENV VARS)"
  log "ERROR" "           -t (SPACE SEPARATED LIST OF TARGET OVERRIDE_VARIABLES THAT WILL BE OVERRIDDEN)"
  exit 127
}
