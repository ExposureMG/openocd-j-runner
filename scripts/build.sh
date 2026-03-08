HOST_TRIPLET="i686-w64-mingw32"
echo "--- Configuring Build ---"
./configure \
    --host=$HOST_TRIPLET \
    --enable-static \
    --disable-shared \
    --disable-all-adapters \
    --disable-werror \
    --disable-docs \
    --disable-doxygen-html \
    --disable-doxygen-pdf \
    --disable-libgpiod \
    --disable-usb_blaster_libftdi \
    --disable-amtjtagaccel \
    --disable-gw16012 \
    --disable-presto \
    --disable-openjtag \
    --enable-ftdi \
    --enable-ft2232_ftd2xx \
    --enable-dirtyjtag \
    --with-ftd2xx-win32-zipdir="deps/ftd2xx" \
    LIBUSB1_CFLAGS="-Ideps/libusb-win/include/libusb-1.0" \
    LDFLAGS="-Wl,--allow-multiple-definition" \
    LIBUSB1_LIBS="-Ldeps/libusb-win/lib -lusb-1.0 -lsetupapi -lole32 -ladvapi32 -lwinmm -lmsvcr120" \
    CPPFLAGS="-DHAVE_LIBUSB_ERROR_NAME" \
    CFLAGS="-O2"

echo "--- Starting Build ---"
make -j$(nproc)