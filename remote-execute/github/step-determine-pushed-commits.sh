#!/bin/bash

# Retrieves the range of the commits in a push, and stores the results in GITHUB_ENV as PUSHED_COMMIT_START and PUSHED_COMMIT_REV_RANGE.

# PUSH_FALLBACK_INDEX:      Optionally set fallback behaviour when no changed commits are detected.
# PUSH_FALLBACK_REV_RANGE:  Optionally set fallback behaviour when no changed commits are detected.
# GITHUB_CONTEXT:           The github action context object as an environment variable.
# REMOTE_SCRIPT_NAME:       The script name as set by the cicd-tools remote executor (remote-script.sh).

# CI only script.

set -eo pipefail

export PUSHED_COMMIT_START
export PUSHED_COMMIT_REV_RANGE

PUSH_FALLBACK_INDEX="${PUSH_FALLBACK_INDEX-"$(git rev-list --max-parents=0 HEAD)"}"
PUSH_FALLBACK_REV_RANGE="${PUSH_FALLBACK_REV_RANGE-"HEAD"}"

commits() {

  count() {
    echo "${GITHUB_CONTEXT}" | jq '.event.commits | length'
  }

  create_indexes() {
    PUSHED_COMMIT_START="HEAD~${COMMIT_COUNT}"
    PUSHED_COMMIT_REV_RANGE="${PUSHED_COMMIT_START}..HEAD"

    if [[ "${PUSHED_COMMIT_START}" == "HEAD~0" ]]; then
      fallback_behaviour
    fi

    if ! git rev-parse "${PUSHED_COMMIT_START}" >> /dev/null 2>&1; then
      fallback_behaviour
    fi
  }

  fallback_behaviour() {
    echo "WARNING: unable to determine number of changed commits." >> /dev/stderr
    echo "WARNING: fallback values are being used instead." >> /dev/stderr
    PUSHED_COMMIT_START="${PUSH_FALLBACK_INDEX}"
    PUSHED_COMMIT_REV_RANGE="${PUSH_FALLBACK_REV_RANGE}"
  }

  "$@"

}

main() {

  local COMMIT_COUNT

  echo "DEBUG: -- ${REMOTE_SCRIPT_NAME} --" >> /dev/stderr

  COMMIT_COUNT=$(commits "count")
  echo "DEBUG: GitHub reports ${COMMIT_COUNT} commit(s) have changed." >> /dev/stderr

  commits "create_indexes"

  {
    echo "PUSHED_COMMIT_REV_RANGE=${PUSHED_COMMIT_REV_RANGE}"
    echo "PUSHED_COMMIT_START=${PUSHED_COMMIT_START}"
  } >> "${GITHUB_ENV}"

  echo "DEBUG: the PUSHED_COMMIT_REV_RANGE and PUSHED_COMMIT_START environment variables have been set." >> /dev/stderr

}

main "$@"
