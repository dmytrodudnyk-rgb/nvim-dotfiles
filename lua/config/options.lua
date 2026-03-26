-- ============================================================
-- Editor options
-- LazyVim already sets sensible defaults. Add your overrides here.
-- Full list of LazyVim defaults:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- ============================================================

-- Line numbers
vim.opt.relativenumber = true   -- relative line numbers (easier for j/k motion)
vim.opt.number = true           -- also show the absolute number on the current line

-- Tabs & indentation
vim.opt.tabstop = 4             -- visual width of a tab character
vim.opt.shiftwidth = 4          -- spaces used for each indent level
vim.opt.expandtab = true        -- use spaces instead of tabs

-- Search
vim.opt.ignorecase = true       -- case-insensitive search...
vim.opt.smartcase = true        -- ...unless the query contains uppercase

-- Appearance
vim.opt.termguicolors = true    -- enable 24-bit color
vim.opt.scrolloff = 8           -- keep 8 lines visible above/below the cursor
vim.opt.sidescrolloff = 8       -- keep 8 columns visible left/right of the cursor
vim.opt.wrap = false            -- don't soft-wrap long lines

-- Files
vim.opt.undofile = true         -- persist undo history across sessions
vim.opt.swapfile = false        -- disable swap files (use undofile instead)
vim.opt.updatetime = 250        -- faster CursorHold events (ms) — speeds up LSP hints
