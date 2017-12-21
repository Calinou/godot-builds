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
  echo_header "Building 64-bit editor for Windows…"
  scons platform=windows bits=64 tools=yes target=release_debug use_lto=yes $SCONS_FLAGS
  echo_header "Building 32-bit editor for Windows…"
  scons platform=windows bits=32 tools=yes target=release_debug use_lto=no $SCONS_FLAGS

  strip "$GODOT_DIR/bin/godot.windows.opt.tools.64.exe" \
        "$GODOT_DIR/bin/godot.windows.opt.tools.32.exe"

  echo_header "Packaging editors for Windows…"
  mkdir -p "$EDITOR_PATH/x86_64/Godot" "$EDITOR_PATH/x86/Godot"
  mv "$GODOT_DIR/bin/godot.windows.opt.tools.64.exe" "$EDITOR_PATH/x86_64/Godot/godot.exe"
  mv "$GODOT_DIR/bin/godot.windows.opt.tools.32.exe" "$EDITOR_PATH/x86/Godot/godot.exe"

  # Create ZIP archives
  cd "$EDITOR_PATH/x86_64"
  zip -r9 "Godot-Windows-x86_64.zip" "Godot"
  cd "$EDITOR_PATH/x86"
  zip -r9 "Godot-Windows-x86.zip" "Godot"

  # Generate Windows installers
  echo_header "Generating Windows installers…"
  cd "$INNOSETUP_DIR"
  mv "$EDITOR_PATH/x86_64/Godot/godot.exe" "."
  wine "$ISCC" "godot.iss"
  mv "$EDITOR_PATH/x86/Godot/godot.exe" "."
  wine "$ISCC" "godot.iss" /DApp32Bit

  # Remove temporary directories
  rmdir "$EDITOR_PATH/x86_64" "$EDITOR_PATH/x86"

  # Move installers to the artifacts path
  cp "$INSTALLER_PATH/Output/godot-windows-installer-x86_64.exe" "$EDITOR_PATH/Godot-Windows-x86_64.exe"
  cp "$INSTALLER_PATH/Output/godot-windows-installer-x86.exe" "$EDITOR_PATH/Godot-Windows-x86.exe"

  echo_success "Finished building editor for Windows."
fi

if [ "$1" == "templates" ]; then
  echo_header "Building 64-bit debug export template for Windows…"
  scons platform=windows bits=64 tools=no target=release_debug use_lto=yes $SCONS_FLAGS
  echo_header "Building 32-bit debug export template for Windows…"
  scons platform=windows bits=32 tools=no target=release_debug use_lto=no $SCONS_FLAGS
  echo_header "Building 64-bit release export template for Windows…"
  scons platform=windows bits=64 tools=no target=release use_lto=yes $SCONS_FLAGS
  echo_header "Building 32-bit release export template for Windows…"
  scons platform=windows bits=32 tools=no target=release use_lto=no $SCONS_FLAGS

  strip "$GODOT_DIR/bin/godot.windows.opt.debug.64.exe" \
        "$GODOT_DIR/bin/godot.windows.opt.debug.32.exe" \
        "$GODOT_DIR/bin/godot.windows.opt.64.exe" \
        "$GODOT_DIR/bin/godot.windows.opt.32.exe"

  mv "$GODOT_DIR/bin/godot.windows.opt.debug.64.exe" "$TEMPLATES_DIR/windows_64_debug.exe"
  mv "$GODOT_DIR/bin/godot.windows.opt.debug.32.exe" "$TEMPLATES_DIR/windows_32_debug.exe"
  mv "$GODOT_DIR/bin/godot.windows.opt.64.exe" "$TEMPLATES_DIR/windows_64_release.exe"
  mv "$GODOT_DIR/bin/godot.windows.opt.32.exe" "$TEMPLATES_DIR/windows_32_release.exe"

  echo_success "Finsished building export templates for Windows."
fi
