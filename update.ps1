#Requires -Version 5.1
# ============================================================
# nvim-dotfiles update — Windows (native)
# Updates: all Scoop packages (neovim, lazygit, tools, fonts),
#          Neovim plugins, and LSP servers
# Usage: nvim-update.ps1
# ============================================================

function Log-Step { param($msg); Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Log-Ok   { param($msg); Write-Host "  [OK] $msg" -ForegroundColor Green }
function Log-Warn { param($msg); Write-Host "  [WARN] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      nvim-dotfiles update             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Scoop packages ────────────────────────────────────────────────────────────
Log-Step "Updating all Scoop packages (neovim, lazygit, ripgrep, fd, nodejs, fonts)..."
scoop update *
Log-Ok "All Scoop packages updated"

# ── Neovim plugins ────────────────────────────────────────────────────────────
Log-Step "Updating Neovim plugins..."
try {
    nvim --headless "+Lazy! update" +qa 2>$null
    Log-Ok "Plugins updated"
} catch {
    Log-Warn "Plugin update completed with warnings. Check :Lazy inside nvim."
}

# ── Mason LSP servers ─────────────────────────────────────────────────────────
Log-Step "Updating LSP servers via Mason..."
try {
    nvim --headless "+MasonUpdate" +qa 2>$null
    Log-Ok "LSP servers updated"
} catch {
    Log-Warn "Mason update completed with warnings. Check :Mason inside nvim."
}

Write-Host ""
Write-Host "All done!" -ForegroundColor Green
Write-Host "Tip: commit lazy-lock.json to pin these plugin versions across all your machines."
Write-Host ""
