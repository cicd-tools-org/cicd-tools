#!/bin/bash

# Runs shfmt on the specified files.

# 1:  The Docker image and tag to use.
# @:  An array of shell files to format.

# pre-commit script.

set -eo pipefail

main() {

  IMAGE="${1}"
  shift

  # shellcheck source=.pre-commit/.template.sh
  source "$(dirname -- "${BASH_SOURCE[0]}")/.template.sh"

  if [[ -f "cookiecutter.json" ]]; then
    SHFMT_OPTIONS="$(jq -erM "._GITHUB_CI_DEFAULT_SHFMT_OPTIONS" cookiecutter.json)"
  else
    SHFMT_OPTIONS="{{cookiecutter._GITHUB_CI_DEFAULT_SHFMT_OPTIONS}}"
  fi

  # shellcheck disable=SC2046
  docker run -t --rm -v "$(pwd):/mnt" -w "/mnt" $(xargs <<< "${IMAGE} -d ${SHFMT_OPTIONS} $*")

}

main "$@"
