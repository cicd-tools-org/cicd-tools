#!/bin/bash

# Library for working with the CICD-tools container.

set -eo pipefail

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/tools.sh"

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/logging.sh"

container() {
  local PREFIX
  local COMMAND

  PREFIX="_container"
  COMMAND="${PREFIX}_${1}"
  if [[ $(type -t "${COMMAND}") == function ]]; then
    shift
    "${COMMAND}" "$@"
  else
    "${PREFIX}_usage"
  fi
}

_container_get_image() {
  if cicd_tools "is_template"; then
    cicd_tools "config_value" "cookiecutter.json" "_DOCKER_DEFAULT_CONTAINER"
  else
    cicd_tools "config_value" ".cicd-tools/configuration/cicd-tools.json" "CONTAINER"
  fi
}

_container_run() {
  local CONTAINER_IMAGE
  CONTAINER_IMAGE="$(container "get_image")"
  log "DEBUG" "CONTAINER > ${CONTAINER_IMAGE} $*"
  docker run -t --rm -v "$(pwd):/mnt" -w "/mnt" "${CONTAINER_IMAGE}" "$@"
}

_container_usage() {
  log "ERROR" "container.sh -- CICD-tools container interface."
  log "ERROR" "USAGE: container.sh [COMMAND]"
  log "ERROR" "  COMMANDS:"
  log "ERROR" "  get_image           -- Return the the currently configured container image."
  log "ERROR" "  run [SUB COMMAND]   -- Run the given sub command inside the container."
}
