# Quick script to install OpenCode on Windows
# This will install Scoop (if needed) and then OpenCode

Write-Host "Installing OpenCode..." -ForegroundColor Cyan
Write-Host ""

# Check if Scoop is installed
$scoopInstalled = Get-Command scoop -ErrorAction SilentlyContinue

if (-not $scoopInstalled) {
    Write-Host "Scoop not found. Installing Scoop first..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        # Set execution policy for current user
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        
        # Install Scoop
        Write-Host "Downloading and installing Scoop..." -ForegroundColor Yellow
        irm get.scoop.sh | iex
        
        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-Host "[OK] Scoop installed successfully!" -ForegroundColor Green
        Write-Host ""
    } catch {
        Write-Host "[X] Failed to install Scoop: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "You can install Scoop manually:" -ForegroundColor Yellow
        Write-Host "  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
        Write-Host "  irm get.scoop.sh | iex" -ForegroundColor Cyan
        Write-Host ""
        exit 1
    }
} else {
    Write-Host "[OK] Scoop is already installed" -ForegroundColor Green
    Write-Host ""
}

# Install OpenCode via Scoop
Write-Host "Installing OpenCode via Scoop..." -ForegroundColor Yellow

try {
    scoop install opencode
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # Verify installation
    Start-Sleep -Seconds 2
    $opencodeCmd = Get-Command opencode -ErrorAction SilentlyContinue
    
    if ($opencodeCmd) {
        $version = opencode --version 2>&1 | Select-Object -First 1
        Write-Host ""
        Write-Host "[OK] OpenCode installed successfully!" -ForegroundColor Green
        Write-Host "Version: $version" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "You can now use OpenCode. Restart OpenWork to detect it." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[!] OpenCode may be installed but not in PATH yet." -ForegroundColor Yellow
        Write-Host "Try restarting your terminal, or run:" -ForegroundColor Yellow
        Write-Host "  refreshenv" -ForegroundColor Cyan
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "[X] Failed to install OpenCode: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative installation methods:" -ForegroundColor Yellow
    Write-Host "  1. Chocolatey: choco install opencode -y" -ForegroundColor Cyan
    Write-Host "  2. Manual: Download from https://opencode.ai/install" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}
