#!/bin/bash

# Runs tomll on the specified files and then runs diff to detect changes.

# 1:  The Docker image and tag to use.
# @:  An array of toml files to lint.

# pre-commit script.

set -eo pipefail

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/container.sh"

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/logging.sh"

main() {
  for TOML_FILE in "$@"; do

    log "INFO" "PRE-COMMIT > tomll < ${TOML_FILE}"

    diff "${TOML_FILE}" <(docker run -i --rm "$(container "get_image")" tomll < "${TOML_FILE}")

  done
}

main "$@"
