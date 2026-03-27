# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Neovim IDE config powered by LazyVim. Single-command bootstrap installs everything (Neovim, plugins, LSPs, fonts) on Linux/macOS/Windows. The Lua config is platform-agnostic; only bootstrap/update scripts differ per OS.

## Key commands

```bash
# Bootstrap (installs everything from scratch)
./bootstrap.sh                          # Linux/macOS
./bootstrap.ps1                         # Windows

# Update (Neovim, tools, plugins, LSPs)
nvim-update                             # Linux/macOS (installed to ~/bin)
nvim-update.ps1                         # Windows

# Headless plugin sync
nvim --headless "+Lazy! sync" +qa

# Headless LSP install
nvim --headless "+MasonInstall <server-name>" +qa

# Health check
nvim +:checkhealth
```

## Architecture

**Entry point:** `init.lua` -> `require("config.lazy")`

**Config layer** (`lua/config/`):
- `lazy.lua` - Plugin spec, LazyVim extras imports, lazy.nvim settings (luarocks disabled, semver tags disabled)
- `options.lua` - Editor overrides (4-space tabs, relative numbers, scrolloff 8, no wrap, platform-specific python3_host_prog)
- `keymaps.lua` - Custom bindings on top of LazyVim defaults (jk escape, Ctrl-s save, Alt-j/k line move, persistent visual indent)

**Plugin layer** (`lua/plugins/`):
- Files here are auto-imported by lazy.nvim. Drop a `.lua` file to add a plugin.
- `extra-lsp.lua` - Swift (sourcekit, macOS-only) + Kotlin LSP configs not covered by LazyVim extras
- `claudecode.lua` - Claude Code integration with diff-in-new-tab + keep-terminal-focus

**LazyVim extras enabled** (in `lazy.lua`):
- Languages: python, typescript, rust, go, clangd, java, yaml, toml, markdown, docker, sql
- Editor: yanky, mini-surround, neogen, dial, inc-rename, illuminate, harpoon2, aerial, refactoring
- UI: treesitter-context, indent-blankline, mini-animate
- Other: eslint, dap.core, rest, claudecode

**Bootstrap/update scripts** (shell, not Lua):
- `bootstrap.sh` / `bootstrap.ps1` - Full install from zero
- `update.sh` / `update.ps1` - Incremental update of everything
- Use `MANUAL_STEPS` array pattern: collect post-install instructions, print them as numbered checklist at the end

## Adding a new plugin

Create `lua/plugins/<name>.lua` returning a lazy.nvim plugin spec table. It gets auto-imported.

## Adding a new language

If LazyVim has an extra for it: add `{ import = "lazyvim.plugins.extras.lang.<name>" }` to `lazy.lua`.
If not: add LSP config to `extra-lsp.lua` and Mason ensure_installed entry.

## Platform notes

- **Python provider**: venv on macOS/Windows (`~/.venv/neovim`), system apt package on Linux
- **sourcekit-lsp**: macOS only (requires Xcode); not available on Linux without manual Swift toolchain
- **npm global prefix**: bootstrap redirects from `/usr/*` to `~/.local` to avoid sudo
- `lazy-lock.json` is committed for reproducible plugin versions across machines
