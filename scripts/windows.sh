#!/bin/bash
#
# This script compiles and packages Godot for Windows using MinGW and InnoSetup.
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail

# Build Godot editor or templates, depending on the first command-line argument
# Note that LTO is not available for 32-bit targets, so it is disabled when
# building for these targets

if [ "$1" == "editor" ]; then
  scons platform=windows bits=64 tools=yes target=release_debug use_lto=yes -j$THREADS
  scons platform=windows bits=32 tools=yes target=release_debug use_lto=no -j$THREADS

  strip "$GODOT_BIN_DIR/godot.windows.opt.tools.64.exe" \
        "$GODOT_BIN_DIR/godot.windows.opt.tools.32.exe"

  mv "$GODOT_BIN_DIR/godot.windows.opt.tools.64.exe" "$ARTIFACTS_PATH"
  mv "$GODOT_BIN_DIR/godot.windows.opt.tools.32.exe" "$ARTIFACTS_PATH"
fi

if [ "$1" == "templates" ]; then
  scons platform=windows bits=64 tools=no target=release_debug use_lto=yes -j$THREADS
  scons platform=windows bits=32 tools=no target=release_debug use_lto=no -j$THREADS
  scons platform=windows bits=64 tools=no target=release use_lto=yes -j$THREADS
  scons platform=windows bits=32 tools=no target=release use_lto=no -j$THREADS

  strip "$GODOT_BIN_DIR/godot.windows.opt.debug.64.exe" \
        "$GODOT_BIN_DIR/godot.windows.opt.debug.32.exe" \
        "$GODOT_BIN_DIR/godot.windows.opt.64.exe" \
        "$GODOT_BIN_DIR/godot.windows.opt.32.exe"

  mv "$GODOT_BIN_DIR/godot.windows.opt.debug.64.exe" "$ARTIFACTS_PATH"
  mv "$GODOT_BIN_DIR/godot.windows.opt.debug.32.exe" "$ARTIFACTS_PATH"
  mv "$GODOT_BIN_DIR/godot.windows.opt.64.exe" "$ARTIFACTS_PATH"
  mv "$GODOT_BIN_DIR/godot.windows.opt.32.exe" "$ARTIFACTS_PATH"
fi

# Generate Windows installers
cd "$INSTALLER_PATH"
cp "$GODOT_PATH/bin/godot.windows.opt.tools.64.exe" "godot.exe"
wine "$ISCC" "godot.iss"
cp "$GODOT_PATH/bin/godot.windows.opt.tools.32.exe" "godot.exe"
wine "$ISCC" "godot.iss" /DApp32Bit

# Move installers to the artifacts path
cp "$INSTALLER_PATH/Output/godot-windows-installer-x86_64.exe" "$ARTIFACTS_PATH"
cp "$INSTALLER_PATH/Output/godot-windows-installer-x86.exe" "$ARTIFACTS_PATH"
