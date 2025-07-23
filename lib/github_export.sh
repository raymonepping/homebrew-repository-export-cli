#!/usr/bin/env bash
set -euo pipefail

# --- Expects: pretty_label, check_dependencies ---

collect_repo_data() {
  local USERNAME="$1"
  local TMPDIR="$2"
  local DATA_JSON="$3"
  local CONFIG="$4"

  local FIELDS=($(jq -r '.fields[]' "$CONFIG"))
  # API_FIELDS = all unique top-level parents
  local API_FIELDS
  API_FIELDS=$(for f in "${FIELDS[@]}"; do echo "$f" | cut -d. -f1; done | sort -u | tr '\n' ',' | sed 's/,$//')
  local CUSTOM_FIELDS=($(jq -r '.custom[]' "$CONFIG"))

  # Build pretty labels
  local -a ALL_FIELDS=("User")
  declare -A FIELD_LABELS
  FIELD_LABELS["User"]="User"
  for key in "${FIELDS[@]}"; do
    local label; label=$(pretty_label "$key")
    local orig_label="$label"; local i=2
    while printf '%s\n' "${ALL_FIELDS[@]}" | grep -q -F "$label"; do
      label="${orig_label} $i"; ((i++))
    done
    ALL_FIELDS+=("$label")
    FIELD_LABELS["$key"]="$label"
  done
  for custom in "${CUSTOM_FIELDS[@]}"; do
    local label; label=$(pretty_label "$custom")
    local orig_label="$label"; local i=2
    while printf '%s\n' "${ALL_FIELDS[@]}" | grep -q -F "$label"; do
      label="${orig_label} $i"; ((i++))
    done
    ALL_FIELDS+=("$label")
    FIELD_LABELS["$custom"]="$label"
  done

  local REPO_LIST
  REPO_LIST=$(gh repo list "$USERNAME" --limit 1000 --json "$API_FIELDS,url")
  local TOTAL; TOTAL=$(echo "$REPO_LIST" | jq 'length')
  local COUNT=0
  printf "\n🔍 [%s] Found %d repositories\n" "$USERNAME" "$TOTAL" >&2

  echo "$REPO_LIST" | jq -c '.[]' | while read -r repo_json; do
    COUNT=$((COUNT+1))
    _jq() { echo "$repo_json" | jq -r "$1"; }
    # Progress bar
    local PERCENT=$((COUNT * 100 / (TOTAL==0?1:TOTAL)))
    local BAR_LENGTH=24
    local FILLED=$((BAR_LENGTH * COUNT / (TOTAL==0?1:TOTAL)))
    local BAR=$(printf "%0.s#" $(seq 1 $FILLED))
    local EMPTY=$(printf "%0.s-" $(seq 1 $((BAR_LENGTH - FILLED))))
    local REPO_NAME; REPO_NAME=$(_jq '.name')
    printf "\r  [%s%s] %3d%% (%d/%d) Exporting: %-40s" "$BAR" "$EMPTY" "$PERCENT" "$COUNT" "$TOTAL" "$REPO_NAME" >&2

    declare -A ROW
    ROW["User"]="$USERNAME"
    for FIELD in "${FIELDS[@]}"; do
      # Full subfield path for jq extraction
      local jq_query; jq_query=".$(echo $FIELD | sed 's/\./"]["/g; s/^/["/; s/$/"]/')"
      local val; val=$(_jq "$jq_query // \"-\"")
      [[ "$val" == "true" ]] && val="✅"
      [[ "$val" == "false" || "$val" == "null" ]] && val="-"
      local label="${FIELD_LABELS[$FIELD]}"
      ROW["$label"]="$val"
    done

    # Custom fields via git
    local REPO_URL REPO_DIR; REPO_URL=$(_jq '.url'); REPO_DIR="$TMPDIR/$REPO_NAME"
    git clone --quiet --depth 1 "$REPO_URL" "$REPO_DIR" 2>/dev/null || continue

    for CUSTOM in "${CUSTOM_FIELDS[@]}"; do
      local v="-"
      case "$CUSTOM" in
        lastContributor)
          v=$(git -C "$REPO_DIR" log -1 --pretty=format:'%an' 2>/dev/null || echo "-")
          ;;
        lastCommitMessage)
          v=$(git -C "$REPO_DIR" log -1 --pretty=format:'%s' 2>/dev/null || echo "-")
          ;;
        readmePresent)
          [[ -f "$REPO_DIR/README.md" ]] && v="✅"
          ;;
        branchCount)
          v=$(git -C "$REPO_DIR" branch -a | wc -l | xargs)
          ;;
        hasWorkflows)
          [[ -d "$REPO_DIR/.github/workflows" ]] && v="✅"
          ;;
        measuredSizeKb)
          # Only measure if diskUsage==0 or "-"
          if [[ "${ROW[Size (KB)]}" == "0" || "${ROW[Size (KB)]}" == "-" ]]; then
            v=$(du -sk "$REPO_DIR" | awk '{print $1}')
          fi
          ;;
      esac
      local label="${FIELD_LABELS[$CUSTOM]}"
      ROW["$label"]="$v"
    done

    # Output as JSON (pretty labels as keys)
    {
      echo -n "{"
      local first=1
      for label in "${ALL_FIELDS[@]}"; do
        [[ "$first" -eq 1 ]] && first=0 || echo -n ","
        echo -n "\"$label\":\"${ROW[$label]//\"/\\\"}\""
      done
      echo "}"
    } >> "$DATA_JSON"
    echo "" >> "$DATA_JSON"
    rm -rf "$REPO_DIR"
  done
  echo "" >&2
}

export -f collect_repo_data
