#!/bin/bash

# Build the CICD-tools container.

# CICD-Tools Development script.

set -eo pipefail

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../.cicd-tools/boxes/bootstrap/libraries/logging.sh"

main() {
  log "INFO" "Building the CICD-tools utility container ..."

  pushd .cicd-tools/container >> /dev/null
  docker build -t ghcr.io/cicd-tools-org/cicd-tools .
  popd >> /dev/null

  log "INFO" "Container successfully built."
}

main "$@"
