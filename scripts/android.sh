#!/bin/bash
#
# This script compiles Godot for Android.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.

set -euo pipefail

# The paths to the Android SDK and NDK, only overridden if the user
# does not already have these variables set
export ANDROID_HOME="${ANDROID_HOME:-"$TOOLS_DIR/android"}"
export ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT:-"$TOOLS_DIR/android/ndk-bundle"}"

# Build Godot templates for Android
echo_header "Building ARMv7 debug export template for Android…"
scons platform=android tools=no target=release_debug use_lto=yes $SCONS_FLAGS
echo_header "Building ARMv7 release export template for Android…"
scons platform=android tools=no target=release use_lto=yes $SCONS_FLAGS

# Package export templates into APKs
echo_header "Packaging Android export templates into APKs…"
cd "platform/android/java"
./gradlew build
cd "../../.."

# Move the export templates over
mv "$GODOT_DIR/bin/android_debug.apk" "$TEMPLATES_DIR"
mv "$GODOT_DIR/bin/android_release.apk" "$TEMPLATES_DIR"

echo_success "Finished building export templates for Android."
