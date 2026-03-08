i686-w64-mingw32-strip src/openocd.exe
mkdir output
cp src/openocd.exe output/
cp tcl ../output/scripts
make distclean