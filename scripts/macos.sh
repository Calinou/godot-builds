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
  echo_header "Building 64-bit editor for macOS…"
  scons platform=osx bits=64 tools=yes target=release_debug use_lto=yes $SCONS_FLAGS
  strip "$GODOT_DIR/bin/godot.osx.opt.tools.64"

  # Prepare the .app directory then archive it
  echo_header "Packaging editor for macOS…"
  cp -r "$GODOT_DIR/misc/dist/osx_tools.app" "$GODOT_DIR/bin/Godot.app"
  mkdir -p "$GOODT_DIR/bin/Godot.app/Contents/MacOS"
  mv "$GODOT_DIR/bin/godot.osx.opt.tools.64" "$GODOT_DIR/bin/Godot.app/Contents/MacOS/Godot"
  cd "$GODOT_DIR/bin"
  zip -r9 "Godot-macOS-x86_64.zip" "Godot.app"

  # Move the generated ZIP archive to the editor artifacts directory
  mv "$GODOT_DIR/bin/Godot-macOS-x86_64.zip" "$EDITOR_PATH"
  cd "$GODOT_DIR"

  echo_success "Finished building editor for macOS."
fi

if [ "$1" == "templates" ]; then
  echo_header "Building 64-bit debug export template for macOS…"
  scons platform=osx bits=64 tools=no target=release_debug use_lto=yes $SCONS_FLAGS
  echo_header "Building 64-bit release export template for macOS…"
  scons platform=osx bits=64 tools=no target=release use_lto=yes $SCONS_FLAGS
  strip "$GODOT_DIR/bin/godot.osx.opt.debug.64" "$GODOT_DIR/bin/godot.osx.opt.64"
  mv "$GODOT_DIR/bin/godot.osx.opt.debug.64" "$TEMPLATES_PATH"
  mv "$GODOT_DIR/bin/godot.osx.opt.64" "$TEMPLATES_PATH"

  echo_success "Finished building export templates for macOS."
fi
