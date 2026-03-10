param(
    [switch]$NoStop = ($env:NO_STRIP -eq "1"),
    [string]$TargetStrip = $env:TARGET_STRIP
)

if (-not $TargetStrip) { $TargetStrip = "i686-w64-mingw32-strip" }

if (Test-Path "src/openocd.exe") {
    if (-not $NoStop) {
        Write-Host "Stripping binary (using $TargetStrip)..."
        & $TargetStrip src/openocd.exe
    } else {
        Write-Host "Skipping strip (-nostrip passed)"
    }
    New-Item -ItemType Directory -Force -Path output | Out-Null
    Copy-Item "src\openocd.exe" "output\" -Force
    Copy-Item "tcl" "output\scripts" -Recurse -Force
}

make clean
make distclean
