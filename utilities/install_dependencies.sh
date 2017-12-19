#!/bin/bash
#
# This script installs dependencies required to compile Godot.
# Only Fedora and Ubuntu are currently supported.
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail

# Path to the Xcode DMG image
export XCODE_DMG="$DIR/Xcode_7.3.1.dmg"

echo -e "\n\e[4mInstalling dependencies (administrative privileges may be required)\e[0m\n"

# Display a warning message if no Xcode DMG is found
if [ ! -f "$XCODE_DMG" ]; then
  echo -e "\e[1;33mNOTE:\e[0m Couldn't find a Xcode 7.3.1 DMG image.\nIf you want to build for macOS and iOS, download it from here (requires a free Apple Developer ID):\n\e[1mhttps://developer.apple.com/download/more/\e[0m\n"
fi

# Install system packages

if [ -f "/etc/redhat-release" ]; then
  # Fedora
  sudo dnf update -y
  sudo dnf install -y git cmake scons pkgconfig gcc-c++ curl libxml2-devel libX11-devel \
                      libXcursor-devel libXrandr-devel libXinerama-devel mesa-libGL-devel \
                      alsa-lib-devel pulseaudio-libs-devel freetype-devel \
                      openssl-devel libudev-devel mesa-libGLU-devel mingw32-gcc-c++ mingw64-gcc-c++ \
                      mingw32-winpthreads-static mingw64-winpthreads-static wine \
                      llvm-devel uuid-devel xar-devel fuse-devel
else
  # Ubuntu
  sudo apt-get update -y
  sudo apt-get install -y openssh-client git cmake curl build-essential scons \
                          pkg-config libx11-dev libxcursor-dev libxinerama-dev \
                          libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev \
                          libfreetype6-dev libssl-dev libudev-dev libxrandr-dev
fi

mkdir -p "$TOOLS_DIR"

# Install InnoSetup

if [  -d "$TOOLS_DIR/innosetup" ]; then
  curl -o "$TOOLS_DIR/innosetup.zip" "https://archive.hugo.pro/.public/godot-builds/innosetup-5.5.9-unicode.zip"
  unzip -q "$TOOLS_DIR/innosetup.zip" -d "$TOOLS_DIR"
  rm "$TOOLS_DIR/innosetup.zip"
fi

# Install the Android SDK

if [  -d "$TOOLS_DIR/android" ]; then
  # Download and extract the SDK
  curl -o "$TOOLS_DIR/android.zip" "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
  # The SDK tools must be located in `$TOOLS_DIR/android/tools` as
  # other directories will exist within `$TOOLS_DIR/android`
  mkdir "$TOOLS_DIR/android"
  unzip -q "$TOOLS_DIR/android.zip" -d "$TOOLS_DIR/android"
  rm "$TOOLS_DIR/android.zip"
fi

# If the user provides an Xcode DMG image, install OSXCross
# (which includes darling-dmg)

if [ -f "$XCODE_DMG" ] && [ ! -d "$TOOLS_DIR/osxcross" ] && [ ! -d "$TOOLS_DIR/cctools-port" ]; then
  # OSXCross (for macOS builds)
  curl -o "$TOOLS_DIR/osxcross.zip" "https://codeload.github.com/tpoechtrager/osxcross/zip/master"
  unzip -q "$TOOLS_DIR/osxcross.zip" -d "$TOOLS_DIR"
  mv "$TOOLS_DIR/osxcross-master" "$TOOLS_DIR/osxcross"
  cd "$TOOLS_DIR/osxcross"
  tools/gen_sdk_package_darling_dmg.sh "$XCODE_DMG"
  mv "*.tar.xz" "$TOOLS_DIR/osxcross/tarballs"
  UNATTENDED=1 ./build.sh

  # cctools-port (for iOS builds)
  curl -o "$TOOLS_DIR/cctools-port.zip" "https://github.com/tpoechtrager/cctools-port/archive/master.zip"
  unzip -q "$TOOLS_DIR/cctools-port.zip" -d "$TOOLS_DIR"
  mv "TOOLS_DIR/cctools-port-master" "$TOOLS_DIR/cctools-port"
fi
