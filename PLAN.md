# Neovim + LazyVim Full IDE Setup — Portable Bootstrap

## Context
Setting up a modern terminal IDE using Neovim + LazyVim, fully bootstrapped from a single git repo. Goal: on any new machine, paste one command and the entire environment installs itself. Languages: Python, JavaScript/TypeScript, Rust, Go, C/C++, Java, Swift, Kotlin.

**Only pre-requisite: `curl` on Linux/macOS, PowerShell on Windows.** Everything else is installed by the bootstrap scripts.

---

## About lazygit

lazygit is a terminal UI for git — think of it as a full interactive git dashboard in your terminal. You can stage individual lines/hunks, commit, push, branch, resolve merge conflicts, and view file diffs — all without typing git commands. LazyVim integrates it directly: `<leader>gg` opens it in a floating window inside Neovim. It's optional but makes day-to-day git work significantly faster.

---

## Repo structure

```
dotfiles-nvim/
├── bootstrap.sh          ← Linux/macOS: curl -fsSL <url>/bootstrap.sh | bash
├── bootstrap.ps1         ← Windows native: irm <url>/bootstrap.ps1 | iex
├── update.sh             ← Linux/macOS: nvim-update
├── update.ps1            ← Windows: nvim-update.ps1
├── init.lua              ← LazyVim bootstrap (verbatim from starter template)
└── lua/
    ├── config/
    │   ├── lazy.lua      ← plugin spec + language extras
    │   ├── options.lua
    │   └── keymaps.lua
    └── plugins/
        └── extra-lsp.lua ← Swift + Kotlin manual LSP config
```

**Linux/macOS one-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles-nvim/main/bootstrap.sh | bash
```

**Windows one-liner (PowerShell):**
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://raw.githubusercontent.com/<you>/dotfiles-nvim/main/bootstrap.ps1 | iex
```

---

## Logging helpers (shared pattern in all scripts)

All scripts use the same colored log levels:
- `log_step` — bold blue `==>` — major phase
- `log_ok`   — green `  ✓` — completed item
- `log_warn` — yellow `[WARN]` — non-fatal issue
- `log_err`  — red `[ERR]` — fatal error (exits)

Scripts end with a structured **Post-install checklist** block (see below).

---

## bootstrap.sh (Linux/macOS)

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/<you>/dotfiles-nvim.git"
NVIM_CONFIG="$HOME/.config/nvim"
MANUAL_STEPS=()   # collected during install, printed at the end

# ── Logging ───────────────────────────────────────────────────────────────
log_step() { printf '\n\e[1;34m==>\e[0m \e[1m%s\e[0m\n' "$*"; }
log_ok()   { printf '  \e[32m✓\e[0m %s\n' "$*"; }
log_warn() { printf '  \e[33m[WARN]\e[0m %s\n' "$*"; }
log_err()  { printf '\e[1;31m[ERR]\e[0m %s\n' "$*" >&2; exit 1; }
add_step() { MANUAL_STEPS+=("$*"); }

OS="$(uname -s)"
ARCH="$(uname -m)"

[[ "$OS" == "Linux" || "$OS" == "Darwin" ]] || log_err "Unsupported OS: $OS"

# ── 1. Git ────────────────────────────────────────────────────────────────
log_step "Checking git..."
if ! command -v git &>/dev/null; then
  case "$OS" in
    Linux)  sudo apt-get update -qq && sudo apt-get install -y git ;;
    Darwin) xcode-select --install 2>/dev/null || true
            log_warn "xcode-select install may require a GUI prompt. Re-run this script after it completes."
            ;;
  esac
fi
log_ok "git $(git --version | cut -d' ' -f3)"

# ── 2. Neovim ─────────────────────────────────────────────────────────────
log_step "Installing Neovim..."
if command -v nvim &>/dev/null; then
  NVIM_VER=$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')
  log_warn "Neovim $NVIM_VER already installed — skipping. Run 'nvim-update' to upgrade."
else
  case "$OS" in
    Linux)
      case "$ARCH" in
        aarch64|arm64) FNAME="nvim-linux-arm64.appimage" ;;
        x86_64)        FNAME="nvim-linux-x86_64.appimage" ;;
        *)             log_err "Unsupported architecture: $ARCH" ;;
      esac
      curl -fsSLo /tmp/nvim.appimage \
        "https://github.com/neovim/neovim/releases/latest/download/${FNAME}"
      chmod u+x /tmp/nvim.appimage
      sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
      ;;
    Darwin)
      if ! command -v brew &>/dev/null; then
        log_step "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        [[ "$ARCH" == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
      brew install neovim
      ;;
  esac
  log_ok "Neovim $(nvim --version | head -1)"
fi

# ── 3. System dependencies ────────────────────────────────────────────────
log_step "Installing system dependencies..."
case "$OS" in
  Linux)
    sudo apt-get update -qq
    sudo apt-get install -y ripgrep fd-find curl unzip build-essential
    log_ok "ripgrep, fd, curl, unzip, build-essential"

    if ! command -v node &>/dev/null; then
      log_step "Installing Node.js LTS (required for TypeScript, Python LSPs)..."
      curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
      sudo apt-get install -y nodejs
    fi
    log_ok "Node.js $(node --version)"

    log_step "Installing lazygit..."
    LG_VER=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
    curl -fsSLo /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VER}/lazygit_${LG_VER}_Linux_x86_64.tar.gz"
    tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo mv /tmp/lazygit /usr/local/bin/lazygit
    log_ok "lazygit v${LG_VER}"
    ;;

  Darwin)
    brew install ripgrep fd node lazygit
    log_ok "ripgrep, fd, node, lazygit"
    ;;
esac

# ── 4. Nerd Font ──────────────────────────────────────────────────────────
log_step "Installing JetBrainsMono Nerd Font..."
case "$OS" in
  Linux)
    mkdir -p ~/.local/share/fonts
    curl -fsSLo ~/.local/share/fonts/JetBrainsMono.tar.xz \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    tar -xf ~/.local/share/fonts/JetBrainsMono.tar.xz -C ~/.local/share/fonts/
    rm ~/.local/share/fonts/JetBrainsMono.tar.xz
    fc-cache -fv
    log_ok "JetBrainsMono Nerd Font installed to ~/.local/share/fonts/"
    add_step "In your terminal emulator: set font to 'JetBrainsMono Nerd Font Mono'"
    ;;
  Darwin)
    brew install --cask font-jetbrains-mono-nerd-font
    log_ok "JetBrainsMono Nerd Font installed (system fonts)"
    add_step "In your terminal (iTerm2/Terminal/Warp): set font to 'JetBrainsMono Nerd Font Mono'"
    ;;
esac

# ── 5. Clone dotfiles ─────────────────────────────────────────────────────
log_step "Setting up Neovim config..."
if [[ -d "$NVIM_CONFIG" ]]; then
  BACKUP="${NVIM_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
  log_warn "Existing config found — moving to $BACKUP"
  mv "$NVIM_CONFIG" "$BACKUP"
fi
git clone "$DOTFILES_REPO" "$NVIM_CONFIG"
log_ok "Dotfiles cloned to $NVIM_CONFIG"

# ── 6. Install update script ──────────────────────────────────────────────
log_step "Installing nvim-update script..."
mkdir -p "$HOME/bin"
cp "$NVIM_CONFIG/update.sh" "$HOME/bin/nvim-update"
chmod +x "$HOME/bin/nvim-update"

BASHRC_UPDATED=false
if ! grep -q '"$HOME/bin"' ~/.bashrc 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
  BASHRC_UPDATED=true
fi
if [[ -f ~/.zshrc ]] && ! grep -q '"$HOME/bin"' ~/.zshrc 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
fi
log_ok "nvim-update → ~/bin/nvim-update"
$BASHRC_UPDATED && log_ok "Added ~/bin to PATH in ~/.bashrc"

# ── 7. Plugin + LSP bootstrap (headless) ─────────────────────────────────
log_step "Installing Neovim plugins (headless — this may take 1-2 minutes)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null && log_ok "Plugins installed" \
  || log_warn "Plugin install had warnings — open nvim and run :Lazy to verify"

log_step "Installing LSP servers via Mason (headless)..."
nvim --headless \
  "+MasonInstall pyright ruff-lsp typescript-language-server clangd jdtls kotlin-language-server" \
  +qa 2>/dev/null && log_ok "LSP servers installed" \
  || log_warn "Mason install had warnings — open nvim and run :Mason to verify"

# ── Swift caveat ──────────────────────────────────────────────────────────
if [[ "$OS" == "Linux" ]]; then
  add_step "Swift LSP (sourcekit-lsp): not auto-installed on Linux. Requires a Swift toolchain from swift.org. On macOS it comes with Xcode automatically."
fi

# ── Post-install summary ──────────────────────────────────────────────────
printf '\n\e[1;32m══════════════════════════════════════════\e[0m\n'
printf '\e[1;32m  Setup complete!\e[0m\n'
printf '\e[1;32m══════════════════════════════════════════\e[0m\n'
printf '\n\e[1mInstalled:\e[0m\n'
printf '  • Neovim %s\n' "$(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')"
printf '  • Plugins via lazy.nvim (LazyVim distribution)\n'
printf '  • LSPs: pyright, ruff, ts_ls, clangd, jdtls, kotlin-language-server\n'
printf '  • lazygit (open inside nvim with <leader>gg)\n'
printf '  • JetBrainsMono Nerd Font\n'

if [[ ${#MANUAL_STEPS[@]} -gt 0 ]]; then
  printf '\n\e[1;33mManual steps required:\e[0m\n'
  for i in "${!MANUAL_STEPS[@]}"; do
    printf '  %d. %s\n' "$((i+1))" "${MANUAL_STEPS[$i]}"
  done
fi

printf '\n\e[1mUseful commands:\e[0m\n'
printf '  nvim              — launch editor\n'
printf '  nvim-update       — update everything (run periodically)\n'
printf '  :checkhealth      — diagnose issues from inside nvim\n'
printf '  :Lazy             — plugin manager UI\n'
printf '  :Mason            — LSP/tool manager UI\n'
printf '  :LspInfo          — show active LSP for current file\n'
printf '\n'
```

---

## bootstrap.ps1 (Windows native)

Uses **Scoop** — installs to user profile, no admin rights required.

```powershell
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DOTFILES_REPO = "https://github.com/<you>/dotfiles-nvim.git"
$NVIM_CONFIG   = "$env:LOCALAPPDATA\nvim"
$ManualSteps   = [System.Collections.Generic.List[string]]::new()

function Log-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan -NoNewline; Write-Host "" }
function Log-Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Log-Warn($msg) { Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Log-Err($msg)  { Write-Host "[ERR] $msg" -ForegroundColor Red; exit 1 }
function Add-Step($s)   { $ManualSteps.Add($s) }

# ── 1. Scoop ───────────────────────────────────────────────────────────────
Log-Step "Checking Scoop (package manager)..."
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Log-Step "Installing Scoop..."
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","User") + ";" + $env:PATH
}
Log-Ok "Scoop ready"

# ── 2. Scoop buckets + tools ───────────────────────────────────────────────
Log-Step "Adding Scoop buckets..."
scoop bucket add extras 2>$null; scoop bucket add nerd-fonts 2>$null
Log-Ok "extras, nerd-fonts buckets added"

Log-Step "Installing tools (neovim, ripgrep, fd, lazygit, nodejs, git)..."
scoop install git neovim ripgrep fd lazygit nodejs
Log-Ok "All tools installed"

# ── 3. Nerd Font ──────────────────────────────────────────────────────────
Log-Step "Installing JetBrainsMono Nerd Font..."
scoop install JetBrainsMono-NF
Log-Ok "Font installed (current user)"
Add-Step "In Windows Terminal: Settings > Profile > Appearance > Font face > 'JetBrainsMono NF'"

# ── 4. Clone dotfiles ─────────────────────────────────────────────────────
Log-Step "Setting up Neovim config..."
if (Test-Path $NVIM_CONFIG) {
    $backup = "$NVIM_CONFIG.bak.$((Get-Date).ToString('yyyyMMddHHmmss'))"
    Log-Warn "Existing config found — moving to $backup"
    Move-Item $NVIM_CONFIG $backup
}
git clone $DOTFILES_REPO $NVIM_CONFIG
Log-Ok "Dotfiles cloned to $NVIM_CONFIG"

# ── 5. Install update script ───────────────────────────────────────────────
Log-Step "Installing nvim-update script..."
$binDir = "$HOME\bin"
New-Item -ItemType Directory -Force $binDir | Out-Null
Copy-Item "$NVIM_CONFIG\update.ps1" "$binDir\nvim-update.ps1"

$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$binDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$binDir;$userPath", "User")
    $env:PATH = "$binDir;$env:PATH"
    Log-Ok "Added $binDir to user PATH"
}
Log-Ok "nvim-update.ps1 → $binDir"
Add-Step "Restart your terminal (or run '. `$PROFILE') to pick up the new PATH"

# ── 6. Plugin + LSP bootstrap ─────────────────────────────────────────────
Log-Step "Installing Neovim plugins (headless — may take 1-2 min)..."
try {
    nvim --headless "+Lazy! sync" +qa 2>$null
    Log-Ok "Plugins installed"
} catch {
    Log-Warn "Plugin install had warnings — open nvim and run :Lazy to verify"
}

Log-Step "Installing LSP servers via Mason..."
try {
    nvim --headless "+MasonInstall pyright ruff-lsp typescript-language-server clangd jdtls kotlin-language-server" +qa 2>$null
    Log-Ok "LSP servers installed"
} catch {
    Log-Warn "Mason install had warnings — open nvim and run :Mason to verify"
}

Add-Step "Swift LSP (sourcekit-lsp) is not supported on Windows natively. Use on macOS with Xcode."

# ── Summary ───────────────────────────────────────────────────────────────
Write-Host "`n===========================================" -ForegroundColor Green
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host "`nInstalled:" -ForegroundColor White
$nvimVer = (nvim --version | Select-Object -First 1) -replace 'NVIM v', ''
Write-Host "  * Neovim $nvimVer"
Write-Host "  * Plugins via lazy.nvim (LazyVim distribution)"
Write-Host "  * LSPs: pyright, ruff, ts_ls, clangd, jdtls, kotlin-language-server"
Write-Host "  * lazygit (open inside nvim with <leader>gg)"
Write-Host "  * JetBrainsMono Nerd Font"

if ($ManualSteps.Count -gt 0) {
    Write-Host "`nManual steps required:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $ManualSteps.Count; $i++) {
        Write-Host "  $($i+1). $($ManualSteps[$i])"
    }
}

Write-Host "`nUseful commands:" -ForegroundColor White
Write-Host "  nvim              -- launch editor"
Write-Host "  nvim-update.ps1   -- update everything"
Write-Host "  :checkhealth      -- diagnose issues (inside nvim)"
Write-Host "  :Lazy             -- plugin manager UI"
Write-Host "  :Mason            -- LSP manager UI"
Write-Host ""
```

---

## update.sh (Linux/macOS)

```bash
#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
ARCH="$(uname -m)"
log_step() { printf '\n\e[1;34m==>\e[0m \e[1m%s\e[0m\n' "$*"; }
log_ok()   { printf '  \e[32m✓\e[0m %s\n' "$*"; }
log_warn() { printf '  \e[33m[WARN]\e[0m %s\n' "$*"; }

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
  Darwin) brew upgrade neovim ;;
esac
log_ok "Neovim $(nvim --version | head -1 | grep -oP '\d+\.\d+\.\d+')"

log_step "Updating lazygit..."
case "$OS" in
  Linux)
    LG_VER=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
    curl -fsSLo /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VER}/lazygit_${LG_VER}_Linux_x86_64.tar.gz"
    tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo mv /tmp/lazygit /usr/local/bin/lazygit
    log_ok "lazygit v${LG_VER}"
    ;;
  Darwin) brew upgrade lazygit; log_ok "lazygit updated" ;;
esac

log_step "Updating system deps..."
case "$OS" in
  Linux)  sudo apt-get update -qq && sudo apt-get upgrade -y ripgrep fd-find nodejs ;;
  Darwin) brew upgrade ripgrep fd node ;;
esac
log_ok "ripgrep, fd, nodejs upgraded"

log_step "Updating Neovim plugins..."
nvim --headless "+Lazy! update" +qa && log_ok "Plugins updated" \
  || log_warn "Plugin update had warnings — check :Lazy inside nvim"

log_step "Updating Mason LSP servers..."
nvim --headless "+MasonUpdate" +qa && log_ok "LSP servers updated" \
  || log_warn "Mason update had warnings — check :Mason inside nvim"

printf '\n\e[1;32mAll done!\e[0m Commit lazy-lock.json to pin plugin versions across machines.\n\n'
```

---

## update.ps1 (Windows)

```powershell
#Requires -Version 5.1
function Log-Step($m) { Write-Host "`n==> $m" -ForegroundColor Cyan }
function Log-Ok($m)   { Write-Host "  [OK] $m" -ForegroundColor Green }
function Log-Warn($m) { Write-Host "  [WARN] $m" -ForegroundColor Yellow }

Log-Step "Updating all Scoop packages (neovim, lazygit, ripgrep, fd, nodejs, fonts)..."
scoop update *
Log-Ok "Scoop packages updated"

Log-Step "Updating Neovim plugins..."
try { nvim --headless "+Lazy! update" +qa; Log-Ok "Plugins updated" }
catch { Log-Warn "Check :Lazy inside nvim for warnings" }

Log-Step "Updating Mason LSP servers..."
try { nvim --headless "+MasonUpdate" +qa; Log-Ok "LSP servers updated" }
catch { Log-Warn "Check :Mason inside nvim for warnings" }

Write-Host "`nAll done! Commit lazy-lock.json to pin plugin versions." -ForegroundColor Green
```

---

## Language extras (lua/config/lazy.lua)

Inside the `spec` table:

```lua
{ import = "lazyvim.plugins.extras.lang.python" },     -- pyright + ruff
{ import = "lazyvim.plugins.extras.lang.typescript" },  -- ts_ls + prettier
{ import = "lazyvim.plugins.extras.lang.rust" },        -- rust-analyzer
{ import = "lazyvim.plugins.extras.lang.go" },          -- gopls
{ import = "lazyvim.plugins.extras.lang.clangd" },      -- clangd (C/C++)
{ import = "lazyvim.plugins.extras.lang.java" },        -- jdtls
```

## Swift + Kotlin (lua/plugins/extra-lsp.lua)

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {},               -- Swift: auto-detected on macOS w/ Xcode
        kotlin_language_server = {},  -- Kotlin: Mason auto-installs
      },
    },
  },
}
```

---

## Language coverage

| Language | Extra | LSP | Formatter | Notes |
|----------|-------|-----|-----------|-------|
| Python | `lang.python` | pyright | ruff | |
| JS/TS | `lang.typescript` | ts_ls | prettier | |
| Rust | `lang.rust` | rust-analyzer | rustfmt | |
| Go | `lang.go` | gopls | gofmt | |
| C/C++ | `lang.clangd` | clangd | clang-format | |
| Java | `lang.java` | jdtls | — | |
| Kotlin | manual | kotlin-language-server | — | Mason auto-installs |
| Swift | manual | sourcekit-lsp | — | macOS only (Xcode required) |

---

## Key keybindings

| Key | Action |
|-----|--------|
| `<Space>` (leader) | which-key palette |
| `<leader>e` | file tree (neo-tree) |
| `<leader>ff` | fuzzy file search |
| `<leader>fg` | live grep |
| `<leader>gg` | lazygit (full git UI) |
| `K` | hover docs |
| `gd` | go to definition |
| `<leader>ca` | code action |
| `<leader>cr` | rename symbol |
| `]d` / `[d` | next/prev diagnostic |

---

## README.md

The repo's README — clear, no fluff, copy-paste ready.

```markdown
# nvim-dotfiles

Neovim IDE setup powered by [LazyVim](https://lazyvim.org). One command bootstraps a full IDE on any machine.

## Requirements

| Platform | Pre-requisite |
|----------|--------------|
| Linux (Debian/Ubuntu) | `curl` |
| macOS | `curl` |
| Windows | PowerShell 5.1+ |

Everything else (Neovim, git, LSPs, fonts) is installed automatically.

## Install

**Linux / macOS**
```bash
curl -fsSL https://raw.githubusercontent.com/<you>/nvim-dotfiles/main/bootstrap.sh | bash
```

**Windows** (PowerShell, run as your user — no admin needed)
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://raw.githubusercontent.com/<you>/nvim-dotfiles/main/bootstrap.ps1 | iex
```

After the script finishes, follow the printed checklist (font setup, etc.), then run `nvim`.

## Update

```bash
nvim-update          # Linux / macOS
nvim-update.ps1      # Windows
```

Updates Neovim, all plugins, all LSP servers, and system dependencies in one shot.

## Features

| Category | Tool | Notes |
|----------|------|-------|
| Plugin manager | lazy.nvim | Lazy-loads plugins, lockfile for reproducibility |
| LSP | nvim-lspconfig + Mason | Auto-installs language servers |
| Autocomplete | nvim-cmp + LuaSnip | Snippet-aware, LSP-backed |
| Syntax highlighting | nvim-treesitter | Semantic highlighting for all languages |
| File tree | neo-tree | Sidebar explorer |
| Fuzzy search | Telescope + ripgrep | Files, live grep, buffers, symbols |
| Git UI | lazygit | Full TUI git client, opens in floating window |
| Git signs | gitsigns.nvim | Added/changed/deleted lines in gutter |
| Statusline | lualine | Branch, diagnostics, file info |
| Keybind help | which-key | Popup cheatsheet on any prefix key |
| Formatting | conform.nvim | Auto-format on save (per-language) |
| Linting | nvim-lint | In-editor diagnostics |
| Terminal | toggleterm | Floating/split terminal inside nvim |

## Language support

| Language | LSP | Formatter |
|----------|-----|-----------|
| Python | pyright | ruff |
| JavaScript / TypeScript | ts_ls | prettier |
| Rust | rust-analyzer | rustfmt |
| Go | gopls | gofmt |
| C / C++ | clangd | clang-format |
| Java | jdtls | — |
| Kotlin | kotlin-language-server | — |
| Swift | sourcekit-lsp (macOS only) | — |

## Keybindings

`<leader>` = **Space**

### Navigation
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search across project) |
| `<leader>fb` | Switch buffers |
| `<leader>fr` | Recent files |
| `<leader><leader>` | Find open buffers |

### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cd` | Show line diagnostics |
| `]d` / `[d` | Next / prev diagnostic |

### Git
| Key | Action |
|-----|--------|
| `<leader>gg` | Open lazygit |
| `<leader>gb` | Git blame line |
| `]h` / `[h` | Next / prev git hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |

### Code
| Key | Action |
|-----|--------|
| `<leader>cf` | Format file |
| `gcc` | Toggle line comment |
| `gbc` | Toggle block comment |
| `<Tab>` / `<S-Tab>` | Next / prev completion item |
| `<CR>` | Confirm completion |

### Windows & Tabs
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Move between splits |
| `<leader>|` | Split window right |
| `<leader>-` | Split window below |
| `<leader>wd` | Close window |
| `<S-h>` / `<S-l>` | Prev / next buffer |

### Misc
| Key | Action |
|-----|--------|
| `<leader>?` | Show all keybindings (which-key) |
| `<C-\>` | Toggle floating terminal |
| `<leader>xl` | Location list |
| `<leader>xq` | Quickfix list |
| `<Esc>` | Clear search highlight |

> **Tip:** Press `<Space>` and wait — which-key will show all available commands grouped by category.

## Portability

The config is identical on all platforms. On a new machine:

1. Run the bootstrap script for your platform
2. Done — `lazy-lock.json` in this repo pins exact plugin versions for reproducibility

To add new plugins or LSPs, edit `lua/plugins/` and `lua/config/lazy.lua`, commit, and re-run `nvim-update` on other machines.
```

---

## Verification

```bash
nvim --version        # ≥ 0.9.0
```

Inside nvim:
- `:checkhealth` — diagnoses missing deps, shows what's broken
- `:Lazy` — plugin manager UI (all should be ✓)
- `:Mason` — LSP manager (shows installed servers)
- `:LspInfo` — confirms active LSP for current file
