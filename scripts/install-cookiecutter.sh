#!/bin/bash

# Install the bootstrapped CICD-tools system to an existing cookiecutter repository.

# CICD-Tools Development script.

set -eo pipefail

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../.cicd-tools/boxes/bootstrap/libraries/logging.sh"

CICD_TOOLS_GITHUB_PATH="${CICD_TOOLS_ACTION_PATH-"$(dirname -- "${BASH_SOURCE[0]}")/../.github"}"
CICD_TOOLS_BOOTSTRAP_PATH="${CICD_TOOLS_TOOLBOX_PATH-"$(dirname -- "${BASH_SOURCE[0]}")/../.cicd-tools"}"

main() {
  local CICD_TOOLS_INSTALL_TARGET_PATH

  _install_args "$@"
  _install_bootstrap
  _install_actions
  _install_cookiecutter_symlinks
  _install_cookiecutter_copy

  log "INFO" "Successfully bootstrapped CICD-tools."
}

_install_args() {
  while getopts "d:" OPTION; do
    case "$OPTION" in
      d)
        CICD_TOOLS_INSTALL_TARGET_PATH="${OPTARG}"
        [[ ! -d "${CICD_TOOLS_INSTALL_TARGET_PATH}" ]] && _install_no_target_path
        ;;
      \?)
        _install_usage
        ;;
      :)
        _install_usage
        ;;
      *)
        _install_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ -z "${CICD_TOOLS_INSTALL_TARGET_PATH}" ]]; then
    _install_usage
  fi
}

_install_actions() {
  log "INFO" "INSTALL > Installing the GitHub Actions to '${CICD_TOOLS_INSTALL_TARGET_PATH}/.github/actions' ..."
  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/.github/actions"
  _install_action_folder "action-00-toolbox"
}

_install_action_folder() {
  log "DEBUG" "COPY >  Copying the GitHub Action '${1}' ..."
  set -x
  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/.github/actions/${1}"
  cp -v "${CICD_TOOLS_GITHUB_PATH}/actions/${1}/"* "${CICD_TOOLS_INSTALL_TARGET_PATH}/.github/actions/${1}"
  { set +x; } 2> /dev/null
}

_install_bootstrap() {
  log "INFO" "INSTALL > Boot-Strapping CICD-Tools to '${CICD_TOOLS_INSTALL_TARGET_PATH}/.cicd-tools' ..."
  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/.cicd-tools/boxes"
  _install_bootstrap_folder "bin"
  _install_bootstrap_folder "configuration"
  _install_bootstrap_folder "boxes/bootstrap"
  _install_bootstrap_folder "pgp"
}

_install_bootstrap_folder() {
  log "DEBUG" "COPY > Copying the CICD-Tools '${1}' folder ..."
  set -x
  cp -rv "${CICD_TOOLS_BOOTSTRAP_PATH}/${1}" "$(dirname -- "${CICD_TOOLS_INSTALL_TARGET_PATH}/.cicd-tools/${1}")"
  { set +x; } 2> /dev/null
}

_install_cookiecutter_symlinks() {
  log "INFO" "INSTALL > Destination: '${CICD_TOOLS_INSTALL_TARGET_PATH}/{{cookiecutter.project_slug}}/.cicd-tools': ..."
  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/{{cookiecutter.project_slug}}/.cicd-tools"
  _install_cookiecutter_symlink_directory ".cicd-tools/bin" "{{cookiecutter.project_slug}}/.cicd-tools/bin"
  _install_cookiecutter_symlink_directory ".cicd-tools/configuration" "{{cookiecutter.project_slug}}/.cicd-tools/configuration"
  _install_cookiecutter_symlink_directory ".cicd-tools/boxes/bootstrap/libraries" "{{cookiecutter.project_slug}}/.cicd-tools/boxes/bootstrap/libraries"
  _install_cookiecutter_symlink_directory ".cicd-tools/boxes/bootstrap/pre-commit" "{{cookiecutter.project_slug}}/.cicd-tools/boxes/bootstrap/pre-commit"
  _install_cookiecutter_symlink_directory ".cicd-tools/boxes/bootstrap/schemas" "{{cookiecutter.project_slug}}/.cicd-tools/boxes/bootstrap/schemas"
  _install_cookiecutter_symlink_directory ".cicd-tools/pgp" "{{cookiecutter.project_slug}}/.cicd-tools/pgp"

  log "INFO" "INSTALL > Destination: '${CICD_TOOLS_INSTALL_TARGET_PATH}/{{cookiecutter.project_slug}}/.github/actions': ..."
  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/{{cookiecutter.project_slug}}/.github/actions"
  _install_cookiecutter_symlink_directory ".github/actions/action-00-toolbox" "{{cookiecutter.project_slug}}/.github/actions/action-00-toolbox"
}

_install_cookiecutter_symlink_directory() {
  # 1:  Source
  # 2:  Destination

  local INSTALL_PATH
  local SOURCE_FILE
  local LINK_NAME
  local LINK_SOURCE

  INSTALL_PATH="$(realpath "${CICD_TOOLS_INSTALL_TARGET_PATH}")"

  log "DEBUG" "SYMLINK > Source: '${1}/*'"
  log "DEBUG" "SYMLINK > Destination: '${2}/*'"

  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/${2}" >> /dev/null
  pushd "${CICD_TOOLS_INSTALL_TARGET_PATH}/${2}" >> /dev/null
  for SOURCE_FILE in "$(_install_cookiecutter_symlink_relative_path)/${1}/"*; do
    LINK_NAME="${SOURCE_FILE}"
    LINK_SOURCE="$(basename "${SOURCE_FILE}")"
    _install_cookiecutter_symlink_write "${LINK_NAME}" "${LINK_SOURCE}"
  done
  popd >> /dev/null
}

_install_cookiecutter_symlink_relative_path() {
  realpath --relative-to="$(pwd)" "${INSTALL_PATH}"
}

_install_cookiecutter_symlink_write() {
  set -x
  ln -sf "${1}" "${2}"
  { set +x; } 2> /dev/null
}

_install_cookiecutter_copy() {
  # 1: Source
  log "INFO" "INSTALL > Copying additional template content ..."
  _install_cookiecutter_copy_file "{{cookiecutter.project_slug}}/.cicd-tools/configuration/cicd-tools.json"
  _install_cookiecutter_copy_file "{{cookiecutter.project_slug}}/scripts/format.sh"
}

_install_cookiecutter_copy_file() {
  log "DEBUG" "COPY > Source: '${1}'"
  log "DEBUG" "COPY > Destination: '${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}'"
  set -x
  mkdir -p "$(dirname -- "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}")"
  cp -v "${1}" "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}"
  { set +x; } 2> /dev/null
}

_install_no_target_path() {
  log "ERROR" "The path '${CICD_TOOLS_INSTALL_TARGET_PATH}' does not exist."
  exit 127
}

_install_usage() {
  log "ERROR" "install-cookiecutter.sh -- install the bootstrapped CICD-tools system to an existing cookiecutter repository."
  log "ERROR" "USAGE: install-cookiecutter.sh -d [DESTINATION PATH]"
  exit 127
}

main "$@"
