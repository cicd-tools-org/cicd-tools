#!/bin/bash

# Library for CICD-Tools installers.

set -eo pipefail

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/toolbox.sh"

CICD_TOOLS_GPG_KEYNAME="F07A79647E91E561A786B6D0D9020F7FEE20DBF2"
CICD_TOOLS_CONFIGURATION_ROOT_PATH=".cicd-tools"
CICD_TOOLS_TARGET_PRECOMMIT_VERSION="0.6.0"

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
  environment \
    -m "CICD_TOOLS_BOOTSTRAP_PATH CICD_TOOLS_TEMPLATE_PATH CICD_TOOLS_INSTALL_TARGET_PATH"

  log "INFO" "INSTALL > Boot-Strapping CICD-Tools to '${CICD_TOOLS_INSTALL_TARGET_PATH}/.cicd-tools' ..."
  mkdir -p "${CICD_TOOLS_INSTALL_TARGET_PATH}/${CICD_TOOLS_CONFIGURATION_ROOT_PATH}"
  _installer_bootstrap_folder "configuration"
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
  _installer_cookiecutter_symlink_directory ".cicd-tools/configuration" "{{cookiecutter.project_slug}}/.cicd-tools/configuration"

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

_installer_import_support_libraries() {

  local CICD_TOOLS_LATEST_TOOLBOX_VERSION

  CICD_TOOLS_LATEST_TOOLBOX_VERSION="$(get_latest_toolbox_version)"

  # shellcheck source=/dev/null
  source "$(dirname -- "${BASH_SOURCE[0]}")/../../${CICD_TOOLS_TOOLBOX_ROOT_PATH}/${CICD_TOOLS_LATEST_TOOLBOX_VERSION}/libraries/environment.sh"

  # shellcheck source=/dev/null
  source "$(dirname -- "${BASH_SOURCE[0]}")/../../${CICD_TOOLS_TOOLBOX_ROOT_PATH}/${CICD_TOOLS_LATEST_TOOLBOX_VERSION}/libraries/logging.sh"

  # shellcheck source=/dev/null
  source "$(dirname -- "${BASH_SOURCE[0]}")/../../${CICD_TOOLS_TOOLBOX_ROOT_PATH}/${CICD_TOOLS_LATEST_TOOLBOX_VERSION}/libraries/tools.sh"
}

_installer_initialize_vale() {
  #1: prefix folder

  local TARGET_FOLDER
  local VALE_FOLDER

  log "DEBUG" "VALE INITIALIZE > '${1}'"

  if [[ "${1}" != "." ]]; then
    VALE_FOLDER="${1}"
    log "DEBUG" "VALE CREATE > '${1}/.vale.ini'"
    _installer_prefixed_copy_file "${1}" .vale.ini
  else
    VALE_FOLDER="$(basename "${CICD_TOOLS_INSTALL_TARGET_PATH}")"
  fi

  TARGET_FOLDER="${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/.vale/Vocab/${VALE_FOLDER}"

  _installer_line_in_file "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/.gitignore" '.vale/*'
  _installer_line_in_file "${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/.gitignore" '!.vale/Vocab'

  if [[ ! -d "${TARGET_FOLDER}" ]]; then
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

  local TARGET_DEFAULT_PYTHON_PACKAGE
  TARGET_DEFAULT_PYTHON_PACKAGE="$(basename "${CICD_TOOLS_INSTALL_TARGET_PATH}")"

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
        pre_bump_hooks = ['poetry run pre-commit run --hook-stage=manual commitizen-pre-bump --files pyproject.toml -c .cicd-tools/configuration/pre-commit-bootstrap.yaml || true']
        version = '$(poetry version -s)'
        version_files = ['pyproject.toml:version']
        version_provider = 'poetry'

EOF
    log "WARNING" "POETRY > Commitizen config written to ${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/pyproject.toml"
  fi
  if [[ ! -d "${CICD_TOOLS_INSTALL_TARGET_PATH}/ ${TARGET_DEFAULT_PYTHON_PACKAGE}" ]] &&
    ! grep "tool.poetry.packages" pyproject.toml >> /dev/null &&
    ! grep "package-mode" pyproject.toml >> /dev/null; then
    sed -i.bak "s/\[tool.poetry\]/\[tool.poetry\]\\npackage-mode = false/g" pyproject.toml
    rm pyproject.toml.bak
    log "WARNING" "POETRY > Poetry 'package-mode' config written to ${CICD_TOOLS_INSTALL_TARGET_PATH}/${1}/pyproject.toml"
  fi

  # Sort the pyproject.toml file using the default cookiecutter container tomll binary

  docker run -i \
    --rm \
    -v "${PWD}":/mnt \
    --workdir /mnt \
    "$(cicd_tools config_value "${CICD_TOOLS_ROOT_PATH}/cookiecutter.json" "_DOCKER_DEFAULT_CONTAINER")" \
    tomll \
    pyproject.toml

  popd >> /dev/null
}

_installer_precommit_hooks_update() {
  # 1: The folder to validate

  local TARGET_FOLDER="${1}"

  if [[ -e "${TARGET_FOLDER}/.pre-commit-config.yaml" ]]; then
    # Update Pre-Commit Version
    yq --inplace '.repos |= map(select(.repo =="https://github.com/cicd-tools-org/pre-commit.git").rev = "'${CICD_TOOLS_TARGET_PRECOMMIT_VERSION}'")' "${TARGET_FOLDER}/.pre-commit-config.yaml"
    # Sort Pre-Commit Repos and Hooks
    yq --inplace '.repos |= sort_by(.repo) | .repos.[].hooks |= sort_by(.id)' "${TARGET_FOLDER}/.pre-commit-config.yaml"
  fi
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

_installer_regenerate_toolbox_signature() {
  environment \
    -m "CICD_TOOLS_GPG_KEYNAME CICD_TOOLS_CONFIGURATION_ROOT_PATH"

  log "WARNING" "REGENERATE SIGNATURE > Regenerating the CICD-Tools toolbox signature ..."

  gpg \
    --local-user "${CICD_TOOLS_GPG_KEYNAME}" \
    -a \
    -b \
    "${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/pgp/verification.txt" \
    -o "${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/pgp/verification.sign"

  log "INFO" "REGENERATE SIGNATURE > The CICD-Tools toolbox signature has been successfully regenerated."
}

_installer_update_legacy_bootstrap() {
  # 1: Target Folder

  local TARGET_FOLDER="${1}"

  if [[ -d "${TARGET_FOLDER}/${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/bin" ]]; then
    log "WARNING" "LEGACY > Removing legacy CICD-Tools install scripts at '${TARGET_FOLDER}/${CICD_TOOLS_CONFIGURATION_ROOT_PATH}' ..."
    rm -rf "${TARGET_FOLDER:?}/${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/bin"
  fi
  if [[ -d "${TARGET_FOLDER}/${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/boxes/bootstrap" ]]; then
    log "WARNING" "LEGACY > Removing legacy CICD-Tools bootstrap toolbox at '${TARGET_FOLDER}/${CICD_TOOLS_CONFIGURATION_ROOT_PATH}' ..."
    rm -rf "${TARGET_FOLDER:?}/${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/boxes"
  fi
  if [[ -e "${TARGET_FOLDER}/pyproject.toml" ]]; then
    log "WARNING" "LEGACY > Migrating legacy CICD-Tools commitizen bump script at '${TARGET_FOLDER}/${CICD_TOOLS_CONFIGURATION_ROOT_PATH}' ..."
    sed -i.bak 's,.cicd-tools/boxes/bootstrap/commitizen/pre_bump.sh,poetry run pre-commit run --hook-stage=manual commitizen-pre-bump --files pyproject.toml -c .cicd-tools/configuration/pre-commit-bootstrap.yaml || true,' "${TARGET_FOLDER}/pyproject.toml"
    rm "${TARGET_FOLDER}/pyproject.toml.bak"
  fi
  if [[ -e "${TARGET_FOLDER}/.gitignore" ]]; then
    log "WARNING" "LEGACY > Migrating legacy CICD-Tools .gitignore entries at '${TARGET_FOLDER}/${CICD_TOOLS_CONFIGURATION_ROOT_PATH}' ..."
    sed -i.bak '/!.cicd-tools\/boxes\/bootstrap/d' "${TARGET_FOLDER}/.gitignore"
    rm "${TARGET_FOLDER}/.gitignore.bak"
  fi
}

_installer_update_precommit_repo() {
  local CICD_TOOLS_INSTALL_SUB_PATH_CONFIG=".cicd-tools"
  local CICD_TOOLS_INSTALL_SUB_PATH_TOOLBOX="src/cicd-tools"
  local CICD_TOOLS_INSTALL_TARGET_PATH_CONFIG="${CICD_TOOLS_INSTALL_TARGET_PATH}/${CICD_TOOLS_INSTALL_SUB_PATH_CONFIG}"
  local CICD_TOOLS_INSTALL_TARGET_PATH_TOOLBOX="${CICD_TOOLS_INSTALL_TARGET_PATH}/${CICD_TOOLS_INSTALL_SUB_PATH_TOOLBOX}"

  environment \
    -m "CICD_TOOLS_INSTALL_TARGET_PATH CICD_TOOLS_TOOLBOX_VERSION CICD_TOOLS_TOOLBOX_ROOT_PATH"

  log "INFO" "INSTALL > Updating pre-commit repository at '${CICD_TOOLS_INSTALL_TARGET_PATH}' ..."

  _installer_update_precommit_configuration_folder "configuration"
  _installer_update_precommit_toolbox_folder "libraries"
  _installer_update_precommit_toolbox_folder "schemas"
  _installer_update_precommit_toolbox_signature

  log "INFO" "INSTALL > pre-commit has been updated!"
}

_installer_update_precommit_configuration_folder() {
  local TARGET_FOLDER

  log "DEBUG" "COPY CONFIG > Copying the CICD-Tools '${1}' folder from toolbox default configuration ..."

  TARGET_FOLDER="$(dirname -- "${CICD_TOOLS_INSTALL_TARGET_PATH_CONFIG}/${1}")"

  if [[ -d "${TARGET_FOLDER}/${1}" ]]; then
    log "WARNING" "COPY CONFIG > Removing existing content at '${TARGET_FOLDER}/${1}' ..."
    rm -rf "${TARGET_FOLDER}/${1:?}"
  fi

  mkdir -p "${TARGET_FOLDER}"

  set -x
  cp -rv "${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/${1}" "${TARGET_FOLDER}"
  { set +x; } 2> /dev/null
}

_installer_update_precommit_toolbox_folder() {
  local TARGET_FOLDER

  log "DEBUG" "COPY TOOLBOX> Copying the CICD-Tools '${1}' folder from toolbox version '${CICD_TOOLS_TOOLBOX_VERSION}' ..."

  TARGET_FOLDER="$(dirname -- "${CICD_TOOLS_INSTALL_TARGET_PATH_TOOLBOX}/${1}")"

  if [[ -d "${TARGET_FOLDER}/${1}" ]]; then
    log "WARNING" "COPY TOOLBOX> Removing existing content at '${TARGET_FOLDER}/${1}' ..."
    rm -rf "${TARGET_FOLDER}/${1:?}"
  fi

  mkdir -p "${TARGET_FOLDER}"

  set -x
  cp -rv "${CICD_TOOLS_TOOLBOX_ROOT_PATH}/${CICD_TOOLS_TOOLBOX_VERSION}/${1}" "${TARGET_FOLDER}"
  { set +x; } 2> /dev/null
}

_installer_bootstrap_configuration_folder() {
  local TARGET_FOLDER

  log "DEBUG" "COPY CONFIG > Copying the CICD-Tools '${1}' folder from toolbox default configuration ..."

  TARGET_FOLDER="$(dirname -- "${CICD_TOOLS_INSTALL_TARGET_PATH_CONFIG}/${1}")"

  if [[ -d "${TARGET_FOLDER}/${1}" ]]; then
    log "WARNING" "COPY CONFIG > Removing existing content at '${TARGET_FOLDER}/${1}' ..."
    rm -rf "${TARGET_FOLDER}/${1:?}"
  fi

  mkdir -p "${TARGET_FOLDER}"

  set -x
  cp -rv "${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/${1}" "${TARGET_FOLDER}"
  { set +x; } 2> /dev/null
}

_installer_bootstrap_toolbox_folder() {
  local TARGET_FOLDER

  log "DEBUG" "COPY TOOLBOX> Copying the CICD-Tools '${1}' folder from toolbox version '${CICD_TOOLS_TOOLBOX_VERSION}' ..."

  TARGET_FOLDER="$(dirname -- "${CICD_TOOLS_INSTALL_TARGET_PATH_TOOLBOX}/${1}")"

  if [[ -d "${TARGET_FOLDER}/${1}" ]]; then
    log "WARNING" "COPY TOOLBOX> Removing existing content at '${TARGET_FOLDER}/${1}' ..."
    rm -rf "${TARGET_FOLDER}/${1:?}"
  fi

  mkdir -p "${TARGET_FOLDER}"

  set -x
  cp -rv "${CICD_TOOLS_TOOLBOX_ROOT_PATH}/${CICD_TOOLS_TOOLBOX_VERSION}/${1}" "${TARGET_FOLDER}"
  { set +x; } 2> /dev/null
}

_installer_update_precommit_toolbox_signature() {
  local TARGET_FOLDER

  log "DEBUG" "COPY SIGNATURE > Copying the CICD-Tools toolbox signature from pre-generated defaults ..."

  TARGET_FOLDER="${CICD_TOOLS_INSTALL_TARGET_PATH_TOOLBOX}/pgp"

  if [[ -d "${TARGET_FOLDER}" ]]; then
    log "WARNING" "COPY SIGNATURE > Removing existing signature at '${TARGET_FOLDER}' ..."
    rm -rf "${TARGET_FOLDER:?}}"
  fi

  mkdir -p "${TARGET_FOLDER}"

  log "DEBUG" "COPY SIGNATURE > Rechecking signature ..."
  gpg --verify "${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/pgp/verification.sign" "${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/pgp/verification.txt"

  set -x
  cp -rv "${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/pgp/verification.sign" "${TARGET_FOLDER}"
  cp -rv "${CICD_TOOLS_CONFIGURATION_ROOT_PATH}/pgp/verification.txt" "${TARGET_FOLDER}"
  { set +x; } 2> /dev/null
}

_installer_validate_folder() {
  # 1: The folder to validate

  local TARGET_FOLDER="${1}"

  if [[ ! -d "${TARGET_FOLDER}" ]]; then
    log "ERROR" "The specified folder '${TARGET_FOLDER}' does not exist!"
    return 127
  fi
}
