#!/bin/bash

# Default target is w32
export TARGET="w32"

while [[ $# -gt 0 ]]; do
  case $1 in
    -w32)
      export TARGET="w32"
      shift
      ;;
    -w64)
      export TARGET="w64"
      shift
      ;;
    -linux)
      echo "Linux unsupported"
      exit 1
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEPS_DIR="$BASE_DIR/deps"
LOG_DIR="$BASE_DIR/logs"
LOG_TIMESTAMP="$(date -u +%Y-%m-%dT%H-%M-%S)"
LOG_TMP="$LOG_DIR/build-${LOG_TIMESTAMP}.log"

mkdir -p "$LOG_DIR"
mkdir -p "$BASE_DIR/output"

# Rename log with result suffix on exit
finalize_log() {
  local exit_code=$?
  if [ $exit_code -eq 0 ]; then
    mv "$LOG_TMP" "${LOG_TMP%.log}-success.log"
  else
    mv "$LOG_TMP" "${LOG_TMP%.log}-fail.log"
  fi
}
trap finalize_log EXIT

# Tee all output to a log file while keeping it visible in the terminal
exec > >(tee "$LOG_TMP") 2>&1

echo "OpenOCD-JRunner Build Tool v0.1.0 (0.11) - GNU/Linux"
echo "Building for $TARGET"
echo "Log: $LOG_TMP"

cd "$BASE_DIR"
chmod +x scripts/*

echo "--- Bootstrapping ---"
if [ -f "config.status" ]; then
  echo "Previous build detected, cleaning first..."
  ./scripts/clean.sh
fi
./bootstrap

echo "--- Downloading submodules ---"
git submodule init
git submodule update

echo "--- Downloading dependencies ---"
./scripts/deps.sh
if [ ! -f "$DEPS_DIR/ftd2xx/i386/ftd2xx.lib" ]; then echo "ERROR: Dependency download failed! (FTD2XX)"; exit 1; fi
if [ ! -f "$DEPS_DIR/libusb-win/include/libusb-1.0/libusb.h" ]; then echo "ERROR: Dependency download failed! (Libusb-1)"; exit 1; fi

./scripts/build.sh
if [ ! -f "src/openocd.exe" ]; then echo "ERROR: Build failed! (scripts/build.sh)"; exit 1; fi

echo "--- Cleaning up ---"
./scripts/clean.sh
if [ ! -f "output/openocd.exe" ]; then echo "ERROR: Clean failed! (scripts/clean.sh)"; exit 1; fi

echo "--- Build Complete! Check output folder ---"
