#!/bin/bash
#
# This script compiles and packages Godot for Windows using MinGW and InnoSetup.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.

set -euo pipefail

# The path to the InnoSetup installation
export INNOSETUP_DIR="$TOOLS_DIR/innosetup"

# The path to ISCC.exe
export ISCC="$INNOSETUP_DIR/ISCC.exe"

# Build Godot editor or templates, depending on the first command-line argument
# Note that LTO is not available for 32-bit targets, so it is disabled when
# building for these targets

if [ "$1" == "editor" ]; then
  scons platform=windows bits=64 tools=yes target=release_debug use_lto=yes $SCONS_FLAGS
  scons platform=windows bits=32 tools=yes target=release_debug use_lto=no $SCONS_FLAGS

  strip "$GODOT_DIR/bin/godot.windows.opt.tools.64.exe" \
        "$GODOT_DIR/bin/godot.windows.opt.tools.32.exe"

  mkdir -p "$EDITOR_PATH/godot-windows-x86_64" "$EDITOR_PATH/godot-windows-x86"
  mv "$GODOT_DIR/bin/godot.windows.opt.tools.64.exe" "$EDITOR_PATH/godot-windows-x86_64/godot.exe"
  mv "$GODOT_DIR/bin/godot.windows.opt.tools.32.exe" "$EDITOR_PATH/godot-windows-x86/godot.exe"

  # Create ZIP archives
  cd "$EDITOR_PATH"
  zip -r9 "godot-windows-x86_64.zip" "godot-windows-x86_64"
  zip -r9 "godot-windows-x86.zip" "godot-windows-x86"

  # Generate Windows installers
  cd "$INNOSETUP_DIR"
  cp "$EDITOR_PATH/godot-windows-x86-64/godot.exe" "."
  wine "$ISCC" "godot.iss"
  cp "$EDITOR_PATH/godot-windows-x86/godot.exe" "."
  wine "$ISCC" "godot.iss" /DApp32Bit

  # Move installers to the artifacts path
  cp "$INSTALLER_PATH/Output/godot-windows-installer-x86_64.exe" "$EDITOR_PATH/godot-windows-installer-x86_64.exe"
  cp "$INSTALLER_PATH/Output/godot-windows-installer-x86.exe" "$EDITOR_PATH/godot-windows-installer-x86.exe"
fi

if [ "$1" == "templates" ]; then
  scons platform=windows bits=64 tools=no target=release_debug use_lto=yes $SCONS_FLAGS
  scons platform=windows bits=32 tools=no target=release_debug use_lto=no $SCONS_FLAGS
  scons platform=windows bits=64 tools=no target=release use_lto=yes $SCONS_FLAGS
  scons platform=windows bits=32 tools=no target=release use_lto=no $SCONS_FLAGS

  strip "$GODOT_DIR/bin/godot.windows.opt.debug.64.exe" \
        "$GODOT_DIR/bin/godot.windows.opt.debug.32.exe" \
        "$GODOT_DIR/bin/godot.windows.opt.64.exe" \
        "$GODOT_DIR/bin/godot.windows.opt.32.exe"

  mv "$GODOT_DIR/bin/godot.windows.opt.debug.64.exe" "$TEMPLATES_DIR/windows_64_debug.exe"
  mv "$GODOT_DIR/bin/godot.windows.opt.debug.32.exe" "$TEMPLATES_DIR/windows_32_debug.exe"
  mv "$GODOT_DIR/bin/godot.windows.opt.64.exe" "$TEMPLATES_DIR/windows_64_release.exe"
  mv "$GODOT_DIR/bin/godot.windows.opt.32.exe" "$TEMPLATES_DIR/windows_32_release.exe"
fi
