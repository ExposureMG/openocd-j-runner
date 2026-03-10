<#
.SYNOPSIS
    OpenOCD-JRunner Build Tool (PowerShell edition)

.DESCRIPTION
    Builds OpenOCD for Windows using MSYS2/MinGW toolchain.
    Equivalent to the Linux build.sh script.

.PARAMETER Target
    Build target architecture: w32 (default) or w64.

.PARAMETER Clean
    Force a full clean rebuild (re-bootstrap, re-configure, recompile).

.PARAMETER NoStrip
    Skip stripping the output binary (strip is enabled by default).

.PARAMETER Check
    Run the dependency checker only, then exit.

.PARAMETER Help
    Show this help message.

.EXAMPLE
    .\build.ps1
    .\build.ps1 -Target w64
    .\build.ps1 -Target w64 -Clean
    .\build.ps1 -Target w64 -Clean -NoStrip
    .\build.ps1 -Check
#>

param(
    [ValidateSet("w32", "w64")]
    [string]$Target = "w32",

    [switch]$Clean,
    [switch]$NoStrip,
    [switch]$Check,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Help ─────────────────────────────────────────────────────────────────────
function Show-Help {
    Write-Host @"
  __  __ _               ___   ____ ____  
  \ \/ /| |__   _____  _/ _ \ / ___|  _ \ 
   \  / | '_ \ / _ \ \/ / | | | |   | | | |
   /  \ | |_) | (_) >  <| |_| | |___| |_| |
  /_/\_\|_.__/ \___/_/\_\\___/ \____|____/ 
                               Builder

OpenOCD-JRunner Build Tool v0.1.0 (0.11) - Windows/PowerShell

USAGE:
    .\build.ps1 [OPTIONS]

OPTIONS:
    -Target w32     Build for Windows 32-bit (default)
    -Target w64     Build for Windows 64-bit
    -Clean          Force full clean rebuild
    -NoStrip        Skip stripping the output binary
    -Check          Run dependency checker only, then exit
    -Help           Show this help message

EXAMPLES:
    .\build.ps1                           # Incremental w32 build
    .\build.ps1 -Target w64              # Incremental w64 build
    .\build.ps1 -Target w64 -Clean       # Full clean w64 build
    .\build.ps1 -Target w64 -NoStrip     # w64 build, no strip
    .\build.ps1 -Check                   # Check dependencies only

PREREQUISITES:
    - MSYS2 installed (https://www.msys2.org/)
    - From MSYS2 shell, install the toolchain:
        pacman -S mingw-w64-i686-gcc mingw-w64-x86_64-gcc make autoconf automake libtool git

    - Add MSYS2 tools to PATH (typically C:\msys64\usr\bin and C:\msys64\mingw32\bin)

OUTPUT:
    output\openocd.exe
    output\scripts\
    logs\
"@
    exit 0
}

# ─── Dependency Checker ───────────────────────────────────────────────────────
function Invoke-DepCheck {
    Write-Host "=== Dependency Check ===" -ForegroundColor Cyan

    $tools = @(
        "i686-w64-mingw32-gcc",
        "x86_64-w64-mingw32-gcc",
        "i686-w64-mingw32-strip",
        "x86_64-w64-mingw32-strip",
        "automake",
        "autoconf",
        "libtoolize",
        "make",
        "git",
        "curl",
        "unzip",
        "tar",
        "pkg-config",
        "bash"
    )

    $allOk = $true
    foreach ($tool in $tools) {
        $found = Get-Command $tool -ErrorAction SilentlyContinue
        if ($found) {
            Write-Host "  [OK]  $tool" -ForegroundColor Green
        } else {
            Write-Host "  [!!]  $tool  *** MISSING ***" -ForegroundColor Red
            $allOk = $false
        }
    }

    Write-Host ""
    if ($allOk) {
        Write-Host "  All required tools found." -ForegroundColor Green
    } else {
        Write-Host "  Some tools are missing. Please install MSYS2 to continue." -ForegroundColor Yellow
    }
    Write-Host "========================" -ForegroundColor Cyan
    return $allOk
}

# ─── Logging ──────────────────────────────────────────────────────────────────
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $line = "[$timestamp] $Message"
    Add-Content -Path $script:LogFile -Value $line
    Write-Host $Message
}

function Invoke-Checked {
    param([string]$Description, [scriptblock]$Command)
    Write-Log ">>> $Description"
    & $Command
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: $Description failed (exit code $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

# ─── Entry Point ──────────────────────────────────────────────────────────────
if ($Help.IsPresent) { Show-Help }

$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DepsDir = Join-Path $BaseDir "deps"
$LogDir  = Join-Path $BaseDir "logs"
$OutDir  = Join-Path $BaseDir "output"

# Dep check runs always
Invoke-DepCheck | Out-Null

if ($Check) {
    Invoke-DepCheck
    exit 0
}

# Setup log
$LogTimestamp = Get-Date -Format "yyyy-MM-ddTHH-mm-ss"
$script:LogFile = Join-Path $LogDir "build-${LogTimestamp}.log"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Set toolchain based on target
$StripTool = if ($Target -eq "w64") { "x86_64-w64-mingw32-strip" } else { "i686-w64-mingw32-strip" }
$env:TARGET      = $Target
$env:TARGET_STRIP = $StripTool

Write-Host @"

  __  __ _               ___   ____ ____  
  \ \/ /| |__   _____  _/ _ \ / ___|  _ \ 
   \  / | '_ \ / _ \ \/ / | | | |   | | | |
   /  \ | |_) | (_) >  <| |_| | |___| |_| |
  /_/\_\|_.__/ \___/_/\_\\___/ \____|____/ 
                               Builder

"@ -ForegroundColor Cyan

Write-Log "OpenOCD-JRunner Build Tool v0.1.0 (0.11) - Windows/PowerShell"
Write-Log "Building for $Target"
Write-Log "Log: $($script:LogFile)"

Push-Location $BaseDir
try {

    # ─── Bootstrap ────────────────────────────────────────────────────────────
    Write-Log "--- Bootstrapping ---"
    if ($Clean -and (Test-Path "config.status")) {
        Write-Log "Clean build requested, cleaning first..."
        Invoke-Checked "clean" { .\scripts\powershell\clean.ps1 }
    }

    if ($Clean -or -not (Test-Path "configure")) {
        Invoke-Checked "bootstrap" { bash bootstrap }
    } else {
        Write-Log "Skipping bootstrap (already present)"
    }

    # ─── Submodules ───────────────────────────────────────────────────────────
    Write-Log "--- Downloading submodules ---"
    if ($Clean -or -not (Test-Path "jimtcl/configure")) {
        Invoke-Checked "git submodule init"   { git submodule init }
        Invoke-Checked "git submodule update" { git submodule update }
    } else {
        Write-Log "Skipping submodules (already present)"
    }

    # ─── Dependencies ─────────────────────────────────────────────────────────
    Write-Log "--- Downloading dependencies ---"
    Invoke-Checked "deps.ps1" { .\scripts\powershell\deps.ps1 }

    if (-not (Test-Path "$DepsDir/ftd2xx/i386/ftd2xx.lib")) {
        Write-Host "ERROR: Dependency download failed! (FTD2XX)" -ForegroundColor Red; exit 1
    }
    if (-not (Test-Path "$DepsDir/libusb-win/include/libusb-1.0/libusb.h")) {
        Write-Host "ERROR: Dependency download failed! (Libusb-1)" -ForegroundColor Red; exit 1
    }

    # ─── Build ────────────────────────────────────────────────────────────────
    Invoke-Checked "scripts\powershell\build.ps1" { .\scripts\powershell\build.ps1 }

    if (-not (Test-Path "src/openocd.exe")) {
        Write-Host "ERROR: Build failed — src/openocd.exe not found" -ForegroundColor Red; exit 1
    }

    # ─── Strip & Extract ──────────────────────────────────────────────────────
    Write-Log "--- Extracting Output ---"
    if ($Clean) {
        Invoke-Checked "clean extract" { .\scripts\powershell\clean.ps1 }
    } else {
        if (-not $NoStrip) {
            Write-Log "Stripping binary..."
            Invoke-Checked "strip" { & $StripTool src/openocd.exe }
        } else {
            Write-Log "Skipping strip (-NoStrip passed)"
        }
        New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
        Copy-Item "src/openocd.exe" "$OutDir/openocd.exe" -Force
        Copy-Item "tcl" "$OutDir/scripts" -Recurse -Force
    }

    if (-not (Test-Path "$OutDir/openocd.exe")) {
        Write-Host "ERROR: Build/Extract failed — no openocd.exe in output" -ForegroundColor Red; exit 1
    }

    # Rename log to success
    $successLog = $script:LogFile -replace "\.log$", "-success.log"
    Move-Item $script:LogFile $successLog -Force
    Write-Log "--- Build Complete! Check output folder ---"

} catch {
    # Rename log to fail
    $failLog = $script:LogFile -replace "\.log$", "-fail.log"
    if (Test-Path $script:LogFile) { Move-Item $script:LogFile $failLog -Force }
    Write-Host "Build failed: $_" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}
