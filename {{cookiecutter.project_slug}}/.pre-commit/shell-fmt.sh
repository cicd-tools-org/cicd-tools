#!/bin/bash

# Runs shfmt on the specified files.

# @:  An array of shell files to format.

# pre-commit script.

set -eo pipefail

main() {

  # shellcheck source=.pre-commit/.docker-shim.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/.docker-shim.sh"

  if docker_interface "is_tooling"; then
    SHFMT_OPTIONS="$(docker_interface "configuration" "_GITHUB_CI_DEFAULT_SHFMT_OPTIONS")"
  else
    SHFMT_OPTIONS="{{cookiecutter._GITHUB_CI_DEFAULT_SHFMT_OPTIONS}}"
  fi

  # shellcheck disable=SC2046
  docker run -t --rm -v "$(pwd):/mnt" -w "/mnt" $(xargs <<< "$(docker_interface "get_image") /bin/shfmt -d ${SHFMT_OPTIONS} $*")

}

main "$@"
