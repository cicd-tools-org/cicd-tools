#!/bin/bash

# Download a remotely hosted script, and if it's shell or bash then execute it securely.

# 1:                      The remote-execute path (or alternatively the full url) of the script that should be executed in the current environment.
# @:                      An array of arguments to pass to the remote script. (The script will be sourced, with these arguments.)
# REMOTE_SCRIPT_RETRIES:  Optionally sets the number of fetch attempts.
# REMOTE_RETRY_MAX_TIME:  Optionally sets the maximum retry time.
# SCRIPT_DOWNLOAD_NAME:   Optionally set a filename to download to, rather than execute.  (Especially useful for non-shell scripts.)
# SCRIPT_HASH:            Optionally sets a sha256sum for the remote file.  (The manifest will not be used to lookup hashes.)

# CI bootstrap script.

set -eo pipefail

REMOTE_SCRIPT_RETRIES="${REMOTE_SCRIPT_RETRIES-3}"
REMOTE_RETRY_MAX_TIME="${REMOTE_RETRY_MAX_TIME-30}"
SCRIPT_HASH="${SCRIPT_HASH-""}"

cache() {

  is_hit() {
    test -f "${CACHE_FOLDER}/${CACHE_KEY}"
  }

  initialize() {
    mkdir -p "${CACHE_FOLDER}"
    CACHE_KEY="$(sha256sum <<< "${SCRIPT_URL}" | cut -f1 -d ' ')"
  }

  load() {
    cp "${CACHE_FOLDER}/${CACHE_KEY}" "${TEMP_FILE}"
  }

  save() {
    cp "${TEMP_FILE}" "${CACHE_FOLDER}/${CACHE_KEY}"
  }

  "$@"

}

checksum() {

  validate() {

    is_manually_disabled() {
      test "$(jq -erM --arg url "${SCRIPT_URL}" '."disable-security"' "${REMOTE_SCRIPT_MANIFEST}")" == "true"
    }

    is_manually_specified() {
      test "${SCRIPT_HASH}" != ""
    }

    perform_comparison() {
      if ! sha256sum "${TEMP_FILE}" | cut -f1 -d ' ' | grep "${SCRIPT_HASH}" >> /dev/null; then
        echo "ERROR: sha256 checksum failed for remote script '${SCRIPT_URL}'!" >> /dev/stderr
        echo "DEBUG: expected hash '${SCRIPT_HASH}'!" >> /dev/stderr
        exit 127
      fi
    }

    perform_validation() {
      if ! is_manually_specified; then
        query_manifest
      else
        echo "DEBUG: using manually specified sha256sum for '${SCRIPT_URL}'!" >> /dev/stderr
      fi
      perform_comparison
    }

    query_manifest() {
      if ! SCRIPT_HASH="$(jq -erM --arg url "${SCRIPT_URL}" '.manifest[$url]' "${REMOTE_SCRIPT_MANIFEST}")"; then
        echo "ERROR: sha256 checksum not found for remote script '${SCRIPT_URL}'!" >> /dev/stderr
        exit 127
      fi
    }

    if ! is_manually_disabled; then
      perform_validation
    else
      echo "WARNING: sha256sum verification has been manually disabled!" >> /dev/stderr
    fi

  }

  "$@"

}

download() {
  curl --fail \
    --location \
    --silent \
    --show-error \
    --retry "${REMOTE_SCRIPT_RETRIES}" \
    --retry-max-time "${REMOTE_RETRY_MAX_TIME}" \
    "${SCRIPT_URL}" \
    > "${TEMP_FILE}"
}

remote() {

  append_prefix() {
    local REMOTE_SHA
    local REMOTE_SOURCE
    REMOTE_SHA="$(jq -erM '.["cicd-tools-sha"]' "${REMOTE_SCRIPT_MANIFEST}")"
    REMOTE_SOURCE="$(jq -erM '.["cicd-tools-source"]' "${REMOTE_SCRIPT_MANIFEST}")"
    SCRIPT_URL="${REMOTE_SOURCE}/${REMOTE_SHA}/${SCRIPT_URL}"
  }

  is_bash_script() {
    [[ "${SCRIPT_URL}" == *.sh ]] || [[ "${SCRIPT_URL}" == *.bash ]]
  }

  is_download() {
    test "${SCRIPT_DOWNLOAD_NAME}" != ""
  }

  is_url() {
    [[ "${SCRIPT_URL}" == https:* ]]
  }

  "$@"

}

main() {

  local CACHE_KEY
  local CACHE_FOLDER
  local REMOTE_SCRIPT_MANIFEST
  local SCRIPT_URL
  local TEMP_FILE

  echo "DEBUG: -- ${BASH_SOURCE[0]} --" >> /dev/stderr

  CACHE_KEY=""
  CACHE_FOLDER="${HOME}/.cache/remote_scripts"
  REMOTE_SCRIPT_MANIFEST="$(dirname -- "${BASH_SOURCE[0]}")/manifest.json"

  SCRIPT_URL="${1}"
  REMOTE_SCRIPT_NAME="${1}"
  shift

  TEMP_FILE="$(mktemp)"
  trap 'rm -f "${TEMP_FILE}"' EXIT

  if ! remote "is_url"; then
    remote "append_prefix"
  fi

  cache "initialize"

  if ! cache "is_hit"; then
    echo "DEBUG: cache miss, downloading script." >> /dev/stderr
    download
    checksum "validate"
    cache "save"
  else
    echo "DEBUG: cache hit, re-using script." >> /dev/stderr
    cache "load"
  fi

  if remote "is_bash_script" && ! remote "is_download"; then
    echo "DEBUG: executing remote script '${SCRIPT_URL}'" >> /dev/stderr
    chmod +x "${TEMP_FILE}"
    REMOTE_SCRIPT_NAME="${REMOTE_SCRIPT_NAME}" "${TEMP_FILE}" "$@"
    exit $?
  fi

  if remote "is_download"; then
    echo "DEBUG: saving remote script '${SCRIPT_URL}'" >> /dev/stderr
    echo "DEBUG: local filename '${SCRIPT_DOWNLOAD_NAME}'" >> /dev/stderr
    cp "${TEMP_FILE}" "${SCRIPT_DOWNLOAD_NAME}"
    exit $?
  fi

  echo "ERROR: only executing scripts that end in '.bash' or '.sh'."
  echo "ERROR: set SCRIPT_DOWNLOAD_NAME environment variable to download the remote script without executing."
  exit 127

}

main "$@"
