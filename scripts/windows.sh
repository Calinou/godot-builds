#!/bin/bash
#
# This script compiles and packages Godot for Windows using MinGW and InnoSetup.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.

set -euo pipefail

# The path to the Inno Setup compiler (ISCC.exe)
export ISCC="$TOOLS_DIR/innosetup/ISCC.exe"

# NOTE: LTO is not available for 32-bit targets, so it is disabled when
# building for these targets

if [ "$1" == "editor" ]; then
  echo_header "Building 64-bit editor for Windows…"
  scons platform=windows bits=64 tools=yes target=release_debug use_lto=yes $SCONS_FLAGS
  echo_header "Building 32-bit editor for Windows…"
  scons platform=windows bits=32 tools=yes target=release_debug use_lto=no $SCONS_FLAGS

  strip "$GODOT_DIR/bin/godot.windows.opt.tools.64.exe" \
        "$GODOT_DIR/bin/godot.windows.opt.tools.32.exe"

  echo_header "Packaging editors for Windows…"
  mkdir -p "$EDITOR_DIR/x86_64/Godot" "$EDITOR_DIR/x86/Godot"
  mv "$GODOT_DIR/bin/godot.windows.opt.tools.64.exe" "$EDITOR_DIR/x86_64/Godot/godot.exe"
  mv "$GODOT_DIR/bin/godot.windows.opt.tools.32.exe" "$EDITOR_DIR/x86/Godot/godot.exe"

  # Create ZIP archives
  cd "$EDITOR_DIR/x86_64"
  zip -r9 "Godot-Windows-x86_64.zip" "Godot"
  cd "$EDITOR_DIR/x86"
  zip -r9 "Godot-Windows-x86.zip" "Godot"

  # Prepare Windows installer generation
  echo_header "Generating Windows installers…"
  cd "$EDITOR_DIR"
  cp "$RESOURCES_DIR/windows/godot.iss" "."

  # Generate 64-bit Windows installer
  mv "$EDITOR_DIR/x86_64/Godot/godot.exe" "."
  wine "$ISCC" "godot.iss"

  # Generate 32-bit Windows installer
  mv "$EDITOR_DIR/x86/Godot/godot.exe" "."
  wine "$ISCC" "godot.iss" /DApp32Bit

  # Move installers to the artifacts path
  mv "$EDITOR_DIR/Output/godot-windows-installer-x86_64.exe" "$EDITOR_DIR/Godot-Windows-x86_64.exe"
  mv "$EDTIOR_DIR/Output/godot-windows-installer-x86.exe" "$EDITOR_DIR/Godot-Windows-x86.exe"

  # Remove temporary directories
  rmdir "$EDITOR_DIR/x86_64" \
        "$EDITOR_DIR/x86" \
        "$EDITOR_DIR/Output"

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
