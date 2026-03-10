#!/bin/bash

if [ -f "src/openocd.exe" ]; then
  if [ "$NO_STRIP" != "1" ]; then
    _STRIP="${TARGET_STRIP:-${STRIP:-i686-w64-mingw32-strip}}"
    echo "Stripping binary (using $_STRIP)..."
    $_STRIP src/openocd.exe
  else
    echo "Skipping strip (-nostrip passed)"
  fi
  mkdir -p output
  cp src/openocd.exe output/
  cp -r tcl/ output/scripts
fi
make clean
make distclean
