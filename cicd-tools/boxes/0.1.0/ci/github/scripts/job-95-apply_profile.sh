#!/bin/bash

# Applies a profile to a CI machine with Mac Maker.

# MAC_MAKER_ARCHITECTURE:   The architecture to use (ie. x86_64).
# MAC_MAKER_VERSION:        The Version of Mac Maker to use.
# MAC_MAKER_OS_VERSION:     The Mac OS version to use (ie. 10.15).
# PROJECT_OWNER:            The Github Owner of the Mac Maker project.
# TEST_PROFILE_ORIGIN:      Identifies the test repository as: owner/repository.

# CI only script.

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/environment.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/environment.sh" \
  -m "MAC_MAKER_ARCHITECTURE MAC_MAKER_VERSION MAC_MAKER_OS_VERSION PROJECT_OWNER TEST_PROFILE_ORIGIN"

main() {

  log "DEBUG" "${BASH_SOURCE[0]} '$*'"

  _mac_maker_apply__fetch_binary "$@"
  _mac_maker_apply__apply_profile "$@"

}

_mac_maker_apply__apply_profile() {

  export ANSIBLE_BECOME_PASSWORD
  export HOME
  export USER

  ANSIBLE_BECOME_PASSWORD="not needed"
  USER="$(id -un)"
  HOME="/Users/${USER}"

  log "DEBUG" "MAC MAKER > Applying Remote Profile ..."

  ./mac_maker apply github "https://github.com/${TEST_PROFILE_ORIGIN}" --branch main

  log "INFO" "MAC MAKER > Profile applied successfully."

}

_mac_maker_apply__fetch_binary() {

  local RELEASE_FOLDER
  local RELEASE_URL

  RELEASE_URL="https://github.com/${PROJECT_OWNER}/mac_maker/releases/download/v${MAC_MAKER_VERSION}/mac_maker_${MAC_MAKER_OS_VERSION}_${MAC_MAKER_ARCHITECTURE}_v${MAC_MAKER_VERSION}.tar.gz"
  RELEASE_FOLDER="mac_maker_${MAC_MAKER_OS_VERSION}_${MAC_MAKER_ARCHITECTURE}_v${MAC_MAKER_VERSION}"

  log "DEBUG" "MAC MAKER > Require binary version: '${MAC_MAKER_VERSION}'."
  log "DEBUG" "MAC MAKER > Require architecture: '${MAC_MAKER_ARCHITECTURE}'."
  log "DEBUG" "MAC MAKER > Require os: '${MAC_MAKER_OS_VERSION}'."
  log "DEBUG" "MAC MAKER > Downloading: '${RELEASE_URL}' ..."

  curl -L "${RELEASE_URL}" > binary.tar.gz
  tar xvzf binary.tar.gz
  mv "${RELEASE_FOLDER}/mac_maker" .

  log "INFO" "MAC MAKER > Downloaded and unpacked: '${RELEASE_FOLDER}'."

}

main "$@"
