# OpenOCD-JRunner

![Version](https://img.shields.io/badge/OpenOCD-0.10.0--dev-blue?style=for-the-badge&logo=openocd)
![Build Size](https://img.shields.io/badge/Size-3.3_MiB-success?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Windows_x86-orange?style=for-the-badge&logo=windows)
![Build Status](https://img.shields.io/github/actions/workflow/status/ExposureMG/openocd-j-runner/c-cpp.yml?style=for-the-badge&logo=github)


High performance, stripped build of OpenOCD-DirtyJTAG

## Changes
- All adapters and drivers stripped
- FTD2XX and DirtyJTAG enabled
- i686 (32bit) using Libusb0
- Compile errors fixed
- Documentation stripped & Repo cleaned

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
