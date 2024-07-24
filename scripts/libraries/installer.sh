#!/bin/bash

# Library for CICD-Tools installers.

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../.cicd-tools/boxes/bootstrap/libraries/logging.sh"

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/environment.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../.cicd-tools/boxes/bootstrap/libraries/environment.sh" \
  -m "CICD_TOOLS_BOOTSTRAP_PATH CICD_TOOLS_TEMPLATE_PATH CICD_TOOLS_INSTALL_TARGET_PATH"

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/tools.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../.cicd-tools/boxes/bootstrap/libraries/tools.sh"

set -eo pipefail

# shellcheck disable=SC2034
CICD_TOOLS_ROOT_PATH="${CICD_TOOLS_ROOT_PATH-"$(realpath "$(dirname -- "${BASH_SOURCE[0]}")")/../.."}"

_installer_actions() {
  log "INFO" "INSTALL > Installing the GitHub Actions to '${CICD_TOOLS_INSTALL_TARGET_PATH}/.github/actions' ..."
  _installer_action_folder "action-00-toolbox"
}

_installer_action_folder() {
  log "DEBUG" "COPY >  Copying the GitHub Action '${1}' ..."
  set -x
  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/.github/actions/${1}"
  cp -v "${CICD_TOOLS_TEMPLATE_PATH}/.github/actions/${1}/"* "${CICD_TOOLS_INSTALL_TARGET_PATH}/.github/actions/${1}"
  { set +x; } 2> /dev/null
}

_installer_bootstrap() {
  log "INFO" "INSTALL > Boot-Strapping CICD-Tools to '${CICD_TOOLS_INSTALL_TARGET_PATH}/.cicd-tools' ..."
  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/.cicd-tools/boxes"
  _installer_bootstrap_folder "bin"
  _installer_bootstrap_folder "configuration"
  _installer_bootstrap_folder "boxes/bootstrap"
  _installer_bootstrap_folder "pgp"
}

_installer_bootstrap_folder() {
  log "DEBUG" "COPY > Copying the CICD-Tools '${1}' folder ..."
  set -x
  cp -rv "${CICD_TOOLS_BOOTSTRAP_PATH}/${1}" "$(dirname -- "${CICD_TOOLS_INSTALL_TARGET_PATH}/.cicd-tools/${1}")"
  { set +x; } 2> /dev/null
}

_installer_conditional_recursive_copy() {
  # 1: source / destination
  log "DEBUG" "RECURSIVE COPY > Source: '{{cookiecutter.project_slug}}/${1}'"
  log "DEBUG" "RECURSIVE COPY > Destination: '${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}'"

  if [[ ! -e "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}" ]]; then
    set -x
    mkdir -p "$(dirname "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}")"
    cp -rp "{{cookiecutter.project_slug}}/${1}" "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}"
    { set +x; } 2> /dev/null
  else
    log "DEBUG" "SKIP > '${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}' already exists!"
  fi
}

_installer_cookiecutter_symlinks() {
  log "INFO" "INSTALL > Destination: '${CICD_TOOLS_INSTALL_TARGET_PATH}/{{cookiecutter.project_slug}}/.cicd-tools': ..."
  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/{{cookiecutter.project_slug}}/.cicd-tools"
  _installer_cookiecutter_symlink_directory ".cicd-tools/bin" "{{cookiecutter.project_slug}}/.cicd-tools/bin"
  _installer_cookiecutter_symlink_directory ".cicd-tools/configuration" "{{cookiecutter.project_slug}}/.cicd-tools/configuration"
  _installer_cookiecutter_symlink_directory ".cicd-tools/boxes/bootstrap/commitizen" "{{cookiecutter.project_slug}}/.cicd-tools/boxes/bootstrap/commitizen"
  _installer_cookiecutter_symlink_directory ".cicd-tools/boxes/bootstrap/libraries" "{{cookiecutter.project_slug}}/.cicd-tools/boxes/bootstrap/libraries"
  _installer_cookiecutter_symlink_directory ".cicd-tools/boxes/bootstrap/schemas" "{{cookiecutter.project_slug}}/.cicd-tools/boxes/bootstrap/schemas"
  _installer_cookiecutter_symlink_directory ".cicd-tools/pgp" "{{cookiecutter.project_slug}}/.cicd-tools/pgp"

  log "INFO" "INSTALL > Destination: '${CICD_TOOLS_INSTALL_TARGET_PATH}/{{cookiecutter.project_slug}}/.github/actions': ..."
  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/{{cookiecutter.project_slug}}/.github/actions"
  _installer_cookiecutter_symlink_directory ".github/actions/action-00-toolbox" "{{cookiecutter.project_slug}}/.github/actions/action-00-toolbox"
}

_installer_cookiecutter_symlink_directory() {
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
  for SOURCE_FILE in "$(_installer_cookiecutter_symlink_relative_path)/${1}/"*; do
    LINK_NAME="${SOURCE_FILE}"
    LINK_SOURCE="$(basename "${SOURCE_FILE}")"
    _installer_cookiecutter_symlink_write "${LINK_NAME}" "${LINK_SOURCE}"
  done
  popd >> /dev/null
}

_installer_cookiecutter_symlink_relative_path() {
  realpath --relative-to="$(pwd)" "${INSTALL_PATH}"
}

_installer_cookiecutter_symlink_write() {
  set -x
  ln -sf "${1}" "${2}"
  { set +x; } 2> /dev/null
}

_installer_line_in_file() {
  #1: destination file
  #2: string you wish to append

  log "DEBUG" "LINE IN FILE > Destination: '${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}'"
  log "DEBUG" "LINE IN FILE > Content: '${2}'"

  if ! grep "${2}" "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}" >> /dev/null; then
    echo "${2}" >> "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}"
    log "INFO" "LINE IN FILE > Updated: '${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}'"
  else
    log "DEBUG" "SKIP > Already present!"
  fi
}

_installer_initialize_vale() {
  #1: prefix folder

  local TARGET_FOLDER
  local VALE_FOLDER

  log "DEBUG" "VALE INITIALIZE > '${1}'"

  if [[ "${1}" != "." ]]; then
    VALE_FOLDER=${1}
    log "DEBUG" "VALE CREATE > '${1}/.vale.ini'"
    _installer_prefixed_copy_file "${1}" .vale.ini
  else
    VALE_FOLDER="$(basename "${CICD_TOOLS_INSTALL_TARGET_PATH}")"
  fi

  TARGET_FOLDER="${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/.vale/Vocab/${VALE_FOLDER}"

  _installer_line_in_file "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/.gitignore" '.vale/*'
  _installer_line_in_file "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/.gitignore" '!.vale/Vocab'

  if [[ -f "${TARGET_FOLDER}" ]]; then
    log "DEBUG" "VALE CREATE > '${TARGET_FOLDER}/'"
    mkdir -p "${TARGET_FOLDER}/"
  fi

  _installer_line_in_file "${TARGET_FOLDER}/accept.txt" "$(basename "${CICD_TOOLS_INSTALL_TARGET_PATH}")"
  sort "${TARGET_FOLDER}/accept.txt" -o "${TARGET_FOLDER}/accept.txt"
  touch "${TARGET_FOLDER}/reject.txt"

  log "DEBUG" "VALE CREATE > '.vale.ini'"
  _installer_jinja_render ".vale.ini"
}

_installer_jinja_render() {
  #1: source / destination

  log "DEBUG" "JINJA RENDER > Source: '{{cookiecutter.project_slug}}/${1}'"
  log "DEBUG" "JINJA RENDER > Destination: '${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}'"

  if [[ ! -e "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}" ]]; then
    mkdir -p "$(dirname -- "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}")"
    poetry run jinja -d - -f json "{{cookiecutter.project_slug}}/${1}" -o "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}" <<< "$(
      cat <<- EOF
    {
      "cookiecutter": {
        "optional_toml_linting": "true",
        "optional_workflow_linting": "true",
        "github_handle": "${CICD_TOOLS_GITHUB_HANDLE}",
        "project_slug": "$(basename "${CICD_TOOLS_INSTALL_TARGET_PATH}")",
        "_GITHUB_CI_DEFAULT_PYTHON_VERSIONS": ["3.9"],
        "_GITHUB_CI_DEFAULT_VERBOSE_NOTIFICATIONS": false
      }
    }
EOF
    )"
    log "DEBUG" "JINJA RENDER > Wrote: '${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}'"
  else
    log "DEBUG" "SKIP > '${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}' already exists!"
  fi
}

_installer_poetry_init() {
  #1: path from install location

  pushd "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}" >> /dev/null
  if [[ ! -f "pyproject.toml" ]]; then
    poetry init -q --dev-dependency=commitizen --dev-dependency=pre-commit
    sed -i.bak 's/packages = .*//g' pyproject.toml
    rm pyproject.toml.bak
    log "INFO" "POETRY > Initialized ${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/pyproject.toml"
  fi
  if ! grep "tool.commitizen" pyproject.toml >> /dev/null; then
    cat >> pyproject.toml <<- EOF
        [tool.commitizen]
        bump_message = 'bump(RELEASE): \$current_version → \$new_version'
        pre_bump_hooks = ['.cicd-tools/boxes/bootstrap/commitizen/pre_bump.sh']
        version = '$(poetry version -s)'
        version_files = ['pyproject.toml:version']
        version_provider = 'poetry'
EOF
    log "INFO" "POETRY > Commitizen config written to ${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/pyproject.toml"
  fi

  docker run -i \
    --rm \
    -v "${PWD}":/mnt \
    --workdir /mnt \
    "$(cicd_tools config_value "${CICD_TOOLS_ROOT_PATH}/cookiecutter.json" "_DOCKER_DEFAULT_CONTAINER")" \
    tomll \
    pyproject.toml

  popd >> /dev/null
}

_installer_prefixed_copy_file() {
  # 1:  Prefix
  # 2:  Source

  log "DEBUG" "PREFIXED COPY > Source: '${1}/${2}'"
  log "DEBUG" "PREFIXED COPY > Destination: '${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/${2}'"

  if [[ ! -e "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/${2}" ]]; then
    set -x
    mkdir -p "$(dirname -- "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/${2}")"
    cp -v "${1}/${2}" "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/${2}"
    { set +x; } 2> /dev/null
  else
    log "DEBUG" "SKIP > '${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/${2}' already exists!"
  fi
}
