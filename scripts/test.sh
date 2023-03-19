#!/bin/bash

# Templates and builds the example role with the specified scenario.

# 1:  Scenario filename. (Provide basename only, the path is implied.)

# CICD-Tools Development script.

set -eo pipefail

scenario() {

  is_present() {
    test "${USER_SCENARIO}" != ""
  }

  setup() {
    if ! git diff --exit-code cookiecutter.json; then
      echo "ERROR: your cookiecutter.json file has changes that are not checked in."
      exit 127
    else
      cp "./.github/scenarios/${USER_SCENARIO}" ./cookiecutter.json
    fi
  }

  "$@"

}

main() {

  local USER_SCENARIO

  USER_SCENARIO="${1}"

  rm -rf "../cicd-tool-box"

  if scenario "is_present"; then
    scenario "setup"
  fi

  TEMPLATE_FOLDER="$(git rev-parse --show-toplevel)"

  pushd .. >> /dev/null
  cookiecutter --no-input "${TEMPLATE_FOLDER}"
  cd cicd-tool-box
  echo -e "\nExit from this shell when finished testing ..."
  bash
  popd >> /dev/null

}

main "$@"
