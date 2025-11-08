#!/usr/bin/env bash
set -Eeuo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: $0 <new_app_name>"
  echo "Example: $0 new_app.net"
  exit 1
fi

NEW_APP_NAME="$1"
SOURCE_REPO="$(git rev-parse --show-toplevel)"
PARENT_DIR="$(dirname "$SOURCE_REPO")"
TARGET_DIR="$PARENT_DIR/$NEW_APP_NAME"

if [ -d "$TARGET_DIR" ]; then
  echo "Error: Directory $TARGET_DIR already exists"
  exit 1
fi

echo "Cloning $SOURCE_REPO to $TARGET_DIR..."
git clone "$SOURCE_REPO" "$TARGET_DIR"

echo "Removing origin remote from $NEW_APP_NAME..."
cd "$TARGET_DIR"
git remote remove origin

echo "Done! New app created at $TARGET_DIR"
echo "You can now run 'mise rebase' in that directory to rebase on this repo."

