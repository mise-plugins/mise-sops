#! /usr/bin/env bash

if [ "${MISE_TRACE-}" = "1" ]; then
  set -x
fi

echoerr() {
  echo "$1" >&2
}

sops_bin() {
  echo "$MISE_INSTALL_PATH/bin/sops"
}

sops_env() {
  local filename
  filename=$(eval "printf '%s' '${MISE_TOOL_OPTS__FILENAME-}'")
  if [[ -z ${filename} ]]; then
    echoerr "mise-sops: No filename provided."
    return 1
  fi
  if [[ ${filename} != /* ]] && [[ -n ${MISE_PROJECT_ROOT-} ]]; then
    filename="${MISE_PROJECT_ROOT-}/${filename}"
  fi
  if [[ ! -f ${filename} ]]; then
    echoerr "mise-sops: Filename '${filename}' not found."
    return 1
  fi
  "$(sops_bin)" -d "${filename}"
}
