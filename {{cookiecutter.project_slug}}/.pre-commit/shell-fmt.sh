#!/bin/bash

# Runs shfmt on the specified files and then runs diff to detect changes.

# @:  An array of shell files to lint.

# pre-commit script.

set -eo pipefail

main() {

  if [[ -f "cookiecutter.json" ]]; then
    SHFMT_OPTIONS="$(jq -erM ._GITHUB_CI_DEFAULT_SHFMT_OPTIONS cookiecutter.json)"
  else
    SHFMT_OPTIONS="{{cookiecutter._GITHUB_CI_DEFAULT_SHFMT_OPTIONS}}"
  fi

  xargs shfmt <<< "-d ${SHFMT_OPTIONS} $*"

}

main "$@"
