#!/usr/bin/env bash
set -euo pipefail

TASK="${1:-:app:assembleDebug}"
SDK_DIR="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-/usr/local/lib/android/sdk}}"

if [ ! -d "$SDK_DIR" ]; then
  echo "Android SDK not found. Checked: $SDK_DIR" >&2
  exit 1
fi

cat > local.properties <<EOF
sdk.dir=${SDK_DIR}
KEYSTORE_FILE=${KEYSTORE_FILE:-keystore/release.jks}
KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD:-}
KEY_ALIAS=${KEY_ALIAS:-}
KEY_PASSWORD=${KEY_PASSWORD:-}
EOF

if [ -n "${KEYSTORE_BASE64:-}" ]; then
  KEYSTORE_PATH="${KEYSTORE_FILE:-keystore/release.jks}"
  mkdir -p "$(dirname "$KEYSTORE_PATH")"
  printf '%s' "$KEYSTORE_BASE64" | base64 -d > "$KEYSTORE_PATH"
fi

chmod +x ./gradlew

./gradlew --stop || true
./gradlew --no-daemon "${TASK}"