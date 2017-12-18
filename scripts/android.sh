#!/bin/bash
#
# This script compiles Godot for Android.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.

set -euo pipefail

# The paths to the Android SDK and NDK
export ANDROID_HOME="$TOOLS_DIR/android"
export ANDROID_NDK_ROOT="$TOOLS_DIR/android/ndk-bundle"

# Build Godot templates for Android

scons platform=android tools=no target=release_debug use_lto=yes $SCONS_FLAGS
scons platform=android tools=no target=release use_lto=yes $SCONS_FLAGS
cd "platform/android/java"
./gradlew build
cd "../../.."
