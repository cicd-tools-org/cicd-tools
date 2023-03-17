#!/bin/bash

# Verifies the correct headers are present on GitHub workflow files.

# @:  An array of GitHub workflow files to lint.

# pre-commit script.

set -eo pipefail

main() {

  for WORKFLOW_FILE_PATH in "$@"; do

    WORKFLOW_BASENAME="$(basename "${WORKFLOW_FILE_PATH}")"

    if [[ "${WORKFLOW_BASENAME}" == .* ]]; then
      HEADER_NAME="$(echo "${WORKFLOW_BASENAME}" | cut -d. -f2)"
    else
      HEADER_NAME=".+-github-$(echo "${WORKFLOW_BASENAME}" | cut -d. -f1)"
    fi

    if ! grep -E "name: ${HEADER_NAME}" "${WORKFLOW_FILE_PATH}" >> /dev/null; then
      echo "ERROR: Incorrect Header on '${WORKFLOW_FILE_PATH}'"
      echo "EXPECTED: ${HEADER_NAME}"
      exit 127
    fi

  done

}

main "$@"
