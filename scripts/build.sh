HOST_TRIPLET="i686-w64-mingw32"
echo "--- Configuring Build ---"
./configure \
    --host=$HOST_TRIPLET \
    --enable-static \
    --disable-shared \
    --disable-all-adapters \
    --enable-ftdi \
    --enable-ft2232_ftd2xx \
    --enable-dirtyjtag \
    --with-ftd2xx-win32-zipdir="deps/ftd2xx" \
    LIBUSB1_CFLAGS="-Ideps/libusb-win/include/libusb-1.0" \
    LIBUSB1_LIBS="-Ldeps/libusb-win/lib -lusb-1.0 -lsetupapi -lole32 -ladvapi32 -lwinmm" \
    CFLAGS="-O2"

echo "--- Starting Build ---"
make -j$(nproc)