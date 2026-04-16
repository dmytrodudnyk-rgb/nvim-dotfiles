#Requires -Version 5.1
# ============================================================
# nvim-dotfiles bootstrap -- Windows (native)
# Uses Scoop package manager -- no admin rights needed
# Usage (PowerShell):
#   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#   irm https://raw.githubusercontent.com/dmytrodudnyk-rgb/nvim-dotfiles/main/bootstrap.ps1 | iex
# ============================================================
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DOTFILES_REPO = "https://github.com/dmytrodudnyk-rgb/nvim-dotfiles.git"
$NVIM_CONFIG   = "$env:LOCALAPPDATA\nvim"
$ManualSteps   = [System.Collections.Generic.List[string]]::new()

# ── Logging ──────────────────────────────────────────────────────────────────
function Log-Step { param($msg); Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Log-Ok   { param($msg); Write-Host "  [OK] $msg" -ForegroundColor Green }
function Log-Warn { param($msg); Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Log-Err  { param($msg); Write-Host "[ERR] $msg" -ForegroundColor Red; exit 1 }
function Add-Step { param($s);   $ManualSteps.Add($s) | Out-Null }

Write-Host ""
Write-Host "+=======================================+" -ForegroundColor Cyan
Write-Host "|      nvim-dotfiles bootstrap          |" -ForegroundColor Cyan
Write-Host "+=======================================+" -ForegroundColor Cyan
Write-Host "Platform: Windows ($env:PROCESSOR_ARCHITECTURE)`n"

# ── 1. Scoop ─────────────────────────────────────────────────────────────────
Log-Step "Checking Scoop (package manager)..."
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Log-Step "Scoop not found -- installing Scoop..."
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
    # Reload PATH for the current session
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + $env:PATH
}
Log-Ok "Scoop is ready"

# ── 2. Scoop buckets + tools ──────────────────────────────────────────────────
Log-Step "Adding Scoop buckets (extras, nerd-fonts)..."
scoop bucket add extras 2>$null
scoop bucket add nerd-fonts 2>$null
Log-Ok "Buckets added"

Log-Step "Installing tools: git, neovim, ripgrep, fd, lazygit, nodejs, python, fzf, pwsh..."
scoop install git neovim ripgrep fd lazygit nodejs python fzf pwsh
Log-Ok "All tools installed"

Log-Step "Installing Neovim provider packages..."
# With Scoop nodejs, npm globals install to %APPDATA%\npm (user-local, no admin needed)
# Check prefix just in case and redirect if needed
$npmPrefix = npm config get prefix
if ($npmPrefix -like "*Program Files*" -or $npmPrefix -like "*system*") {
    Log-Warn "npm prefix '$npmPrefix' may require admin -- redirecting to $env:APPDATA\npm"
    npm config set prefix "$env:APPDATA\npm"
}
npm install -g neovim
Log-Ok "neovim npm package installed"

# pynvim in an isolated venv (avoids touching system Python packages)
python -m venv "$HOME\.venv\neovim"
& "$HOME\.venv\neovim\Scripts\pip" install pynvim
Log-Ok "pynvim installed (isolated venv at ~/.venv/neovim)"

# ── 3. Nerd Font ─────────────────────────────────────────────────────────────
Log-Step "Installing JetBrainsMono Nerd Font (required for icons in nvim)..."
scoop install JetBrainsMono-NF
Log-Ok "JetBrainsMono Nerd Font installed (current user)"
Add-Step "In Windows Terminal: press Ctrl+, > Profiles > Defaults > Appearance > Font face > set to 'JetBrainsMono Nerd Font Mono'"

# ── 4. Clone dotfiles ─────────────────────────────────────────────────────────
Log-Step "Setting up Neovim config..."
if (Test-Path $NVIM_CONFIG) {
    $backup = "$NVIM_CONFIG.bak.$((Get-Date).ToString('yyyyMMddHHmmss'))"
    Log-Warn "Existing config found -- backing up to: $backup"
    Move-Item $NVIM_CONFIG $backup
}
git clone $DOTFILES_REPO $NVIM_CONFIG
Log-Ok "Config cloned -> $NVIM_CONFIG"

# ── 5. Install nvim-update script ─────────────────────────────────────────────
Log-Step "Installing nvim-update script..."
$binDir = "$HOME\bin"
New-Item -ItemType Directory -Force $binDir | Out-Null
Copy-Item "$NVIM_CONFIG\update.ps1" "$binDir\nvim-update.ps1"
Log-Ok "nvim-update.ps1 installed -> $binDir"

# Add ~/bin to user PATH if not already there
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$binDir;$userPath", "User")
    $env:PATH = "$binDir;$env:PATH"
    Log-Ok "Added $binDir to user PATH"
    Add-Step "Restart your terminal (or open a new PowerShell window) so 'nvim-update' is available in PATH"
} else {
    Log-Ok "$binDir is already in PATH"
}

# ── 6. Bootstrap plugins via lazy.nvim (headless) ─────────────────────────────
Log-Step "Installing Neovim plugins (headless -- this may take 1-2 minutes)..."
try {
    nvim --headless "+Lazy! sync" +qa 2>$null
    Log-Ok "All plugins installed"
} catch {
    Log-Warn "Plugin install completed with warnings. Open nvim and run :Lazy to check status."
}

# ── 7. Install LSP servers via Mason (headless) ────────────────────────────────
Log-Step "Installing LSP servers via Mason (headless)..."
try {
    nvim --headless "+MasonInstall pyright ruff-lsp typescript-language-server clangd jdtls kotlin-language-server" +qa 2>$null
    Log-Ok "LSP servers installed: pyright, ruff-lsp, ts_ls, clangd, jdtls, kotlin-language-server"
} catch {
    Log-Warn "Mason install completed with warnings. Open nvim and run :Mason to check status."
}

# ── Swift note ────────────────────────────────────────────────────────────────
Add-Step "Swift LSP (sourcekit-lsp) is NOT available on Windows. It works on macOS with Xcode installed."

# ── Post-install summary ──────────────────────────────────────────────────────
Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

Write-Host "`nInstalled:" -ForegroundColor White
$nvimVer = (nvim --version | Select-Object -First 1) -replace 'NVIM v', ''
Write-Host "  * Neovim $nvimVer"
Write-Host "  * LazyVim distribution (plugins via lazy.nvim)"
Write-Host "  * LSP servers: pyright, ruff-lsp, ts_ls, clangd, jdtls, kotlin-language-server"
Write-Host "  * lazygit -- open inside nvim with <Space>gg"
Write-Host "  * JetBrainsMono Nerd Font"

if ($ManualSteps.Count -gt 0) {
    Write-Host "`nManual steps required:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $ManualSteps.Count; $i++) {
        Write-Host "  $($i+1). $($ManualSteps[$i])"
    }
}

Write-Host "`nUseful commands:" -ForegroundColor White
Write-Host "  nvim                -- launch the editor"
Write-Host "  nvim-update.ps1     -- update everything (plugins, LSPs, tools)"
Write-Host "  Inside nvim:"
Write-Host "    :checkhealth      -- diagnose any issues"
Write-Host "    :Lazy             -- plugin manager UI"
Write-Host "    :Mason            -- LSP / tool manager UI"
Write-Host "    :LspInfo          -- show active LSP for current file"
Write-Host "    <Space>?          -- show all keybindings"
Write-Host ""
