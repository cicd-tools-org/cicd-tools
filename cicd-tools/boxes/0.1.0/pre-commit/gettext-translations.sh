#!/bin/bash

# Runs gettext utilities to manage translation related project tasks.
# Requires the gettext binary: https://www.gnu.org/software/gettext/

# pre-commit script.

set -eo pipefail

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/environment.sh"

# shellcheck source=/dev/null
source "$(dirname -- "${BASH_SOURCE[0]}")/../libraries/logging.sh"

GETTEXT_TRANSLATIONS_SED_PATTERN='s,^\"Content-Type: text/plain; charset=CHARSET\\n\"$,\"Content-Type: text/plain; charset=UTF-8\\n\",g'
GETTEXT_TRANSLATIONS_EXAMPLE_LANGUAGES_CODES_URL="https://www.gnu.org/software/gettext/manual/html_node/Usual-Language-Codes.html"

_gettext_translations_args() {
  local GETTEXT_TRANSLATIONS_COMMAND
  local OPTARG
  local OPTIND
  local OPTION

  if [[ -z "${1}" ]]; then
    _gettext_translations_usage
  fi

  OPTIND=1
  GETTEXT_TRANSLATIONS_COMMAND="${1}"
  shift

  while getopts "b:c:e:i:m:p:r:s:u" OPTION; do
    case "${OPTION}" in
      b)
        GETTEXT_TRANSLATIONS_EXTRACTION_FILE_NAME="${OPTARG}"
        ;;
      c)
        GETTEXT_TRANSLATIONS_CODE_BASE_PATH="${OPTARG}"
        ;;
      e)
        GETTEXT_TRANSLATIONS_EMAIL_ADDRESS="${OPTARG}"
        ;;
      i)
        GETTEXT_TRANSLATIONS_DOCKER_IMAGE="${OPTARG}"
        ;;
      m)
        GETTEXT_TRANSLATIONS_EMPTY_MESSAGE_MATCH="${OPTARG}"
        ;;
      p)
        GETTEXT_TRANSLATIONS_BASE_PATH="${OPTARG}"
        ;;
      r)
        GETTEXT_TRANSLATIONS_CODE_BASE_REGEX="${OPTARG}"
        ;;
      s)
        GETTEXT_TRANSLATIONS_LANGUAGES_BEING_SKIPPED+=("${OPTARG}")
        ;;
      u)
        GETTEXT_TRANSLATIONS_UTF8_OVERRIDE="1"
        ;;
      \?)
        _gettext_translations_usage
        ;;
      :)
        _gettext_translations_usage
        ;;
      *)
        _gettext_translations_usage
        ;;
    esac
  done
  shift $((OPTIND - 1))

  case "${GETTEXT_TRANSLATIONS_COMMAND}" in
    add)
      if [[ -z "${GETTEXT_TRANSLATIONS_BASE_PATH}" ]]; then
        _gettext_translations_usage_title
        _gettext_translations_usage_add
        _gettext_translations_usage_terminate
      fi
      gettext_translations_add
      ;;
    compile)
      if [[ -z "${GETTEXT_TRANSLATIONS_BASE_PATH}" ]]; then
        _gettext_translations_usage_title
        _gettext_translations_usage_compile
        _gettext_translations_usage_terminate
      fi
      gettext_translations_compile
      ;;
    missing)
      if [[ -z "${GETTEXT_TRANSLATIONS_BASE_PATH}" ]] ||
        [[ -z "${GETTEXT_TRANSLATIONS_EMPTY_MESSAGE_MATCH}" ]]; then
        _gettext_translations_usage_title
        _gettext_translations_usage_missing
        _gettext_translations_usage_terminate
      fi
      gettext_translations_missing
      ;;
    update)
      if [[ -z "${GETTEXT_TRANSLATIONS_BASE_PATH}" ]] ||
        [[ -z "${GETTEXT_TRANSLATIONS_CODE_BASE_PATH}" ]] ||
        [[ -z "${GETTEXT_TRANSLATIONS_CODE_BASE_REGEX}" ]] ||
        [[ -z "${GETTEXT_TRANSLATIONS_EMAIL_ADDRESS}" ]] ||
        [[ -z "${GETTEXT_TRANSLATIONS_EXTRACTION_FILE_NAME}" ]]; then
        _gettext_translations_usage_title
        _gettext_translations_usage_update
        _gettext_translations_usage_terminate
      fi
      gettext_translations_update
      ;;
    :)
      _gettext_translations_usage

      ;;
    *)
      _gettext_translations_usage
      ;;
  esac
}

_gettext_translations_check_existing_base_path() {
  if [[ ! -d "${GETTEXT_TRANSLATIONS_BASE_PATH}" ]]; then
    log "ERROR" "The specified path '${GETTEXT_TRANSLATIONS_BASE_PATH}' does not exist."
    return 127
  fi
}

_gettext_translations_check_existing_po_files() {
  # $1: LANGUAGE NAME
  if ! ls -la "${GETTEXT_TRANSLATIONS_BASE_PATH}/${1}/LC_MESSAGES/"*.po 1> /dev/null 2>&1; then
    log "ERROR" "There are no po files in '${GETTEXT_TRANSLATIONS_BASE_PATH}/${1}/LC_MESSAGES'."
    return 127
  fi

}

_gettext_translations_check_existing_pot_files() {
  if ! ls -la "${GETTEXT_TRANSLATIONS_BASE_PATH}/"*.pot 1> /dev/null 2>&1; then
    log "ERROR" "There are no pot files in '${GETTEXT_TRANSLATIONS_BASE_PATH}'."
    return 127
  fi
}

_gettext_translations_generate_or_update_pot_file() {
  local GETTEXT_TRANSLATIONS_EXTRACTED_TEMP_FILE
  local GETTEXT_TRANSLATIONS_SOURCE_FILE
  local GETTEXT_TRANSLATIONS_SOURCE_FILES
  local GETTEXT_TRANSLATIONS_TMP_DIR
  local GETTEXT_TRANSLATIONS_UPDATED_TEMP_FILE

  GETTEXT_TRANSLATIONS_SOURCE_FILES=()

  if [[ ! -d "${GETTEXT_TRANSLATIONS_CODE_BASE_PATH}" ]]; then
    log "ERROR" "The specified code base path '${GETTEXT_TRANSLATIONS_CODE_BASE_PATH}' does not exist."
    return 127
  fi

  GETTEXT_TRANSLATIONS_TMP_DIR="$(mktemp -d "./tmp.XXXXXXXXX")"
  GETTEXT_TRANSLATIONS_EXTRACTED_TEMP_FILE="${GETTEXT_TRANSLATIONS_TMP_DIR}/extracted.pot"
  GETTEXT_TRANSLATIONS_UPDATED_TEMP_FILE="${GETTEXT_TRANSLATIONS_TMP_DIR}/updated.pot"

  # shellcheck disable=SC2064
  trap "rm -rf \"${GETTEXT_TRANSLATIONS_TMP_DIR}\"" EXIT

  log "INFO" "Extracting strings from all '${GETTEXT_TRANSLATIONS_CODE_BASE_REGEX}' files in '${GETTEXT_TRANSLATIONS_CODE_BASE_PATH}' ..."

  while IFS= read -r -d $'\0' GETTEXT_TRANSLATIONS_SOURCE_FILE; do
    GETTEXT_TRANSLATIONS_SOURCE_FILES+=("${GETTEXT_TRANSLATIONS_SOURCE_FILE}")
  done < <(
    find \
      "${GETTEXT_TRANSLATIONS_CODE_BASE_PATH}" \
      -iname "${GETTEXT_TRANSLATIONS_CODE_BASE_REGEX}" \
      -print0
  )

  _gettext_translations_run_binary xgettext \
    --force-po \
    --from-code=UTF-8 \
    --msgid-bugs-address="${GETTEXT_TRANSLATIONS_EMAIL_ADDRESS}" \
    -d "${GETTEXT_TRANSLATIONS_EXTRACTION_FILE_NAME}" \
    -o "${GETTEXT_TRANSLATIONS_EXTRACTED_TEMP_FILE}" \
    "${GETTEXT_TRANSLATIONS_SOURCE_FILES[@]}"

  if [[ ! -f "${GETTEXT_TRANSLATIONS_BASE_POT_FILE}" ]]; then
    log "INFO" "Writing extract strings to '${GETTEXT_TRANSLATIONS_BASE_POT_FILE}' ..."
    _gettext_translations_write_base_pot_file "${GETTEXT_TRANSLATIONS_EXTRACTED_TEMP_FILE}"
    return
  fi

  log "INFO" "Merging changes to '${GETTEXT_TRANSLATIONS_BASE_POT_FILE}' from '${GETTEXT_TRANSLATIONS_EXTRACTED_TEMP_FILE}' ..."

  _gettext_translations_run_binary msgmerge \
    -q \
    -N \
    "${GETTEXT_TRANSLATIONS_BASE_POT_FILE}" \
    "${GETTEXT_TRANSLATIONS_EXTRACTED_TEMP_FILE}" \
    -o "${GETTEXT_TRANSLATIONS_UPDATED_TEMP_FILE}"

  _gettext_translations_write_base_pot_file "${GETTEXT_TRANSLATIONS_UPDATED_TEMP_FILE}"
}

_gettext_translations_identify_existing_languages() {
  local GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH

  while IFS= read -r -d '' GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH; do
    if ! ls -la "${GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH}/LC_MESSAGES/"*.po 1> /dev/null 2>&1; then
      log "WARNING" "Skipping '${GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH}' as there are no .po files. "
    else
      GETTEXT_TRANSLATIONS_LANGUAGES+=("$(basename "${GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH#*/}")")
    fi
  done < <(find "${GETTEXT_TRANSLATIONS_BASE_PATH}" -maxdepth 1 -mindepth 1 -type d -print0)

  if ! ((${#GETTEXT_TRANSLATIONS_LANGUAGES[@]})); then
    log "ERROR" "No existing translations were found."
    return 127
  fi
}

_gettext_translations_run_binary() {
  # $1 The binary to run
  # $@ The arguments to pass to that binary
  local GETTEXT_TRANSLATIONS_BINARY

  GETTEXT_TRANSLATIONS_BINARY="${1}"
  shift

  log "DEBUG" "  Container Image: '${GETTEXT_TRANSLATIONS_DOCKER_IMAGE}'"
  log "DEBUG" "  Container Binary: '${GETTEXT_TRANSLATIONS_BINARY}'"
  log "DEBUG" "  Container Arguments: '$*'"

  docker run \
    --rm \
    -t \
    -v "$(git rev-parse --show-toplevel):/mnt" \
    "${GETTEXT_TRANSLATIONS_DOCKER_IMAGE}" \
    "${GETTEXT_TRANSLATIONS_BINARY}" \
    "$@"
}

_gettext_translations_write_base_pot_file() {
  # $1: The source file

  if [[ -n "${GETTEXT_TRANSLATIONS_UTF8_OVERRIDE}" ]]; then
    sed \
      "${GETTEXT_TRANSLATIONS_SED_PATTERN}" \
      "${1}" \
      > "${GETTEXT_TRANSLATIONS_BASE_POT_FILE}"
  else
    cat "${1}" \
      > "${GETTEXT_TRANSLATIONS_BASE_POT_FILE}"
  fi

  # Revert changes that only modify the POT-Creation-Date field only.
  if git diff --quiet --exit-code -I '(^"POT-Creation-Date:)' "${GETTEXT_TRANSLATIONS_BASE_POT_FILE}"; then
    log "WARNING" 'Reverting an empty update with changes to the "POT-Creation-Date" field ...'
    git checkout "${GETTEXT_TRANSLATIONS_BASE_POT_FILE}"
  fi
}

_gettext_translations_usage() {
  _gettext_translations_usage_title
  _gettext_translations_usage_add
  _gettext_translations_usage_compile
  _gettext_translations_usage_missing
  _gettext_translations_usage_update
  _gettext_translations_usage_terminate
}

_gettext_translations_usage_add() {
  log "ERROR" "--------------------------------------------------------------------------------"
  log "ERROR" "add            < add a new language to the project."
  log "ERROR" "translations.sh add"
  log "ERROR" "               -i [CONTAINER IMAGE WITH GETTEXT BINARIES]"
  log "ERROR" "               -p [BASE FILE PATH ('locales' folder or similar)]"
}

_gettext_translations_usage_compile() {
  log "ERROR" "--------------------------------------------------------------------------------"
  log "ERROR" "compile        < compile or recompile .mo files"
  log "ERROR" "translations.sh compile"
  log "ERROR" "               -i [CONTAINER IMAGE WITH GETTEXT BINARIES]"
  log "ERROR" "               -p [BASE FILE PATH ('locales' folder or similar)]"
}

_gettext_translations_usage_missing() {
  log "ERROR" "--------------------------------------------------------------------------------"
  log "ERROR" "missing        < search for untranslated strings"
  log "ERROR" "translations.sh missing"
  log "ERROR" "               -i [CONTAINER IMAGE WITH GETTEXT BINARIES]"
  log "ERROR" "               -p [BASE FILE PATH ('locales' folder or similar)]"
  log "ERROR" "               -m [EMPTY MESSAGE MATCH STRING (defaults to 'msgstr ""')]"
  log "ERROR" "               -s [LANGUAGES TO SKIP (use multiple times as needed)]"
}

_gettext_translations_usage_terminate() {
  exit 127
}

_gettext_translations_usage_title() {
  log "ERROR" "translations.sh -- manage translation tasks with gnu gettext."
}

_gettext_translations_usage_update() {
  log "ERROR" "--------------------------------------------------------------------------------"
  log "ERROR" "update         < extract strings from the code base and update all files."
  log "ERROR" "translations.sh update"
  log "ERROR" "               -i [CONTAINER IMAGE WITH GETTEXT BINARIES]"
  log "ERROR" "               -p [BASE FILE PATH ('locales' folder or similar)]"
  log "ERROR" "               -b [BASE FILE NAME (defaults to 'base')]"
  log "ERROR" "               -c [CODE BASE PATH (root folder of source code)]"
  log "ERROR" "               -e [CONTACT EMAIL (written to .po and .pot files)]"
  log "ERROR" "               -r [CODE BASE REGEX (defaults to '*.py')]"
  log "ERROR" "               -u (optionally set the CHARSET to UTF-8)"
}

gettext_translations_add() {
  local GETTEXT_TRANSLATIONS_LANGUAGE
  local GETTEXT_TRANSLATIONS_NEW_LANGUAGE_PATH
  local GETTEXT_TRANSLATIONS_NEW_PO_FILE_NAME
  local GETTEXT_TRANSLATIONS_POT_FILE

  environment -m "GETTEXT_TRANSLATIONS_DOCKER_IMAGE"

  # shellcheck disable=SC2128
  if [[ -z "${GETTEXT_TRANSLATIONS_LANGUAGES}" ]]; then
    log "ERROR" "You must set the environment variable 'GETTEXT_TRANSLATIONS_LANGUAGES' to add new languages."
    log "ERROR" "Please assign a space separated list of new language codes from:"
    log "ERROR" "  ${GETTEXT_TRANSLATIONS_EXAMPLE_LANGUAGES_CODES_URL}"
    log "ERROR" "For example:"
    log "ERROR" "  export GETTEXT_TRANSLATIONS_LANGUAGES='en de fr ko'"
    return 127
  fi

  if ! _gettext_translations_check_existing_base_path ||
    ! _gettext_translations_check_existing_pot_files; then
    return 127
  fi

  while read -r -d ' ' GETTEXT_TRANSLATIONS_LANGUAGE; do
    if [[ -z "${GETTEXT_TRANSLATIONS_LANGUAGE}" ]]; then
      break
    fi

    echo ""

    log "INFO" "Adding '${GETTEXT_TRANSLATIONS_LANGUAGE}' ..."
    GETTEXT_TRANSLATIONS_NEW_LANGUAGE_PATH="${GETTEXT_TRANSLATIONS_BASE_PATH}/${GETTEXT_TRANSLATIONS_LANGUAGE}/LC_MESSAGES"

    log "INFO" "  Creating '${GETTEXT_TRANSLATIONS_NEW_LANGUAGE_PATH}' ..."
    if [[ -d "${GETTEXT_TRANSLATIONS_NEW_LANGUAGE_PATH}" ]]; then
      log "WARNING" "Found an existing path for this language!"
      log "WARNING" "Skipping to avoid overwriting content."
      continue
    fi
    mkdir -p "${GETTEXT_TRANSLATIONS_NEW_LANGUAGE_PATH}"

    for GETTEXT_TRANSLATIONS_POT_FILE in "${GETTEXT_TRANSLATIONS_BASE_PATH}"/*.pot; do
      GETTEXT_TRANSLATIONS_NEW_PO_FILE_NAME="${GETTEXT_TRANSLATIONS_NEW_LANGUAGE_PATH}/$(basename "${GETTEXT_TRANSLATIONS_POT_FILE}" ".pot").po"

      log "INFO" "  Using '${GETTEXT_TRANSLATIONS_POT_FILE}' to create '${GETTEXT_TRANSLATIONS_NEW_PO_FILE_NAME}' ..."
      cp -rp \
        "${GETTEXT_TRANSLATIONS_POT_FILE}" \
        "${GETTEXT_TRANSLATIONS_NEW_PO_FILE_NAME}"
      _gettext_translations_run_binary msgmerge \
        -q \
        --force-po \
        -U "${GETTEXT_TRANSLATIONS_NEW_PO_FILE_NAME}" \
        "${GETTEXT_TRANSLATIONS_POT_FILE}" --lang="${GETTEXT_TRANSLATIONS_LANGUAGE}"
    done

  done <<< "${GETTEXT_TRANSLATIONS_LANGUAGES}"

  log "INFO" "Done."
}

gettext_translations_compile() {
  local GETTEXT_TRANSLATIONS_LANGUAGE
  local GETTEXT_TRANSLATIONS_LANGUAGES
  local GETTEXT_TRANSLATIONS_LANGUAGE_PO_FILE
  local GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH
  local GETTEXT_TRANSLATIONS_NEW_MO_FILE_NAME

  GETTEXT_TRANSLATIONS_LANGUAGES=()

  environment -m "GETTEXT_TRANSLATIONS_DOCKER_IMAGE"

  if ! _gettext_translations_check_existing_base_path ||
    ! _gettext_translations_identify_existing_languages; then
    return 127
  fi

  for GETTEXT_TRANSLATIONS_LANGUAGE in "${GETTEXT_TRANSLATIONS_LANGUAGES[@]}"; do

    log "INFO" "Processing '${GETTEXT_TRANSLATIONS_LANGUAGE}' ..."

    _gettext_translations_check_existing_po_files "${GETTEXT_TRANSLATIONS_LANGUAGE}"

    GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH="${GETTEXT_TRANSLATIONS_BASE_PATH}/${GETTEXT_TRANSLATIONS_LANGUAGE}/LC_MESSAGES"

    for GETTEXT_TRANSLATIONS_LANGUAGE_PO_FILE in "${GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH}"/*.po; do
      GETTEXT_TRANSLATIONS_NEW_MO_FILE_NAME="${GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH}/$(basename "${GETTEXT_TRANSLATIONS_LANGUAGE_PO_FILE}" ".po").mo"
      log "INFO" "  Compiling '${GETTEXT_TRANSLATIONS_LANGUAGE_PO_FILE}' -> '${GETTEXT_TRANSLATIONS_NEW_MO_FILE_NAME}' ..."
      _gettext_translations_run_binary msgfmt \
        -o "${GETTEXT_TRANSLATIONS_NEW_MO_FILE_NAME}" \
        "${GETTEXT_TRANSLATIONS_LANGUAGE_PO_FILE}"
    done

  done

  log "INFO" "Done."
}

gettext_translations_missing() {
  local GETTEXT_TRANSLATIONS_LANGUAGE
  local GETTEXT_TRANSLATIONS_LANGUAGES
  local GETTEXT_TRANSLATIONS_LANGUAGE_TO_SKIP
  local GETTEXT_TRANSLATIONS_MISSING=0

  GETTEXT_TRANSLATIONS_LANGUAGES=()

  if ! _gettext_translations_check_existing_base_path ||
    ! _gettext_translations_identify_existing_languages; then
    return 127
  fi

  for GETTEXT_TRANSLATIONS_LANGUAGE in "${GETTEXT_TRANSLATIONS_LANGUAGES[@]}"; do

    for GETTEXT_TRANSLATIONS_LANGUAGE_TO_SKIP in "${GETTEXT_TRANSLATIONS_LANGUAGES_BEING_SKIPPED[@]}"; do
      if [[ "${GETTEXT_TRANSLATIONS_LANGUAGE_TO_SKIP}" == "${GETTEXT_TRANSLATIONS_LANGUAGE}" ]]; then
        log "WARNING" "Skipping checks on '${GETTEXT_TRANSLATIONS_LANGUAGE}' ..."
        break
      fi
      GETTEXT_TRANSLATIONS_LANGUAGE_TO_SKIP=""
    done

    if [[ -n "${GETTEXT_TRANSLATIONS_LANGUAGE_TO_SKIP}" ]]; then
      continue
    fi

    log "INFO" "Checking '${GETTEXT_TRANSLATIONS_LANGUAGE}' for missing translations ..."
    if [[ "$(
      grep \
        -c \
        "${GETTEXT_TRANSLATIONS_EMPTY_MESSAGE_MATCH}" \
        "${GETTEXT_TRANSLATIONS_BASE_PATH}/${GETTEXT_TRANSLATIONS_LANGUAGE}/LC_MESSAGES/"*.po ||
        true
    )" -gt "1" ]] \
      ; then
      log "ERROR" "Found untranslated strings!"
      GETTEXT_TRANSLATIONS_MISSING=127
      continue
    fi
    log "INFO" "No missing translations found."
  done
  return "${GETTEXT_TRANSLATIONS_MISSING}"
}

gettext_translations_update() {
  local GETTEXT_TRANSLATIONS_BASE_POT_FILE
  local GETTEXT_TRANSLATIONS_LANGUAGE
  local GETTEXT_TRANSLATIONS_LANGUAGES
  local GETTEXT_TRANSLATIONS_LANGUAGE_PO_FILE
  local GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH

  GETTEXT_TRANSLATIONS_LANGUAGES=()

  environment -m "GETTEXT_TRANSLATIONS_DOCKER_IMAGE"

  mkdir -p "${GETTEXT_TRANSLATIONS_BASE_PATH}"

  if ! _gettext_translations_identify_existing_languages; then
    log "WARNING" "There are no target languages defined for this project yet."
  fi

  GETTEXT_TRANSLATIONS_BASE_POT_FILE="${GETTEXT_TRANSLATIONS_BASE_PATH}/${GETTEXT_TRANSLATIONS_EXTRACTION_FILE_NAME}.pot"
  _gettext_translations_generate_or_update_pot_file

  for GETTEXT_TRANSLATIONS_LANGUAGE in "${GETTEXT_TRANSLATIONS_LANGUAGES[@]}"; do

    log "INFO" "  Updating '${GETTEXT_TRANSLATIONS_LANGUAGE}' with changes to '${GETTEXT_TRANSLATIONS_BASE_POT_FILE}' ..."

    GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH="${GETTEXT_TRANSLATIONS_BASE_PATH}/${GETTEXT_TRANSLATIONS_LANGUAGE}/LC_MESSAGES"

    for GETTEXT_TRANSLATIONS_LANGUAGE_PO_FILE in "${GETTEXT_TRANSLATIONS_LANGUAGE_SUB_PATH}"/*.po; do

      _gettext_translations_run_binary msgmerge \
        -q \
        --force-po \
        --lang="${GETTEXT_TRANSLATIONS_LANGUAGE}" \
        -U "${GETTEXT_TRANSLATIONS_BASE_PATH}/${GETTEXT_TRANSLATIONS_LANGUAGE}/LC_MESSAGES/${GETTEXT_TRANSLATIONS_EXTRACTION_FILE_NAME}.po" \
        "${GETTEXT_TRANSLATIONS_BASE_POT_FILE}"

    done

  done

  log "INFO" "Done."
}

main() {
  local GETTEXT_TRANSLATIONS_BASE_PATH
  local GETTEXT_TRANSLATIONS_CODE_BASE_PATH
  local GETTEXT_TRANSLATIONS_CODE_BASE_REGEX
  local GETTEXT_TRANSLATIONS_EMAIL_ADDRESS
  local GETTEXT_TRANSLATIONS_EMPTY_MESSAGE_MATCH
  local GETTEXT_TRANSLATIONS_EXTRACTION_FILE_NAME
  local GETTEXT_TRANSLATIONS_LANGUAGES_BEING_SKIPPED
  local GETTEXT_TRANSLATIONS_UTF8_OVERRIDE

  GETTEXT_TRANSLATIONS_CODE_BASE_REGEX="*.py"
  GETTEXT_TRANSLATIONS_EMPTY_MESSAGE_MATCH='msgstr ""'
  GETTEXT_TRANSLATIONS_EXTRACTION_FILE_NAME="base"
  GETTEXT_TRANSLATIONS_LANGUAGES_BEING_SKIPPED=()

  _gettext_translations_args "$@"

}

main "$@"
