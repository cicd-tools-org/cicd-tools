#!/bin/bash

# Sends a notification to Slack via a webhook.

# 1:                        The notification is divided into 2 parts:  This first part is typically a link to the CI run that triggered the notification.
# 2:                        The notification is divided into 2 parts:  This second part typically contains the message proper, with any emojis being used.
# NOTIFICATION_RETRIES:     Optionally sets the number of attempts.
# NOTIFICATION_MAX_TIME:    Optionally sets the maximum retry time.
# NOTIFICATION_WEBHOOK_URL: The Slack webhook URL to use.
# REMOTE_SCRIPT_NAME:       The script name as set by the cicd-tools remote executor (remote-script.sh).

# CI only script.

set -eo pipefail

NOTIFICATION_RETRIES="${NOTIFICATION_RETRIES-3}"
NOTIFICATION_MAX_TIME="${NOTIFICATION_MAX_TIME-30}"

slack() {

  create_body() {
    echo {} | jq \
      --arg text "${1}: ${2}" \
      '. + { "text": $text }'
  }

  is_webhook_defined() {
    test "${NOTIFICATION_WEBHOOK_URL}" != ""
  }

  post() {

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
  }

  "$@"

}

main() {

  local REQUEST_BODY

  echo "DEBUG: -- ${REMOTE_SCRIPT_NAME} --" >> /dev/stderr

  if slack "is_webhook_defined"; then
    echo "DEBUG: a webhook has been configured, preparing to send notification." >> /dev/stderr
    REQUEST_BODY="$(slack "create_body" "$@")"
    echo "DEBUG: a request body has been generated: '${REQUEST_BODY}'." >> /dev/stderr
    slack "post" "${REQUEST_BODY}"
    echo "DEBUG: the payload has been sent." >> /dev/stderr
  else
    echo "DEBUG: no webhook is configured, skipping this task." >> /dev/stderr
  fi

}

main "$@"
