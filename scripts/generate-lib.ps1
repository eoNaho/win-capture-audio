# scripts/generate-lib.ps1
# Generates obs.lib from obs.dll using dumpbin and lib (MSVC tools)
# Must be run in a Developer Command Prompt or where dumpbin/lib are in PATH.

param (
    [string]$BinDir = "..\deps\obs-studio\bin\64bit"
)

$ErrorActionPreference = "Stop"
$TargetDir = Join-Path $PSScriptRoot $BinDir
$DllPath = Join-Path $TargetDir "obs.dll"
$LibPath = Join-Path $TargetDir "obs.lib"
$DefPath = Join-Path $TargetDir "obs.def"
$ExportsPath = Join-Path $TargetDir "exports.txt"

if (-not (Test-Path $DllPath)) {
    Write-Error "obs.dll not found at $DllPath"
    exit 1
}

if (Test-Path $LibPath) {
    Write-Host "obs.lib already exists. Skipping generation."
    exit 0
}

Write-Host "Checking for MSVC tools..."
if (-not (Get-Command "dumpbin" -ErrorAction SilentlyContinue)) {
    Write-Error "dumpbin.exe not found. Run this in a VS Developer Command Prompt."
    exit 1
}
if (-not (Get-Command "lib" -ErrorAction SilentlyContinue)) {
    Write-Error "lib.exe not found. Run this in a VS Developer Command Prompt."
    exit 1
}

Write-Host "Generating exports from obs.dll..."
# Use cmd /c to handle redirection correctly
cmd /c "dumpbin /exports `"$DllPath`" > `"$ExportsPath`""

Write-Host "Creating .def file..."
$defContent = @("EXPORTS")
$lines = Get-Content $ExportsPath
foreach ($line in $lines) {
    # Match lines like:  123 00 00012345 function_name
    # Skip non-symbol lines
    if ($line -match "^\s+\d+\s+[0-9A-F]+\s+[0-9A-F]+\s+(.+)$") {
        $symbol = $matches[1].Trim()
        if ($symbol -ne "" -and $symbol -notmatch "number of functions" -and $symbol -notmatch "RVA") {
             $defContent += $symbol
        }
    }
}
$defContent | Set-Content $DefPath

Write-Host "Generating obs.lib..."
lib /def:"$DefPath" /out:"$LibPath" /machine:x64

if (Test-Path $LibPath) {
    Write-Host "Successfully generated $LibPath"
    Remove-Item $DefPath
    Remove-Item $ExportsPath
} else {
    Write-Error "Failed to generate obs.lib"
    exit 1
}
