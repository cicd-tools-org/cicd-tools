#!/bin/bash

# Generates a changelog for the specified tag and stores it in the GITHUB_ENV as CHANGELOG_CONTENT.

# 1:  The new git tag the changelog is being generated for.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

main() {

  local CHANGE_LOG_CONTENT

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  log "DEBUG" "Removing local release tag ..."
  _changelog_remove_commit_tag "${1}"

  log "DEBUG" "Generating changelog ..."
  CHANGE_LOG_CONTENT="$(_changelog_generate "${1}")"

  log "INFO" "Changelog has been generated."

  echo "${CHANGE_LOG_CONTENT}" >> /dev/stderr

  {
    echo "CHANGE_LOG_CONTENT<<EOF"
    echo "${CHANGE_LOG_CONTENT}"
    echo "EOF"
  } >> "${GITHUB_ENV}"

  log "DEBUG" "This value has been stored to the GITHUB_ENV as CHANGE_LOG_CONTENT."

}

_changelog_generate() {
  npx -q "conventional-changelog-cli@^3.0.0" \
    --config .cicd-tools/configuration/changelog.json \
    -r 1
}

_changelog_remove_commit_tag() {
  # 1:  The new git tag the changelog is being generated for.
  git tag --delete "${1}"
}

main "$@"
