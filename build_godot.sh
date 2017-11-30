#!/bin/bash
#
# This script compiles and packages Godot for various platforms.
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail

# `DIR` contains the directory where the script is located, regardless of where
# it is run from. This makes it easy to run this set of build scripts from any
# location
export DIR
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Specify the number of CPU threads to use as the command line argument
# If not set, defaults to all CPU threads
export THREADS
THREADS="${1:-"$(nproc)"}"

# Common directories used in the script
export SCRIPTS_DIR
SCRIPTS_DIR="$DIR/scripts"

# The directory where utility scripts are located
export UTILITIES_DIR
UTILITIES_DIR="$DIR/utilities"

# The directory where SDKs and tools like InnoSetup are located
export TOOLS_DIR
TOOLS_DIR="$DIR/tools"

# The directory where build artifacts will be copied
# EDITOR_DIR and TEMPLATES_DIR are used by platform-specific scripts
export ARTIFACTS_DIR
ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"
export EDITOR_DIR="$ARTIFACTS_DIR/editor"
export TEMPLATES_DIR="$ARTIFACTS_DIR/templates"

# The directory where the Godot Git repository will be cloned
export GODOT_DIR="/tmp/godot"

# Delete the existing Godot Git repository (it probably is from an old build)
# then clone a fresh copy
# rm -rf "$GODOT_DIR"
# git clone --depth=1 "https://github.com/godotengine/godot.git" "$GODOT_DIR"

cd "$GODOT_DIR"

# Set the environment variables used in build naming

# Commit date (not the system date!)
export BUILD_DATE
BUILD_DATE="$(git show -s --format=%cd --date=short)"
# Short (9-character) commit hash
export BUILD_COMMIT
BUILD_COMMIT="$(git rev-parse --short=9 HEAD)"
# The final version string
export BUILD_VERSION="$BUILD_DATE.$BUILD_COMMIT"

# SCons flags to use in all build commands
export SCONS_FLAGS="progress=no -j$THREADS"

# Run the scripts

# Desktop platforms
# "$SCRIPTS_DIR/linux.sh" editor
# "$SCRIPTS_DIR/linux.sh" templates
# "$SCRIPTS_DIR/macos.sh" editor
# "$SCRIPTS_DIR/macos.sh" templates
"$SCRIPTS_DIR/windows.sh" editor
"$SCRIPTS_DIR/windows.sh" templates

# Mobile/Web platforms
# "$SCRIPTS_DIR/html5.sh"
# "$SCRIPTS_DIR/ios.sh"
# "$SCRIPTS_DIR/android.sh"

# Deploy

# "$SCRIPTS_DIR/deploy.sh"
