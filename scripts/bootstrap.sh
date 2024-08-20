#!/bin/bash

# Bootstrap the CICD-Tools system with the specified toolbox version.

# CICD-Tools Development script.

set -eo pipefail

CICD_TOOLS_TOOLBOX_PATH="${CICD_TOOLS_TOOLBOX_PATH-"cicd-tools/boxes"}"

main() {
  local CICD_TOOLS_INSTALL_TARGET_PATH
  local CICD_TOOLS_TOOLBOX_VERSION

  _bootstrap_args "$@"
  _bootstrap_import_installer_libraries "${CICD_TOOLS_TOOLBOX_VERSION}"

  _installer_update_precommit_repo
  _installer_update_legacy_bootstrap "${CICD_TOOLS_INSTALL_TARGET_PATH}"

  _bootstrap_restore_precommit_repo_configuration "${CICD_TOOLS_INSTALL_TARGET_PATH}"

  _installer_update_legacy_bootstrap "."
  _installer_precommit_hooks_update "."

  _installer_update_legacy_bootstrap "{{cookiecutter.project_slug}}"

  _bootstrap_symlinks_template_configuration

  log "INFO" "This repository and '${CICD_TOOLS_INSTALL_TARGET_PATH}' have been successfully bootstrapped with version '${CICD_TOOLS_TOOLBOX_VERSION}'."
}

_bootstrap_args() {
  local OPTARG
  local OPTIND
  local OPTION

  while getopts "b:d:" OPTION; do
    case "$OPTION" in
      b)
        CICD_TOOLS_TOOLBOX_VERSION="${OPTARG}"
        ;;
      d)
        CICD_TOOLS_INSTALL_TARGET_PATH="${OPTARG}"
        ;;
      \?)
        _bootstrap_usage
        ;;
      :)
        _bootstrap_usage
        ;;
      *)
        _bootstrap_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ -z "${CICD_TOOLS_TOOLBOX_VERSION}" ]] ||
    [[ -z "${CICD_TOOLS_INSTALL_TARGET_PATH}" ]]; then
    _bootstrap_usage
  fi

  _installer_validate_folder "${CICD_TOOLS_TOOLBOX_ROOT_PATH}/${CICD_TOOLS_TOOLBOX_VERSION}"
  _installer_validate_folder "${CICD_TOOLS_INSTALL_TARGET_PATH}"
}

_bootstrap_import_installer_libraries() {
  # 1:  The toolbox version to use during import.

  # shellcheck source=./scripts/libraries/installer.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/libraries/installer.sh"

  _installer_import_support_libraries
}

_bootstrap_relative_path() {
  realpath --relative-to="$(pwd)" "$(git rev-parse --show-toplevel)"
}

_bootstrap_restore_precommit_repo_configuration() {
  # 1: Precommit repo path

  pushd "${1}" >> /dev/null
  git checkout "${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/configuration/pre-commit-bootstrap.yaml"
  popd >> /dev/null
}

_bootstrap_symlink_directory_contents() {
  # 1:  Source
  # 2:  Destination

  local SOURCE_FILE
  local LINK_NAME
  local LINK_SOURCE

  log "DEBUG" "LINK > Source: '${1}/*'"

  mkdir -p "${2}"
  pushd "${2}" >> /dev/null

  for SOURCE_FILE in "$(_bootstrap_relative_path)/${1}/"*; do
    LINK_NAME="${SOURCE_FILE}"
    LINK_SOURCE="$(basename "${SOURCE_FILE}")"
    _bootstrap_symlink_write "${LINK_NAME}" "${LINK_SOURCE}"
  done
  popd >> /dev/null
}

_bootstrap_symlinks_template_configuration() {
  local SOURCE_FILE
  local LINK_NAME
  local LINK_SOURCE

  log "DEBUG" "SYMLINK > Destination: '{{cookiecutter.project_slug}}/.cicd-tools': ..."

  _bootstrap_symlink_directory_contents ".cicd-tools/configuration" "{{cookiecutter.project_slug}}/.cicd-tools/configuration"
}

_bootstrap_symlink_write() {
  set -x
  ln -sf "${1}" "${2}"
  { set +x; } 2> /dev/null
}

_bootstrap_usage() {
  log "ERROR" "bootstrap.sh -- bootstrap CICD-Tools with a specific toolbox."
  log "ERROR" "-------------------------------------------------------------"
  log "ERROR" "bootstrap.sh"
  log "ERROR" "           -b [TOOLBOX VERSION]"
  log "ERROR" "           -d [PRE-COMMIT REPOSITORY PATH]"
  exit 127
}

_bootstrap_import_installer_libraries

main "$@"
