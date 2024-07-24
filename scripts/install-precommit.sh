#!/bin/bash

# Install the default CICD-Tools precommit hook into an existing repository.

# CICD-Tools Development script.

set -eo pipefail

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../.cicd-tools/boxes/bootstrap/libraries/logging.sh"

# shellcheck disable=SC2034
CICD_TOOLS_BOOTSTRAP_PATH="${CICD_TOOLS_TOOLBOX_PATH-"$(dirname -- "${BASH_SOURCE[0]}")/../.cicd-tools"}"
# shellcheck disable=SC2034
CICD_TOOLS_GITHUB_PATH="${CICD_TOOLS_ACTION_PATH-"$(dirname -- "${BASH_SOURCE[0]}")/../.github"}"
# shellcheck disable=SC2034
CICD_TOOLS_TEMPLATE_PATH="${CICD_TOOLS_ACTION_PATH-"$(dirname -- "${BASH_SOURCE[0]}")/../{{cookiecutter.project_slug}}"}"

main() {
  local CICD_TOOLS_INSTALL_TARGET_PATH

  _install_args "$@"

  # shellcheck source=./scripts/libraries/installer.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/libraries/installer.sh"

  _installer_bootstrap
  _installer_poetry_init "."

  _installer_conditional_recursive_copy ".gitignore"
  _installer_conditional_recursive_copy ".markdownlint.yml"
  _installer_conditional_recursive_copy ".yamllint.yml"

  _installer_jinja_render ".pre-commit-config.yaml"

  _installer_initialize_vale "."

  log "INFO" "Successfully installed CICD-Tools precommit hooks."
}

_install_args() {
  local OPTARG
  local OPTIND
  local OPTION

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

_install_no_target_path() {
  log "ERROR" "The path '${CICD_TOOLS_INSTALL_TARGET_PATH}' does not exist."
  exit 127
}

_install_usage() {
  log "ERROR" "install-precommit.sh -- install CICD-Tools precommit hook support into an existing repository."
  log "ERROR" "USAGE: install-precommit.sh -d [DESTINATION PATH]"
  exit 127
}

main "$@"
