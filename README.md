# OpenOCD-JRunner
![Build Status](https://github.com/ExposureMG/openocd-j-runner/actions/workflows/main.yml/badge.svg)
Forked version of OpenOCD-DirtyJTAG designed for use with [J-Runner with Extras]()

## Changes
- Complete Build Script (Linux x86 / amd64 -> Windows i686) (Tested working 8th March 2026)
- Significantly slim down repo
- Fix compile errors

## Building
**Requirements:**
- Linux, BSD or WSL2
- GCC
- MinGW64
- GNU Make
- Bash, 7z and Unzip

**Build.sh will download, configure, build and cleanup OpenOCD-JRunner**
### Build.sh options
- Disable all adapters & drivers
- Disable included documentation
- Enable Libusb0 (Lib32-Libusb) and FTDI (FTD2XX)
- Enable DirtyJTAG and FT2232 Adapters

Note: Other targets are certainly possible but useless for J-Runner. To change target, adjust 'HOST_TRIPLET' in script/build.sh. Different binaries for FTD2XX and Libusb will need to be linked in scripts/deps.sh.