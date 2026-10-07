#!/usr/bin/env bash
#
# Installs the prd-craft skill set into a project or into your user-level agent
# skills directory.
#
# The skill set is platform independent: every agent that can read a folder with a
# SKILL.md can use it. This script only copies files; it never edits your agent
# configuration.
#
# Targets:
#   project    -> <project>/.agents/skills/     (checked into the project, shared with the team)
#   user       -> ~/.agents/skills/             (available in every project)
#   claude     -> <project>/.claude/skills/     (Claude Code project scope)
#   claudeuser -> ~/.claude/skills/            (Claude Code user scope)
#
# Usage:
#   ./install.sh                     # install into ./.agents/skills
#   ./install.sh user                # install into ~/.agents/skills
#   ./install.sh project /path/to/repo
#   ./install.sh --dry-run user

set -euo pipefail

TARGET="project"
DEST=""
DRY_RUN=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN="1"; shift ;;
    project|user|claude|claudeuser) TARGET="$1"; shift ;;
    -h|--help) sed -n '2,25p' "$0"; exit 0 ;;
    *) DEST="$1"; shift ;;
  esac
done

SRC_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS="prd-craft kvkk-publish-review"
EXTRA_FILES="ROUTING.md"

case "$TARGET" in
  user)       DST_ROOT="$HOME/.agents/skills" ;;
  claudeuser) DST_ROOT="$HOME/.claude/skills" ;;
  claude)     ROOT="${DEST:-$(pwd)}"; DST_ROOT="$ROOT/.claude/skills" ;;
  project)    ROOT="${DEST:-$(pwd)}"; DST_ROOT="$ROOT/.agents/skills" ;;
  *) echo "Unknown target: $TARGET" >&2; exit 1 ;;
esac

echo
echo "  prd-craft skill set installer"
echo "  source : $SRC_ROOT"
echo "  target : $DST_ROOT"
echo

COPIED=0
FAILED=""

for s in $SKILLS; do
  FROM="$SRC_ROOT/$s"
  if [ ! -d "$FROM" ]; then
    FAILED="$FAILED\n    - $s (missing in source: $FROM)"
    continue
  fi
  TO="$DST_ROOT/$s"
  if [ -n "$DRY_RUN" ]; then
    echo "  WOULD COPY  $s  ->  $TO"
    COPIED=$((COPIED + 1))
    continue
  fi
  if [ -e "$TO" ]; then
    echo "  EXISTS      $s (overwriting)"
    rm -rf "$TO"
  fi
  mkdir -p "$(dirname "$TO")"
  cp -R "$FROM" "$TO"
  N=$(find "$TO" -type f | wc -l | tr -d ' ')
  echo "  COPIED      $s  ($N files)"
  COPIED=$((COPIED + 1))
done

for f in $EXTRA_FILES; do
  FROM="$SRC_ROOT/$f"
  [ -f "$FROM" ] || continue
  TO="$DST_ROOT/$f"
  if [ -n "$DRY_RUN" ]; then
    echo "  WOULD COPY  $f  ->  $TO"
    COPIED=$((COPIED + 1))
    continue
  fi
  mkdir -p "$(dirname "$TO")"
  cp "$FROM" "$TO"
  echo "  COPIED      $f"
  COPIED=$((COPIED + 1))
done

echo
cat <<'NOTE'
  ROUTING.md is the single routing point: it decides which skill answers a request,
  and both skills must be able to read it. Keep it next to the skill folders.
NOTE

if [ -n "$DRY_RUN" ]; then
  echo "  Nothing was written (--dry-run). $COPIED item(s) would be copied."
  exit 0
fi

if [ -n "$FAILED" ]; then
  echo "  INSTALL INCOMPLETE:"
  printf "$FAILED\n" >&2
  exit 1
fi

echo "  Done. $COPIED item(s) installed."
echo
echo "  Next:"
echo "    1. Restart your agent session so it picks the skills up."
echo "    2. Ask something like 'I want an app that finds broken links in my docs'"
echo "       and check that the first line of the answer is a decision declaration:"
echo "       skill: prd-craft | none | undecided  .  rationale: <one sentence>"