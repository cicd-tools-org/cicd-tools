#!/bin/bash

# .github/scripts/task-setup-ansible-cache.sh
# Creates symlinks for attaching an external cache folder for Ansible.
# Separate folders for Ansible-Compat, and Molecule are maintained.

# 1:  The path of the mount point of the external cache folder.
# 2:  A newline separated list of paths to symlink to the GitHub cache.

# CI only script

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

main() {

  local ACCESS_FOLDERS
  local ENCODED_NAME
  local MOUNT_FOLDER

  MOUNT_FOLDER="${1}"
  IFS=$'\n' read -ar ACCESS_FOLDERS <<< "${2}"

  for ACCESS_FOLDER in "${ACCESS_FOLDERS[@]}"; do
    ENCODED_NAME="$(tr '/' '-' <<< "${ACCESS_FOLDER}")"
    _cache_mkpath -p "${MOUNT_FOLDER}/${ENCODED_NAME}"
    _cache_mkpath -p "${ACCESS_FOLDER}"
    _cache_mklink "${MOUNT_FOLDER}/${ENCODED_NAME}" "${ACCESS_FOLDER}"
  done

}

_cache_mkpath() {
  # 1: The path to create
  log "DEBUG" "CACHE > creating ${1}"
  mkdir -p "${1}"
}

_cache_mklink() {
  # 1: The source path
  # 2: The link path
  log "DEBUG" "CACHE > link ${1} -> ${2}"
  mkdir -p "${1}" "${2}"
}

main "$@"
