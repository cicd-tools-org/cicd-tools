#!/bin/bash

# Library for CICD-Tools installers.

set -eo pipefail

CICD_TOOLS_TOOLBOX_ROOT_PATH="cicd-tools/boxes"

get_latest_toolbox_version() {
  find "${CICD_TOOLS_TOOLBOX_ROOT_PATH}"/* \
    -iname '[0-9].[0-9].[0-9]' \
    -type d \
    -maxdepth 0 \
    -exec basename {} \; |
    sort -V |
    tail -n 1
}
