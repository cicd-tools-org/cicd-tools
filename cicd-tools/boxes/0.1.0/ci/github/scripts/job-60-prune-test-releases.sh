#!/bin/bash

# Remove existing releases on the test repository.

# GITHUB_TOKEN:   The token used to authorize the call.
# REMOTE_ORIGIN:  The git remote repository name (organization/repo).
# TEST_PUSH_TAG:  The tag name to clean up.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/environment.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/environment.sh" \
  -m "GITHUB_TOKEN REMOTE_ORIGIN TEST_PUSH_TAG"

main() {
  log "DEBUG" "${BASH_SOURCE[0]} '$*'"
  while _prune_releases_check_releases; do
    sleep 0.5
    log "DEBUG" "RELEASE PRUNING > Deleting test release for tag: '${TEST_PUSH_TAG}' ..."
    gh release delete -R "${REMOTE_ORIGIN}" -y "${TEST_PUSH_TAG}"
  done
}

_prune_releases_check_releases() {
  gh release view -R "${REMOTE_ORIGIN}" "${TEST_PUSH_TAG}"
}

main "$@"
