#!/bin/bash

# Interface for running commands in docker containers or local binaries.

set -eo pipefail

# shellcheck source=./logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/logging.sh"

CONTAINER_EXECUTION_TARGET_LOCAL_BINARY="LOCAL BINARY"
CONTAINER_EXECUTION_TARGET_CONTAINER="CONTAINER"
CONTAINER_LOCAL_BINARY_KEYWORD="system"

container() {
  # $1: image name ("system" to run local binary)
  # $2: command name
  # $@: additional arguments

  # Set CONTAINER_ENVIRONMENT_VARIABLES to space separated pairs of VAR=VALUE
  # Set CONTAINER_PERSISTED_SESSION_ID to use a named container with this id
  # Set CONTAINER_VOLUME_MOUNTS to space separated pairs of LOCAL_PATH:CONTAINER_PATH

  local CONTAINER_ARGUMENTS
  local CONTAINER_CODEBASE_MOUNT_FOLDER="${PRE_COMMIT_OVERRIDE_DOCKER_HOST_PATH:-${PWD}}"
  local CONTAINER_COMMAND
  local CONTAINER_CONSTRUCTED_COMMAND
  local CONTAINER_ENVIRONMENT_VARIABLE
  local CONTAINER_EXECUTION_TARGET
  local CONTAINER_IMAGE
  local CONTAINER_VOLUME_MOUNT

  CONTAINER_IMAGE="${1}"
  CONTAINER_COMMAND="${2}"
  shift 2
  CONTAINER_ARGUMENTS=("$@")
  CONTAINER_CONSTRUCTED_COMMAND=()

  if _container_is_local_binary; then
    CONTAINER_EXECUTION_TARGET="${CONTAINER_EXECUTION_TARGET_LOCAL_BINARY}"
    CONTAINER_CONSTRUCTED_COMMAND+=("${CONTAINER_COMMAND}" "${CONTAINER_ARGUMENTS[@]}")
  else
    CONTAINER_EXECUTION_TARGET="${CONTAINER_EXECUTION_TARGET_CONTAINER}"
    CONTAINER_CONSTRUCTED_COMMAND+=("docker" "run")

    if [[ -n "${CONTAINER_PERSISTED_SESSION_ID}" ]]; then
      CONTAINER_CONSTRUCTED_COMMAND+=("--name" "${CONTAINER_PERSISTED_SESSION_ID}")
    else
      CONTAINER_CONSTRUCTED_COMMAND+=("--rm")
    fi

    CONTAINER_CONSTRUCTED_COMMAND+=("-i" "-v" "${CONTAINER_CODEBASE_MOUNT_FOLDER}:/mnt" "--workdir" "/mnt")

    if [[ -n "${CONTAINER_ENVIRONMENT_VARIABLES}" ]]; then
      for CONTAINER_ENVIRONMENT_VARIABLE in ${CONTAINER_ENVIRONMENT_VARIABLES}; do
        CONTAINER_CONSTRUCTED_COMMAND+=("-e" "${CONTAINER_ENVIRONMENT_VARIABLE}")
      done
    fi

    if [[ -n "${CONTAINER_VOLUME_MOUNTS}" ]]; then
      for CONTAINER_VOLUME_MOUNT in ${CONTAINER_VOLUME_MOUNTS}; do
        CONTAINER_CONSTRUCTED_COMMAND+=("-v" "${CONTAINER_VOLUME_MOUNT}")
      done
    fi

    CONTAINER_CONSTRUCTED_COMMAND+=("${CONTAINER_IMAGE}" "${CONTAINER_COMMAND}" "${CONTAINER_ARGUMENTS[@]}")

  fi

  _container_run_command
}

container_session_create() {
  # $1: session id
  # $2: image name ("system" to run local binary)

  local CONTAINER_IMAGE
  local CONTAINER_PERSISTED_SESSION_ID

  CONTAINER_PERSISTED_SESSION_ID="${1}"
  CONTAINER_IMAGE="${2}"
  shift 2

  if _container_is_local_binary; then
    return 0
  fi

  container "${CONTAINER_IMAGE}" hostname > /dev/null
}

container_session_destroy() {
  # $1: session id
  # $2: image name ("system" to run local binary)

  local CONTAINER_IMAGE
  local CONTAINER_PERSISTED_SESSION_ID

  CONTAINER_PERSISTED_SESSION_ID="${1}"
  CONTAINER_IMAGE="${2}"
  shift 2

  if _container_is_local_binary; then
    return 0
  fi

  docker rm "${CONTAINER_PERSISTED_SESSION_ID}"
  docker rmi "cicd-tools-session-${CONTAINER_PERSISTED_SESSION_ID}"
}

container_session_run() {
  # $1: session id
  # $2: image name ("system" to run local binary)
  # $3: command name
  # $@: additional arguments

  local CONTAINER_IMAGE
  local CONTAINER_COMMAND
  local CONTAINER_PERSISTED_SESSION_ID

  CONTAINER_PERSISTED_SESSION_ID="${1}"
  CONTAINER_IMAGE="${2}"
  CONTAINER_COMMAND="${3}"
  shift 3

  if ! _container_is_local_binary; then
    docker commit "${CONTAINER_PERSISTED_SESSION_ID}" "cicd-tools-session-${CONTAINER_PERSISTED_SESSION_ID}" > /dev/null
    docker rm "${CONTAINER_PERSISTED_SESSION_ID}" > /dev/null
    CONTAINER_IMAGE="cicd-tools-session-${CONTAINER_PERSISTED_SESSION_ID}"
  fi

  container "${CONTAINER_IMAGE}" "${CONTAINER_COMMAND}" "$@"
}

container_cache_image() {
  # $1: image name ("system" to run local binary)

  local CONTAINER_IMAGE

  CONTAINER_IMAGE="${1}"

  if ! _container_is_local_binary; then
    _container_cached_pull
  fi
}

_container_is_local_binary() {
  [[ "${CONTAINER_IMAGE}" == "${CONTAINER_LOCAL_BINARY_KEYWORD}" ]]
}

_container_cached_pull() {
  log "INFO" "${CONTAINER_EXECUTION_TARGET_CONTAINER} > Caching Image: ${CONTAINER_IMAGE}"
  docker pull -q "${CONTAINER_IMAGE}" > /dev/null
}

_container_run_command() {
  local CONTAINER_EXIT_CODE=0
  if ! _container_is_local_binary; then
    log "DEBUG" "${CONTAINER_EXECUTION_TARGET} > Image: ${CONTAINER_IMAGE}"
  fi
  log "DEBUG" "${CONTAINER_EXECUTION_TARGET} > Command: ${CONTAINER_COMMAND}"
  log "DEBUG" "${CONTAINER_EXECUTION_TARGET} > Args: ${CONTAINER_ARGUMENTS[*]}"

  set +e
  set -x
  "${CONTAINER_CONSTRUCTED_COMMAND[@]}"
  CONTAINER_EXIT_CODE=$?
  { set +x; } 2> /dev/null
  set -e

  return "${CONTAINER_EXIT_CODE}"
}
