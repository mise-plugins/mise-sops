# shellcheck shell=bash

if [[ ${MISE_TRACE-} == 1 ]]; then
  set -x
fi

set -euo pipefail

export RELEASES_PATH=https://api.github.com/repos/getsops/sops/releases

echoerr() {
  printf 'mise-sops: %s\n' "$1" >&2
}

sops_bin() {
  "${MISE_INSTALL_PATH}/bin/sops" "$@"
}

sops_env() {
  if [[ -z ${MISE_TOOL_OPTS__FILENAME-} ]]; then
    echoerr "no filename provided"
    return 1
  fi

  # split filenames
  FILENAMES=${MISE_TOOL_OPTS__FILENAME//:/$'\n'}

  # export names filter
  if [[ -n ${MISE_TOOL_OPTS__NAMES-} ]]; then
    # convert delimiter into regex alternation
    NAMES="^export (${MISE_TOOL_OPTS__NAMES//:/|})="
  else
    # match everything
    NAMES="^export ([a-zA-Z0-9_]+)="
  fi

  FILES=0
  LINES=0

  while read -r filename; do
    if [[ ${filename} != /* ]] && [[ -n ${MISE_PROJECT_ROOT-} ]]; then
      filename="${MISE_PROJECT_ROOT-}/${filename}"
    fi

    if [[ ! -f ${filename} ]]; then
      echoerr "filename not found: ${filename}"
      continue
    fi

    FILES=1

    while read -r LINE; do
      if [[ ${LINE} =~ ${NAMES} ]]; then
        LINES=1
        printf '%s\n' "${LINE}"
      fi
    done < <(sops_bin -d "${filename}")
  done <<< "${FILENAMES}"

  if ((!FILES)); then
    return 1
  fi

  if ((!LINES)); then
    echoerr "no variables match name pattern: ${MISE_TOOL_OPTS__NAMES-}"
    return 1
  fi
}
