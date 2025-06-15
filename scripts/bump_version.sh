#!/usr/bin/env bash
# Bump semantic version and create git tag
# Usage: ./scripts/bump_version.sh [major|minor|patch]

set -euo pipefail

usage() {
  echo "Usage: $0 {major|minor|patch}" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

LEVEL="$1"
if [[ "$LEVEL" != "major" && "$LEVEL" != "minor" && "$LEVEL" != "patch" ]]; then
  usage
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/VERSION"

# Initialise VERSION file if missing
if [[ ! -f "$VERSION_FILE" ]]; then
  echo "0.0.0" > "$VERSION_FILE"
fi

CURRENT="$(cat "$VERSION_FILE" | tr -d '[:space:]')"
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

case "$LEVEL" in
  major)
    MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor)
    MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch)
    PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

echo "$NEW_VERSION" > "$VERSION_FILE"

git add "$VERSION_FILE"
git commit -m "chore(release): v$NEW_VERSION"
git tag "v$NEW_VERSION"

echo "Version bumped to $NEW_VERSION" 