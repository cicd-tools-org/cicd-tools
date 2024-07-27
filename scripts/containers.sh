#!/bin/bash

# Build the CICD-Tools container.

# CICD-Tools Development script.

set -eo pipefail

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../.cicd-tools/boxes/bootstrap/libraries/logging.sh"

main() {
  log "INFO" "Building the CICD-Tools utility container ..."

  pushd .cicd-tools/containers/utilities >> /dev/null
  log "INFO" "Building AMD64 ..."
  docker build \
    --no-cache \
    --platform linux/amd64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_1=amd64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_2=x86_64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_3=x86_64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_4=64-bit \
    -t ghcr.io/cicd-tools-org/cicd-tools:linux-amd .
  log "INFO" "Building ARM64 ..."
  docker build \
    --no-cache \
    --platform linux/arm64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_1=arm64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_2=arm64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_3=aarch64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_4=arm64 \
    -t ghcr.io/cicd-tools-org/cicd-tools:linux-arm .
  popd >> /dev/null

  log "INFO" "Building the CICD-Tools gpg container ..."

  pushd .cicd-tools/containers/gpg >> /dev/null
  log "INFO" "  Building AMD64 ..."
  docker build \
    --no-cache \
    --platform linux/amd64 \
    -t ghcr.io/cicd-tools-org/cicd-tools-gpg:linux-amd .
  log "INFO" "  Building ARM64 ..."
  docker build \
    --no-cache \
    --platform linux/arm64 \
    -t ghcr.io/cicd-tools-org/cicd-tools-gpg:linux-arm .
  popd >> /dev/null

  log "INFO" "Containers successfully built."
}

main "$@"
