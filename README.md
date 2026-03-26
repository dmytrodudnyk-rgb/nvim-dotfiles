# nvim-dotfiles

Neovim IDE setup powered by [LazyVim](https://lazyvim.org). One command bootstraps a full IDE on any machine — no manual plugin installation, no manual LSP setup.

## Requirements

| Platform | Pre-requisite |
|----------|--------------|
| Linux (Debian/Ubuntu) | `curl` |
| macOS | `curl` |
| Windows | PowerShell 5.1+ |

Everything else — Neovim, git, LSP servers, fonts, and tools — is installed automatically by the bootstrap script.

## Install

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/dmytrodudnyk-rgb/nvim-dotfiles/main/bootstrap.sh | bash
```

### Windows (PowerShell — no admin rights needed)

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://raw.githubusercontent.com/dmytrodudnyk-rgb/nvim-dotfiles/main/bootstrap.ps1 | iex
```

After the script finishes, read the **Manual steps required** section it prints, then run `nvim`.

### Font setup (required)

The bootstrap script installs JetBrainsMono Nerd Font automatically, but you need to select it in your terminal:

1. **Close and reopen your terminal** — font lists are only refreshed on startup
2. Open your terminal's font settings and search for **`JetBrainsMono Nerd Font Mono`**
3. Select it and save

> Without a Nerd Font, icons in the file tree, statusline, and git signs will show as garbled squares instead of glyphs.

If the font still doesn't appear after restarting, refresh the font cache manually:
```bash
fc-cache -fv && sudo fc-cache -fv
```
Then restart the terminal again.

## Update

Run this periodically to keep everything current:

```bash
nvim-update          # Linux / macOS
nvim-update.ps1      # Windows
```

This updates Neovim, lazygit, system packages, all plugins, and all LSP servers in one shot.

---

## Features

| Category | Tool | Notes |
|----------|------|-------|
| Plugin manager | [lazy.nvim](https://github.com/folke/lazy.nvim) | Lazy-loads plugins; `lazy-lock.json` pins exact versions |
| LSP | nvim-lspconfig + [Mason](https://github.com/williamboman/mason.nvim) | Language servers auto-installed on first launch |
| Autocomplete | nvim-cmp + LuaSnip | Snippet-aware, LSP-backed completions |
| Syntax highlighting | nvim-treesitter | Semantic, accurate highlighting for all supported languages |
| File tree | neo-tree | Sidebar file explorer |
| Fuzzy search | Telescope + ripgrep | Find files, live grep, buffers, LSP symbols |
| Git UI | [lazygit](https://github.com/jesseduffield/lazygit) | Full TUI git client in a floating window (`<Space>gg`) |
| Git signs | gitsigns.nvim | Added/changed/removed lines shown in the gutter |
| Statusline | lualine | Shows branch, diagnostics, file info |
| Keybind help | which-key | Press `<Space>` and wait for a contextual popup of all bindings |
| Formatting | conform.nvim | Auto-formats on save using the per-language formatter |
| Linting | nvim-lint | Inline diagnostics beyond what the LSP provides |
| Terminal | toggleterm | Floating or split terminal inside nvim (`<C-\>`) |

---

## Language support

| Language | LSP | Formatter | Notes |
|----------|-----|-----------|-------|
| Python | pyright | ruff | |
| JavaScript / TypeScript | ts_ls | prettier | |
| Rust | rust-analyzer | rustfmt | via rustaceanvim |
| Go | gopls | gofmt | |
| C / C++ | clangd | clang-format | |
| Java | jdtls | — | |
| Kotlin | kotlin-language-server | — | Mason auto-installs |
| Swift | sourcekit-lsp | — | macOS only (requires Xcode) |

---

## Keybindings

`<leader>` = **Space**

> **Tip:** Press `<Space>` and wait 1 second — which-key will show every available command organised by category.

### Navigation

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer (neo-tree) |
| `<leader>ff` | Find files (fuzzy) |
| `<leader>fg` | Live grep — search text across the project |
| `<leader>fb` | Switch between open buffers |
| `<leader>fr` | Recent files |
| `<leader><leader>` | Find open buffers (quick switch) |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find all references |
| `gi` | Go to implementation |
| `K` | Show hover documentation |
| `<leader>ca` | Code action (fix, refactor, etc.) |
| `<leader>cr` | Rename symbol (live preview across all references) |
| `<leader>cd` | Show diagnostics for current line |
| `]d` / `[d` | Jump to next / previous diagnostic |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open lazygit (full git UI) |
| `<leader>gb` | Git blame for current line |
| `]h` / `[h` | Next / previous git hunk |
| `<leader>ghs` | Stage hunk under cursor |
| `<leader>ghr` | Reset hunk under cursor |

### Code

| Key | Action |
|-----|--------|
| `<leader>cf` | Format current file |
| `gcc` | Toggle line comment |
| `gbc` | Toggle block comment |
| `<Tab>` / `<S-Tab>` | Next / previous completion item |
| `<CR>` | Confirm selected completion |
| `<C-a>` / `<C-x>` | Smart increment / decrement (numbers, booleans, dates, hex…) |
| `g<C-a>` / `g<C-x>` | Sequential increment on visual selection |

### Yank & Paste

| Key | Action |
|-----|--------|
| `p` / `P` | Paste (cursor stays in place after yank) |
| `<C-p>` / `<C-n>` | Cycle through yank history after paste |
| `<leader>p` | Open yank history picker |

### AI (Claude Code)

| Key | Action |
|-----|--------|
| `<leader>ac` | Toggle Claude Code pane |
| `<leader>af` | Focus Claude pane |
| `<leader>ar` | Resume previous Claude session |
| `<leader>aC` | Continue last conversation |
| `<leader>ab` | Add current buffer to Claude's context |
| `<leader>as` | Send visual selection to Claude |
| `<leader>as` (neo-tree) | Add file under cursor to Claude's context |
| `<leader>aa` | Accept Claude's proposed diff |
| `<leader>ad` | Deny Claude's proposed diff |

### Windows & Buffers

| Key | Action |
|-----|--------|
| `<C-h>` / `<C-l>` / `<C-j>` / `<C-k>` | Move between splits |
| `<leader>\|` | Split window vertically |
| `<leader>-` | Split window horizontally |
| `<leader>wd` | Close current window |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bd` | Delete (close) current buffer |

### Misc

| Key | Action |
|-----|--------|
| `<leader>?` | Show all keybindings (which-key full list) |
| `<C-\>` | Toggle floating terminal |
| `jk` (insert mode) | Exit to normal mode |
| `<C-s>` | Save file |
| `<Esc>` | Clear search highlight |

---

## Portability

The Lua config is **platform-agnostic** — the same files work on Linux, macOS, and Windows. Only the bootstrap/update scripts differ per platform.

On a new machine:
1. Run the one-liner bootstrap for your platform
2. `lazy-lock.json` (committed to this repo) pins the exact plugin versions, so you get an identical environment everywhere

To add new plugins: create a `.lua` file in `lua/plugins/`, commit, and run `nvim-update` on your other machines.
