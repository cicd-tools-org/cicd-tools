#!/bin/bash

# Interface to code formatters inside the CICD-Tools container.
# Requires the docker CLI binary: https://www.docker.com/

# CICD-Tools script.

set -eo pipefail

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/container.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../boxes/bootstrap/libraries/container.sh"

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../boxes/bootstrap/libraries/logging.sh"

main() {
  _fmt "$@"
  log "INFO" "TOOLING CONTAINER > Command completed successfully."
}

_fmt() {

  local COMMAND
  local PREFIX

  _fmt_shell() {
    local SHFMT_OPTIONS

    if cicd_tools "is_template"; then
      SHFMT_OPTIONS="$(cicd_tools "config_value" "cookiecutter.json" "_CONFIG_DEFAULT_SHFMT_OPTIONS")"
    else
      SHFMT_OPTIONS="$(cicd_tools "config_value" ".cicd-tools/configuration/cicd-tools.json" "SHFMT_OPTIONS")"
    fi

    log "INFO" "TOOLING CONTAINER > 'shfmt -w ${SHFMT_OPTIONS} $*'"

    # shellcheck disable=SC2046
    container "run" \
      $(xargs <<< "shfmt -w ${SHFMT_OPTIONS} $*")
  }

  _fmt_toml() {
    local TOML_FILE

    for TOML_FILE in "$@"; do

      log "INFO" "TOOLING CONTAINER > tomll ${TOML_FILE}"

      docker run -i --rm -v "$(pwd)":/mnt "$(container "get_image")" tomll /mnt/"${TOML_FILE}"

    done
  }

  _fmt_usage() {
    log "ERROR" "format.sh -- interface to the CICD-Tools code formatters."
    log "ERROR" "USAGE: format.sh [COMMAND] [FILES]"
    log "ERROR" "  COMMANDS:"
    log "ERROR" "  toml   - Format the specified TOML file."
    log "ERROR" "  shell  - Format the specified shell file."
    exit 127
  }

  PREFIX="_fmt"
  COMMAND="${PREFIX}_${1}"
  if [[ $(type -t "${COMMAND}") == function ]]; then
    shift
    "${COMMAND}" "$@"
  else
    "${PREFIX}_usage"
  fi

}

main "$@"
