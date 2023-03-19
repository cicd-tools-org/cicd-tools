#!/bin/bash

# Runs tomll on the specified files and then runs diff to detect changes.

# 1:  The Docker image and tag to use.
# @:  An array of toml files to lint.

# pre-commit script.

set -eo pipefail

main() {

  # shellcheck source=.pre-commit/.docker-shim.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/.docker-shim.sh"

  for TOML_FILE in "$@"; do

    diff "${TOML_FILE}" <(docker run -i --rm "$(docker_interface "get_image")" /bin/tomll < "${TOML_FILE}")

  done

}

main "$@"
