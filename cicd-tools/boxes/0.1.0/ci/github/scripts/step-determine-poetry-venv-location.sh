#!/bin/bash

# Identifies the location of Poetry Venvs on this platform, and sets it as the step's output.

# 1:  The platform identifier for this GitHub runner.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

main() {

  local POETRY_LOCATION

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  case "${1}" in
    Linux)
      POETRY_LOCATION="${HOME}/.cache/pypoetry/virtualenvs"
      ;;
    macOS)
      POETRY_LOCATION="${HOME}/Library/Caches/pypoetry/virtualenvs"
      ;;
    *)
      log "ERROR" "Unknown platform: '${1}'"
      exit 127
      ;;
  esac

  log "DEBUG" "POETRY_LOCATION > Storing the path '${POETRY_LOCATION}' ..."

  echo "POETRY_LOCATION=${POETRY_LOCATION}" >> "${GITHUB_OUTPUT}"

}

main "$@"
