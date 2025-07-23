#!/usr/bin/env bash
set -euo pipefail

build_badges() {
  local repo="${1:-raymonepping/homebrew-repository-export-cli}"
  local date_str="${2:-$(date '+%Y-%m-%d')}"
  local version="${3:-v1.0.0}"

  # Remove leading 'v' from version for badge
  local version_clean="${version#v}"

  cat <<EOF
[![Exported](https://img.shields.io/badge/Exported-${date_str}-informational?style=flat-square)](#)
[![Version](https://img.shields.io/badge/Version-${version_clean}-blue?style=flat-square)](#)
[![Stars](https://img.shields.io/github/stars/${repo}?style=social)](https://github.com/${repo}/stargazers)
[![CI](https://github.com/${repo}/actions/workflows/ci.yml/badge.svg)](https://github.com/${repo}/actions)
EOF
}
