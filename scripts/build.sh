echo "--- Configuring Build ---"
./configure \
    --host=$HOST_TRIPLET \
    --enable-static \
    --disable-shared \
    --disable-all-adapters \
    --enable-ftdi \
    --enable-ft2232_ftd2xx \
    --enable-dirtyjtag \
    --with-ftd2xx-win32-zipdir="$DEPS_DIR/ftd2xx" \
    LIBUSB1_CFLAGS="-I$DEPS_DIR/libusb-win/include/libusb-1.0" \
    LIBUSB1_LIBS="-L$DEPS_DIR/libusb-win/lib -lusb-1.0 -lsetupapi -lole32 -ladvapi32 -lwinmm" \
    CFLAGS="-O2"

echo "--- Starting Build ---"
make -j$(nproc)