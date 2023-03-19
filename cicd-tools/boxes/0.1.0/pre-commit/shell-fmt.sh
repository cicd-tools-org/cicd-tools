#!/bin/bash

# Runs shfmt on the specified files.

# @:  An array of shell files to format.

# pre-commit script.

set -eo pipefail

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/container.sh"

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/tools.sh"

main() {
  local SHFMT_OPTIONS

  if cicd_tools "is_template"; then
    SHFMT_OPTIONS="$(cicd_tools "config_value" "cookiecutter.json" "_CONFIG_DEFAULT_SHFMT_OPTIONS")"
  else
    SHFMT_OPTIONS="$(cicd_tools "config_value" ".cicd-tools/configuration.json" "SHFMT_OPTIONS")"
  fi

  log "INFO" "PRE-COMMIT > 'shfmt -d ${SHFMT_OPTIONS} $*'"

  # shellcheck disable=SC2046
  container "run" \
    $(xargs <<< "shfmt -d ${SHFMT_OPTIONS} $*")
}

main "$@"
