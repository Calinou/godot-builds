#!/bin/bash
#
# This script compiles Godot for Linux using GCC.
#
# Copyright © 2017 Hugo Locurcio and contributors - CC0 1.0 Universal
# See `LICENSE.md` included in the source distribution for details.

set -euo pipefail

if [ "$1" == "editor" ]; then
  # Build editor
  echo_header "Building 64-bit editor for Linux…"
  scons platform=x11 bits=64 tools=yes target=release_debug use_lto=yes $SCONS_FLAGS
  strip "$GODOT_DIR/bin/godot.x11.opt.tools.64"

  # Move the editor binary over
  mv "$GODOT_DIR/bin/godot.x11.opt.tools.64" "$EDITOR_DIR"

  echo_success "Finished building editor for Linux."
fi

if [ "$1" == "templates" ]; then
  # Build export templates
  echo_header "Building 64-bit debug export template for Linux…"
  scons platform=x11 bits=64 tools=no target=release_debug use_lto=yes $SCONS_FLAGS
  echo_header "Building 64-bit release export template for Linux…"
  scons platform=x11 bits=64 tools=no target=release use_lto=yes $SCONS_FLAGS
  strip "$GODOT_DIR/bin/godot.x11.opt.debug.64" "$GODOT_DIR/bin/godot.x11.opt.64"

  # Move export templates over
  mv "$GODOT_DIR/bin/godot.x11.opt.debug.64" "$TEMPLATES_DIR"
  mv "$GODOT_DIR/bin/godot.x11.opt.64" "$TEMPLATES_DIR"

  echo_success "Finished building export templates for Linux."
fi
