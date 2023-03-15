#!/bin/bash

# Executes a remotely hosted script securely.

# 1:                      The URL of the script that should be executed in the current environment.
# 2:                      The SHA256 hash of the script for verification.
# @:                      An array of arguments to pass to the remote script.
# REMOTE_RETRY_MAX_TIME:  Optionally sets the maximum retry time.  (Defaults to 30 seconds.)
# REMOTE_SCRIPT_RETRIES:  Optionally set the number of fetch attempts.  (Defaults to 3.)

# CI bootstrap script.

set -eo pipefail

export REMOTE_SCRIPT_NAME

SCRIPT_URL="${1}"
SCRIPT_HASH="${2}"
SCRIPT_CONTENTS=""
REMOTE_SCRIPT_NAME="${1}"
REMOTE_RETRY_MAX_TIME="${REMOTE_RETRY_MAX_TIME-30}"
REMOTE_SCRIPT_RETRIES="${REMOTE_SCRIPT_RETRIES-3}"

is_validation_requested() {
  test "${SCRIPT_HASH}" != ""
}

validate_checksum() {
  if ! echo "${SCRIPT_CONTENTS}" | sha256sum | grep -E "^${SCRIPT_HASH}\s+-$"; then
    echo "ERROR: sha256 checksum failed for remote script '${SCRIPT_URL}'!" >> /dev/stderr
    exit 127
  fi
}

validate_disabled() {
  echo "WARNING: checksum validation not being used!" >> /dev/stderr
  echo "WARNING: executing '${SCRIPT_URL}'" >> /dev/stderr
}

main() {

  SCRIPT_CONTENTS="$(curl --location --silent --show-error --retry "${REMOTE_SCRIPT_RETRIES}" --retry-max-time "${REMOTE_RETRY_MAX_TIME}" "${SCRIPT_URL}")"

  if is_validation_requested; then
    validate_checksum
  else
    validate_disabled
  fi

  eval "${SCRIPT_CONTENTS}"

}

shift
shift
main "$@"
