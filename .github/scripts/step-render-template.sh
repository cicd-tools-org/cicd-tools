#!/bin/bash

# Perform automated templating.

# Implementation:
# Templates implementing this script must output the rendered cookiecutter template to the folder "template".
# To test various template options, simply PREPEND additional arguments to this script.

# 1:  Git Username
# 2:  Git Email

# CI only script.

set -eo pipefail

NAME=${1:-"Pro Buddy Dev"}
EMAIL=${2:-"somedude@coolstartup.com"}

main() {

  git config --global user.name "${NAME}"
  git config --global user.email "${EMAIL}"

  echo -e "\n\n\n" | cookiecutter template/

}

main "$@"
