#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
DEPS_DIR="$BASE_DIR/deps"
VERSIONS_FILE="$DEPS_DIR/.versions"

mkdir -p "$DEPS_DIR"
cd "$DEPS_DIR"

ftdi_ver="2.12.36.20-WHQL-Certified"
libusb1_ver="1.0.29"
hidapi_ver="0.15.0"

# Derive arch from TARGET exported by build.sh
if [ "$TARGET" = "w64" ]; then
  LIBUSB_ARCH="MinGW64"
  HIDAPI_ARCH="x64"
else
  LIBUSB_ARCH="MinGW32"
  HIDAPI_ARCH="x86"
fi

# Read a stored version for a dep, returns empty string if not found
stored_ver() {
    grep "^$1=" "$VERSIONS_FILE" 2>/dev/null | cut -d= -f2
}

# Write or update a version entry in the versions file
write_ver() {
    if grep -q "^$1=" "$VERSIONS_FILE" 2>/dev/null; then
        sed -i "s/^$1=.*/$1=$2/" "$VERSIONS_FILE"
    else
        echo "$1=$2" >> "$VERSIONS_FILE"
    fi
}

# FTDI D2XX
if [ "$(stored_ver ftd2xx)" = "$ftdi_ver" ] && [ -d "ftd2xx" ]; then
    echo "--- Skipping FTDI D2XX (v$ftdi_ver already downloaded) ---"
else
    echo "--- Downloading FTDI D2XX v$ftdi_ver ---"
    rm -rf ftd2xx
    wget --user-agent="Mozilla/5.0" "https://ftdichip.com/wp-content/uploads/2025/03/CDM-v$ftdi_ver.zip" -O ftd2xx.zip
    if [ ! -f "ftd2xx.zip" ]; then echo "FTD2XX download failed!"; exit 1; fi
    unzip -q ftd2xx.zip -d ftd2xx_tmp

    mkdir -p ftd2xx/i386 ftd2xx/amd64
    cp ftd2xx_tmp/ftd2xx.h ftd2xx/
    cp ftd2xx_tmp/i386/ftd2xx.lib ftd2xx/i386/
    cp ftd2xx_tmp/amd64/ftd2xx.lib ftd2xx/amd64/

    rm -rf ftd2xx_tmp ftd2xx.zip
    write_ver ftd2xx "$ftdi_ver"
fi

# libusb-1.0
if [ "$(stored_ver libusb1)" = "$libusb1_ver" ] && [ -d "libusb-win" ]; then
    echo "--- Skipping libusb-1.0 (v$libusb1_ver already downloaded) ---"
else
    echo "--- Downloading libusb-1.0 v$libusb1_ver ---"
    rm -rf libusb-win
    curl -L "https://github.com/libusb/libusb/releases/download/v$libusb1_ver/libusb-$libusb1_ver.7z" -o libusb.7z

    if [ ! -f "libusb.7z" ]; then echo "Libusb1 download failed!"; exit 1; fi
    7z x libusb.7z -olibusb-tmp > /dev/null

    mkdir -p libusb-win/include/libusb-1.0
    mkdir -p libusb-win/lib
    cp libusb-tmp/include/libusb.h libusb-win/include/libusb-1.0/
    cp libusb-tmp/$LIBUSB_ARCH/static/libusb-1.0.a libusb-win/lib/

    rm -rf libusb-tmp libusb.7z
    write_ver libusb1 "$libusb1_ver"
fi

# hidapi
if [ "$(stored_ver hidapi)" = "$hidapi_ver" ] && [ -d "hidapi" ]; then
    echo "--- Skipping hidapi (v$hidapi_ver already downloaded) ---"
else
    echo "--- Downloading hidapi v$hidapi_ver ---"
    rm -rf hidapi
    curl -L "https://github.com/libusb/hidapi/releases/download/hidapi-$hidapi_ver/hidapi-win.zip" -o hidapi.zip

    if [ ! -f "hidapi.zip" ]; then echo "HIDAPI download failed!"; exit 1; fi
    unzip -q hidapi.zip -d hidapi_tmp

    mkdir -p hidapi/include/hidapi
    mkdir -p hidapi/lib
    cp hidapi_tmp/include/hidapi.h hidapi/include/hidapi/
    cp hidapi_tmp/$HIDAPI_ARCH/hidapi.lib hidapi/lib/

    rm -rf hidapi_tmp hidapi.zip
    write_ver hidapi "$hidapi_ver"
fi

echo "--- All dependencies verified and structured ---"
