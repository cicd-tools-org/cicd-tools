#!/bin/bash

# Installs all Python packages required to render the cookiecutter template.

# Implementation:
# Templates implementing this script must install versions of cookiecutter and poetry,
# plus any other required Python packages.

# CI only script.

set -eo pipefail

main() {

  python -m pip install cookiecutter poetry --verbose

}

main "$@"
