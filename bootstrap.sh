#!/usr/bin/env bash
# ============================================================
# nvim-dotfiles bootstrap — Linux & macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/dmytrodudnyk-rgb/nvim-dotfiles/main/bootstrap.sh | bash
# ============================================================
set -euo pipefail

DOTFILES_REPO="https://github.com/dmytrodudnyk-rgb/nvim-dotfiles.git"
NVIM_CONFIG="$HOME/.config/nvim"
MANUAL_STEPS=()

# ── Logging ──────────────────────────────────────────────────────────────────
log_step() { printf '\n\e[1;34m==>\e[0m \e[1m%s\e[0m\n' "$*"; }
log_ok()   { printf '  \e[32m✓\e[0m %s\n' "$*"; }
log_warn() { printf '  \e[33m[WARN]\e[0m %s\n' "$*"; }
log_err()  { printf '\e[1;31m[ERR]\e[0m %s\n' "$*" >&2; exit 1; }
add_step() { MANUAL_STEPS+=("$*"); }

OS="$(uname -s)"
ARCH="$(uname -m)"

[[ "$OS" == "Linux" || "$OS" == "Darwin" ]] || log_err "Unsupported OS: $OS (only Linux and macOS are supported)"

printf '\e[1;34m'
printf '╔═══════════════════════════════════════╗\n'
printf '║      nvim-dotfiles bootstrap          ║\n'
printf '╚═══════════════════════════════════════╝\n'
printf '\e[0m'
printf 'Platform: %s (%s)\n' "$OS" "$ARCH"
printf '\n'

# ── 1. git ────────────────────────────────────────────────────────────────────
log_step "Checking git..."
if ! command -v git &>/dev/null; then
  case "$OS" in
    Linux)
      sudo apt-get update -qq
      sudo apt-get install -y git
      ;;
    Darwin)
      log_warn "Running: xcode-select --install (may require a GUI confirmation dialog)"
      xcode-select --install 2>/dev/null || true
      log_warn "If a dialog appeared, accept it, wait for installation, then re-run this script."
      command -v git &>/dev/null || log_err "git not found after xcode-select install. Please re-run."
      ;;
  esac
fi
log_ok "git $(git --version | cut -d' ' -f3)"

# ── 2. Neovim ────────────────────────────────────────────────────────────────
log_step "Installing Neovim..."
if command -v nvim &>/dev/null; then
  NVIM_VER="$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')"
  log_warn "Neovim $NVIM_VER is already installed — skipping. Run 'nvim-update' to upgrade to the latest version."
else
  case "$OS" in
    Linux)
      case "$ARCH" in
        aarch64|arm64) FNAME="nvim-linux-arm64.appimage" ;;
        x86_64)        FNAME="nvim-linux-x86_64.appimage" ;;
        *)             log_err "Unsupported CPU architecture: $ARCH" ;;
      esac
      log_ok "Downloading $FNAME..."
      curl -fsSLo /tmp/nvim.appimage \
        "https://github.com/neovim/neovim/releases/latest/download/${FNAME}"
      chmod u+x /tmp/nvim.appimage
      sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
      ;;
    Darwin)
      if ! command -v brew &>/dev/null; then
        log_step "Homebrew not found — installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Apple Silicon: add brew to PATH for the current shell session
        if [[ "$ARCH" == "arm64" ]] && [[ -f /opt/homebrew/bin/brew ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
      fi
      brew install neovim
      ;;
  esac
  log_ok "Neovim $(nvim --version | head -1)"
fi

# ── 3. System dependencies ────────────────────────────────────────────────────
log_step "Installing system dependencies..."
case "$OS" in
  Linux)
    sudo apt-get update -qq
    sudo apt-get install -y ripgrep fd-find curl unzip build-essential xclip fzf python3-pip python3-venv
    log_ok "ripgrep, fd-find, curl, unzip, build-essential, xclip, fzf"

    if ! command -v node &>/dev/null; then
      log_step "Installing Node.js LTS (required for TypeScript and Python LSPs)..."
      curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
      sudo apt-get install -y nodejs
    fi
    log_ok "Node.js $(node --version)"

    log_step "Installing Neovim provider packages..."
    # If npm global prefix is a system path, redirect it to ~/.local to avoid needing sudo
    NPM_PREFIX="$(npm config get prefix)"
    if [[ "$NPM_PREFIX" == /usr* ]]; then
      log_warn "npm global prefix is '$NPM_PREFIX' (requires sudo) — redirecting to ~/.local"
      npm config set prefix ~/.local
    fi
    npm install -g neovim
    # Use apt for pynvim — avoids pip IPv6 issues and doesn't touch user packages
    sudo apt-get install -y python3-pynvim
    log_ok "neovim (npm → $(npm config get prefix)), pynvim (apt)"

    log_step "Installing lazygit (interactive git TUI)..."
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
    brew install ripgrep fd node lazygit fzf
    log_ok "ripgrep, fd, node, lazygit, fzf"
    npm install -g neovim
    # macOS: use venv for pynvim (no apt available)
    python3 -m venv ~/.venv/neovim
    ~/.venv/neovim/bin/pip install pynvim
    log_ok "neovim (npm), pynvim (isolated venv at ~/.venv/neovim)"
    ;;
esac

# ── 4. Nerd Font ─────────────────────────────────────────────────────────────
log_step "Installing JetBrainsMono Nerd Font (required for icons in nvim)..."
case "$OS" in
  Linux)
    mkdir -p ~/.local/share/fonts
    curl -fsSLo /tmp/JetBrainsMono.tar.xz \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    tar -xf /tmp/JetBrainsMono.tar.xz -C ~/.local/share/fonts/
    rm -f /tmp/JetBrainsMono.tar.xz
    fc-cache -fv >/dev/null
    log_ok "JetBrainsMono Nerd Font installed → ~/.local/share/fonts/"
    add_step "Set your terminal font to 'JetBrainsMono Nerd Font Mono' in your terminal's settings. If the font doesn't appear in the list, close and reopen the terminal — the font list is only refreshed on startup. Search for 'JetBrainsMono' in the font picker."
    ;;
  Darwin)
    brew install --cask font-jetbrains-mono-nerd-font
    log_ok "JetBrainsMono Nerd Font installed (available system-wide)"
    add_step "Set your terminal font to 'JetBrainsMono Nerd Font Mono' in your terminal's preferences. If the font doesn't appear in the list, close and reopen the terminal — the font list is only refreshed on startup. Search for 'JetBrainsMono' in the font picker."
    ;;
esac

# ── 5. Clone dotfiles ─────────────────────────────────────────────────────────
log_step "Setting up Neovim config..."
if [[ -d "$NVIM_CONFIG" ]]; then
  BACKUP="${NVIM_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
  log_warn "Existing Neovim config found — backing up to: $BACKUP"
  mv "$NVIM_CONFIG" "$BACKUP"
fi
git clone "$DOTFILES_REPO" "$NVIM_CONFIG"
log_ok "Config cloned → $NVIM_CONFIG"

# ── 6. Install nvim-update script ─────────────────────────────────────────────
log_step "Installing nvim-update script..."
mkdir -p "$HOME/bin"
cp "$NVIM_CONFIG/update.sh" "$HOME/bin/nvim-update"
chmod +x "$HOME/bin/nvim-update"

SHELL_UPDATED=false
for RC in ~/.bashrc ~/.zshrc; do
  if [[ -f "$RC" ]]; then
    if ! grep -q '"$HOME/bin"' "$RC" 2>/dev/null; then
      echo 'export PATH="$HOME/bin:$PATH"' >> "$RC"
      log_ok "Added ~/bin to PATH in $RC"
      SHELL_UPDATED=true
    fi
    if ! grep -q '"$HOME/.local/bin"' "$RC" 2>/dev/null; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$RC"
      log_ok "Added ~/.local/bin to PATH in $RC"
      SHELL_UPDATED=true
    fi
  fi
done

# Fish shell — uses fish_add_path which is idempotent (no duplicate entries)
if command -v fish &>/dev/null; then
  fish -c "fish_add_path $HOME/bin $HOME/.local/bin"
  log_ok "Added ~/bin and ~/.local/bin to fish PATH (fish_user_paths)"
fi

[[ "$SHELL_UPDATED" == "false" ]] && log_ok "~/bin and ~/.local/bin already in PATH"
log_ok "nvim-update installed → ~/bin/nvim-update"

# ── 7. Bootstrap plugins via lazy.nvim (headless) ────────────────────────────
log_step "Installing Neovim plugins (headless — this may take 1–2 minutes)..."
if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
  log_ok "All plugins installed"
else
  log_warn "Plugin install completed with warnings. Open nvim and run :Lazy to check status."
fi

# ── 8. Install LSP servers via Mason (headless) ───────────────────────────────
log_step "Installing LSP servers via Mason (headless)..."
if nvim --headless \
  "+MasonInstall pyright ruff-lsp typescript-language-server clangd jdtls kotlin-language-server" \
  +qa 2>/dev/null; then
  log_ok "LSP servers installed: pyright, ruff-lsp, ts_ls, clangd, jdtls, kotlin-language-server"
else
  log_warn "Mason install completed with warnings. Open nvim and run :Mason to check status."
fi

# ── Swift note ────────────────────────────────────────────────────────────────
if [[ "$OS" == "Linux" ]]; then
  add_step "Swift LSP (sourcekit-lsp) is NOT available on Linux. On macOS it comes bundled with Xcode — install Xcode and Swift support will activate automatically."
fi

# ── Post-install summary ──────────────────────────────────────────────────────
printf '\n'
printf '\e[1;32m══════════════════════════════════════════\e[0m\n'
printf '\e[1;32m  Setup complete!\e[0m\n'
printf '\e[1;32m══════════════════════════════════════════\e[0m\n'

printf '\n\e[1mInstalled:\e[0m\n'
printf '  • Neovim %s\n' "$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')"
printf '  • LazyVim distribution (plugins via lazy.nvim)\n'
printf '  • LSP servers: pyright, ruff-lsp, ts_ls, clangd, jdtls, kotlin-language-server\n'
printf '  • lazygit — open inside nvim with <Space>gg\n'
printf '  • JetBrainsMono Nerd Font\n'

if [[ ${#MANUAL_STEPS[@]} -gt 0 ]]; then
  printf '\n\e[1;33mManual steps required:\e[0m\n'
  for i in "${!MANUAL_STEPS[@]}"; do
    printf '  %d. %s\n' "$((i+1))" "${MANUAL_STEPS[$i]}"
  done
fi

printf '\n\e[1mUseful commands:\e[0m\n'
printf '  nvim                — launch the editor\n'
printf '  nvim-update         — update everything (plugins, LSPs, tools)\n'
printf '  nvim +:checkhealth  — diagnose any issues\n'
printf '  Inside nvim:\n'
printf '    :Lazy             — plugin manager UI\n'
printf '    :Mason            — LSP / tool manager UI\n'
printf '    :LspInfo          — show active LSP for current file\n'
printf '    <Space>?          — show all keybindings\n'
printf '\n'
