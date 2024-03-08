#!/bin/bash

# Sends a alert to OpsGenie via a API Key.

# NOTIFICATION_RETRIES:         Optionally sets the number of attempts.
# NOTIFICATION_MAX_TIME:        Optionally sets the maximum retry time.
# NOTIFICATION_API_KEY:         The OpsGenie API key to use.
# NOTIFICATION_USE_EU_INSTANCE: Optionally use an EU OpsGenie server.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/environment.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/environment.sh" \
  -o "NOTIFICATION_RETRIES NOTIFICATION_MAX_TIME" \
  -d "3 30"

main() {
  local OPSGENIE_ALIAS
  local OPSGENIE_GITHUB_CI_LINK
  local OPSGENIE_MESSAGE
  local OPSGENIE_PRIORITY
  local OPSGENIE_REQUEST_BODY

  OPSGENIE_PRIORITY="P1"
  OPTIND=1

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  _opsgenie_args "$@"

  if _opsgenie_is_webhook_defined; then
    log "DEBUG" "NOTIFICATION > A webhook has been configured, preparing to send notification."
    OPSGENIE_REQUEST_BODY="$(_opsgenie_create_body)"
    log "DEBUG" "NOTIFICATION > A request body has been generated."
    _opsgenie_post "${OPSGENIE_REQUEST_BODY}"
    log "INFO" "NOTIFICATION > The payload has been sent."
  else
    log "WARNING" "NOTIFICATION > No API key is configured, skipping this task."
  fi
}

_opsgenie_args() {
  while getopts "a:l:m:p:" OPTION; do
    case "$OPTION" in
      a)
        OPSGENIE_ALIAS="${OPTARG}"
        ;;
      l)
        OPSGENIE_GITHUB_CI_LINK="${OPTARG}"
        ;;
      m)
        OPSGENIE_MESSAGE="${OPTARG}"
        ;;
      p)
        OPSGENIE_PRIORITY="${OPTARG}"
        ;;
      \?)
        _opsgenie_usage
        ;;
      :)
        _opsgenie_usage
        ;;
      *)
        _opsgenie_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ -z "${OPSGENIE_ALIAS}" ]] ||
    [[ -z "${OPSGENIE_GITHUB_CI_LINK}" ]] ||
    [[ -z "${OPSGENIE_MESSAGE}" ]]; then
    _opsgenie_usage
  fi

  if [[ "P1" != "${OPSGENIE_PRIORITY}" ]] &&
    [[ "P2" != "${OPSGENIE_PRIORITY}" ]] &&
    [[ "P3" != "${OPSGENIE_PRIORITY}" ]] &&
    [[ "P4" != "${OPSGENIE_PRIORITY}" ]] &&
    [[ "P5" != "${OPSGENIE_PRIORITY}" ]]; then
    _opsgenie_usage
  fi
}

_opsgenie_create_body() {
  echo {} | jq \
    --arg alias "${OPSGENIE_ALIAS}" \
    --arg priority "${OPSGENIE_PRIORITY}" \
    --arg message "${OPSGENIE_MESSAGE}" \
    --arg source "${OPSGENIE_GITHUB_CI_LINK}" \
    '. + {
      "entity": "github-actions",
      "source": $source,
      "alias": $alias,
      "message": $message,
      "priority": $priority
    }'
}

_opsgenie_is_webhook_defined() {
  test "${NOTIFICATION_API_KEY}" != ""
}

_opsgenie_post() {
  local OPSGENIE_HOST

  OPSGENIE_HOST="api.opsgenie.com"
  if [[ -n "${NOTIFICATION_USE_EU_INSTANCE}" ]]; then
    OPSGENIE_HOST="api.eu.opsgenie.com"
  fi

  set -x
  curl --fail \
    --location \
    --silent \
    --show-error \
    --retry "${NOTIFICATION_RETRIES}" \
    --retry-max-time "${NOTIFICATION_MAX_TIME}" \
    -H "Host: ${OPSGENIE_HOST}" \
    -H "Authorization: GenieKey ${NOTIFICATION_API_KEY}" \
    -H "Content-Type: application/json" \
    --data "${1}" \
    -X POST \
    "https://${OPSGENIE_HOST}/v2/alerts"
  { set +x; } 2> /dev/null
}

_opsgenie_usage() {
  log "ERROR" "opsgenie.sh -- post a CI alert to OpsGenie."
  log "ERROR" "USAGE: opsgenie.sh -a [ALERT ALIAS] -l [LINK TO GITHUB WORKFLOW RUN] -m [MESSAGE CONTENT] -p [PRIORITY (default: P1)]"
  log "ERROR" "  Optional: NOTIFICATION_API_KEY should be set to correct OpsGenie API key value."
  exit 127
}

main "$@"
