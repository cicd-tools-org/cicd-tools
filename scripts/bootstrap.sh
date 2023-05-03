#!/bin/bash

# Bootstrap the CICD-tools system with the specified toolbox version.

# CICD-Tools Development script.

set -eo pipefail

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../.cicd-tools/boxes/bootstrap/libraries/logging.sh"

CICD_TOOLS_TOOLBOX_PATH="${CICD_TOOLS_TOOLBOX_PATH-"cicd-tools/boxes"}"
CICD_TOOLS_INSTALL_SUB_PATH="boxes/bootstrap"

main() {
  local CICD_TOOLS_TOOLBOX_VERSION

  _link_args "$@"
  _link_symlinks ".cicd-tools"
  _link_symlinks "{{cookiecutter.project_slug}}/.cicd-tools"
  _link_symlinks_template

  log "INFO" "All symlinks have been updated."
}

_link_args() {
  while getopts "b:" OPTION; do
    case "$OPTION" in
      b)
        CICD_TOOLS_TOOLBOX_VERSION="${OPTARG}"
        ;;
      \?)
        _link_usage
        ;;
      :)
        _link_usage
        ;;
      *)
        _link_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ -z "${CICD_TOOLS_TOOLBOX_VERSION}" ]]; then
    _link_usage
  fi
}

_link_symlink_directory_contents() {
  # 1:  Source
  # 2:  Destination

  local SOURCE_FILE
  local LINK_NAME
  local LINK_SOURCE

  log "DEBUG" "LINK > Source: '${1}/*'"

  mkdir -p "${2}"
  pushd "${2}" >> /dev/null

  for SOURCE_FILE in "$(_link_relative_path_new)/${1}/"*; do
    LINK_NAME="${SOURCE_FILE}"
    LINK_SOURCE="$(basename "${SOURCE_FILE}")"
    _link_symlink_write "${LINK_NAME}" "${LINK_SOURCE}"
  done
  popd >> /dev/null
}

_link_relative_path_new() {
  realpath --relative-to="$(pwd)" "$(git rev-parse --show-toplevel)"
}

_link_symlinks() {
  # 1: Installation Folder

  local LINK_NAME
  local LINK_SOURCE

  log "DEBUG" "SYMLINK > Destination: '${1}': ..."

  _link_symlink_directory_contents "${CICD_TOOLS_TOOLBOX_PATH}/${CICD_TOOLS_TOOLBOX_VERSION}/libraries" "${1}/${CICD_TOOLS_INSTALL_SUB_PATH}/libraries"
  _link_symlink_directory_contents "${CICD_TOOLS_TOOLBOX_PATH}/${CICD_TOOLS_TOOLBOX_VERSION}/pre-commit" "${1}/${CICD_TOOLS_INSTALL_SUB_PATH}/pre-commit"
  _link_symlink_directory_contents "${CICD_TOOLS_TOOLBOX_PATH}/${CICD_TOOLS_TOOLBOX_VERSION}/schemas" "${1}/${CICD_TOOLS_INSTALL_SUB_PATH}/schemas"

}

_link_symlinks_template() {
  local SOURCE_FILE
  local LINK_NAME
  local LINK_SOURCE

  log "DEBUG" "SYMLINK > Destination: '{{cookiecutter.project_slug}}/.cicd-tools': ..."

  _link_symlink_directory_contents ".cicd-tools/bin" "{{cookiecutter.project_slug}}/.cicd-tools/bin"
  _link_symlink_directory_contents ".cicd-tools/pgp" "{{cookiecutter.project_slug}}/.cicd-tools/pgp"

  log "DEBUG" "LINK > Source: '.github/actions/*'"
  mkdir -p "{{cookiecutter.project_slug}}/.github/actions"
  pushd "{{cookiecutter.project_slug}}/.github/actions" >> /dev/null
  for SOURCE_FILE in "../../../.github/actions/"*; do
    mkdir -p "$(basename "${SOURCE_FILE}")"
    pushd "$(basename "${SOURCE_FILE}")" >> /dev/null
    LINK_NAME="../${SOURCE_FILE}/action.yml"
    LINK_SOURCE="action.yml"
    _link_symlink_write "${LINK_NAME}" "${LINK_SOURCE}"
    popd >> /dev/null
  done
  popd >> /dev/null
}

_link_symlink_write() {
  set -x
  ln -sf "${1}" "${2}"
  { set +x; } 2> /dev/null
}

_link_usage() {
  log "ERROR" "bootstrap.sh -- bootstrap the CICD-tools system with the specified toolbox version."
  log "ERROR" "USAGE: link.sh -b [TOOLBOX VERSION]"
  exit 127
}

main "$@"
