#!/usr/bin/env bash

# This script installs LaTeX and related tools

set -e

CONTAINER_OS=${1:-"debian"}
SCRIPT=("${BASH_SOURCE[@]}")
SCRIPT_PATH="${SCRIPT##*/}"
SCRIPT_NAME="${SCRIPT_PATH%.*}"
MARKER_FILE="/usr/local/etc/codespace-markers/${SCRIPT_NAME}"
MARKER_FILE_DIR=$(dirname "${MARKER_FILE}")

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

function apt_get_update_if_needed() {
  if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" -eq 0 ]; then
    apt-get update
  fi
}

function check_packages() {
  if [ "${CONTAINER_OS}" = "debian" ]; then
    if ! dpkg --status "$@" >/dev/null 2>&1; then
      apt_get_update_if_needed
      apt-get install --no-install-recommends --assume-yes "$@"
    fi
  fi
}

if [ -f "${MARKER_FILE}" ]; then
  echo "Marker file found:"
  cat "${MARKER_FILE}"
  # shellcheck source=/dev/null
  source "${MARKER_FILE}"
fi

if [ "${LATEXENV_ALREADY_INSTALLED}" != "true" ]; then
  check_packages \
    biber \
    chktex \
    cm-super \
    dvidvi \
    dvipng \
    fragmaster \
    git \
    lacheck \
    latexdiff \
    latexmk \
    lcdf-typetools \
    lmodern \
    make \
    psutils \
    purifyeps \
    t1utils \
    tex-gyre \
    texinfo \
    texlive-base \
    texlive-bibtex-extra \
    texlive-binaries \
    texlive-extra-utils \
    texlive-font-utils \
    texlive-fonts-extra \
    texlive-fonts-extra-links \
    texlive-fonts-recommended \
    texlive-formats-extra \
    texlive-lang-english \
    texlive-lang-european \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-latex-recommended \
    texlive-luatex \
    texlive-metapost \
    texlive-pictures \
    texlive-plain-generic \
    texlive-pstricks \
    texlive-science \
    texlive-xetex

  LATEXENV_ALREADY_INSTALLED="true"
fi

if [ ! -d "$MARKER_FILE_DIR" ]; then
  mkdir -p "$MARKER_FILE_DIR"
fi

echo -e "\
    LATEXENV_ALREADY_INSTALLED=${LATEXENV_ALREADY_INSTALLED}" >"${MARKER_FILE}"
