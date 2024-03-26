#! /usr/bin/env bash

if [ "${MISE_TRACE-}" = "1" ]; then
  set -x
fi

echoerr() {
  echo "$1" >&2
}

sops_bin() {
  echo "${MISE_INSTALL_PATH}/bin/sops"
}

DELIMS="[,;:]"

sops_env() {
  if [[ -z ${MISE_TOOL_OPTS__FILENAME-} ]]; then
    echoerr "mise-sops: No filename provided."
    return 1
  fi

  # split filenames
  FILENAMES=${MISE_TOOL_OPTS__FILENAME//${DELIMS}/$'\n'}

  # export names filter
  if [[ -n ${MISE_TOOL_OPTS__NAMES-} ]]; then
    # convert delimiters into regex alternation
    NAMES="^export (${MISE_TOOL_OPTS__NAMES//${DELIMS}/|})="
  else
    # match everything
    NAMES="^export ([a-zA-Z0-9_]+)="
  fi

  while read -r filename; do
    if [[ ${filename} != /* ]] && [[ -n ${MISE_PROJECT_ROOT-} ]]; then
      filename="${MISE_PROJECT_ROOT-}/${filename}"
    fi
    if [[ ! -f ${filename} ]]; then
      echoerr "mise-sops: Filename '${filename}' not found."
      continue
    fi
    while read -r LINE; do
      if [[ ${LINE} =~ ${NAMES} ]]; then
        printf '%s\n' "${LINE}"
      fi
    done < <("$(sops_bin)" -d "${filename}")
  done <<< "${FILENAMES}"
}
