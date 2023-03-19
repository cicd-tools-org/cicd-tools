#!/bin/bash

# Runs actionlint.

# 1:  The Docker image and tag to use.

# pre-commit script.

set -eo pipefail

main() {

  IMAGE="${1}"
  shift

  # shellcheck source=.pre-commit/.template.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/.template.sh"

  docker run -t --rm -v "$(pwd):/mnt" -w "/mnt" "${IMAGE}"

}

main "$@"
