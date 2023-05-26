#!/bin/bash

# Runs actionlint.

# pre-commit script.

set -eo pipefail

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/container.sh"

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/logging.sh"

main() {
  log "INFO" "PRE-COMMIT > actionlint"
  container "run" actionlint -config-file /mnt/.cicd-tools/configuration/actionlint.yaml
}

main "$@"
