#!/usr/bin/env bash
# release-notes: write release notes from the commits since the previous tag.
#
#   release-notes.sh TAG
#
# Commits here are one line, `area: summary`, so the notes group themselves by
# area. A subject with no area goes under "other". With no earlier tag, the
# notes cover every commit.
set -euo pipefail

tag=${1:?usage: release-notes.sh TAG}

if previous=$(git describe --tags --abbrev=0 --match 'v*' "${tag}^" 2> /dev/null); then
  range="${previous}..${tag}"
  echo "Changes since ${previous}."
else
  range="${tag}"
  echo "The first release."
fi
echo

git log --no-merges --reverse --format='%s' "${range}" | awk '
  {
    if (match($0, /^[a-z0-9._-]+: /)) {
      area = substr($0, 1, RLENGTH - 2)
      text = substr($0, RLENGTH + 1)
    } else {
      area = "other"
      text = $0
    }
    if (!(area in seen)) {
      seen[area] = 1
      order[++count] = area
    }
    lines[area] = lines[area] "- " text "\n"
  }
  END {
    for (i = 1; i <= count; i++) {
      printf "## %s\n\n%s\n", order[i], lines[order[i]]
    }
  }
'
