-- ============================================================
-- Custom keymaps
-- LazyVim already sets many useful defaults. Add your overrides here.
-- Full list of LazyVim defaults:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- ============================================================

local map = vim.keymap.set

-- ── Better escape ────────────────────────────────────────────────────────────
-- jk in insert mode exits to normal mode (faster than reaching for Esc)
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- ── Save file ────────────────────────────────────────────────────────────────
map({ "n", "i", "v" }, "<C-s>", "<Cmd>w<CR><Esc>", { desc = "Save file" })

-- ── Move lines up/down ────────────────────────────────────────────────────────
-- Alt+j/k moves selected lines in visual mode
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ── Better indenting in visual mode ──────────────────────────────────────────
-- Stay in visual mode after indenting
map("v", "<", "<gv", { desc = "Indent left (stay in visual)" })
map("v", ">", ">gv", { desc = "Indent right (stay in visual)" })

-- ── Clear search highlight ────────────────────────────────────────────────────
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- ── Close all buffers ────────────────────────────────────────────────────────
map("n", "<leader>bD", "<Cmd>bufdo bdelete<CR>", { desc = "Close all buffers" })

-- ── Terminal escape ──────────────────────────────────────────────────────────
map("t", "jk", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ── Tabs ─────────────────────────────────────────────────────────────────────
-- Open new tab with current buffer (instead of empty)
map("n", "<leader><tab><tab>", "<Cmd>tab split<CR>", { desc = "New tab (current buffer)" })
map("n", "<leader><tab>n", "<Cmd>tab split<CR>", { desc = "New tab (current buffer)" })
