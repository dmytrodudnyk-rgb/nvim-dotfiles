#!/usr/bin/env bash
# ============================================================
# nvim-dotfiles update — Linux & macOS
# Updates: Neovim, lazygit, system deps, plugins, LSP servers
# Usage: nvim-update
# ============================================================
set -euo pipefail

OS="$(uname -s)"
ARCH="$(uname -m)"

log_step() { printf '\n\e[1;34m==>\e[0m \e[1m%s\e[0m\n' "$*"; }
log_ok()   { printf '  \e[32m✓\e[0m %s\n' "$*"; }
log_warn() { printf '  \e[33m[WARN]\e[0m %s\n' "$*"; }

printf '\e[1;34m'
printf '╔═══════════════════════════════════════╗\n'
printf '║      nvim-dotfiles update             ║\n'
printf '╚═══════════════════════════════════════╝\n'
printf '\e[0m\n'

# ── Neovim ───────────────────────────────────────────────────────────────────
log_step "Updating Neovim..."
case "$OS" in
  Linux)
    case "$ARCH" in
      aarch64|arm64) FNAME="nvim-linux-arm64.appimage" ;;
      *)             FNAME="nvim-linux-x86_64.appimage" ;;
    esac
    curl -fsSLo /tmp/nvim.appimage \
      "https://github.com/neovim/neovim/releases/latest/download/${FNAME}"
    chmod u+x /tmp/nvim.appimage
    sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
    ;;
  Darwin)
    brew upgrade neovim
    ;;
  *)
    log_warn "Unknown OS '$OS' — skipping Neovim binary update."
    ;;
esac
log_ok "Neovim $(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')"

# ── lazygit ───────────────────────────────────────────────────────────────────
log_step "Updating lazygit..."
case "$OS" in
  Linux)
    LG_VER="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')"
    curl -fsSLo /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VER}/lazygit_${LG_VER}_Linux_x86_64.tar.gz"
    tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo mv /tmp/lazygit /usr/local/bin/lazygit
    rm -f /tmp/lazygit.tar.gz
    log_ok "lazygit v${LG_VER}"
    ;;
  Darwin)
    brew upgrade lazygit
    log_ok "lazygit updated"
    ;;
esac

# ── System dependencies ───────────────────────────────────────────────────────
log_step "Updating system dependencies..."
case "$OS" in
  Linux)
    sudo apt-get update -qq
    sudo apt-get upgrade -y ripgrep fd-find nodejs
    log_ok "ripgrep, fd-find, nodejs upgraded"
    ;;
  Darwin)
    brew upgrade ripgrep fd node
    log_ok "ripgrep, fd, node upgraded"
    ;;
esac

# ── Neovim plugins ────────────────────────────────────────────────────────────
log_step "Updating Neovim plugins..."
if nvim --headless "+Lazy! update" +qa 2>/dev/null; then
  log_ok "Plugins updated"
else
  log_warn "Plugin update completed with warnings. Check :Lazy inside nvim."
fi

# ── Mason LSP servers ─────────────────────────────────────────────────────────
log_step "Updating LSP servers via Mason..."
if nvim --headless "+MasonUpdate" +qa 2>/dev/null; then
  log_ok "LSP servers updated"
else
  log_warn "Mason update completed with warnings. Check :Mason inside nvim."
fi

printf '\n\e[1;32mAll done!\e[0m\n'
printf 'Tip: commit lazy-lock.json to pin these plugin versions across all your machines.\n\n'
