# OpenOCD-JRunner

![Version](https://img.shields.io/badge/OpenOCD-0.10.0--dev-blue?style=for-the-badge&logo=openocd)
![Platform](https://img.shields.io/badge/Platform-Windows_i686-orange?style=for-the-badge&logo=windows)
![Build Status](https://img.shields.io/github/actions/workflow/status/ExposureMG/openocd-j-runner/dev.yml?style=for-the-badge&logo=github)


High performance, opinionated and stripped build of OpenOCD-DirtyJTAG

## Drivers
- FTD2XX
- DirtyJTAG
- CMSIS-DAP

## Changes
- All adapters and drivers stripped
- FTD2XX and DirtyJTAG enabled
- i686 (32bit) GCC MinGW-w32
- LibUSB-Win32 and LibUSB-1.0 statically linked
- VCRedist 2013 x86 statically linked
- Compile errors fixed
- Documentation stripped & Repo cleaned
- TCL Scripts cleaned

## Planned
- Update to OpenOCD 0.11 / 0.12

## Building
**Requirements:**
- GCC and MinGW64
- GNU Make
- Bash, 7z and Unzip

Note: Other build targets are certainly possible but useless for J-Runner. To change target, adjust 'HOST_TRIPLET' in script/build.sh. Different binaries for FTD2XX and Libusb will need to be linked in scripts/deps.sh.
