#!/usr/bin/env bash
set -euo pipefail

RPROMPT=""

# Source badges builder (adjust path as needed)
# source "$(dirname "$0")/../lib/badges.sh"

# --- Helper: Render a template with variable replacement ---
render_tpl_with_vars() {
  local tpl_file="$1"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//'{{ badges }}'/$BADGES}"
    line="${line//'@@BADGES@@'/$BADGES}"
    line="${line//'{{ TIMESTAMP }}'/$EXPORT_DATE}"
    line="${line//'{{ VERSION }}'/$VERSION}"
    echo "$line"
  done < "$tpl_file"
}

# Usage: render_output <format> <outfile_path> <data_json>
# $1 = markdown|md|csv|json
# $2 = output file path (extension optional)
# $3 = JSON file with one object per line (pretty-labelled keys)

render_output() {
  local format="$1"
  local outfile="$2"
  local data="$3"

  # Grab delimiter from config (default: ,)
  local delim
  delim=$(jq -r '.delimiter[0] // ","' "$CONFIG_FILE" 2>/dev/null || echo ",")
  [[ -z "$delim" ]] && delim=','

  # Use TMPDIR if set, otherwise make one (defensive!)
  TMPDIR="${TMPDIR:-$(mktemp -d)}"

  # Set outfile extension (let main handle basename logic)
  local outfile_final="$outfile"
  case "$format" in
    markdown|md) outfile_final="${outfile%.md}.md" ;;
    csv)         outfile_final="${outfile%.csv}.csv" ;;
    json)        outfile_final="${outfile%.json}.json" ;;
  esac

  # Read as array of lines (each is a JSON object, keys are pretty labels)
  mapfile -t LINES < <(jq -s '.[]' "$data" | jq -c '.')

  # Defensive: If no data, create placeholder fields
  if [[ "${#LINES[@]}" -gt 0 ]]; then
    mapfile -t FIELDS < <(echo "${LINES[0]}" | jq -r 'keys_unsorted[]')
  else
    FIELDS=("No data found")
  fi

  # Set safe fallback values if not set
  : "${GITHUB_REPO:=raymonepping/repository_export}"
  : "${EXPORT_DATE:=$(date '+%Y-%m-%d')}"
  : "${VERSION:=v1.0.0}"

  # Build badges string
  # BADGES="$(build_badges "$GITHUB_REPO" "$EXPORT_DATE" "$VERSION")"
  BADGES="$(build_badges "$GITHUB_REPO" "$VERSION")"

  # --- Markdown / MD Output ---
  if [[ "$format" =~ ^(markdown|md)$ ]]; then
    local HDR="|"; local DIV="|"; local TABLE=""
    if [[ "${FIELDS[0]}" != "No data found" ]]; then
      for label in "${FIELDS[@]}"; do
        HDR="$HDR $label |"
        DIV="$DIV --- |"
      done
      TABLE="$HDR"$'\n'"$DIV"
      for row in "${LINES[@]}"; do
        mapfile -t VALUES < <(echo "$row" | jq -r '.[]')
        ROW="|"
        for v in "${VALUES[@]}"; do
          ROW="$ROW $v |"
        done
        TABLE+=$'\n'"$ROW"
      done
    else
      TABLE="(No data found)"
    fi

    # Write to temp
    local TABLE_FILE="$TMPDIR/table.md"
    echo "$TABLE" > "$TABLE_FILE"

    # Compose output with template variable substitution
    {
      [[ -f "$TPL_DIR/header.tpl" ]] && render_tpl_with_vars "$TPL_DIR/header.tpl"
      if [[ -f "$TPL_DIR/body.tpl" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
          case "$line" in
            *'{{ table }}'*)
              cat "$TABLE_FILE"
              ;;
            *'{{ badges }}'*|*'@@BADGES@@'*)
              [[ -n "${BADGES:-}" ]] && echo "$BADGES"
              ;;
            *)
              # In case body.tpl ever uses {{ ... }} variables, expand them
              line="${line//'{{ badges }}'/$BADGES}"
              line="${line//'@@BADGES@@'/$BADGES}"
              line="${line//'{{ TIMESTAMP }}'/$EXPORT_DATE}"
              line="${line//'{{ VERSION }}'/$VERSION}"
              echo "$line"
              ;;
          esac
        done < "$TPL_DIR/body.tpl"
      else
        cat "$TABLE_FILE"
      fi
      [[ -f "$TPL_DIR/footer.tpl" ]] && render_tpl_with_vars "$TPL_DIR/footer.tpl"
    } > "$outfile_final"
    return
  fi

  # --- CSV Output ---
  if [[ "$format" == "csv" ]]; then
    local csv_delim="$delim"
    if [[ "${FIELDS[0]}" != "No data found" ]]; then
      {
        IFS="$csv_delim"; echo "${FIELDS[*]}"
        for row in "${LINES[@]}"; do
          mapfile -t VALUES < <(echo "$row" | jq -r '.[]')
          (
            for val in "${VALUES[@]}"; do
              printf '"%s"%s' "${val//\"/\"\"}" "$csv_delim"
            done
          ) | sed "s/${csv_delim}\$//"
          echo
        done
      } > "$outfile_final"
    else
      echo "(No data found)" > "$outfile_final"
    fi
    return
  fi

  # --- JSON Output ---
  if [[ "$format" == "json" ]]; then
    jq -s '.' "$data" > "$outfile_final"
    return
  fi

  echo "❌ Unsupported format: $format" >&2
  exit 1
}

export -f render_output
