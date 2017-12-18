#!/bin/bash
#
# This script installs dependencies required to compile Godot.
# Only Fedora and Ubuntu are currently supported.
#
# This script is licensed under CC0 1.0 Universal:
# https://creativecommons.org/publicdomain/zero/1.0/

set -euo pipefail

# The Android SDK components required to build Godot for Android
export ANDROID_SDK_COMPONENTS="platform-tools build-tools;27.0.2 extras;android;m2repository ndk-bundle"

# Install system packages

if [ -f "/etc/redhat-release" ]; then
  # Fedora
  sudo dnf update -y
  sudo dnf install -y git cmake ruby scons pkgconfig wget gcc-c++ libX11-devel libXcursor-devel \
                 libXrandr-devel libXinerama-devel mesa-libGL-devel \
                 alsa-lib-devel pulseaudio-libs-devel freetype-devel \
                 openssl-devel libudev-devel mesa-libGLU-devel mingw32-gcc-c++ mingw64-gcc-c++ \
                 mingw32-winpthreads-static mingw64-winpthreads-static wine
else
  # Ubuntu
  sudo apt-get update -y
  sudo apt-get install -y openssh-client git cmake wget ruby build-essential scons \
                     pkg-config libx11-dev libxcursor-dev libxinerama-dev \
                     libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev \
                     libfreetype6-dev libssl-dev libudev-dev libxrandr-dev
fi

mkdir -p "$TOOLS_DIR"

# Install InnoSetup

if [ ! -d "$TOOLS_DIR/innosetup" ]; then
  curl -o "$TOOLS_DIR/innosetup.zip" "https://archive.hugo.pro/.public/godot-builds/innosetup-5.5.9-unicode.zip"
  unzip "$TOOLS_DIR/innosetup.zip" -d "$TOOLS_DIR"
  rm "$TOOLS_DIR/innosetup.zip"
fi

# Install the Android SDK, its required components and the Android NDK

if [ ! -d "$TOOLS_DIR/android" ]; then
  # Download and extract the SDK
  mkdir "$TOOLS_DIR/android"
  curl -o "$TOOLS_DIR/android.zip" "https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
  unzip "$TOOLS_DIR/android.zip" -d "$TOOLS_DIR/android"
  rm "$TOOLS_DIR/android.zip"
fi

# Install the required components and NDK

cd "$TOOLS_DIR/android/tools/bin"
# Copy the license directory over
cp -r "$RESOURCES_DIR/android/licenses" "$TOOLS_DIR/android"
# Run the command-line SDK manager to install the components
# Note: the variable must not be surrounded by double quotes for this to work
./sdkmanager $ANDROID_SDK_COMPONENTS
