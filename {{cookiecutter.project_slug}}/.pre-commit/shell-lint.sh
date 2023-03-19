#!/bin/bash

# Runs shellcheck on the specified files.

# 1:  The Docker image and tag to use.
# @:  An array of shell files to check.

# pre-commit script.

set -eo pipefail

main() {

  IMAGE="${1}"
  shift

  # shellcheck source=.pre-commit/.template.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/.template.sh"

  docker run -t --rm -v "$(pwd):/mnt" -w "/mnt" "${IMAGE}" "-x" "--exclude" "SC2317" "$@"

}

main "$@"
