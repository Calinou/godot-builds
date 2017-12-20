#!/bin/bash
#
# This script compiles Godot for macOS using OSXCross.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.

set -euo pipefail

# The path to the OSXCross installation
export OSXCROSS_ROOT="$TOOLS_DIR/osxcross"

# Specify the macOS SDK version as SCons defaults to darwin14
export SCONS_FLAGS="$SCONS_FLAGS osxcross_sdk=darwin15"

# Build Godot editor or templates, depending on the first command-line argument

if [ "$1" == "editor" ]; then
  scons platform=osx bits=64 tools=yes target=release_debug use_lto=yes $SCONS_FLAGS
  strip "$GODOT_BIN_DIR/godot.osx.opt.tools.64"
  mv "$GODOT_BIN_DIR/godot.osx.opt.tools.64" "$ARTIFACTS_PATH"
fi

if [ "$1" == "templates" ]; then
  scons platform=osx bits=64 tools=no target=release_debug use_lto=yes $SCONS_FLAGS
  scons platform=osx bits=64 tools=no target=release use_lto=yes $SCONS_FLAGS
  strip "$GODOT_BIN_DIR/godot.osx.opt.debug.64" "$GODOT_BIN_DIR/godot.osx.opt.64"
  mv "$GODOT_BIN_DIR/godot.osx.opt.debug.64" "$ARTIFACTS_PATH"
  mv "$GODOT_BIN_DIR/godot.osx.opt.64" "$ARTIFACTS_PATH"
fi
