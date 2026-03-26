-- ============================================================
-- lazy.nvim bootstrap + plugin spec
-- Docs: https://lazyvim.org/configuration
-- ============================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit...", "ErrorMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- Core: LazyVim and its default plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- ── Language extras ────────────────────────────────────────────────────
    -- Each extra adds the LSP server, formatter, treesitter grammar,
    -- and any language-specific tools (e.g. rustaceanvim for Rust).
    { import = "lazyvim.plugins.extras.lang.python" },     -- pyright + ruff
    { import = "lazyvim.plugins.extras.lang.typescript" },  -- ts_ls + prettier
    { import = "lazyvim.plugins.extras.lang.rust" },        -- rust-analyzer + rustaceanvim
    { import = "lazyvim.plugins.extras.lang.go" },          -- gopls + gofmt
    { import = "lazyvim.plugins.extras.lang.clangd" },      -- clangd + clang-format (C/C++)
    { import = "lazyvim.plugins.extras.lang.java" },        -- jdtls (Java)

    -- ── Your custom plugins ────────────────────────────────────────────────
    -- Drop any .lua file into lua/plugins/ and it will be auto-imported.
    { import = "plugins" },
  },

  defaults = {
    lazy = false,    -- custom plugins load eagerly unless they set lazy=true
    version = false, -- always use the latest git commit (more stable than semver tags)
  },

  install = {
    -- Colorscheme to use while plugins are being installed
    colorscheme = { "tokyonight", "habamax" },
  },

  checker = {
    enabled = true,  -- periodically check for plugin updates
    notify = false,  -- don't pop up a notification on every check
  },

  performance = {
    rtp = {
      -- Disable unused built-in Neovim plugins to speed up startup
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
