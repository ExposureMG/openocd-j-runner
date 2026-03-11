param(
    [string]$Target = $env:TARGET
)

$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent | Split-Path -Parent
$DepsDir = Join-Path $BaseDir "deps"
$VersionsFile = Join-Path $DepsDir ".versions"

New-Item -ItemType Directory -Force -Path $DepsDir | Out-Null
Push-Location $DepsDir

$ftdi_ver = "2.12.36.20-WHQL-Certified"
$libusb1_ver = "1.0.29"
$hidapi_ver = "0.15.0"

if ($Target -eq "w64") {
    $LIBUSB_ARCH = "MinGW64"
    $HIDAPI_ARCH = "x64"
} else {
    $LIBUSB_ARCH = "MinGW32"
    $HIDAPI_ARCH = "x86"
}

function Get-StoredVer($Name) {
    if (Test-Path $VersionsFile) {
        $line = Get-Content $VersionsFile | Where-Object { $_ -match "^$Name=" }
        if ($line) { return $line.Split("=")[1] }
    }
    return ""
}

function Set-StoredVer($Name, $Version) {
    if (Test-Path $VersionsFile) {
        $lines = @(Get-Content $VersionsFile)
        $found = $false
        for ($i=0; $i -lt $lines.Length; $i++) {
            if ($lines[$i] -match "^$Name=") {
                $lines[$i] = "$Name=$Version"
                $found = $true
            }
        }
        if (-not $found) { $lines += "$Name=$Version" }
        $lines | Set-Content $VersionsFile
    } else {
        "$Name=$Version" | Set-Content $VersionsFile
    }
}

# FTDI
if ((Get-StoredVer "ftd2xx") -eq $ftdi_ver -and (Test-Path "ftd2xx")) {
    Write-Host "--- Skipping FTDI D2XX (v$ftdi_ver already downloaded) ---"
} else {
    Write-Host "--- Downloading FTDI D2XX v$ftdi_ver ---"
    if (Test-Path "ftd2xx") { Remove-Item "ftd2xx" -Recurse -Force }
    Invoke-WebRequest -Uri "https://ftdichip.com/wp-content/uploads/2025/03/CDM-v$ftdi_ver.zip" -OutFile "ftd2xx.zip" -UserAgent "Mozilla/5.0"
    if (-not (Test-Path "ftd2xx.zip")) { Write-Error "FTD2XX download failed!"; exit 1 }
    Expand-Archive "ftd2xx.zip" -DestinationPath "ftd2xx_tmp" -Force
    
    New-Item -ItemType Directory -Force "ftd2xx/i386" | Out-Null
    New-Item -ItemType Directory -Force "ftd2xx/amd64" | Out-Null
    Copy-Item "ftd2xx_tmp/ftd2xx.h" "ftd2xx/"
    Copy-Item "ftd2xx_tmp/i386/ftd2xx.lib" "ftd2xx/i386/"
    Copy-Item "ftd2xx_tmp/amd64/ftd2xx.lib" "ftd2xx/amd64/"
    
    Remove-Item "ftd2xx_tmp", "ftd2xx.zip" -Recurse -Force
    Set-StoredVer "ftd2xx" $ftdi_ver
}

# libusb
if ((Get-StoredVer "libusb1_$Target") -eq $libusb1_ver -and (Test-Path "libusb-win")) {
    Write-Host "--- Skipping libusb-1.0 (v$libusb1_ver for $Target already downloaded) ---"
} else {
    Write-Host "--- Downloading libusb-1.0 v$libusb1_ver ---"
    if (Test-Path "libusb-win") { Remove-Item "libusb-win" -Recurse -Force }
    Invoke-WebRequest -Uri "https://github.com/libusb/libusb/releases/download/v$libusb1_ver/libusb-$libusb1_ver.7z" -OutFile "libusb.7z"
    if (-not (Test-Path "libusb.7z")) { Write-Error "Libusb1 download failed!"; exit 1 }
    
    # Needs MSYS 7z or tar
    if (Get-Command 7z -ErrorAction SilentlyContinue) {
        7z x libusb.7z -olibusb-tmp | Out-Null
    } else {
        # Fallback to tar if 7z isn't installed in the path
        New-Item -ItemType Directory -Force "libusb-tmp" | Out-Null
        Push-Location libusb-tmp
        tar -xf ../libusb.7z
        Pop-Location
    }
    
    New-Item -ItemType Directory -Force "libusb-win/include/libusb-1.0" | Out-Null
    New-Item -ItemType Directory -Force "libusb-win/lib" | Out-Null
    Copy-Item "libusb-tmp/include/libusb.h" "libusb-win/include/libusb-1.0/"
    Copy-Item "libusb-tmp/$LIBUSB_ARCH/static/libusb-1.0.a" "libusb-win/lib/"
    
    Remove-Item "libusb-tmp", "libusb.7z" -Recurse -Force
    Set-StoredVer "libusb1_$Target" $libusb1_ver
}

# hidapi
if ((Get-StoredVer "hidapi_$Target") -eq $hidapi_ver -and (Test-Path "hidapi")) {
    Write-Host "--- Skipping hidapi (v$hidapi_ver for $Target already downloaded) ---"
} else {
    Write-Host "--- Downloading hidapi v$hidapi_ver ---"
    if (Test-Path "hidapi") { Remove-Item "hidapi" -Recurse -Force }
    Invoke-WebRequest -Uri "https://github.com/libusb/hidapi/releases/download/hidapi-$hidapi_ver/hidapi-win.zip" -OutFile "hidapi.zip"
    if (-not (Test-Path "hidapi.zip")) { Write-Error "HIDAPI download failed!"; exit 1 }
    
    Expand-Archive "hidapi.zip" -DestinationPath "hidapi_tmp" -Force
    
    New-Item -ItemType Directory -Force "hidapi/include/hidapi" | Out-Null
    New-Item -ItemType Directory -Force "hidapi/lib" | Out-Null
    Copy-Item "hidapi_tmp/include/hidapi.h" "hidapi/include/hidapi/"
    Copy-Item "hidapi_tmp/$HIDAPI_ARCH/hidapi.lib" "hidapi/lib/"
    
    Remove-Item "hidapi_tmp", "hidapi.zip" -Recurse -Force
    Set-StoredVer "hidapi_$Target" $hidapi_ver
}

Write-Host "--- All dependencies verified and structured ---"
Pop-Location
