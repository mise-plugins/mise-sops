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
  if [[ -z ${MISE_TOOL_OPTS__FILENAME-} ]]; then
    echoerr "mise-sops: No filename provided."
    return 1
  fi

  while read -r filename; do
    if [[ ${filename} != /* ]] && [[ -n ${MISE_PROJECT_ROOT-} ]]; then
      filename="${MISE_PROJECT_ROOT-}/${filename}"
    fi
    if [[ ! -f ${filename} ]]; then
      echoerr "mise-sops: Filename '${filename}' not found."
      continue
    fi
    "$(sops_bin)" -d "${filename}"
  done < <(tr : $'\n' <<<"${MISE_TOOL_OPTS__FILENAME}")
}
