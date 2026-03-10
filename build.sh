#!/bin/bash

# Default target is w32
export TARGET="w32"

# ─── Help ────────────────────────────────────────────────────────────────────
print_help() {
  cat <<EOF
  __  __ _               ___   ____ ____  
  \ \/ /| |__   _____  _/ _ \ / ___|  _ \ 
   \  / | '_ \ / _ \ \/ / | | | |   | | | |
   /  \ | |_) | (_) >  <| |_| | |___| |_| |
  /_/\_\|_.__/ \___/_/\_\\\___/ \____|____/ 
                               Builder

OpenOCD-JRunner Build Tool v0.1.0 (0.11) - GNU/Linux

USAGE:
  ./build.sh [OPTIONS]

OPTIONS:
  -w32        Build for Windows 32-bit (default)
  -w64        Build for Windows 64-bit
  -clean      Force full clean rebuild (re-bootstrap, re-configure, recompile)
  -nostrip    Skip stripping the output binary (stripping is on by default)
  -check      Run dependency checker only, then exit
  -help       Show this help message

EXAMPLES:
  ./build.sh                    # Incremental w32 build, strip output
  ./build.sh -w64               # Incremental w64 build, strip output
  ./build.sh -clean             # Full clean w32 build
  ./build.sh -w64 -clean        # Full clean w64 build
  ./build.sh -w64 -nostrip      # w64 build, no strip
  ./build.sh -check             # Check dependencies only
  ./build.sh -w64 -clean -nostrip  # Full clean w64 build, no strip

OUTPUT:
  Binaries are placed in:  output/openocd.exe
  Scripts are placed in:   output/scripts/
  Logs are written to:     logs/

NOTES:
  - A PowerShell equivalent is available as build.ps1 for native Windows builds.
  - Pass -clean any time the Makefile.am or configure.ac changes.
EOF
  exit 0
}

# ─── Dependency Checker ───────────────────────────────────────────────────────
check_deps() {
  local ok=1
  echo "=== Dependency Check ==="

  check_tool() {
    if command -v "$1" &>/dev/null; then
      echo "  [OK]  $1"
    else
      echo "  [!!]  $1  *** MISSING ***"
      ok=0
    fi
  }

  check_tool "i686-w64-mingw32-gcc"
  check_tool "x86_64-w64-mingw32-gcc"
  check_tool "i686-w64-mingw32-strip"
  check_tool "x86_64-w64-mingw32-strip"
  check_tool "automake"
  check_tool "autoconf"
  check_tool "libtoolize"
  check_tool "make"
  check_tool "git"
  check_tool "curl"
  check_tool "unzip"
  check_tool "tar"
  check_tool "pkg-config"

  echo ""
  if [ $ok -eq 1 ]; then
    echo "  All required tools found."
  else
    echo "  Some tools are missing. Please install them to continue."
  fi
  echo "========================"
}

# ─── Argument Parsing ─────────────────────────────────────────────────────────
CHECK_ONLY=0

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
    -clean)
      export CLEAN_BUILD=1
      shift
      ;;
    -nostrip)
      export NO_STRIP=1
      shift
      ;;
    -check)
      CHECK_ONLY=1
      shift
      ;;
    -help|--help|-h)
      print_help
      ;;
    -linux)
      echo "Linux native builds are not supported."
      exit 1
      ;;
    *)
      echo "Unknown option: $1  (use -help for usage)"
      exit 1
      ;;
  esac
done

# Run dep check always (briefly), or exit if -check only
check_deps
if [ "$CHECK_ONLY" = "1" ]; then exit 0; fi

# ─── Setup ────────────────────────────────────────────────────────────────────
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

echo ""
cat <<'EOF'
  __  __ _               ___   ____ ____  
  \ \/ /| |__   _____  _/ _ \ / ___|  _ \ 
   \  / | '_ \ / _ \ \/ / | | | |   | | | |
   /  \ | |_) | (_) >  <| |_| | |___| |_| |
  /_/\_\|_.__/ \___/_/\_\\___/ \____|____/ 
                               Builder
EOF
echo ""
echo "OpenOCD-JRunner Build Tool v0.1.0 (0.11) - GNU/Linux"
echo "Building for $TARGET"
echo "Log: $LOG_TMP"

cd "$BASE_DIR"
chmod +x scripts/bash/*

# ─── Bootstrap ────────────────────────────────────────────────────────────────
echo "--- Bootstrapping ---"
if [ "$CLEAN_BUILD" = "1" ] && [ -f "config.status" ]; then
  echo "Clean build requested, cleaning first..."
  ./scripts/bash/clean.sh
fi

if [ "$CLEAN_BUILD" = "1" ] || [ ! -f "configure" ]; then
  ./bootstrap
else
  echo "Skipping bootstrap (already present)"
fi

# ─── Submodules ───────────────────────────────────────────────────────────────
echo "--- Downloading submodules ---"
if [ "$CLEAN_BUILD" = "1" ] || [ ! -e "jimtcl/configure" ]; then
  git submodule init
  git submodule update
else
  echo "Skipping submodules (already present)"
fi

# ─── Dependencies ─────────────────────────────────────────────────────────────
echo "--- Downloading dependencies ---"
./scripts/bash/deps.sh
if [ ! -f "$DEPS_DIR/ftd2xx/i386/ftd2xx.lib" ]; then echo "ERROR: Dependency download failed! (FTD2XX)"; exit 1; fi
if [ ! -f "$DEPS_DIR/libusb-win/include/libusb-1.0/libusb.h" ]; then echo "ERROR: Dependency download failed! (Libusb-1)"; exit 1; fi

# ─── Build ────────────────────────────────────────────────────────────────────
./scripts/bash/build.sh
if [ ! -f "src/openocd.exe" ]; then echo "ERROR: Build failed! (scripts/build.sh)"; exit 1; fi

# Determine strip command based on TARGET
TARGET_STRIP="i686-w64-mingw32-strip"
if [ "$TARGET" = "w64" ]; then
  TARGET_STRIP="x86_64-w64-mingw32-strip"
fi
export TARGET_STRIP

# ─── Extract Output ───────────────────────────────────────────────────────────
echo "--- Extracting Output ---"
if [ "$CLEAN_BUILD" = "1" ]; then
  echo "Running full clean..."
  ./scripts/bash/clean.sh
else
  if [ -f "src/openocd.exe" ]; then
    if [ "$NO_STRIP" != "1" ]; then
      echo "Stripping binary..."
      $TARGET_STRIP src/openocd.exe
    else
      echo "Skipping strip (-nostrip passed)"
    fi
    mkdir -p output
    cp src/openocd.exe output/
    cp -r tcl/ output/scripts
  fi
fi

if [ ! -f "output/openocd.exe" ]; then echo "ERROR: Build/Extract failed! No openocd.exe in output"; exit 1; fi

echo "--- Build Complete! Check output folder ---"
