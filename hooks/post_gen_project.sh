#!/bin/bash

# Configures the templated profile for use.

# TEMPLATE_BRANCH_NAME_BASE:         Optional alternate base branch name.
# TEMPLATE_BRANCH_NAME_DEVELOPMENT:  Optional alternate development branch name.
# TEMPLATE_SKIP_GIT_INIT:            Optionally set to 1 to skip creating branches and initial commit.
# TEMPLATE_SKIP_POETRY:              Optionally set to 1 to skip installing dependencies.
# TEMPLATE_SKIP_PRECOMMIT:           Optionally set to 1 to skip installing pre-commit hooks.

# Cookiecutter only script.

set -eo pipefail

TEMPLATE_BRANCH_NAME_BASE="${TEMPLATE_BRANCH_NAME_BASE-"{{ cookiecutter._BRANCH_NAME_BASE }}"}"
TEMPLATE_BRANCH_NAME_DEVELOPMENT="${TEMPLATE_BRANCH_NAME_DEVELOPMENT-"{{ cookiecutter._BRANCH_NAME_DEVELOPMENT }}"}"
TEMPLATE_URL="https://github.com/cicd-tools-org/cicd-tools.git"

initialize_git() {

  if [[ "${TEMPLATE_SKIP_GIT_INIT}" != "1" ]]; then
    git init
    git checkout -b "${TEMPLATE_BRANCH_NAME_BASE}"
    git stage .
    git commit -m "build(COOKIECUTTER): initial generation"
    git symbolic-ref HEAD "refs/heads/${TEMPLATE_BRANCH_NAME_BASE}"
    git checkout -b "${TEMPLATE_BRANCH_NAME_DEVELOPMENT}"
    git checkout "${TEMPLATE_BRANCH_NAME_BASE}"
    mkdir -p templates
  fi

}

initialize_poetry() {

  if [[ "${TEMPLATE_SKIP_POETRY}" != "1" ]]; then
    poetry install --verbose --no-root
  fi

}

initialize_precommit() {

  if [[ "${TEMPLATE_SKIP_PRECOMMIT}" != "1" ]]; then
    poetry run pre-commit install
    pushd ansible_role >> /dev/null
    poetry run molecule dependency
    popd >> /dev/null
  fi

}

rewrite_source() {

  if ! grep "${TEMPLATE_URL}" .cookiecutter/cookiecutter.json; then
    # sed compatible with Linux and BSD
    sed -i.bak 's,"_template": ".*","_template": "'"${TEMPLATE_URL}"'",g' .cookiecutter/cookiecutter.json
    rm .cookiecutter/cookiecutter.json.bak
  fi

}

main() {

  rewrite_source
  initialize_git
  initialize_poetry
  initialize_precommit

}

main
