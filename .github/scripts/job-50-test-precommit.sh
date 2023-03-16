#!/bin/bash

# Performs tests on the pre-commit hooks.

# Implementation:
# Templates implementing this script will likely also have to customize their .job-50-precommit.yml workflow.
# The API demonstrated here is more for example purposes.

# 1:                  The name of a pre-commit test scenario. (See 'main' below.)
# TEST_PROJECT_NAME:  The name of the rendered test project.

# CI only script.

set -eo pipefail

scenario() {

  local TEMP_FILE

  test_commit_lint_fails() {
    util "git_reset"
    TEMP_FILE=$(util "create_tmp")
    touch "${TEMP_FILE}"
    git stage "${TEMP_FILE}"
    git commit -m 'test - pre-commit: improperly formatted commit' || exit 0
    util "fail"
  }

  test_toml_lint_fails() {
    util "git_reset"
    sed -i.bak 's/authors =/    authors = /g' pyproject.toml
    git stage pyproject.toml
    git commit -m 'test(PRE-COMMIT): fail due to tomll' || exit 0
    util "fail"
  }

  test_toml_lint_passes() {
    util "git_reset"
    sed -i.bak 's/python = "^3.8/python = ">=3.8.0,<4.0/g' pyproject.toml
    git stage pyproject.toml
    git commit -m 'test(PRE-COMMIT): upgrade python without issue'
  }

  test_workflow_lint_fails() {
    util "git_reset"
    find .github -type f -name '*.yml' -exec sed -i.bak 's/ubuntu-latest/non-existent-os/g' {} \;
    git stage .github
    git commit -m 'test(PRE-COMMIT): fail due to actionlint' || exit 0
    util "fail"
  }

  "$@"

}

util() {

  create_tmp() {
    mktemp tmp.XXXXXXX
  }

  fail() {
    echo "This commit should have failed."
    exit 127
  }

  git_reset() {
    git reset HEAD
    git clean -fd
    git checkout .
  }

  "$@"

}

main() {

  pushd "${TEST_PROJECT_NAME}" >> /dev/null
  scenario "${1}"
  popd >> /dev/null

}

main "$@"