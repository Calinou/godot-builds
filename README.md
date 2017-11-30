# Godot Build Scripts

This repository contains scripts for compiling Godot for various platforms.

## [Download builds](https://godot.hugo.pro/)

## Using this build system for your own builds

You are welcome to use these build scripts to set up your own build environment.
Here are some technical details:

### Supported platforms

- **Android** (ARMv7 only)
- **HTML5** (WebAssembly)
- **iOS** (ARMv8 + ARMv7)
- **Linux** (64-bit only)
- **macOS** (64-bit only)
- **Windows** (64-bit + 32-bit)

#### Additional notes

- **Linux editors come as [AppImages](https://appimage.org/).**
  - No dependencies need to be installed before running them – just download it,
    make it executable then run it!
  - These also provide substantial file size reductions thanks to the built-in
    DEFLATE compression.
- **Windows editors are packaged into installers generated using [InnoSetup](http://www.jrsoftware.org/isinfo.php).**
  - The installers do not require administrative privileges to work.
  - These also provide built-in LZMA compression, making the download faster.

### Directory structure

| File / directory | Purpose                                                              |
|-----------------:|----------------------------------------------------------------------|
| `build_godot.sh` | The main build script.                                               |
|     `resources/` | Contains resource files, such as Windows installer definition files. |
|       `scripts/` | Contains the platform-specific build and packaging scripts.          |
|     `utilities/` | Contains various utilities, such as for installing dependencies.     |

### Setting it up

This build system has been only tested on Fedora 27. Linux builds are performed
in an Ubuntu 14.04 chroot, so that the binaries can run on both old and new
distributions.

#### Environment variables

Overriding these variables is optional.

- `ARTIFACTS_DIR` can be set to an absolute path where build artifacts (binaries)
will be placed.

## License

Copyright © 2017 Hugo Locurcio and contributors

Files in this repository are licensed under CC0 1.0 Universal,
see [LICENSE.md](LICENSE.md) for more information.
