#!/bin/bash

# Performs pushes against the test repository to trigger rendered workflows.

# 1:                  The local branch you wish to push to a remote branch of the same name.
# 2:                  Optionally define a remote tag you'd like to push to.
# REMOTE_TOKEN:       The auth token that will be used to push.
# REMOTE_ORIGIN:      The remote repository we're pushing to. (format: "owner/repository")
# TEST_PROJECT_PATH:  The relative path to the local repository we're pushing from.

# CI only script.

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/environment.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/environment.sh" \
  -m "REMOTE_TOKEN REMOTE_ORIGIN TEST_PROJECT_PATH"

set -eo pipefail

main() {
  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  pushd "${TEST_PROJECT_PATH}"
  push "local_checkout" "${1}"
  if [[ -z "${2}" ]]; then
    push "local_test_commit"
    push "remote_push" "${1}"
  else
    push "remote_push_tags" "${2}"
  fi
  popd
}

push() {
  local COMMAND
  local PREFIX

  _push_get_remote() {
    echo "https://${REMOTE_TOKEN}@github.com/${REMOTE_ORIGIN}.git"
  }

  _push_local_checkout() {
    # 1:  The local branch you are pushing from.

    log "DEBUG" "REMOTE PUSH > Checking out local branch: '${1}' ..."
    git checkout "${1}"
  }

  _push_local_test_commit() {
    log "DEBUG" "REMOTE PUSH > Adding a simple test commit."
    echo "test commit" > test_file.txt
    git add test_file.txt
    git commit -m 'feat(TEST_FILE): add test file'
  }

  _push_remote_push() {
    # 1:  The remote branch you are pushing to.

    log "DEBUG" "REMOTE PUSH > Force pushing to remote on branch: '${1}' ..."
    git push "$(push "get_remote")" HEAD:"${1}" --force

    log "INFO" "REMOTE PUSH > Successfully pushed remote branch '${1}'."
  }

  _push_remote_push_tags() {
    # 1:  The tag you'd like to push

    set +e
    log "DEBUG" "REMOTE PUSH > Attempting to delete existing remote tag: '${1}' ..."
    git push --delete "$(push "get_remote")" "${1}"
    set -e

    log "DEBUG" "REMOTE PUSH > Pushing to remote tag: '${1}' ..."
    git tag "${1}"
    git push "$(push "get_remote")" --tags

    log "INFO" "REMOTE PUSH > Successfully pushed remote tag '${1}'."
  }

  _push_usage() {
    log "ERROR" "REMOTE PUSH > Unknown command '${COMMAND}' ..."
    exit 127
  }

  PREFIX="_push"
  COMMAND="${PREFIX}_${1}"
  if [[ $(type -t "${COMMAND}") == function ]]; then
    shift
    "${COMMAND}" "$@"
  else
    "${PREFIX}_usage"
  fi
}

main "$@"
