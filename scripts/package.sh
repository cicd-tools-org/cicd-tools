#!/bin/bash

# Build a manifest, and create a tar bundle for the selected version.

# CICD-Tools Development script.

set -eo pipefail

CICD_TOOLS_BUNDLE_PATH="${CICD_TOOLS_BUNDLE_PATH-"cicd-tools/boxes"}"
CICD_TOOLS_BUNDLE_TIME="2023-01-01"

main() {
  local CICD_TOOLS_TOOLBOX_VERSION

  _package_args "$@"
  _package_tarball

}

_package_args() {
  local OPTARG
  local OPTIND
  local OPTION

  while getopts "b:d" OPTION; do
    case "$OPTION" in
      b)
        CICD_TOOLS_TOOLBOX_VERSION="${OPTARG}"
        ;;
      \?)
        _package_usage
        ;;
      :)
        _package_usage
        ;;
      *)
        _package_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ -z "${CICD_TOOLS_TOOLBOX_VERSION}" ]]; then
    _package_usage
  fi
}

_package_import_support_libraries() {
  # 1:  The toolbox version to use during import.

  # shellcheck source=/dev/null
  source "$(dirname -- "${BASH_SOURCE[0]}")/../cicd-tools/boxes/${1}/libraries/logging.sh"
}

_package_tarball() {
  pushd "${CICD_TOOLS_BUNDLE_PATH}" >> /dev/null
  log "DEBUG" "PACKAGE > Packaging version ${CICD_TOOLS_TOOLBOX_VERSION} ..."
  gtar c --mtime="${CICD_TOOLS_BUNDLE_TIME}" -v "${CICD_TOOLS_TOOLBOX_VERSION}" | gzip -n > "${CICD_TOOLS_TOOLBOX_VERSION}.tar.gz"
  log "DEBUG" "PACKAGE > Tarball has been generated."
}

_package_usage() {
  log "ERROR" "package.sh -- create a tarball for a specific toolbox version."
  log "ERROR" "USAGE: package.sh -b [TOOLBOX VERSION]"
  exit 127
}

_package_import_support_libraries "0.1.0"

main "$@"
