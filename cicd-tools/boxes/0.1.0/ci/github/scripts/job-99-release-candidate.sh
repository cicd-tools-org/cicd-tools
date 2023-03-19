#!/bin/bash

# Evaluates if the current git reference is a release candidate.

# 1:  The git reference that created the workflow flow.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

_release_candidate_is_release_candidate() {
  test "${MATCH}" == "true"
}

main() {
  local MATCH

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  MATCH="false"

  if [[ "${1}" =~ ^refs/tags/[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$ ]] &&
    [[ "${1}" != "refs/tags/0.0.0" ]]; then
    MATCH="true"
  fi

  if _release_candidate_is_release_candidate; then
    log "INFO" "'${1}' is a release candidate (${MATCH})."
  else
    log "INFO" "'${1}' is NOT a release candidate (${MATCH})."
  fi

  echo "release_candidate=${MATCH}" >> "${GITHUB_OUTPUT}"

  log "DEBUG" "The value '${MATCH}' has now set to the output 'release_candidate' for this step."
}

main "$@"
