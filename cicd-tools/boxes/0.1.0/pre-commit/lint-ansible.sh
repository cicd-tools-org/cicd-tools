#!/bin/bash

# Runs ansible-galaxy to install/update the dependencies if needed, and then runs ansible-lint on each active target folder's changes.

# @:  An array of folders to run ansible-lint on.

# pre-commit script.

set -eo pipefail

# shellcheck source=../libraries/tools.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/tools.sh"

main() {
  local TARGET_FOLDERS=${*-"."}
  for TARGET in ${TARGET_FOLDERS}; do
    log "INFO" "PRE-COMMIT > Moving to target folder: '${TARGET}' ..."
    pushd "${TARGET}" >> /dev/null
    log "DEBUG" "PRE-COMMIT > Executing 'ansible-lint' ..."
    cicd_tools "poetry" ansible-lint
    popd >> /dev/null
  done
}

main "$@"
