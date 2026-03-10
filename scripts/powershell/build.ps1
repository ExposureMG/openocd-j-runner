param(
    [string]$Target = $env:TARGET,
    [switch]$CleanBuild = ($env:CLEAN_BUILD -eq "1")
)

if ($Target -eq "w64") {
    $HOST_TRIPLET="x86_64-w64-mingw32"
    $LIBUSB_ARCH="MinGW64"
    $HIDAPI_ARCH="x64"
    $STRIP="${HOST_TRIPLET}-strip"
    $FTD2XX_ARCH="amd64"
} else {
    $HOST_TRIPLET="i686-w64-mingw32"
    $LIBUSB_ARCH="MinGW32"
    $HIDAPI_ARCH="x86"
    $STRIP="${HOST_TRIPLET}-strip"
    $FTD2XX_ARCH="i386"
}

$env:HOST_TRIPLET = $HOST_TRIPLET
$env:LIBUSB_ARCH = $LIBUSB_ARCH
$env:HIDAPI_ARCH = $HIDAPI_ARCH
$env:STRIP = $STRIP
$env:FTD2XX_ARCH = $FTD2XX_ARCH

Write-Host "--- Configuring Build ---"
if ($CleanBuild -or -not (Test-Path "Makefile")) {
    # configure is an autotools bash script, so we must invoke it via bash
    bash ./configure --host=$HOST_TRIPLET --enable-static --disable-shared --disable-werror --disable-docs --disable-doxygen-html --disable-doxygen-pdf --disable-linuxgpiod --disable-usb-blaster --disable-usb-blaster-2 --disable-amtjtagaccel --disable-gw16012 --disable-presto --disable-openjtag --disable-parport --disable-jtag-vpi --disable-jtag-dpi --disable-dummy --disable-ep93xx --disable-at91rm9200 --disable-bcm2835gpio --disable-imx-gpio --disable-remote-bitbang --disable-buspirate --disable-sysfsgpio --disable-xlnx-pcie-xvc --disable-stlink --disable-ti-icdi --disable-ulink --disable-ft232r --disable-vsllink --disable-xds110 --disable-osbdm --disable-opendous --disable-rlink --disable-aice --disable-usbprog --disable-armjtagew --disable-kitprog --disable-cmsis-dap-v2 --disable-nulink --disable-rshim --disable-jlink --disable-internal-libjaylink --disable-bluenrg-x --disable-cc3220sf --disable-cc26xx --enable-ftdi --enable-dirtyjtag --enable-cmsis-dap --with-ftd2xx-win32-zipdir="deps/ftd2xx" LIBUSB1_CFLAGS="-Ideps/libusb-win/include/libusb-1.0" LDFLAGS="-static -static-libgcc -static-libstdc++ -Wl,--allow-multiple-definition" LIBUSB1_LIBS="-Ldeps/libusb-win/lib -lusb-1.0 -lsetupapi -lole32 -ladvapi32 -lwinmm" CPPFLAGS="-DHAVE_LIBUSB_ERROR_NAME" CFLAGS="-O2 -Wno-alloc-size-larger-than" HIDAPI_CFLAGS="-Ideps/hidapi/include/hidapi" HIDAPI_LIBS="-Ldeps/hidapi/lib -lhidapi -lsetupapi -lole32 -ladvapi32 -lhid"
} else {
    Write-Host "Skipping configure (already configured)"
}

Write-Host "--- Starting Build ---"
$cores = if ($env:NUMBER_OF_PROCESSORS) { $env:NUMBER_OF_PROCESSORS } else { 4 }
make -j$cores
