# XboxOCD Builder (OpenOCD-JRunner)

| Branch | Build Status |
|--------|--------------|
| [`0.11-master`](https://github.com/ExposureMG/xboxocd/releases/latest) | [![Release Build](https://github.com/ExposureMG/xboxocd/actions/workflows/release.yml/badge.svg?branch=0.11-master)](https://github.com/ExposureMG/xboxocd/actions/workflows/release.yml) |
| [`0.11-nightly`](https://github.com/ExposureMG/xboxocd/releases/tag/nightly) | [![Nightly Build](https://github.com/ExposureMG/xboxocd/actions/workflows/nightly.yml/badge.svg?branch=0.11-nightly)](https://github.com/ExposureMG/xboxocd/actions/workflows/nightly.yml) |

Hard fork of OpenOCD 0.11:
- Custom build system wrapper (Opinionated)
- DirtyJTAG Patches updated and merged
- Libraries / dependencies statically linked
- FTD2XX Re-enabled

---

## Build Instructions

Required: `mingw32-gcc`, `mingw64-gcc`, `automake`, `autoconf`, `make`, `git`, `curl`, `unzip`

### Linux (Cross-Compilation)
```bash
./build.sh          # Default: Build 32-bit Windows binary
./build.sh -w64     # Build 64-bit Windows binary
./build.sh -clean   # Clean build (re-downloads, re-configures)
./build.sh -help    # Show all CLI options
```

### Windows (Native Compilation)
```powershell
.\build.ps1                 # Default: Build 32-bit Windows binary
.\build.ps1 -Target w64     # Build 64-bit Windows binary
.\build.ps1 -Clean          # Clean build
.\build.ps1 -Help           # Show all CLI options
```

### Enabled Adapters
- `ftdi`
- `dirtyjtag`
- `cmsis-dap`

### Disabled Adapters
- xds110, osbdm, opendous, rlink, aice, usbprog
- armjtagew, kitprog, cmsis-dap-v2, nulink, rshim
- jlink, internal-libjaylink, bluenrg-x, cc3220sf, cc26xx
- ti-icdi, ulink, ft232r, vsllink, stlink
- bcm2835gpio, imx-gpio, remote-bitbang, buspirate
- sysfsgpio, xlnx-pcie-xvc
- usb-blaster, usb-blaster-2, amtjtagaccel, gw16012
- presto, openjtag, parport, jtag-vpi, jtag-dpi
- dummy, ep93xx, at91rm9200
- linuxgpiod, doxygen (html/pdf), shared libraries
