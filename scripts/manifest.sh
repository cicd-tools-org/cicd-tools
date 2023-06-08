#!/bin/bash

# Build and publish the CICD-Tools manifest.

# CICD-Tools Development script.

set -eo pipefail

CICD_TOOLS_BRANCH=$(git branch --show-current)
CICD_TOOLS_KEY_NAME="F07A79647E91E561A786B6D0D9020F7FEE20DBF2"
CICD_TOOLS_DISABLE_SECURITY="false"
CICD_TOOLS_TOOLBOX_PATH="${CICD_TOOLS_TOOLBOX_PATH-"cicd-tools/boxes"}"
CICD_TOOLS_REPOSITORY="cicd-tools-org/cicd-tools"
CICD_TOOLS_REMOTE_HOSTNAME="${CICD_TOOLS_REMOTE_HOSTNAME-"raw.githubusercontent.com"}"
CICD_TOOLS_REMOTE_PREFIX="${CICD_TOOLS_REMOTE_PREFIX-"https://${CICD_TOOLS_REMOTE_HOSTNAME}/${CICD_TOOLS_REPOSITORY}"}"
CICD_TOOLS_SOURCE="${CICD_TOOLS_SOURCE-"${CICD_TOOLS_BRANCH}"}"

MANIFEST_FILE=".cicd-tools/manifest.json"
MANIFEST_REPOSITORY_PATH="../manifest"

# shellcheck source=./.cicd-tools/boxes/bootstrap/libraries/logging.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../.cicd-tools/boxes/bootstrap/libraries/logging.sh"

main() {
  _manifest_args "$@"
}

_manifest_args() {
  while getopts "d" OPTION; do
    case "$OPTION" in
      d)
        CICD_TOOLS_DISABLE_SECURITY="true"
        ;;
      \?)
        _manifest_usage
        ;;
      :)
        _manifest_usage
        ;;
      *)
        _manifest_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))
  _manifest_commands "$@"
}

_manifest_commands() {
  case "${1}" in
    build)
      _manifest_build
      _manifest_sign
      _manifest_security_warning
      ;;
    publish)
      [[ "${CICD_TOOLS_DISABLE_SECURITY}" == "true" ]] && _manifest_usage_publish
      _manifest_publish
      ;;
    *)
      _manifest_usage
      ;;
  esac
}

_manifest_is_security_disabled() {
  test "${CICD_TOOLS_DISABLE_SECURITY}" == "true"
}

_manifest_build() {
  local MANIFEST_CONTENT

  pushd "${CICD_TOOLS_TOOLBOX_PATH}" >> /dev/null
  # shellcheck disable=SC2016
  log "DEBUG" "MANIFEST > Regenerating manifest checksums ..."
  MANIFEST_CONTENT="$(
    # shellcheck disable=SC2035
    sha256sum *.tar.gz |
      jq -R 'split("  ") | { (select(.[0])[1]): select(.[0])[0] }' |
      jq -eMs \
        --arg path "${CICD_TOOLS_TOOLBOX_PATH}" \
        --arg security "${CICD_TOOLS_DISABLE_SECURITY}" \
        --arg sha "${CICD_TOOLS_SOURCE}" \
        --arg source "${CICD_TOOLS_REMOTE_PREFIX}" \
        'add | {
                "disable_security": $security | test("true"),
                "manifest": .,
                "source": $source,
                "toolbox_path": $path,
                "version": $sha
            }'
  )"
  popd >> /dev/null
  log "DEBUG" "MANIFEST > Writing '.cicd-tools/manifest.json' ..."
  echo "${MANIFEST_CONTENT}" > "${MANIFEST_FILE}"
  log "DEBUG" "MANIFEST > Manifest has been written."
  poetry run check-jsonschema \
    .cicd-tools/manifest.json \
    --schemafile .cicd-tools/boxes/bootstrap/schemas/manifest.json
  log "DEBUG" "MANIFEST > Manifest has passed JSON schema validation."
}

_manifest_publish() {
  log "DEBUG" "MANIFEST > Checking out the '${CICD_TOOLS_BRANCH}' branch ..."
  pushd "${MANIFEST_REPOSITORY_PATH}" >> /dev/null
  git checkout "${CICD_TOOLS_BRANCH}"
  popd
  log "DEBUG" "MANIFEST > Copying '${MANIFEST_FILE}.asc' -> '${MANIFEST_REPOSITORY_PATH}' ..."
  cp "${MANIFEST_FILE}.asc" "${MANIFEST_REPOSITORY_PATH}"
  pushd "${MANIFEST_REPOSITORY_PATH}" >> /dev/null
  git stage .
  git commit -m 'build(MANIFEST): automated manifest update'
  log "DEBUG" "MANIFEST > Automated commit made to manifest repository."
  git pushf
  log "INFO" "MANIFEST > Manifest has been published to remote repository."
  popd >> /dev/null
}

_manifest_security_warning() {
  if _manifest_is_security_disabled; then
    log "WARNING" "You have DISABLED security for all remote execution!"
  else
    log "INFO" "Security for remote execution is ENABLED."
  fi
}

_manifest_sign() {
  gpg --yes -u "${CICD_TOOLS_KEY_NAME}" --armor --clearsign "${MANIFEST_FILE}"
  gpg --verify "${MANIFEST_FILE}.asc"
  log "INFO" "MANIFEST > The manifest has been digitally signed."
}

_manifest_usage() {
  log "ERROR" "package.sh -- create a manifest for the current collection of tarballs."
  log "ERROR" "USAGE: manifest.sh -d (OPTIONALLY DISABLE SECURITY) [COMMAND]"
  log "ERROR" "  COMMANDS:"
  log "ERROR" "  build      - Rebuild and sign the manifest from the current tarball collection."
  log "ERROR" "  publish    - Publish the current signed manifest to a remote repository."
  exit 127
}

_manifest_usage_publish() {
  log "ERROR" "The '-d' flag cannot be used with the 'publish' command, as it has no effect."
  exit 127
}

main "$@"
