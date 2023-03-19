#!/bin/bash

# Builds the dockerfile as needed to run hooks.

# pre-commit script.

set -eo pipefail

PRECOMMIT_DOCKER_IMAGE="ghcr.io/niall-byrne/cicd-tools"
PRECOMMIT_DOCKER_TAG="master"

docker_interface() {

  configuration() {
    if ! is_pulled; then
      docker pull -q "$(get_image)"
    fi
    docker run -i -v "$(pwd)/cookiecutter.json:/cookiecutter.json:ro" "$(get_image)" /bin/jq -erM ".${1}" /cookiecutter.json
  }

  get_image() {
    echo "${PRECOMMIT_DOCKER_IMAGE}:${PRECOMMIT_DOCKER_TAG}"
  }

  is_pulled() {
    [[ "$(docker images -q "${PRECOMMIT_DOCKER_IMAGE}")" != "" ]]
  }

  is_tooling() {
    [[ -f "cookiecutter.json" ]]
  }

  "$@"

}
