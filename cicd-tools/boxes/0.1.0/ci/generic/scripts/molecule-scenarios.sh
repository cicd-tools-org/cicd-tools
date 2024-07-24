#!/bin/bash

# Creates a JSON array of active molecule scenarios.

# CI only script

set -eo pipefail

# shellcheck source=./cicd-tools/boxes/0.1.0/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../../../libraries/logging.sh"

main() {
  local MOLECULE_SCENARIOS_EXCLUDED_REGEX
  local MOLECULE_SCENARIOS_PATH

  _molecule_scenarios_args "$@"
  _molecule_scenarios_generate
}

_molecule_scenarios_args() {
  local OPTARG
  local OPTIND
  local OPTION

  while getopts "e:p:" OPTION; do
    case "$OPTION" in
      e)
        MOLECULE_SCENARIOS_EXCLUDED_REGEX="${OPTARG}"
        ;;
      p)
        MOLECULE_SCENARIOS_PATH="${OPTARG}"
        ;;
      \?)
        _molecule_scenarios_usage
        ;;
      :)
        _molecule_scenarios_usage
        ;;
      *)
        _molecule_scenarios_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))
  if [[ -z "${MOLECULE_SCENARIOS_EXCLUDED_REGEX}" ]] ||
    [[ -z "${MOLECULE_SCENARIOS_PATH}" ]]; then
    _molecule_scenarios_usage
  fi
}

_molecule_scenarios_generate() {
  local SCENARIOS=()
  pushd "${MOLECULE_SCENARIOS_PATH}" >> /dev/null
  while IFS='' read -r SCENARIO; do SCENARIOS+=("${SCENARIO}"); done < <(
    find . \
      -maxdepth 1 \
      -type d \
      -not -name "." \
      -exec basename {} \; |
      grep -vP "${MOLECULE_SCENARIOS_EXCLUDED_REGEX}"
  )
  jq -cM --null-input "\$ARGS.positional" --args "${SCENARIOS[@]}"
  popd >> /dev/null
}

_molecule_scenarios_usage() {
  log "ERROR" "molecule-scenarios.sh -- discover and filter Molecule scenarios."
  log "ERROR" "USAGE: molecule-scenarios.sh -e [EXCLUSION REGEX] -p [PATH TO SCENARIOS]"
  exit 127
}

main "$@"
