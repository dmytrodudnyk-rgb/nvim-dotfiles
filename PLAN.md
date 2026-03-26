# Neovim + LazyVim Full IDE Setup — Portable Bootstrap

## What this is

A modern terminal IDE using Neovim + LazyVim, fully bootstrapped from a single git repo.
On any new machine: paste one command and the entire environment installs itself.

**Languages:** Python, JavaScript/TypeScript, Rust, Go, C/C++, Java, Swift, Kotlin

**Only pre-requisite:** `curl` on Linux/macOS, PowerShell 5.1+ on Windows.
Everything else — Neovim, git, LSP servers, fonts, tools — is installed by the bootstrap scripts.

---

## Repo structure

```
nvim-dotfiles/
├── bootstrap.sh          ← Linux/macOS installer
├── bootstrap.ps1         ← Windows installer (Scoop, no admin)
├── update.sh             ← Linux/macOS updater → installed as ~/bin/nvim-update
├── update.ps1            ← Windows updater → installed as ~/bin/nvim-update.ps1
├── init.lua              ← LazyVim entry point (standard starter template)
├── lazy-lock.json        ← Pinned plugin versions (committed, reproducible)
└── lua/
    ├── config/
    │   ├── lazy.lua      ← Plugin spec + LazyVim language extras
    │   ├── options.lua   ← Editor options + provider config
    │   └── keymaps.lua   ← Custom keybindings
    └── plugins/
        └── extra-lsp.lua ← Swift (sourcekit) + Kotlin LSP config
```

---

## Design decisions and why

### Neovim install: AppImage on Linux
The system `apt` package is outdated on most Ubuntu/Debian machines. We download the latest
AppImage directly from GitHub releases, mark it executable, and move it to `/usr/local/bin/nvim`.
This gives us a current version on first install. `nvim-update` re-downloads it to upgrade.

### pynvim: apt on Linux, venv on macOS/Windows
`pip install pynvim` fails on some systems with IPv6 connectivity errors and hits
`--break-system-packages` restrictions on newer distros. Solution:
- **Linux**: `sudo apt-get install -y python3-pynvim` (bypasses pip entirely)
- **macOS/Windows**: `python3 -m venv ~/.venv/neovim && pip install pynvim`

`options.lua` sets `python3_host_prog` to the venv Python on macOS/Windows only.
Linux uses system Python automatically — no override needed.

If a stale `~/.venv/neovim` exists on Linux (from a previous failed bootstrap), it is removed
automatically before the apt install to prevent the provider from picking up the empty venv.

### npm prefix redirect
System Node.js installs often set the npm global prefix to a system path (`/usr/lib/node_modules`)
which requires sudo for `npm install -g`. The bootstrap checks if the prefix starts with `/usr*`
and redirects it to `~/.local` before installing `neovim` and `tree-sitter-cli` globally.

### luarocks disabled
`lazy.nvim` tries to bootstrap luarocks by default, producing checkhealth errors if Lua build
tools aren't present. Disabled via `rocks = { enabled = false }` in `lazy.lua` — none of the
plugins in this setup require luarocks.

### Perl/Ruby providers disabled
Neovim checks for Perl and Ruby providers by default. Neither is needed here.
Suppressed via `vim.g.loaded_perl_provider = 0` and `vim.g.loaded_ruby_provider = 0` in
`options.lua` to keep `:checkhealth` output clean.

### PATH setup: bash, zsh, fish
The bootstrap adds `~/bin` and `~/.local/bin` to PATH in `~/.bashrc` and `~/.zshrc`.
For fish shell, it uses `fish -c "fish_add_path $HOME/bin $HOME/.local/bin"` which is
natively idempotent (won't add duplicate entries).

### MANUAL_STEPS pattern
Instead of printing caveats inline during install (which scroll off the screen), the scripts
collect them in a `MANUAL_STEPS` array and print them together in a numbered checklist at the
end of the run. This ensures nothing gets missed.

---

## bootstrap.sh — Linux/macOS

Steps, in order:
1. **git** — install via apt (Linux) or xcode-select (macOS) if missing
2. **Neovim** — skip if already installed; otherwise download AppImage (Linux) or `brew install neovim`
3. **System deps** (Linux): `ripgrep fd-find curl unzip build-essential xclip fzf python3-pip python3-venv python3-pynvim`
   - Node.js LTS via nodesource if not present
   - npm prefix check + redirect to `~/.local` if needed
   - `npm install -g neovim tree-sitter-cli`
   - Remove stale `~/.venv/neovim` if it exists on Linux
   - lazygit downloaded from GitHub releases
4. **System deps** (macOS): `brew install ripgrep fd node lazygit fzf`
   - `npm install -g neovim tree-sitter-cli`
   - `python3 -m venv ~/.venv/neovim && pip install pynvim`
5. **JetBrainsMono Nerd Font** — tar.xz to `~/.local/share/fonts/` + `fc-cache` (Linux); brew cask (macOS)
6. **Clone dotfiles** — backs up existing `~/.config/nvim` with timestamp if present
7. **nvim-update script** — copies `update.sh` to `~/bin/nvim-update`, adds `~/bin` and `~/.local/bin` to PATH (bash, zsh, fish)
8. **Headless plugin install** — `nvim --headless "+Lazy! sync" +qa`
9. **Headless LSP install** — `nvim --headless "+MasonInstall pyright ruff-lsp typescript-language-server clangd jdtls kotlin-language-server" +qa`
10. **Post-install summary** — installed versions, manual steps checklist

---

## bootstrap.ps1 — Windows

Uses **Scoop** (user-local package manager, no admin rights required).

Steps, in order:
1. **Scoop** — install if missing, reload PATH
2. **Scoop buckets** — add `extras` and `nerd-fonts`
3. **Tools** — `scoop install git neovim ripgrep fd lazygit nodejs fzf`
4. **npm providers** — prefix check, `npm install -g neovim`
5. **pynvim** — `python -m venv "$HOME\.venv\neovim"` + pip install pynvim
6. **JetBrainsMono-NF** — `scoop install JetBrainsMono-NF`
7. **Clone dotfiles** — backs up existing `%LOCALAPPDATA%\nvim` with timestamp
8. **nvim-update script** — copies `update.ps1` to `~/bin/nvim-update.ps1`, adds to user PATH
9. **Headless plugin + LSP install** — same Mason/Lazy commands as Linux/macOS
10. **Post-install summary** — manual steps checklist

---

## Lua config

### lua/config/lazy.lua

Key settings beyond the plugin spec:
```lua
rocks    = { enabled = false }   -- disable luarocks (not needed, avoids checkhealth noise)
defaults = { lazy = false, version = false }
checker  = { enabled = true, notify = false }
```

Language extras loaded:
```lua
{ import = "lazyvim.plugins.extras.lang.python" },     -- pyright + ruff
{ import = "lazyvim.plugins.extras.lang.typescript" },  -- ts_ls + prettier
{ import = "lazyvim.plugins.extras.lang.rust" },        -- rust-analyzer + rustaceanvim
{ import = "lazyvim.plugins.extras.lang.go" },          -- gopls + gofmt
{ import = "lazyvim.plugins.extras.lang.clangd" },      -- clangd + clang-format
{ import = "lazyvim.plugins.extras.lang.java" },        -- jdtls
```

### lua/config/options.lua

Notable options beyond LazyVim defaults:
- `relativenumber = true`, `tabstop/shiftwidth = 4`, `scrolloff = 8`, `wrap = false`
- `loaded_perl_provider = 0`, `loaded_ruby_provider = 0` — suppress unused provider warnings
- `python3_host_prog` — set to `~/.venv/neovim` Python on macOS and Windows; not set on Linux

### lua/plugins/extra-lsp.lua

Manually configures Swift and Kotlin (not covered by LazyVim extras):
```lua
servers = {
  sourcekit = { filetypes = { "swift", "objective-c", "objective-cpp" } },
  kotlin_language_server = {},
}
-- Mason ensure_installed: { "kotlin-language-server" }
```

sourcekit-lsp is macOS-only (requires Xcode). A note is added to MANUAL_STEPS on Linux.

---

## Language coverage

| Language | How configured | LSP | Formatter |
|----------|---------------|-----|-----------|
| Python | `lang.python` extra | pyright | ruff |
| JS/TS | `lang.typescript` extra | ts_ls | prettier |
| Rust | `lang.rust` extra | rust-analyzer | rustfmt |
| Go | `lang.go` extra | gopls | gofmt |
| C/C++ | `lang.clangd` extra | clangd | clang-format |
| Java | `lang.java` extra | jdtls | — |
| Kotlin | `extra-lsp.lua` + Mason | kotlin-language-server | — |
| Swift | `extra-lsp.lua` | sourcekit-lsp | — | macOS only (Xcode) |

---

## Known caveats / non-issues

- **pynvim version warning** (`:checkhealth`): apt ships `python3-pynvim` 0.5.0 while PyPI has 0.6.0. The warning is cosmetic — LazyVim works fine with 0.5.0.
- **tree-sitter-cli PATH**: After npm install, the binary is in `~/.local/bin` which may not be on PATH until the terminal is restarted. nvim-treesitter compiles grammars lazily on first file open, so this resolves itself.
- **Snacks checkhealth errors**: Timing artifacts during `:checkhealth` in headless mode — not real errors. Opening nvim normally shows no issues.
- **Swift on Linux**: sourcekit-lsp is not available. Install a Swift toolchain from swift.org and add it to PATH if needed.

---

## Update scripts

### update.sh (Linux/macOS)
1. Re-download Neovim AppImage (Linux) / `brew upgrade neovim` (macOS)
2. Re-download latest lazygit (Linux) / `brew upgrade lazygit` (macOS)
3. `apt upgrade` / `brew upgrade` for ripgrep, fd, nodejs
4. `nvim --headless "+Lazy! update" +qa`
5. `nvim --headless "+MasonUpdate" +qa`

### update.ps1 (Windows)
1. `scoop update *` — updates everything in one shot
2. `nvim --headless "+Lazy! update" +qa`
3. `nvim --headless "+MasonUpdate" +qa`

---

## Verification

After bootstrap, confirm everything is working:

```bash
nvim --version        # should be current stable release
nvim +:checkhealth    # check for errors (Perl/Ruby/luarocks warnings are suppressed)
```

Inside nvim:
- `:Lazy` — all plugins should show as installed
- `:Mason` — LSP servers should be listed as installed
- `:LspInfo` — open a `.py`, `.ts`, `.rs` etc. file and confirm the LSP is active
