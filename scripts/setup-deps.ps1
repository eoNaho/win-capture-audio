# scripts/setup-deps.ps1
# Downloads and extracts OBS Studio dependencies for development

$ErrorActionPreference = "Stop"

$depsDir = Join-Path $PSScriptRoot "..\deps"
$obsDir = Join-Path $depsDir "obs-studio"
$srcDir = Join-Path $depsDir "obs-source"

if (-not (Test-Path $depsDir)) { New-Item -ItemType Directory -Path $depsDir | Out-Null }
if (-not (Test-Path $obsDir)) { New-Item -ItemType Directory -Path $obsDir | Out-Null }
if (-not (Test-Path $srcDir)) { New-Item -ItemType Directory -Path $srcDir | Out-Null }

Write-Host "Fetching latest OBS Studio release info..."
$apiUrl = "https://api.github.com/repos/obsproject/obs-studio/releases/latest"
$assets = Invoke-RestMethod -Uri $apiUrl | Select-Object -ExpandProperty assets

# 1. Main Binaries
$binAsset = $assets | Where-Object { $_.name -like "*Windows-x64.zip" -or $_.name -like "*-Full-x64.zip" } | Select-Object -First 1
if (-not $binAsset) { Write-Error "Binaries not found"; exit 1 }

# 2. PDBs (Might contain libs)
$pdbAsset = $assets | Where-Object { $_.name -like "*Windows-x64-PDBs.zip" } | Select-Object -First 1

# 3. Sources (For headers)
$srcAsset = $assets | Where-Object { $_.name -like "*-Sources.tar.gz" -or $_.name -like "*-Sources.zip" } | Select-Object -First 1
if (-not $srcAsset) { Write-Error "Sources not found"; exit 1 }

# --- Download and Extract Binaries ---
$zipUrl = $binAsset.browser_download_url
$zipPath = Join-Path $depsDir "obs-bin.zip"
if (-not (Test-Path "$obsDir/bin/64bit/obs.dll")) {
    Write-Host "Downloading Binaries: $zipUrl"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $obsDir -Force
    Remove-Item $zipPath
} else {
    Write-Host "Binaries already present."
}

# --- Download and Extract PDBs ---
if ($pdbAsset) {
    $pdbUrl = $pdbAsset.browser_download_url
    $pdbPath = Join-Path $depsDir "obs-pdb.zip"
    if (-not (Test-Path "$obsDir/bin/64bit/obs.pdb")) {
        Write-Host "Downloading PDBs: $pdbUrl"
        Invoke-WebRequest -Uri $pdbUrl -OutFile $pdbPath
        Expand-Archive -Path $pdbPath -DestinationPath $obsDir -Force
        Remove-Item $pdbPath
    } else {
        Write-Host "PDBs already present."
    }
}

# --- Download and Extract Sources ---
$srcUrl = $srcAsset.browser_download_url
$srcPath = Join-Path $depsDir "obs-src.zip" 
if (-not (Test-Path "$srcDir/libobs/obs.h")) {
    Write-Host "Downloading Sources: $srcUrl"
    Invoke-WebRequest -Uri $srcUrl -OutFile $srcPath

    # Check extension to decide extraction
    if ($srcAsset.name.EndsWith(".tar.gz")) {
        # Try to use tar
        try {
            tar xzf $srcPath -C $srcDir --strip-components=1
        } catch {
             Write-Warning "tar failed, trying fallback or manual extraction required for tar.gz on old windows"
             # 7z extraction or similar could go here
        }
    } else {
        Expand-Archive -Path $srcPath -DestinationPath $srcDir -Force
    }
    Remove-Item $srcPath
} else {
    Write-Host "Sources already present."
}

Write-Host "Done. Binaries/PDBs in $obsDir"
Write-Host "Sources in $srcDir"
Write-Host "Dependencies setup complete."
