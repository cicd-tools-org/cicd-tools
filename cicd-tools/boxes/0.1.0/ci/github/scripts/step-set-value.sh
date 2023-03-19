#!/bin/bash

# Create configuration for a workflow run dynamically.

# @  An array of commands to execute to generate the JSON value.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

main() {
  local GENERATED_VALUE

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"
  GENERATED_VALUE=$("$@")
  log "DEBUG" "The value has been generated."

  {
    echo "value<<EOF"
    echo "${GENERATED_VALUE}"
    echo "EOF"
  } >> "${GITHUB_OUTPUT}"

  log "DEBUG" "This value has been set to the output 'value' for this job."
}

main "$@"
