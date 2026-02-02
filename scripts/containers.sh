#!/bin/bash

# Build the CICD-Tools container.

# CICD-Tools Development script.

set -eo pipefail

main() {
  log "INFO" "Building the CICD-Tools utility container ..."

  pushd .cicd-tools/containers >> /dev/null
  log "INFO" "Building AMD64 ..."
  docker build \
    --no-cache \
    --platform linux/amd64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_1=amd64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_2=x86_64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_3=x86_64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_4=64-bit \
    -f utilities/Dockerfile \
    -t ghcr.io/cicd-tools-org/cicd-tools:linux-amd .
  log "INFO" "Building ARM64 ..."
  docker build \
    --no-cache \
    --platform linux/arm64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_1=arm64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_2=arm64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_3=aarch64 \
    --build-arg BUILD_ARG_ARCH_FORMAT_4=arm64 \
    -f utilities/Dockerfile \
    -t ghcr.io/cicd-tools-org/cicd-tools:linux-arm .
  popd >> /dev/null

  log "INFO" "Building the CICD-Tools gettext container ..."

  pushd .cicd-tools/containers >> /dev/null
  log "INFO" "  Building AMD64 ..."
  docker build \
    --no-cache \
    --platform linux/amd64 \
    -f gettext/Dockerfile \
    -t ghcr.io/cicd-tools-org/cicd-tools-gettext:linux-amd .
  log "INFO" "  Building ARM64 ..."
  docker build \
    --no-cache \
    --platform linux/arm64 \
    -f gettext/Dockerfile \
    -t ghcr.io/cicd-tools-org/cicd-tools-gettext:linux-arm .
  popd >> /dev/null

  log "INFO" "Building the CICD-Tools gpg container ..."

  pushd .cicd-tools/containers >> /dev/null
  log "INFO" "  Building AMD64 ..."
  docker build \
    --no-cache \
    --platform linux/amd64 \
    -f gpg/Dockerfile \
    -t ghcr.io/cicd-tools-org/cicd-tools-gpg:linux-amd .
  log "INFO" "  Building ARM64 ..."
  docker build \
    --no-cache \
    --platform linux/arm64 \
    -f gpg/Dockerfile \
    -t ghcr.io/cicd-tools-org/cicd-tools-gpg:linux-arm .
  popd >> /dev/null

  log "INFO" "Containers successfully built."
}

_containers_import_support_libraries() {
  # 1:  The toolbox version to use during import.

  # shellcheck source=/dev/null
  source "$(dirname -- "${BASH_SOURCE[0]}")/../cicd-tools/boxes/${1}/libraries/logging.sh"
}

_containers_import_support_libraries "0.1.0"

main "$@"
