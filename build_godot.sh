#!/bin/bash
#
# This script compiles and packages Godot for various platforms.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.

set -euo pipefail

# Helper functions

# Output an underlined line in standard output
echo_header() {
  echo -e "\e[1;4m$1\e[0m"
}

# Output a successful build step
echo_success() {
  echo -e "\e[1;4;32m$1\e[0m"
}

export -f echo_header
export -f echo_success

# Variables

# `DIR` contains the directory where the script is located, regardless of where
# it is run from. This makes it easy to run this set of build scripts from any
# location
export DIR
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Specify the number of CPU threads to use as the first command line argument
# If not set, defaults to 1.5 times the number of CPU threads
export THREADS="${1:-"$(($(nproc) * 3/2))"}"

# Common directories used in the script
export SCRIPTS_DIR="$DIR/scripts"

# The directory where utility scripts are located
export UTILITIES_DIR="$DIR/utilities"

# The directory where resource files are located
export RESOURCES_DIR="$DIR/resources"

# The directory where SDKs and tools like InnoSetup are located
export TOOLS_DIR="$DIR/tools"

# The directory where build artifacts will be copied
# EDITOR_DIR and TEMPLATES_DIR are used by platform-specific scripts
export ARTIFACTS_DIR="${ARTIFACTS_DIR:-"$DIR/artifacts"}"
export EDITOR_DIR="$ARTIFACTS_DIR/editor"
export TEMPLATES_DIR="$ARTIFACTS_DIR/templates"

# The directory where the Godot Git repository will be cloned
export GODOT_DIR="/tmp/godot"

# Install or update dependencies
"$UTILITIES_DIR/install_dependencies.sh"

mkdir -p "$EDITOR_DIR" "$TEMPLATES_DIR"

# Delete the existing Godot Git repository (it probably is from an old build)
# then clone a fresh copy
rm -rf "$GODOT_DIR"
echo_header "Cloning Godot Git repository…"
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

# SCons flags to use in all build commands
export SCONS_FLAGS="progress=no debug_symbols=no -j$THREADS"

# Run the scripts

# Desktop platforms
"$SCRIPTS_DIR/linux.sh" editor
"$SCRIPTS_DIR/linux.sh" templates
"$SCRIPTS_DIR/macos.sh" editor
"$SCRIPTS_DIR/macos.sh" templates
"$SCRIPTS_DIR/windows.sh" editor
"$SCRIPTS_DIR/windows.sh" templates

# Mobile/Web platforms
# "$SCRIPTS_DIR/html5.sh"
# "$SCRIPTS_DIR/ios.sh"
"$SCRIPTS_DIR/android.sh"

# Deploy

# "$SCRIPTS_DIR/deploy.sh"
