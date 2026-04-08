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

require("config.dim_inactive")

-- Files
vim.opt.undofile = true         -- persist undo history across sessions
vim.opt.swapfile = false        -- disable swap files (use undofile instead)
vim.opt.updatetime = 250        -- faster CursorHold events (ms) — speeds up LSP hints

-- Disable unused providers to suppress checkhealth warnings
vim.g.loaded_perl_provider = 0  -- Perl not needed
vim.g.loaded_ruby_provider = 0  -- Ruby not needed

-- Python provider:
--   Windows  → isolated venv (Scripts/python)
--   macOS    → isolated venv (bin/python3)
--   Linux    → system Python (python3-pynvim via apt, no override needed)
if vim.fn.has("win32") == 1 then
  vim.g.python3_host_prog = vim.fn.expand("~/.venv/neovim/Scripts/python")
  -- Prefer Scoop's GCC over Strawberry Perl's bundled GCC for treesitter compilation
  local scoop_gcc = vim.fn.expand("~/scoop/apps/gcc/current/bin")
  if vim.fn.isdirectory(scoop_gcc) == 1 then
    vim.env.CC = scoop_gcc .. "/gcc.exe"
  end
  -- Use PowerShell 7 (pwsh) as the shell
  vim.o.shell = "pwsh"
  vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
elseif vim.fn.has("mac") == 1 then
  vim.g.python3_host_prog = vim.fn.expand("~/.venv/neovim/bin/python3")
end

if vim.fn.has("mac") == 1 then
  vim.o.shell = "zsh"
  vim.o.shellcmdflag = "-i -c 'exec fish'"
end

-- WezTerm tab title: "nvim - <cwd>"
if vim.env.TERM_PROGRAM == "WezTerm" or vim.env.WEZTERM_PANE ~= nil then
  local function set_wezterm_title()
    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    io.write(("\027]0;nvim - %s\007"):format(cwd))
  end
  local group = vim.api.nvim_create_augroup("WeztermTitle", { clear = true })
  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    group = group,
    callback = set_wezterm_title,
  })
  vim.api.nvim_create_autocmd("VimLeave", {
    group = group,
    callback = function()
      io.write("\027]0;\007") -- clear title on exit
    end,
  })
end
