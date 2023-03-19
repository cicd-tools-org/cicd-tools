#!/bin/bash

# Perform automated templating.

# Implementation:
# Templates implementing this script must output the cookiecutter template found in the folder "template".
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
  cp "./template/.github/scenarios/${SCENARIO}.json" ./template/cookiecutter.json
  pushd template >> /dev/null
  git diff cookiecutter.json
  popd >> /dev/null
}

main() {

  git config --global user.name "${NAME}"
  git config --global user.email "${EMAIL}"

  if is_scenario_present; then
    setup_scenario
  fi

  cookiecutter --no-input template/

}

main "$@"
