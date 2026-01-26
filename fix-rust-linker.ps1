# Quick fix script for Rust linker issues on Windows
# This sets up the environment so Rust can find link.exe

Write-Host "Checking Rust linker setup..." -ForegroundColor Cyan
Write-Host ""

# Check if link.exe exists in common locations
$linkPaths = @(
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64\link.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\*\bin\Hostx64\x64\link.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Professional\VC\Tools\MSVC\*\bin\Hostx64\x64\link.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\*\bin\Hostx64\x64\link.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64\link.exe"
)

$foundLink = $null
foreach ($path in $linkPaths) {
    $matches = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
    if ($matches) {
        $foundLink = $matches[0].FullName
        Write-Host "[OK] Found link.exe at: $foundLink" -ForegroundColor Green
        break
    }
}

if (-not $foundLink) {
    Write-Host "[X] link.exe not found. Visual Studio Build Tools may not be installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Visual Studio Build Tools:" -ForegroundColor Yellow
    Write-Host "  1. Download: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022" -ForegroundColor Cyan
    Write-Host "  2. Run installer and select 'Desktop development with C++'" -ForegroundColor Cyan
    Write-Host "  3. After installation, restart your terminal and run this script again" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

# Find vcvarsall.bat
$vcvarsPaths = @(
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
)

$vcvarsPath = $null
foreach ($path in $vcvarsPaths) {
    if (Test-Path $path) {
        $vcvarsPath = $path
        Write-Host "[OK] Found vcvarsall.bat at: $vcvarsPath" -ForegroundColor Green
        break
    }
}

if (-not $vcvarsPath) {
    Write-Host "[X] vcvarsall.bat not found. Build Tools installation may be incomplete." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Setting up environment for Rust..." -ForegroundColor Yellow

# Extract the MSVC version directory from link.exe path
$msvcDir = Split-Path (Split-Path (Split-Path (Split-Path $foundLink))) -Parent
$binPath = Join-Path $msvcDir "bin\Hostx64\x64"

# Add to PATH for current session
$env:PATH = "$binPath;$env:PATH"

# Also try to set up via vcvarsall
Write-Host "Configuring environment variables..." -ForegroundColor Yellow

# Create a temporary batch file to set up environment
$tempBat = "$env:TEMP\setup-rust-env.bat"
@"
@echo off
call "$vcvarsPath" x64 >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Failed to set up Visual Studio environment
    exit /b 1
)
echo Environment configured successfully
"@ | Out-File -FilePath $tempBat -Encoding ASCII

# Run the batch file to set up environment
$envSetup = cmd /c "$tempBat && set" | Where-Object { $_ -match '^(PATH|INCLUDE|LIB|LIBPATH)=' }
foreach ($line in $envSetup) {
    $parts = $line -split '=', 2
    if ($parts.Length -eq 2) {
        $varName = $parts[0]
        $varValue = $parts[1]
        [Environment]::SetEnvironmentVariable($varName, $varValue, "Process")
        if ($varName -eq "PATH") {
            $env:PATH = $varValue
        }
    }
}

Remove-Item $tempBat -ErrorAction SilentlyContinue

# Verify link.exe is now accessible
if (Get-Command link.exe -ErrorAction SilentlyContinue) {
    Write-Host "[OK] link.exe is now accessible!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Environment is configured for this terminal session." -ForegroundColor Cyan
    Write-Host "You can now run: pnpm build" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "NOTE: This configuration is only for the current terminal." -ForegroundColor Yellow
    Write-Host "To make it permanent, restart your terminal after installing Build Tools," -ForegroundColor Yellow
    Write-Host "or add the Build Tools bin directory to your system PATH." -ForegroundColor Yellow
} else {
    Write-Host "[X] Still unable to find link.exe in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try restarting your terminal after installing Build Tools." -ForegroundColor Yellow
    Write-Host "Or manually add this to your PATH: $binPath" -ForegroundColor Yellow
}
