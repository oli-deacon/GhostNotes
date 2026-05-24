#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/GhostNotes.xcodeproj"
SCHEME="GhostNotes"
CONFIGURATION="Release"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/.build/GhostNotesDerivedData}"
ARCHIVE_ROOT="${ARCHIVE_ROOT:-$ROOT_DIR/dist}"
ARTIFACT_NAME="${ARTIFACT_NAME:-GhostNotes-mac}"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION/GhostNotes.app"
ZIP_PATH="$ARCHIVE_ROOT/$ARTIFACT_NAME.zip"

rm -rf "$DERIVED_DATA_PATH"
mkdir -p "$ARCHIVE_ROOT"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -destination "platform=macOS" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app bundle was not produced: $APP_PATH" >&2
  exit 1
fi

rm -f "$ZIP_PATH"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

echo "Created release artifact:"
echo "$ZIP_PATH"
