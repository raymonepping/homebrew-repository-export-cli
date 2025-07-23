#!/usr/bin/env bash
set -euo pipefail

# No-op for now, included for interface compatibility
build_pretty_labels() { :; }
export -f build_pretty_labels

# pretty_label <raw_field_name>
# Maps technical/nested field names to printable, title-cased, user-friendly labels
pretty_label() {
  local raw="$1"
  case "$raw" in
    name) echo "Name" ;;
    url) echo "URL" ;;
    description) echo "Description" ;;
    stargazerCount) echo "Stars" ;;
    primaryLanguage.name | primaryLanguage) echo "Primary Language" ;;
    diskUsage) echo "Size (KB)" ;;
    measuredSizeKb) echo "Measured Size (KB)" ;;
    createdAt) echo "Created" ;;
    pushedAt) echo "Last Push" ;;
    defaultBranchRef.name | defaultBranch) echo "Default Branch" ;;
    visibility) echo "Visibility" ;;
    latestRelease.tagName | latestRelease) echo "Release Tag" ;;
    lastContributor) echo "Last Contributor" ;;
    lastCommitMessage) echo "Last Commit Message" ;;
    readmePresent) echo "README Present" ;;
    branchCount) echo "Branch Count" ;;
    hasWorkflows) echo "Has Workflows" ;;
    # Add more "known" mappings here as you wish
    *)
      # Fallback: Replace dots/underscores with spaces, then Title Case
      # E.g., "foo.bar_baz" -> "Foo Bar Baz"
      echo "$raw" | sed -E 's/([._])/ /g; s/\b([a-z])/\u\1/g'
      ;;
  esac
}

export -f pretty_label
