# shellcheck shell=bash

if [[ ${MISE_TRACE-} == 1 ]]; then
  set -x
fi

set -euo pipefail

export RELEASES_PATH=https://api.github.com/repos/getsops/sops/releases

echoerr() {
  printf 'mise-sops: %s\n' "$1" >&2
}

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

min_version() {
  version=$1
  [[ ${version} == $(printf '%s\n' "$@" | sort_versions | tail -n1) ]]
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
