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
-- On Windows, ConPTY intercepts these keys — send raw bytes directly to the pty.
-- jk is used to exit terminal mode instead of <Esc>.
map("t", "<Esc>", function()
  local chan = vim.b.terminal_job_id
  if chan then vim.api.nvim_chan_send(chan, "\27") end
end, { desc = "Pass Escape to terminal" })
map("t", "<S-Tab>", function()
  local chan = vim.b.terminal_job_id
  if chan then vim.api.nvim_chan_send(chan, "\27[Z") end
end, { desc = "Pass Shift-Tab to terminal" })

-- ── Tabs ─────────────────────────────────────────────────────────────────────
-- Open new tab with current buffer (instead of empty)
map("n", "<leader><tab><tab>", "<Cmd>tab split<CR>", { desc = "New tab (current buffer)" })
map("n", "<leader><tab>n", "<Cmd>tab split<CR>", { desc = "New tab (current buffer)" })

-- ── Zoom ─────────────────────────────────────────────────────────────────────
-- Z toggles the current window to fill the screen (ZZ/ZQ are overridden).
map("n", "Z", function() require("snacks").toggle.zoom():toggle() end, { desc = "Zoom window" })

-- ── File search ──────────────────────────────────────────────────────────────
-- Search files in CWD by default
map("n", "<leader><space>", function()
  require("snacks").picker.files({ cwd = vim.uv.cwd() })
end, { desc = "Find Files (cwd)" })
