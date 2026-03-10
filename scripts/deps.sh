#!/bin/bash
rm -rf deps
mkdir -p deps
cd deps

ftd2xx_ver = "2.12.36.20-WHQL-Certified"
libusb_ver = "1.2.7.3"

# --- FTDI D2XX ---
if [ ! -d "ftd2xx" ]; then
    echo "--- Downloading FTDI D2XX ---"
    # The official FTDI site link
    wget --user-agent="Mozilla/5.0" https://ftdichip.com/wp-content/uploads/2025/03/CDM-v$ftd2xx_ver.zip -O ftd2xx.zip
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

# --- libusb-0 ---
if [ ! -d "libusb-win32" ]; then
    echo "--- Downloading libusb-win32 ---"
    # Using -L to follow redirects (302)
    curl -L https://netix.dl.sourceforge.net/project/libusb-win32/libusb-win32-releases/1.2.7.3/libusb-win32-bin-1.2.7.3.zip -o libusb.zip
    
    if [ ! -f "libusb.zip" ]; then echo "Libusb0 download failed!"; exit 1; fi

    unzip libusb.zip -o libusb-tmp > /dev/null
    
    mkdir -p libusb-win32/include/libusb-0 libusb-win32/lib
    
    cp libusb-tmp/libusb-win32-bin-1.2.7.3/include/lusb0_usb.h libusb-win32/include/libusb-0/libusb.h
    cp libusb-tmp/libusb-win32-bin-1.2.7.3/lib/gcc/libusb.a libusb-win32/lib/libusb.a
    
    rm -rf libusb-tmp libusb.zip
fi

echo "--- All dependencies verified and structured ---"