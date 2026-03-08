#!/bin/bash
rm -rf deps
mkdir -p deps
cd deps

# --- FTDI D2XX ---
if [ ! -d "ftd2xx" ]; then
    echo "--- Downloading FTDI D2XX ---"
    # The official FTDI site link
    wget --user-agent="Mozilla/5.0" https://ftdichip.com/wp-content/uploads/2025/03/CDM-v2.12.36.20-WHQL-Certified.zip -O ftd2xx.zip
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

# --- libusb-1.0 (Fixing the 302 Redirect) ---
if [ ! -d "libusb-win" ]; then
    echo "--- Downloading libusb-1 ---"
    # Using -L to follow redirects (302)
    curl -L https://github.com/libusb/libusb/releases/download/v1.0.29/libusb-1.0.29.7z -o libusb.7z
    
    if [ ! -f "libusb.7z" ]; then echo "Libusb1 download failed!"; exit 1; fi

    7z x libusb.7z -olibusb-tmp > /dev/null
    
    mkdir -p libusb-win/include/libusb-1.0
    mkdir -p libusb-win/lib

    # For 32-bit build, we take the MinGW32 static lib
    cp libusb-tmp/include/libusb.h libusb-win/include/libusb-1.0/
    cp libusb-tmp/MinGW32/static/libusb-1.0.a libusb-win/lib/ # Note: path might vary by version
    
    rm -rf libusb-tmp libusb.7z
fi

echo "--- All dependencies verified and structured ---"