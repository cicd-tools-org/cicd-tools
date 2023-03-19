#!/bin/bash

# Runs shellcheck on the specified files.

# @:  An array of shell files to check.

# pre-commit script.

set -eo pipefail

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/container.sh"

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/tools.sh"

main() {
  local SHELLCHECK_OPTS

  if cicd_tools "is_template"; then
    SHELLCHECK_OPTS="$(cicd_tools "config_value" "cookiecutter.json" "_CONFIG_DEFAULT_SHELLCHECK_OPTIONS")"
  else
    SHELLCHECK_OPTS="$(cicd_tools "config_value" ".cicd-tools/configuration.json" "SHELLCHECK_OPTIONS")"
  fi

  log "INFO" "PRE-COMMIT > 'shellcheck -x ${SHELLCHECK_OPTS} $*'"

  # shellcheck disable=SC2046
  container "run" \
    $(xargs <<< "shellcheck -x ${SHELLCHECK_OPTS} $*")
}

main "$@"
