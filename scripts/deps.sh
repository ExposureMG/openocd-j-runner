#!/bin/bash
rm -rf deps
mkdir -p deps
cd deps

ftdi_ver="2.12.36.20-WHQL-Certified"
libusb0_ver="1.2.7.3"
libusb1_ver="1.0.29"

# FTDI D2XX
if [ ! -d "ftd2xx" ]; then
    echo "--- Downloading FTDI D2XX v$ftdi_ver ---"
    wget --user-agent="Mozilla/5.0" https://ftdichip.com/wp-content/uploads/2025/03/CDM-v$ftdi_ver.zip -O ftd2xx.zip
    if [ ! -f "ftd2xx.zip" ]; then echo "FTD2XX download failed!"; exit 1; fi
    unzip -q ftd2xx.zip -d ftd2xx_tmp
    
    # OpenOCD expects specific layout. Let's flatten it.
    mkdir -p ftd2xx
    cp ftd2xx_tmp/ftd2xx.h ftd2xx/
    mkdir -p ftd2xx/i386 ftd2xx/amd64
    cp ftd2xx_tmp/i386/ftd2xx.lib ftd2xx/i386/
    cp ftd2xx_tmp/amd64/ftd2xx.lib ftd2xx/amd64/
    
    rm -rf ftd2xx_tmp ftd2xx.zip
fi

# libusb-0
if [ ! -d "libusb-win32" ]; then
    echo "--- Downloading libusb-win32 v$libusb0_ver ---"
    curl -L https://netix.dl.sourceforge.net/project/libusb-win32/libusb-win32-releases/$libusb0_ver/libusb-win32-bin-$libusb0_ver.zip -o libusb.zip
    
    if [ ! -f "libusb.zip" ]; then echo "Libusb0 download failed!"; exit 1; fi

    unzip libusb.zip -d libusb-tmp > /dev/null
    
    mkdir -p libusb-win32/include/libusb-win32 libusb-win32/lib
    
    cp libusb-tmp/libusb-win32-bin-$libusb0_ver/include/lusb0_usb.h libusb-win32/include/libusb-win32/libusb.h
    cp libusb-tmp/libusb-win32-bin-$libusb0_ver/lib/gcc/libusb.a libusb-win32/lib/libusb.a
    
    rm -rf libusb-tmp libusb.zip
fi

# libusb-1.0
if [ ! -d "libusb-win" ]; then
    echo "--- Downloading libusb-1 v$libusb1_ver ---"
    curl -L https://github.com/libusb/libusb/releases/download/v$libusb1_ver/libusb-$libusb1_ver.7z -o libusb.7z
    
    if [ ! -f "libusb.7z" ]; then echo "Libusb1 download failed!"; exit 1; fi

    7z x libusb.7z -olibusb-tmp > /dev/null
    
    mkdir -p libusb-win/include/libusb-1.0
    mkdir -p libusb-win/lib

    cp libusb-tmp/include/libusb.h libusb-win/include/libusb-1.0/
    cp libusb-tmp/MinGW32/static/libusb-1.0.a libusb-win/lib/
    
    rm -rf libusb-tmp libusb.7z
fi

echo "--- All dependencies verified and structured ---"