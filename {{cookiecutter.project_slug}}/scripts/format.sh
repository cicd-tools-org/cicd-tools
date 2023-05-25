#!/bin/bash

# CICD-Tools Format Script Shim.

set -eo pipefail

exec "$(dirname -- "${BASH_SOURCE[0]}")/../.cicd-tools/bin/format.sh" "$@"
