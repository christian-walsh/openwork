# OpenWork Prerequisites Installer for Windows
# 
# This script automatically installs all prerequisites needed to build and run OpenWork:
# - Microsoft C++ Build Tools (REQUIRED for Rust compilation)
# - Node.js (via winget or Chocolatey)
# - pnpm (via npm)
# - Rust toolchain (via winget, Chocolatey, or rustup.rs)
# - OpenCode CLI (via Scoop or Chocolatey)
#
# Usage:
#   .\install-prerequisites.ps1
#
# Options:
#   -SkipOpenCode    Skip OpenCode installation
#   -SkipRust        Skip Rust installation
#   -SkipNode        Skip Node.js and pnpm installation
#   -SkipBuildTools  Skip Visual Studio Build Tools installation
#
# Example:
#   .\install-prerequisites.ps1 -SkipOpenCode
#
# Note: Some installations may require Administrator privileges or a terminal restart

param(
    [switch]$SkipOpenCode,
    [switch]$SkipRust,
    [switch]$SkipNode,
    [switch]$SkipBuildTools
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenWork Prerequisites Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Test-BuildTools {
    # Check for Visual Studio Build Tools or Visual Studio with C++ workload
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vsWhere) {
        $installed = & $vsWhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        if ($installed) {
            return $true
        }
    }
    
    # Also check for Build Tools specifically
    $buildToolsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools"
    if (Test-Path $buildToolsPath) {
        return $true
    }
    
    return $false
}

function Test-LinkerAvailable {
    # Check if link.exe is accessible
    $linkCmd = Get-Command link.exe -ErrorAction SilentlyContinue
    if ($linkCmd) {
        return $true
    }
    
    # Check common locations
    $linkPaths = @(
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64\link.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\*\bin\Hostx64\x64\link.exe"
    )
    
    foreach ($path in $linkPaths) {
        $matches = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
        if ($matches) {
            return $true
        }
    }
    
    return $false
}

function Install-BuildTools {
    Write-Host "[0/4] Checking Microsoft C++ Build Tools..." -ForegroundColor Yellow
    
    if (Test-BuildTools) {
        Write-Host "  [OK] Visual Studio Build Tools found" -ForegroundColor Green
        
        # Check if linker is accessible
        if (-not (Test-LinkerAvailable)) {
            Write-Host "  WARNING: Build Tools installed but linker not in PATH." -ForegroundColor Yellow
            Write-Host "  Run: .\fix-rust-linker.ps1" -ForegroundColor Cyan
            Write-Host "  Or restart your terminal after Build Tools installation." -ForegroundColor Yellow
        } else {
            Write-Host "  [OK] Linker (link.exe) is accessible" -ForegroundColor Green
        }
        return
    }
    
    Write-Host "  [X] C++ Build Tools not found. This is REQUIRED for Rust compilation." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Installing Visual Studio Build Tools..." -ForegroundColor Yellow
    Write-Host "  This will download and install the Visual Studio Installer." -ForegroundColor Yellow
    Write-Host "  You'll need to:" -ForegroundColor Yellow
    Write-Host "    1. Run the installer when it opens" -ForegroundColor Cyan
    Write-Host "    2. Select 'Desktop development with C++' workload" -ForegroundColor Cyan
    Write-Host "    3. Click Install and wait for completion" -ForegroundColor Cyan
    Write-Host ""
    
    $buildToolsUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe"
    $buildToolsPath = "$env:TEMP\vs_buildtools.exe"
    
    try {
        Write-Host "  Downloading Visual Studio Build Tools installer..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $buildToolsUrl -OutFile $buildToolsPath -UseBasicParsing
        
        Write-Host "  Launching installer..." -ForegroundColor Yellow
        Write-Host "  Please select 'Desktop development with C++' workload in the installer." -ForegroundColor Yellow
        Write-Host ""
        
        Start-Process -FilePath $buildToolsPath -ArgumentList "--quiet", "--wait", "--add", "Microsoft.VisualStudio.Workload.VCTools", "--includeRecommended" -Wait
        
        # Clean up installer
        Remove-Item $buildToolsPath -ErrorAction SilentlyContinue
        
        if (Test-BuildTools) {
            Write-Host "  [OK] Build Tools installed successfully" -ForegroundColor Green
            Write-Host "  IMPORTANT: Restart your terminal for changes to take effect!" -ForegroundColor Yellow
            Write-Host "  After restart, run: .\fix-rust-linker.ps1 (if needed)" -ForegroundColor Cyan
        } else {
            Write-Host "  WARNING: Build Tools may not be fully installed." -ForegroundColor Yellow
            Write-Host "  Please verify the installation completed successfully." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ERROR: Failed to install Build Tools automatically." -ForegroundColor Red
        Write-Host ""
        Write-Host "  Please install manually:" -ForegroundColor Yellow
        Write-Host "    1. Download: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022" -ForegroundColor Cyan
        Write-Host "    2. Run the installer" -ForegroundColor Cyan
        Write-Host "    3. Select 'Desktop development with C++' workload" -ForegroundColor Cyan
        Write-Host "    4. Click Install" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  After installation, restart your terminal and run this script again." -ForegroundColor Yellow
        exit 1
    }
}

function Install-NodeJS {
    Write-Host "[1/3] Checking Node.js..." -ForegroundColor Yellow
    
    if (Test-Command "node") {
        $nodeVersion = node --version
        Write-Host "  [OK] Node.js is installed: $nodeVersion" -ForegroundColor Green
    } else {
        Write-Host "  [X] Node.js not found. Installing..." -ForegroundColor Red
        
        # Try winget first
        if (Test-Command "winget") {
            Write-Host "  Installing Node.js via winget..." -ForegroundColor Yellow
            winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
        } elseif (Test-Command "choco") {
            Write-Host "  Installing Node.js via Chocolatey..." -ForegroundColor Yellow
            choco install nodejs-lts -y
        } else {
            Write-Host "  ERROR: Cannot install Node.js automatically." -ForegroundColor Red
            Write-Host "  Please install Node.js manually from: https://nodejs.org/" -ForegroundColor Yellow
            Write-Host "  After installation, restart your terminal and run this script again." -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host "  Node.js installed. Please restart your terminal and run this script again." -ForegroundColor Green
        exit 0
    }
}

function Install-Pnpm {
    Write-Host "[2/3] Checking pnpm..." -ForegroundColor Yellow
    
    if (Test-Command "pnpm") {
        $pnpmVersion = pnpm --version
        Write-Host "  [OK] pnpm is installed: $pnpmVersion" -ForegroundColor Green
    } else {
        Write-Host "  [X] pnpm not found. Installing..." -ForegroundColor Red
        
        if (Test-Command "npm") {
            Write-Host "  Installing pnpm via npm..." -ForegroundColor Yellow
            npm install -g pnpm
            Write-Host "  [OK] pnpm installed" -ForegroundColor Green
        } else {
            Write-Host "  ERROR: npm not found. Node.js may not be installed correctly." -ForegroundColor Red
            exit 1
        }
    }
}

function Install-Rust {
    Write-Host "[3/4] Checking Rust toolchain..." -ForegroundColor Yellow
    
    if (Test-Command "cargo") {
        $cargoVersion = cargo --version
        Write-Host "  [OK] Rust is installed: $cargoVersion" -ForegroundColor Green
    } else {
        Write-Host "  [X] Rust not found. Installing..." -ForegroundColor Red
        
        # Try winget first
        if (Test-Command "winget") {
            Write-Host "  Installing Rust via winget..." -ForegroundColor Yellow
            winget install Rustlang.Rustup --accept-package-agreements --accept-source-agreements
        } elseif (Test-Command "choco") {
            Write-Host "  Installing Rust via Chocolatey..." -ForegroundColor Yellow
            choco install rust -y
        } else {
            # Download rustup-init.exe directly
            Write-Host "  Downloading Rust installer..." -ForegroundColor Yellow
            $rustupUrl = "https://win.rustup.rs/x86_64"
            $rustupPath = "$env:TEMP\rustup-init.exe"
            
            try {
                Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupPath -UseBasicParsing
                Write-Host "  Running Rust installer..." -ForegroundColor Yellow
                Start-Process -FilePath $rustupPath -ArgumentList "-y" -Wait -NoNewWindow
                Remove-Item $rustupPath -ErrorAction SilentlyContinue
            } catch {
                Write-Host "  ERROR: Failed to download Rust installer." -ForegroundColor Red
                Write-Host "  Please install Rust manually from: https://rustup.rs/" -ForegroundColor Yellow
                exit 1
            }
        }
        
        Write-Host "  Rust installed. Please restart your terminal and run this script again." -ForegroundColor Green
        Write-Host "  After restart, verify with: cargo --version" -ForegroundColor Yellow
        exit 0
    }
    
    # Verify rustc as well
    if (-not (Test-Command "rustc")) {
        Write-Host "  WARNING: rustc not found in PATH. You may need to restart your terminal." -ForegroundColor Yellow
    }
}

function Install-OpenCode {
    Write-Host "[4/4] Checking OpenCode CLI..." -ForegroundColor Yellow
    
    if (Test-Command "opencode") {
        $opencodeVersion = opencode --version 2>&1 | Select-Object -First 1
        Write-Host "  [OK] OpenCode is installed: $opencodeVersion" -ForegroundColor Green
        return
    }
    
    Write-Host "  [X] OpenCode not found. Attempting to install..." -ForegroundColor Red
    
    # Try Scoop first
    if (Test-Command "scoop") {
        Write-Host "  Installing OpenCode via Scoop..." -ForegroundColor Yellow
        try {
            scoop install opencode
            if (Test-Command "opencode") {
                Write-Host "  [OK] OpenCode installed via Scoop" -ForegroundColor Green
                return
            }
        } catch {
            Write-Host "  Scoop installation failed, trying alternative..." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  Scoop not found. Installing Scoop first..." -ForegroundColor Yellow
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            irm get.scoop.sh | iex
            scoop install opencode
            if (Test-Command "opencode") {
                Write-Host "  [OK] OpenCode installed via Scoop" -ForegroundColor Green
                return
            }
        } catch {
            Write-Host "  Scoop installation failed, trying Chocolatey..." -ForegroundColor Yellow
        }
    }
    
    # Try Chocolatey as fallback
    if (Test-Command "choco") {
        Write-Host "  Installing OpenCode via Chocolatey..." -ForegroundColor Yellow
        try {
            choco install opencode -y
            if (Test-Command "opencode") {
                Write-Host "  [OK] OpenCode installed via Chocolatey" -ForegroundColor Green
                return
            }
        } catch {
            Write-Host "  Chocolatey installation failed." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  Chocolatey not found. Installing Chocolatey first..." -ForegroundColor Yellow
        try {
            # Install Chocolatey (requires admin)
            if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                Write-Host "  ERROR: Chocolatey installation requires Administrator privileges." -ForegroundColor Red
                Write-Host "  Please run this script as Administrator, or install OpenCode manually." -ForegroundColor Yellow
            } else {
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
                choco install opencode -y
                if (Test-Command "opencode") {
                    Write-Host "  [OK] OpenCode installed via Chocolatey" -ForegroundColor Green
                    return
                }
            }
        } catch {
            Write-Host "  Chocolatey installation failed." -ForegroundColor Yellow
        }
    }
    
    # If all automatic methods failed
    Write-Host "  WARNING: Could not install OpenCode automatically." -ForegroundColor Yellow
    Write-Host "  Please install OpenCode manually:" -ForegroundColor Yellow
    Write-Host "    1. Scoop: scoop install opencode" -ForegroundColor Cyan
    Write-Host "    2. Chocolatey: choco install opencode -y" -ForegroundColor Cyan
    Write-Host "    3. Manual: https://opencode.ai/install" -ForegroundColor Cyan
    Write-Host ""
}

# Main installation flow
Write-Host "Starting prerequisite installation..." -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator (for Chocolatey)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin -and -not $SkipOpenCode) {
    Write-Host "NOTE: Running without Administrator privileges." -ForegroundColor Yellow
    Write-Host "Some installations (like Chocolatey) may require Admin rights." -ForegroundColor Yellow
    Write-Host ""
}

# Install prerequisites (Build Tools first, as Rust needs them)
if (-not $SkipBuildTools) {
    Install-BuildTools
}

if (-not $SkipNode) {
    Install-NodeJS
    Install-Pnpm
}

if (-not $SkipRust) {
    Install-Rust
}

if (-not $SkipOpenCode) {
    Install-OpenCode
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$allGood = $true

if (Test-BuildTools) {
    Write-Host "[OK] C++ Build Tools: Installed" -ForegroundColor Green
} else {
    Write-Host "[X] C++ Build Tools: Not installed (REQUIRED for Rust)" -ForegroundColor Red
    $allGood = $false
}

if (Test-Command "node") {
    Write-Host "[OK] Node.js: $(node --version)" -ForegroundColor Green
} else {
    Write-Host "[X] Node.js: Not installed" -ForegroundColor Red
    $allGood = $false
}

if (Test-Command "pnpm") {
    Write-Host "[OK] pnpm: $(pnpm --version)" -ForegroundColor Green
} else {
    Write-Host "[X] pnpm: Not installed" -ForegroundColor Red
    $allGood = $false
}

if (Test-Command "cargo") {
    Write-Host "[OK] Rust: $(cargo --version)" -ForegroundColor Green
} else {
    Write-Host "[X] Rust: Not installed" -ForegroundColor Red
    $allGood = $false
}

if (Test-Command "opencode") {
    Write-Host "[OK] OpenCode: $(opencode --version 2>&1 | Select-Object -First 1)" -ForegroundColor Green
} else {
    Write-Host "[X] OpenCode: Not installed (optional, but recommended)" -ForegroundColor Yellow
}

Write-Host ""

if ($allGood) {
    Write-Host "All core prerequisites are installed! [OK]" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Clone the repository: git clone https://github.com/different-ai/openwork.git" -ForegroundColor White
    Write-Host "  2. Install dependencies: cd openwork && pnpm install" -ForegroundColor White
    Write-Host "  3. Build the app: pnpm build" -ForegroundColor White
    Write-Host "  4. Run in dev mode: pnpm dev" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "Some prerequisites are missing. Please:" -ForegroundColor Yellow
    Write-Host "  1. Restart your terminal and run this script again, or" -ForegroundColor Yellow
    Write-Host "  2. Install missing prerequisites manually (see INSTALL_WINDOWS.md)" -ForegroundColor Yellow
    Write-Host ""
}
