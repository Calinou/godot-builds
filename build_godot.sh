#!/bin/bash
#
# This script compiles and packages Godot for various platforms.
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail

# `DIR` contains the directory where the script is located, regardless of where it is run from
# This makes it easy to run this set of build scripts from any location
export DIR
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Common directories used in the script
export SCRIPTS_DIR
SCRIPTS_DIR="$DIR/scripts"
# The directory where utility scripts are located
export UTILITIES_DIR
UTILITIES_DIR="$DIR/utilities"
# The directory where build artifacts will be copied
export ARTIFACTS_DIR
ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"

# Settings

# The directory where the Godot Git repository will be cloned
export GODOT_DIR="/tmp/godot"

# Delete the existing Godot Git repository (it probably is from an old build)
# then clone a fresh copy
rm -rf "$GODOT_DIR"
git clone --depth=1 "https://github.com/godotengine/godot.git" "$GODOT_DIR"

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

# Run the scripts

# Desktop platforms
"scripts/build_linux.sh" editor
"scripts/build_linux.sh" templates
# "scripts/build_macos.sh" editor
# "scripts/build_macos.sh" templates
"scripts/build_windows.sh" editor
"scripts/build_windows.sh" templates

# Mobile/Web platforms
# "scripts/build_html5.sh"
# "scripts/build_ios.sh"
# "scripts/build_android.sh"

# Deploy

# "scripts/deploy.sh"
