#!/bin/bash

# Generates a changelog for the specified tag and stores it in the GITHUB_ENV as CHANGELOG_CONTENT.

# 1:                  The new git tag the changelog is being generated for.
# REMOTE_SCRIPT_NAME: The script name as set by the cicd-tools remote executor (remote-script.sh).

# CI only script.

set -eo pipefail

main() {

  local CHANGE_LOG_CONTENT

  echo "DEBUG: -- ${REMOTE_SCRIPT_NAME} --" >> /dev/stderr

  CHANGE_LOG_CONTENT="$(npx -q conventional-changelog-cli -t "${1}")"

  echo "DEBUG: changelog has been generated." >> /dev/stderr
  echo "${GENERATED_VALUE}" >> /dev/stderr

  {
    echo "CHANGE_LOG_CONTENT<<EOF"
    echo "${CHANGE_LOG_CONTENT}"
    echo "EOF"
  } >> "${GITHUB_ENV}"

  echo "DEBUG: this value has been stored to the GITHUB_ENV as CHANGE_LOG_CONTENT." >> /dev/stderr

}

main "$@"
