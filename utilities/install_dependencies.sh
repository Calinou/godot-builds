#!/bin/bash
#
# This script installs dependencies required to compile Godot.
# Only Fedora and Ubuntu are currently supported.
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail

# TODO: install WINE and MinGW on Fedora for Windows builds
if [ -f "/etc/redhat-release" ]; then
  # Fedora
  dnf update -y
  dnf install -y git cmake ruby scons pkgconfig wget gcc-c++ libX11-devel libXcursor-devel \
                 libXrandr-devel libXinerama-devel mesa-libGL-devel \
                 alsa-lib-devel pulseaudio-libs-devel freetype-devel \
                 openssl-devel libudev-devel mesa-libGLU-devel
else
  # Ubuntu
  apt-get update -y
  apt-get install -y openssh-client git cmake wget ruby build-essential scons \
                     pkg-config libx11-dev libxcursor-dev libxinerama-dev \
                     libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev \
                     libfreetype6-dev libssl-dev libudev-dev libxrandr-dev
fi

# Install InnoSetup

curl -o "$TOOLS_DIR/innosetup.zip" "https://archive.hugo.pro/.public/godot-builds/innosetup-5.5.9-unicode.zip"
unzip "$TOOLS_DIR/innosetup.zip" -d "$TOOLS_DIR"
rm "$TOOLS_DIR/innosetup.zip"
