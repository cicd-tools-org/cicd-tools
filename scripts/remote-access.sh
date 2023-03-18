#!/bin/bash

# Configure secure access to remote cicd-tools.

# 1:                Optionally disable remote execution security by typing 'disable-security'.
# CICD_TOOLS_SHA:   Optionally set the remote Git SHA that will be the source for resources.
# REMOTE_HOSTNAME:  Optionally set the remote hostname where the scripts are downloaded from.
# REMOTE_PREFIX:    Optionally set the entire remote prefix (including hostname and protocol).
# ROOT_SCRIPT_PATH: Optionally set the path under which all remotely executable scripts are kept.

# Development only script.

set -eo pipefail

CICD_TOOLS_REPOSITORY="niall-byrne/cicd-tools"
SYMLINKS=("manifest.json" "remote-script.sh")

DISABLE_SECURITY="false"
CICD_TOOLS_SHA="${CICD_TOOLS_SHA-"master"}"
REMOTE_HOSTNAME="${REMOTE_HOSTNAME-"raw.githubusercontent.com"}"
REMOTE_PREFIX="${REMOTE_PREFIX-"https://${REMOTE_HOSTNAME}/${CICD_TOOLS_REPOSITORY}"}"
ROOT_SCRIPT_PATH="${ROOT_SCRIPT_PATH-"remote-execute"}"

args() {

  parse() {
    if [[ "${1}" == "disable-security" ]]; then
      DISABLE_SECURITY="true"
    fi
  }

  "$@"

}

cicd_tools() {

  is_security_disabled() {
    test "${DISABLE_SECURITY}" == "true"
  }

  write_manifest() {
    sha256sum remote-execute/**/* |
      jq -R 'split("  ") | { (select(.[0])[1]): select(.[0])[0] }' |
      jq -s --arg sha "${CICD_TOOLS_SHA}" --arg source "${REMOTE_PREFIX}" --arg security "${DISABLE_SECURITY}" \
        'add | {
              "cicd-tools-sha": $sha,
              "cicd-tools-source": $source,
              "disable-security": $security | test("true"),
              "manifest": .
          }' |
      sed "s,${ROOT_SCRIPT_PATH},${REMOTE_PREFIX}/${CICD_TOOLS_SHA}/${ROOT_SCRIPT_PATH},g" \
        > .github/cicd-tools/manifest.json
  }

  write_symlinks() {
    pushd "{{cookiecutter.project_slug}}/.github/cicd-tools" >> /dev/null
    for SYMLINK in "${SYMLINKS[@]}"; do
      ln -sf "../../../.github/cicd-tools/${SYMLINK}" "${SYMLINK}"
    done
    popd >> /dev/null
  }

  "$@"

}

main() {

  args "parse" "$@"

  cicd_tools "write_manifest"
  cicd_tools "write_symlinks"

  echo "INFO: regenerated cicd-tools 'manifest.json' and symlinks."

  if cicd_tools "is_security_disabled"; then
    echo "WARNING: you have DISABLED security for all remote execution!"
  else
    echo "INFO: security for remote execution is ENABLED."
  fi

}

main "$@"
