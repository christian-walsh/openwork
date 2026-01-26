# Script to find manually installed OpenCode and configure it

Write-Host "Searching for OpenCode installation..." -ForegroundColor Cyan
Write-Host ""

# Common manual installation locations
$searchPaths = @(
    "$env:USERPROFILE\opencode",
    "$env:USERPROFILE\.opencode",
    "$env:LOCALAPPDATA\opencode",
    "$env:APPDATA\opencode",
    "C:\opencode",
    "C:\Program Files\OpenCode",
    "C:\Program Files (x86)\OpenCode",
    "$env:USERPROFILE\Downloads\opencode",
    "$env:USERPROFILE\Desktop\opencode"
)

$foundPaths = @()

# Search for opencode.exe
Write-Host "Searching common locations..." -ForegroundColor Yellow
foreach ($basePath in $searchPaths) {
    if (Test-Path $basePath) {
        $exePath = Join-Path $basePath "opencode.exe"
        if (Test-Path $exePath) {
            $foundPaths += $exePath
            Write-Host "  [FOUND] $exePath" -ForegroundColor Green
        }
        
        # Also check bin subdirectory
        $binPath = Join-Path $basePath "bin\opencode.exe"
        if (Test-Path $binPath) {
            $foundPaths += $binPath
            Write-Host "  [FOUND] $binPath" -ForegroundColor Green
        }
    }
}

# Search entire user profile (slower but thorough)
Write-Host ""
Write-Host "Performing deep search in user profile (this may take a moment)..." -ForegroundColor Yellow
try {
    $deepSearch = Get-ChildItem -Path $env:USERPROFILE -Filter "opencode.exe" -Recurse -ErrorAction SilentlyContinue -Depth 5 | Select-Object -First 5
    foreach ($item in $deepSearch) {
        if ($foundPaths -notcontains $item.FullName) {
            $foundPaths += $item.FullName
            Write-Host "  [FOUND] $($item.FullName)" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "  Deep search completed (some locations may be inaccessible)" -ForegroundColor Yellow
}

Write-Host ""

if ($foundPaths.Count -eq 0) {
    Write-Host "[X] OpenCode not found in common locations." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please provide the full path to opencode.exe, or:" -ForegroundColor Yellow
    Write-Host "  1. Download OpenCode from https://opencode.ai/install" -ForegroundColor Cyan
    Write-Host "  2. Extract it to a known location" -ForegroundColor Cyan
    Write-Host "  3. Run this script again" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

# If multiple found, let user choose
$selectedPath = $null
if ($foundPaths.Count -eq 1) {
    $selectedPath = $foundPaths[0]
    Write-Host "[OK] Found OpenCode at: $selectedPath" -ForegroundColor Green
} else {
    Write-Host "Multiple OpenCode installations found:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $foundPaths.Count; $i++) {
        Write-Host "  [$i] $($foundPaths[$i])" -ForegroundColor Cyan
    }
    Write-Host ""
    $choice = Read-Host "Enter the number of the correct installation (0-$($foundPaths.Count-1))"
    try {
        $selectedPath = $foundPaths[[int]$choice]
    } catch {
        Write-Host "[X] Invalid selection" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Selected: $selectedPath" -ForegroundColor Green

# Verify it works
Write-Host ""
Write-Host "Testing OpenCode..." -ForegroundColor Yellow
try {
    $version = & $selectedPath --version 2>&1
    Write-Host "[OK] OpenCode is working!" -ForegroundColor Green
    Write-Host "Version: $version" -ForegroundColor Cyan
} catch {
    Write-Host "[X] OpenCode executable found but doesn't work: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Get the directory containing opencode.exe
$opencodeDir = Split-Path $selectedPath -Parent

Write-Host ""
Write-Host "Configuration options:" -ForegroundColor Cyan
Write-Host ""

# Option 1: Add to PATH for current user
Write-Host "Option 1: Add to PATH (Recommended)" -ForegroundColor Yellow
Write-Host "  This will add $opencodeDir to your user PATH" -ForegroundColor White
Write-Host "  Run this command:" -ForegroundColor Cyan
Write-Host "  [Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';$opencodeDir', 'User')" -ForegroundColor White
Write-Host ""

# Option 2: Set OPENCODE_BIN_PATH environment variable
Write-Host "Option 2: Set OPENCODE_BIN_PATH environment variable" -ForegroundColor Yellow
Write-Host "  This tells OpenWork where to find OpenCode" -ForegroundColor White
Write-Host "  Run this command:" -ForegroundColor Cyan
Write-Host "  [Environment]::SetEnvironmentVariable('OPENCODE_BIN_PATH', '$selectedPath', 'User')" -ForegroundColor White
Write-Host ""

# Ask user what they want to do
$action = Read-Host "Choose option (1 or 2, or press Enter to skip)"

if ($action -eq "1") {
    $currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($currentPath -notlike "*$opencodeDir*") {
        [Environment]::SetEnvironmentVariable('Path', $currentPath + ";$opencodeDir", 'User')
        $env:Path += ";$opencodeDir"
        Write-Host "[OK] Added to PATH. Restart your terminal for changes to take effect." -ForegroundColor Green
    } else {
        Write-Host "[OK] Already in PATH" -ForegroundColor Green
    }
} elseif ($action -eq "2") {
    [Environment]::SetEnvironmentVariable('OPENCODE_BIN_PATH', $selectedPath, 'User')
    $env:OPENCODE_BIN_PATH = $selectedPath
    Write-Host "[OK] OPENCODE_BIN_PATH set. Restart OpenWork for changes to take effect." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Manual configuration:" -ForegroundColor Yellow
    Write-Host "  To add to PATH, run:" -ForegroundColor Cyan
    Write-Host "  [Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';$opencodeDir', 'User')" -ForegroundColor White
    Write-Host ""
    Write-Host "  Or set OPENCODE_BIN_PATH:" -ForegroundColor Cyan
    Write-Host "  [Environment]::SetEnvironmentVariable('OPENCODE_BIN_PATH', '$selectedPath', 'User')" -ForegroundColor White
    Write-Host ""
    Write-Host "  After setting, restart your terminal and OpenWork." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Current OpenCode location: $selectedPath" -ForegroundColor Green
Write-Host "Directory: $opencodeDir" -ForegroundColor Cyan
