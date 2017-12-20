#!/bin/bash
#
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.

set -euo pipefail

# Build Godot editor or templates, depending on the first command-line argument

if [ "$1" == "editor" ]; then
  scons platform=x11 bits=64 tools=yes target=release_debug use_lto=yes $SCONS_FLAGS
  strip "$GODOT_BIN_DIR/godot.x11.opt.tools.64"
  mv "$GODOT_BIN_DIR/godot.x11.opt.tools.64" "$ARTIFACTS_PATH"
fi

if [ "$1" == "templates" ]; then
  scons platform=x11 bits=64 tools=no target=release_debug use_lto=yes $SCONS_FLAGS
  scons platform=x11 bits=64 tools=no target=release use_lto=yes $SCONS_FLAGS
  strip "$GODOT_BIN_DIR/godot.x11.opt.debug.64" "$GODOT_BIN_DIR/godot.x11.opt.64"
  mv "$GODOT_BIN_DIR/godot.x11.opt.debug.64" "$ARTIFACTS_PATH"
  mv "$GODOT_BIN_DIR/godot.x11.opt.64" "$ARTIFACTS_PATH"
fi
