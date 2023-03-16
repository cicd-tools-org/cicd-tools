#!/bin/bash

# Download a remotely hosted script, and if it's shell or bash then execute it securely.

# 1:                      The URL of the script that should be executed in the current environment.
# 2:                      The SHA256 hash of the script for verification.
# @:                      An array of arguments to pass to the remote script.
# REMOTE_RETRY_MAX_TIME:  Optionally sets the maximum retry time.  (Defaults to 30 seconds.)
# REMOTE_SCRIPT_RETRIES:  Optionally set the number of fetch attempts.  (Defaults to 3.)
# SCRIPT_DOWNLOAD_NAME:   Optionally sets a name for scripts other than shell and bash to be saved to.  (Defaults to 'downloaded.script'.)

# CI bootstrap script.

set -eo pipefail

export REMOTE_SCRIPT_NAME

CACHE_FOLDER=~/.cache/remote_scripts
CACHE_KEY=""
SCRIPT_URL="${1}"
SCRIPT_HASH="${2}"
SCRIPT_CONTENTS=""
SCRIPT_DOWNLOAD_NAME="${SCRIPT_DOWNLOAD_NAME-downloaded.script}"
REMOTE_RETRY_MAX_TIME="${REMOTE_RETRY_MAX_TIME-30}"
REMOTE_SCRIPT_NAME="${1}"
REMOTE_SCRIPT_RETRIES="${REMOTE_SCRIPT_RETRIES-3}"

cache_initialize() {
  mkdir -p "${CACHE_FOLDER}"
  CACHE_KEY="$(sha256sum <<< "${SCRIPT_URL}" | cut -f1 -d ' ')"
}

cache_read() {
  cat "${CACHE_FOLDER}/${CACHE_KEY}"
}

cache_write() {
  echo "${SCRIPT_CONTENTS}" > "${CACHE_FOLDER}/${CACHE_KEY}"
}

is_bash_script() {
  [[ "${SCRIPT_URL}" == *.sh ]] || [[ "${SCRIPT_URL}" == *.bash ]]
}

is_cache_hit() {
  test -f "${CACHE_FOLDER}/${CACHE_KEY}"
}

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
}

main() {

  cache_initialize

  if ! is_cache_hit; then
    echo "DEBUG: cache miss, downloading script."
    SCRIPT_CONTENTS="$(curl --location --silent --show-error --retry "${REMOTE_SCRIPT_RETRIES}" --retry-max-time "${REMOTE_RETRY_MAX_TIME}" "${SCRIPT_URL}")"
    cache_write
  else
    echo "DEBUG: cache hit, re-using script."
    SCRIPT_CONTENTS="$(cache_read)"
  fi

  if is_validation_requested; then
    validate_checksum
  else
    validate_disabled
  fi

  if is_bash_script; then
    echo "DEBUG: executing '${SCRIPT_URL}'" >> /dev/stderr
    eval "${SCRIPT_CONTENTS}"
  else
    echo "DEBUG: saving non-shell script '${SCRIPT_URL}'" >> /dev/stderr
    echo "${SCRIPT_CONTENTS}" > "${SCRIPT_DOWNLOAD_NAME}"
  fi

}

shift
shift
main "$@"
