#!/bin/bash

# Runs lint-makefile on each received Makefile path.

# @:  An array of Makefiles to run lint-makefile on.

# pre-commit script.

set -eo pipefail

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/tools.sh"

export PYTHONPATH

main() {
  local TARGET
  local TARGET_PATHS=${*-"."}

  for TARGET in ${TARGET_PATHS}; do
    log "DEBUG" "PRE-COMMIT > Executing 'lint_makefile' on '${TARGET}' ..."
    PYTHONPATH="$(dirname -- "${BASH_SOURCE[0]}")"
    python -m "lint_makefile" -f "${TARGET}"
  done
}

main "$@"
