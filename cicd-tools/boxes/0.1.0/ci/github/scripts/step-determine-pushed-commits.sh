#!/bin/bash

# Retrieves the range of the commits in a push, and stores the results in GITHUB_ENV as PUSHED_COMMIT_START and PUSHED_COMMIT_REV_RANGE.

# PUSH_FALLBACK_INDEX:      Optionally set fallback behaviour when no changed commits are detected.
# PUSH_FALLBACK_REV_RANGE:  Optionally set fallback behaviour when no changed commits are detected.
# GITHUB_CONTEXT:           The github action context object as an environment variable.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/environment.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/environment.sh" \
  -m "GITHUB_CONTEXT"

PUSH_FALLBACK_INDEX="${PUSH_FALLBACK_INDEX-"$(git rev-list --max-parents=0 HEAD)"}"
PUSH_FALLBACK_REV_RANGE="${PUSH_FALLBACK_REV_RANGE-"HEAD"}"

main() {
  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  local COMMIT_COUNT

  COMMIT_COUNT=$(_commits_count)
  log "DEBUG" "GitHub reports ${COMMIT_COUNT} commit(s) have changed."
  _commits_create_indexes

  {
    echo "PUSHED_COMMIT_REV_RANGE=${PUSHED_COMMIT_REV_RANGE}"
    echo "PUSHED_COMMIT_START=${PUSHED_COMMIT_START}"
  } >> "${GITHUB_ENV}"

  log "INFO" "The PUSHED_COMMIT_REV_RANGE and PUSHED_COMMIT_START environment variables have been set."
}

_commits_count() {
  echo "${GITHUB_CONTEXT}" | jq '.event.commits | length'
}

_commits_create_indexes() {
  PUSHED_COMMIT_START="HEAD~${COMMIT_COUNT}"
  PUSHED_COMMIT_REV_RANGE="${PUSHED_COMMIT_START}..HEAD"

  if [[ "${PUSHED_COMMIT_START}" == "HEAD~0" ]]; then
    _commits_fallback_behaviour
  fi

  if ! git rev-parse "${PUSHED_COMMIT_START}" >> /dev/null 2>&1; then
    _commits_fallback_behaviour
  fi
}

_commits_fallback_behaviour() {
  log "WARNING" "Unable to determine number of changed commits."
  log "WARNING" "Fallback values are being used instead."
  PUSHED_COMMIT_START="${PUSH_FALLBACK_INDEX}"
  PUSHED_COMMIT_REV_RANGE="${PUSH_FALLBACK_REV_RANGE}"
}

main "$@"
