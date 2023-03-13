#!/bin/bash

# Create configuration for a workflow run dynamically.

# @  An array of commands to execute to generate the JSON value.
# REMOTE_SCRIPT_NAME: The script name as set by the cicd-tools remote executor (remote-script.sh).

# CI only script.

set -eo pipefail

main() {

  local GENERATED_VALUE

  echo "DEBUG: -- ${REMOTE_SCRIPT_NAME} --" >> /dev/stderr

  GENERATED_VALUE=$("$@")
  echo "DEBUG: the value '${GENERATED_VALUE}' has been created." >> /dev/stderr

  {
    echo "value<<EOF"
    echo "${GENERATED_VALUE}"
    echo "EOF"
  } >> "${GITHUB_OUTPUT}"

  echo "DEBUG: this value has now set to the output 'value' for this job." >> /dev/stderr

}

main "$@"

unset main
