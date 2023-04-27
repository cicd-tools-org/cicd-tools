#!/bin/bash

# Sets the ROLE_NAME environment variable.

# 1:  The relative path to the role inside the repository.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

DEFAULT_ROLE_NAME="${DEFAULT_ROLE_NAME-"${PROJECT_NAME}"}"

main() {

  local ROLE_NAME

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  if [[ "${1}" == "." ]]; then
    ROLE_NAME="${DEFAULT_ROLE_NAME}"
  else
    ROLE_NAME="$(basename "${1}")"
  fi

  log "DEBUG" "ROLE_NAME > Storing the value '${ROLE_NAME}' ..."

  echo "ROLE_NAME=${ROLE_NAME}" >> "${GITHUB_ENV}"

}

main "$@"
