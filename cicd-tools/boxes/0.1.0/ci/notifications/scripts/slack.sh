#!/bin/bash

# Sends a notification to Slack via a webhook.

# NOTIFICATION_RETRIES:     Optionally sets the number of attempts.
# NOTIFICATION_MAX_TIME:    Optionally sets the maximum retry time.
# NOTIFICATION_WEBHOOK_URL: The Slack webhook URL to use.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/environment.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/environment.sh" \
  -o "NOTIFICATION_RETRIES NOTIFICATION_MAX_TIME" \
  -d "3 30"

main() {
  local SLACK_REQUEST_BODY
  local SLACK_GITHUB_CI_LINK
  local SLACK_MESSAGE

  OPTIND=1

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  _slack_args "$@"

  if _slack_is_webhook_defined; then
    log "DEBUG" "NOTIFICATION > A webhook has been configured, preparing to send notification."
    SLACK_REQUEST_BODY="$(_slack_create_body)"
    log "DEBUG" "NOTIFICATION > A request body has been generated."
    _slack_post "${SLACK_REQUEST_BODY}"
    log "INFO" "NOTIFICATION > The payload has been sent."
  else
    log "WARNING" "NOTIFICATION > No webhook is configured, skipping this task."
  fi
}

_slack_args() {
  while getopts "l:m:" OPTION; do
    case "$OPTION" in
      l)
        SLACK_GITHUB_CI_LINK="${OPTARG}"
        ;;
      m)
        SLACK_MESSAGE="${OPTARG}"
        ;;
      \?)
        _slack_usage
        ;;
      :)
        _slack_usage
        ;;
      *)
        _slack_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ -z "${SLACK_GITHUB_CI_LINK}" ]] ||
    [[ -z "${SLACK_MESSAGE}" ]]; then
    _slack_usage
  fi
}

_slack_create_body() {
  echo {} | jq \
    --arg text "${SLACK_GITHUB_CI_LINK}: ${SLACK_MESSAGE}" \
    '. + { "text": $text }'
}

_slack_is_webhook_defined() {
  test "${NOTIFICATION_WEBHOOK_URL}" != ""
}

_slack_post() {
  set -x
  curl --fail \
    --location \
    --silent \
    --show-error \
    --retry "${NOTIFICATION_RETRIES}" \
    --retry-max-time "${NOTIFICATION_MAX_TIME}" \
    --data "${1}" \
    -X POST \
    -H 'Content-type: application/json' \
    "${NOTIFICATION_WEBHOOK_URL}"
  { set +x; } 2> /dev/null
}

_slack_usage() {
  log "ERROR" "slack.sh -- post a CI notification to Slack."
  log "ERROR" "USAGE: slack.sh -l [LINK TO GITHUB WORKFLOW RUN] -m [MESSAGE CONTENT]"
  log "ERROR" "  Optional: NOTIFICATION_WEBHOOK_URL should be set to desired Slack webhook endpoint."
  exit 127
}

main "$@"
