#!/usr/bin/env bash
set -euo pipefail

build_badges() {
  local repo="${1:-raymonepping/homebrew-repository-export-cli}"
  local version="${2:-v1.0.0}"
  local brew_tap="${3:-raymonepping/repository-export-cli}"

  # Strip leading 'v'
  local version_clean="${version#v}"

  cat <<EOF
[![brew install](https://img.shields.io/badge/brew--install-success-green?logo=homebrew&style=flat-square)](https://brew.sh "Run: brew install ${brew_tap}")
[![version](https://img.shields.io/badge/version-${version_clean}-blue?style=flat-square)](https://github.com/${repo}/releases)
EOF
}
