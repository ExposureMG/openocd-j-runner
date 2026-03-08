#!/bin/bash
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEPS_DIR="$BASE_DIR/deps"
rm -rf output/
cd "$BASE_DIR"

echo "OpenOCD-JRunner Build Tool v0.0.1 - GNU/Linux"
chmod +x scripts/*

echo "--- Bootstrapping ---"
./bootstrap

echo "--- Downloading submodules ---"
git submodule init
git submodule update

echo "--- Downloading dependencies ---"
./scripts/deps.sh
if [ ! -f "$DEPS_DIR/ftd2xx/i386/ftd2xx.lib" ]; then echo "ERROR: Dependency download failed! (FTD2XX)"; exit 1; fi
if [ ! -f "$DEPS_DIR/libusb-win/include/libusb-1.0/libusb.h" ]; then echo "ERROR: Dependency download failed! (Libusb-1)"; exit 1; fi

./scripts/build.sh
rm -rf $DEPS_DIR
if [ ! -f "src/openocd.exe" ]; then echo "ERROR: Build failed! (scripts/build.sh)"; exit 1; fi

echo "--- Cleaning up ---"
./scripts/clean.sh
if [ ! -f "output/openocd.exe" ]; then echo "ERROR: Clean failed! (scripts/clean.sh)"; exit 1; fi

echo "--- Build Complete! Check output folder ---"