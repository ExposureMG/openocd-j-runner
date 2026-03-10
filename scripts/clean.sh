if [ -f "src/openocd.exe" ]; then
  ${STRIP:-i686-w64-mingw32-strip} src/openocd.exe
  mkdir -p output
  cp src/openocd.exe output/
  cp -r tcl/ output/scripts
fi
make clean
make distclean
