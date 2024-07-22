#!/bin/bash

# Library for logging functions and commands.
# The LOGGING_LEVEL environment variable controls verbosity.

set -eo pipefail

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/colours.sh"

LOGGING_LEVEL=${LOGGING_LEVEL-"DEBUG"}

function log() {

  # USAGE:
  # log (-b) (-n) [CRITICAL|ERROR|WARNING|INFO|DEBUG] [MESSAGE CONTENTS]

  local LOGGING_MESSAGE_CONTENT
  local LOGGING_MESSAGE_LEVEL
  local LOGGING_NEW_LINE="\n"
  local LOGGING_SEVERITY_LEVELS=("DEBUG" "INFO" "WARNING" "ERROR" "CRITICAL")

  # shellcheck disable=SC2034
  local CRITICAL="RED"
  # shellcheck disable=SC2034
  local ERROR="RED"
  # shellcheck disable=SC2034
  local WARNING="YELLOW"
  # shellcheck disable=SC2034
  local INFO="GREEN"
  # shellcheck disable=SC2034
  local DEBUG="CYAN"
  # shellcheck disable=SC2034

  _log_args "$@"

  if [[ "$(_log_get_severity_level "${LOGGING_MESSAGE_LEVEL}")" -ge "$(_log_get_severity_level "${LOGGING_LEVEL}")" ]]; then
    echo \
      -e \
      -n \
      "[$(date -u)] [$(colour fg "${!LOGGING_MESSAGE_LEVEL}")${LOGGING_MESSAGE_LEVEL}$(colour clear)] ${LOGGING_MESSAGE_CONTENT}${LOGGING_NEW_LINE}" \
      >> /dev/stderr
  fi

}

function _log_args() {
  local OPTARG
  local OPTIND
  local OPTION

  while getopts "bn" OPTION; do
    case "$OPTION" in
      b)
        LOGGING_NEW_LINE="\n\n"
        ;;
      n)
        LOGGING_NEW_LINE=""
        ;;
      \?)
        _log_usage
        ;;
      *)
        continue
        ;;
    esac
  done
  shift $((OPTIND - 1))

  LOGGING_MESSAGE_LEVEL="${1}"
  LOGGING_MESSAGE_CONTENT="${2}"

  if [[ -z "${!LOGGING_LEVEL}" ]] ||
    [[ -z "${LOGGING_MESSAGE_CONTENT}" ]]; then
    _log_usage
  fi
}

function _log_get_severity_level() {
  #1: The severity type as a string.
  local LOGGIN_SEVERITY_LEVEL
  for LOGGIN_SEVERITY_LEVEL in "${!LOGGING_SEVERITY_LEVELS[@]}"; do
    if [[ "${LOGGING_SEVERITY_LEVELS["${LOGGIN_SEVERITY_LEVEL}"]}" = "${1}" ]]; then
      echo "${LOGGIN_SEVERITY_LEVEL}"
    fi
  done
}

function _log_usage() {
  log "ERROR" "log -- a function to write logging messages to the console."
  log "ERROR" "-----------------------------------------------------------"
  log "ERROR" "log"
  log "ERROR" "          -b (OPTIONAL SWITCH TO ADD AN EXTRA TRAILING NEWLINE.)"
  log "ERROR" "          -n (OPTIONAL SWITCH TO DISABLE TRAILING NEWLINES.)"
  log "ERROR" "          [LEVEL]       [CRITICAL|ERROR|WARNING|INFO|DEBUG]"
  log "ERROR" "          [MESSAGE]     [THE LOGGING MESSAGE TO WRITE]"
  return 127
}
