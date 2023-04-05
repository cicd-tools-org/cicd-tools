#!/bin/bash

# Perform automated templating.

# Implementation:
# Templates implementing this script should be designed to work from inside a cloned copy of the repository.
# To test various template "scenarios", make a copy of the 'cookiecutter.json' file and copy to the .github/scenarios folder.

# 1:  Scenario filename. (Provide basename only, the path is implied.)
# 2:  Git Username
# 3:  Git Email

# CI only script.

set -eo pipefail

SCENARIO="${1}"
NAME="${2:-"Pro Buddy Dev"}"
EMAIL="${3:-"somedude@coolstartup.com"}"

is_scenario_present() {
  test "${SCENARIO}" != ""
}

setup_scenario() {
  cp "./.github/scenarios/${SCENARIO}.json" ./cookiecutter.json
  git diff cookiecutter.json
}

main() {

  git config --global user.name "${NAME}"
  git config --global user.email "${EMAIL}"

  if is_scenario_present; then
    setup_scenario
  fi

  cookiecutter --no-input -o .. .

}

main "$@"
