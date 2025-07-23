#!/usr/bin/env bash
set -euo pipefail

# ====== Default values ======
CONFIG_FILE="${HOME}/.export_config.json"
OUTPUT_FORMAT="markdown"
OUTPUT_DIR="."
OUTPUT_FILE="github_repos"
SHOW_HELP=false
SHOW_VERSION=false

usage() {
  local BOLD BLUE NC
  BOLD=$'\e[1m'
  BLUE=$'\e[34m'
  NC=$'\e[0m'

  cat <<EOF
${BLUE}📦 repository_export${NC} ${BOLD}v$VERSION${NC} — Export GitHub Repositories to Markdown, CSV, or JSON

${BOLD}USAGE${NC}
    ${0##*/} [OPTIONS]

${BOLD}OPTIONS${NC}
    --output <md|csv|json>         Output format (default: md)
    --output-file <filename>       Output file name (default: repositories.md)
    --output-dir <dir>             Output directory (default: .)
    --config <config.json>         Path to export config (default: .export_config.json)
    --include-archived             Include archived repositories (default: false)
    --exclude-forks                Exclude forked repositories (default: false)
    --help                         Show this help and exit
    --version                      Print version and exit

${BOLD}EXAMPLES${NC}
    ${0##*/} --output md --output-file repos.md
    ${0##*/} --output csv --output-dir ./exports --exclude-forks
    ${0##*/} --help

Exported by Raymon's repository_export CLI — MIT Licensed
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --output)
        OUTPUT_FORMAT="${2,,}"  # lowercase
        shift 2
        ;;
      --output-dir)
        OUTPUT_DIR="$2"
        shift 2
        ;;
      --output-file)
        OUTPUT_FILE="$2"
        shift 2
        ;;
      --config)
        CONFIG_FILE="$2"
        shift 2
        ;;
      --help)
        usage
        exit 0
        ;;
      --version)
        echo "repository_export.sh v${VERSION:-1.0.0}"
        exit 0
        ;;
      *)
        echo "❌ Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  # Add file extension if missing (unless output format is empty/unknown)
  local ext=""
  case "$OUTPUT_FORMAT" in
    markdown|md) ext=".md" ;;
    json)        ext=".json" ;;
    csv)         ext=".csv" ;;
    *)           ext="" ;;
  esac

  if [[ -n "$ext" && "$OUTPUT_FILE" != *"$ext" ]]; then
    OUTPUT_FILE="${OUTPUT_FILE}${ext}"
  fi
}

export CONFIG_FILE OUTPUT_FORMAT OUTPUT_DIR OUTPUT_FILE usage parse_args
