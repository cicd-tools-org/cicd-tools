#!/bin/bash

# Install the bootstrapped CICD-Tools system to an existing poetry based repository.

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
  _installer_actions
  _installer_poetry_init "."

  _installer_conditional_recursive_copy ".github/config/schemas"
  _installer_conditional_recursive_copy ".github/scripts/job-50-test-precommit.sh"
  _installer_conditional_recursive_copy ".gitignore"
  _installer_conditional_recursive_copy ".markdownlint.yml"
  _installer_conditional_recursive_copy ".yamllint.yml"

  _installer_line_in_file ".gitignore" '.cicd-tools/boxes/*'
  _installer_line_in_file ".gitignore" '!.cicd-tools/boxes/bootstrap'

  _installer_jinja_render ".github/config/actions/gaurav-nelson-github-action-markdown-link-check.json"
  _installer_jinja_render ".github/config/workflows/workflow-push.json"
  _installer_jinja_render ".github/scripts/step-setup-environment.sh"
  _installer_jinja_render ".github/workflows/workflow-push.yml"
  _installer_jinja_render ".pre-commit-config.yaml"

  _installer_initialize_vale "."

  log "INFO" "Successfully installed CICD-Tools."
}

_install_args() {
  while getopts "d:g:" OPTION; do
    case "$OPTION" in
      d)
        CICD_TOOLS_INSTALL_TARGET_PATH="${OPTARG}"
        [[ ! -d "${CICD_TOOLS_INSTALL_TARGET_PATH}" ]] && _install_no_target_path
        ;;
      g)
        CICD_TOOLS_GITHUB_HANDLE="${OPTARG}"
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

  if [[ -z "${CICD_TOOLS_INSTALL_TARGET_PATH}" || -z "${CICD_TOOLS_GITHUB_HANDLE}" ]]; then
    _install_usage
  fi
}

_install_no_target_path() {
  log "ERROR" "The path '${CICD_TOOLS_INSTALL_TARGET_PATH}' does not exist."
  exit 127
}

_install_usage() {
  log "ERROR" "install-poetry.sh -- install the bootstrapped CICD-Tools system to an existing poetry repository."
  log "ERROR" "USAGE: install-poetry.sh -d [DESTINATION PATH] -g [GITHUB_HANDLE]"
  exit 127
}

main "$@"
