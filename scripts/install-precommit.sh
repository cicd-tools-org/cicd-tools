#!/bin/bash

# Install the default CICD-Tools precommit hook into an existing repository.

# CICD-Tools Development script.

set -eo pipefail

# shellcheck disable=SC2034
CICD_TOOLS_BOOTSTRAP_PATH="${CICD_TOOLS_TOOLBOX_PATH-"$(dirname -- "${BASH_SOURCE[0]}")/../.cicd-tools"}"
# shellcheck disable=SC2034
CICD_TOOLS_GITHUB_PATH="${CICD_TOOLS_ACTION_PATH-"$(dirname -- "${BASH_SOURCE[0]}")/../.github"}"
# shellcheck disable=SC2034
CICD_TOOLS_TEMPLATE_PATH="${CICD_TOOLS_ACTION_PATH-"$(dirname -- "${BASH_SOURCE[0]}")/../{{cookiecutter.project_slug}}"}"

main() {
  local CICD_TOOLS_INSTALL_TARGET_PATH
  local CICD_TOOLS_TOOLBOX_VERSION

  _install_args "$@"
  _install_import_installer_libraries "${CICD_TOOLS_TOOLBOX_VERSION}"

  _installer_bootstrap

  _installer_update_legacy_bootstrap "${CICD_TOOLS_INSTALL_TARGET_PATH}"

  _installer_poetry_init "."

  _installer_line_in_file ".gitignore" '.cicd-tools/boxes'
  _installer_line_in_file ".gitignore" '.cicd-tools/manifest.json'

  _installer_conditional_recursive_copy ".markdownlint.yml"
  _installer_conditional_recursive_copy ".yamllint.yml"

  _installer_jinja_render ".pre-commit-config.yaml"

  _installer_initialize_vale "."

  _installer_precommit_hooks_update "${CICD_TOOLS_INSTALL_TARGET_PATH}"

  log "INFO" "Successfully installed CICD-Tools precommit hooks."
}

_install_args() {
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

  if [[ -z "${CICD_TOOLS_INSTALL_TARGET_PATH}" ]] ||
    [[ -z "${CICD_TOOLS_TOOLBOX_VERSION}" ]]; then
    _install_usage
  fi
}

_install_import_installer_libraries() {
  # 1:  The toolbox version to use during import.

  # shellcheck source=./scripts/libraries/installer.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/libraries/installer.sh"

  _installer_import_support_libraries
}

_install_no_target_path() {
  log "ERROR" "The path '${CICD_TOOLS_INSTALL_TARGET_PATH}' does not exist."
  exit 127
}

_install_usage() {
  log "ERROR" "install-precommit.sh -- install the CICD-Tools pre-commit config to a repo."
  log "ERROR" "---------------------------------------------------------------------------"
  log "ERROR" "install-precommit.sh"
  log "ERROR" "           -b [TOOLBOX VERSION]"
  log "ERROR" "           -d [DESTINATION REPOSITORY PATH]"
  exit 127
}

_install_import_installer_libraries

main "$@"
