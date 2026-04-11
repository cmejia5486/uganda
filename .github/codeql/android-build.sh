#!/usr/bin/env bash
set -euo pipefail

echo "== Android build helper for CodeQL =="

mkdir -p keystore

if [ -n "${ANDROID_KEYSTORE_BASE64:-}" ]; then
  echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > keystore/release.jks
fi

if [ ! -f local.properties ]; then
  {
    if [ -n "${ANDROID_SDK_ROOT:-}" ]; then
      echo "sdk.dir=${ANDROID_SDK_ROOT}"
    elif [ -n "${ANDROID_HOME:-}" ]; then
      echo "sdk.dir=${ANDROID_HOME}"
    fi

    [ -n "${KEYSTORE_FILE:-}" ] && echo "KEYSTORE_FILE=${KEYSTORE_FILE}"
    [ -n "${KEYSTORE_PASSWORD:-}" ] && echo "KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}"
    [ -n "${KEY_ALIAS:-}" ] && echo "KEY_ALIAS=${KEY_ALIAS}"
    [ -n "${KEY_PASSWORD:-}" ] && echo "KEY_PASSWORD=${KEY_PASSWORD}"
  } > local.properties
fi

chmod +x ./gradlew

./gradlew --stop || true
./gradlew clean --no-daemon

if ./gradlew tasks --all | grep -q "assembleDebug"; then
  ./gradlew :app:assembleDebug \
    --no-daemon \
    --stacktrace \
    -Dkotlin.incremental=false
elif ./gradlew tasks --all | grep -q "assemble"; then
  ./gradlew assemble \
    --no-daemon \
    --stacktrace \
    -Dkotlin.incremental=false
else
  echo "No Gradle build task found"
  exit 1
fi