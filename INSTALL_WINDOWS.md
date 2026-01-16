# OpenWork Windows Installation Guide

A simple guide to get OpenWork running on Windows.

## Prerequisites

You'll need these installed first:

> **Quick Install**: Run the automated installer script:
> ```powershell
> # Download and run the prerequisites installer
> irm https://raw.githubusercontent.com/different-ai/openwork/main/install-prerequisites.ps1 | iex
> 
> # Or if you've cloned the repo:
> .\install-prerequisites.ps1
> ```

Or install manually:

### 1. Node.js and pnpm
- **Node.js**: Download from [nodejs.org](https://nodejs.org/) (LTS version recommended)
- **pnpm**: After installing Node.js, run:
  ```powershell
  npm install -g pnpm
  ```

### 2. Rust Toolchain
- **Rust**: Download from [rustup.rs](https://rustup.rs/) or install via:
  ```powershell
  # Using winget
  winget install Rustlang.Rustup

  # Or download and run rustup-init.exe from rustup.rs
  ```
- After installation, restart your terminal and verify:
  ```powershell
  cargo --version
  rustc --version
  ```

### 3. OpenCode CLI
OpenWork needs the OpenCode CLI to function. Install it using one of these methods:

#### Option A: Scoop (Recommended)
```powershell
# Install Scoop if you don't have it
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# Install OpenCode
scoop install opencode
```

#### Option B: Chocolatey
```powershell
# Install Chocolatey if you don't have it
# Run PowerShell as Administrator, then:
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install OpenCode
choco install opencode -y
```

#### Option C: Manual Install
1. Download OpenCode from [opencode.ai/install](https://opencode.ai/install)
2. Extract and add to your PATH, or install to a location like `%USERPROFILE%\.opencode\bin`

**Verify OpenCode is installed:**
```powershell
opencode --version
```

## Installing OpenWork

### Option 1: Download Pre-built Release (Easiest)

1. Go to [Releases](https://github.com/different-ai/openwork/releases)
2. Download the latest `*.msi` installer
3. Run the installer and follow the prompts
4. Launch OpenWork from the Start Menu

### Option 2: Build from Source

1. **Clone the repository:**
   ```powershell
   git clone https://github.com/different-ai/openwork.git
   cd openwork
   ```

2. **Install dependencies:**
   ```powershell
   pnpm install
   ```

3. **Build the app:**
   ```powershell
   pnpm build
   ```
   
   This creates a Windows executable in `src-tauri/target/release/openwork.exe`

4. **Run the development version:**
   ```powershell
   pnpm dev
   ```

## First Launch

1. **Open OpenWork** (from Start Menu or run `openwork.exe`)

2. **Select a workspace folder:**
   - Click "Select Workspace" or "Host Mode"
   - Choose a folder where you want to work
   - OpenWork will start the OpenCode server automatically

3. **If OpenCode isn't found:**
   - OpenWork will show an error with installation instructions
   - You can click the install button to try automatic installation (Scoop/Chocolatey)
   - Or install OpenCode manually using one of the methods above

## Troubleshooting

### "OpenCode CLI not found"
- Make sure OpenCode is installed and in your PATH
- Try running `opencode --version` in PowerShell to verify
- Restart OpenWork after installing OpenCode

### "Cannot start engine"
- Check that the selected workspace folder exists and is accessible
- Verify OpenCode is working: `opencode serve --help`
- Check Windows Firewall isn't blocking localhost connections

### Build errors
- Ensure Rust toolchain is installed: `rustc --version`
- Try `cargo clean` and rebuild
- Make sure you're using a recent version of Rust (1.70+)

### Missing dependencies
- Node.js version 18+ required
- pnpm version 8+ recommended
- Windows 10 or later required

## Next Steps

Once OpenWork is running:
- **Create a session**: Start working in your selected workspace
- **Manage skills**: Install OpenCode skills from the Skills tab
- **Configure plugins**: Add OpenCode plugins via the config editor

## Need Help?

- **Issues**: [GitHub Issues](https://github.com/different-ai/openwork/issues)
- **Documentation**: See `README.md` for more details
- **OpenCode docs**: [opencode.ai/docs](https://opencode.ai/docs)
