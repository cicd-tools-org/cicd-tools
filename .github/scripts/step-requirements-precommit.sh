#!/bin/bash

# Installs all Python packages required to render the cookiecutter template.

# Implementation:
# Templates implementing this script must install all required and optional pre-commit binaries.

# CI only script.

set -eo pipefail

main() {

  sudo apt-get install -y golang-github-pelletier-go-toml shellcheck

  # shellcheck source=./.github/bootstrap/step-remote-script.sh
  source ./template/.github/bootstrap/step-remote-script.sh "${ACTIONLINT_SCRIPT_URL}" "${ACTIONLINT_SCRIPT_HASH}"
  sudo mv actionlint /usr/local/bin

}

main "$@"
