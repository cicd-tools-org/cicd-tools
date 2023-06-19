#!/bin/bash

# Additional validation for a release candidate.

# 1:  The current tag being released.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

main() {

  local TAG="${1}"

  if ! grep "version: \"${TAG}\"" galaxy.yml; then
    log "ERROR" "The galaxy.yml file contains an incorrect version."
    exit 127
  fi

  log "INFO" "The galaxy.yml file contains the correct version."

}

main "$@"
