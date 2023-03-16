#!/bin/bash

# Evaluates if the current git reference is a release candidate.

# 1:  The git reference that created the workflow flow.
# REMOTE_SCRIPT_NAME: The script name as set by the cicd-tools remote executor (remote-script.sh).

# CI only script.

set -eo pipefail

is_release_candidate() {
  test "${MATCH}" == "true"
}

main() {

  local MATCH

  echo "DEBUG: -- ${REMOTE_SCRIPT_NAME} --" >> /dev/stderr

  MATCH="false"

  if [[ "${1}" =~ ^refs/tags/[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$ ]] &&
    [[ "${1}" != "refs/tags/0.0.0" ]]; then
    MATCH="true"
  fi

  if is_release_candidate; then
    echo "DEBUG: '${1}' is a release candidate (${MATCH})." >> /dev/stderr
  else
    echo "DEBUG: '${1}' is NOT a release candidate (${MATCH})." >> /dev/stderr
  fi

  echo "release_candidate=${MATCH}" >> "${GITHUB_OUTPUT}"

  echo "DEBUG: this value has now set to the output 'release_candidate' for this job." >> /dev/stderr

}

main "$@"
