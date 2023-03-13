#!/bin/bash

# Configures environment variables for GitHub Actions.

# Implementation:
# Templates implementing this script must set the required environment variables in the GitHub runner's environment context.
#
# BRANCH_OR_TAG:                    The current branch or tag being tested.
# CACHE_TTL:                        A unique CACHE value that determines the cache's TTL.  (Default strategy: day of the month.)
# NOTIFICATION:                     Consumed by the notification script to provide a clickable link to the workflow run in GitHub.
# PROJECT_NAME:                     The slugified name of the template project.  Should match the GitHub repository name.
# PROJECT_OWNER:                    The GitHub owner of the project.
# TEMPLATE_BRANCH_NAME_BASE:        The name of the templated repository's default branch name.  (Defaults to 'master'.)
# TEMPLATE_BRANCH_NAME_DEVELOPMENT: The name of the templated repository's development branch name.  (Defaults to 'dev'.)
# TEST_PROJECT_NAME:                The slugified name of the template when populated during testing.  Should match any test GitHub repository in use.

# 1:  A boolean value as a string, indicating if TESTING_MODE is active.

# CI only script.

set -eo pipefail

main() {

  PROJECT_NAME="cicd-tools"
  PROJECT_OWNER="niall-byrne"
  TEST_PROJECT_NAME="cicd-tool-box"

  BRANCH_OR_TAG="$(echo "${GITHUB_REF}" | sed -E 's,refs/heads/|refs/tags/,,g')"
  WORKFLOW_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"

  [[ "${1}" == "true" ]] && TESTING_CONTEXT="-tests"

  {
    echo "BRANCH_OR_TAG=${BRANCH_OR_TAG}"
    echo "CACHE_TTL=$(date +%d)"
    echo "NOTIFICATION=${PROJECT_NAME}${TESTING_CONTEXT} [<${WORKFLOW_URL}|${BRANCH_OR_TAG}>]"
    echo "PROJECT_NAME=${PROJECT_NAME}"
    echo "PROJECT_OWNER=${PROJECT_OWNER}"
    echo "TEMPLATE_BRANCH_NAME_BASE=${TEMPLATE_BRANCH_NAME_BASE-master}"
    echo "TEMPLATE_BRANCH_NAME_DEVELOPMENT=${TEMPLATE_BRANCH_NAME_DEVELOPMENT-dev}"
    echo "TEST_PROJECT_NAME=${TEST_PROJECT_NAME}"
  } >> "${GITHUB_ENV}"

}

main "$@"
