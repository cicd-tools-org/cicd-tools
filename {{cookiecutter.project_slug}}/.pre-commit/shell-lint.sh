#!/bin/bash

# Runs shellcheck on the specified files.

# @:  An array of shell files to check.

# pre-commit script.

set -eo pipefail

main() {

  # shellcheck source=.pre-commit/.docker-shim.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/.docker-shim.sh"

  docker run -t --rm -v "$(pwd):/mnt" -w "/mnt" "$(docker_interface "get_image")" /bin/shellcheck "-x" "--exclude" "SC2317" "$@"

}

main "$@"
