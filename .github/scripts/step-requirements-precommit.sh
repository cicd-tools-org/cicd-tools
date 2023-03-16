#!/bin/bash

# Installs all tools, scripts or binaries required for the pre-commit hooks (other than Actionlint).

# Implementation:
# Templates implementing this script must simply install the required software and ensure it's in PATH.

# CI only script.

set -eo pipefail

main() {

  sudo apt-get install -y golang-github-pelletier-go-toml shellcheck

}

main "$@"
