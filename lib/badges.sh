#!/usr/bin/env bash
set -euo pipefail

build_badges() {
  local repo="${1:-raymonepping/homebrew-repository-export-cli}"
  local version="${2:-v1.0.0}"
  local brew_tap="${3:-raymonepping/repository-export-cli}"

  # Strip leading 'v' from version for badge display
  local version_clean="${version#v}"

  # Homebrew install link
  local brew_link="https://brew.sh"

  # Custom install command (for copy-paste clarity)
  local install_cmd="brew install ${brew_tap}"

  cat <<EOF
[![brew install](https://img.shields.io/badge/brew--install-success-green?logo=homebrew&style=flat-square)](${brew_link} "Run: $install_cmd")
[![version](https://img.shields.io/badge/version-${version_clean}-blue?style=flat-square")](https://github.com/${repo}/releases)
EOF
}
