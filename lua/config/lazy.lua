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

    -- ── Editor enhancements ───────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.coding.yanky" },       -- yank history ring + better paste
    { import = "lazyvim.plugins.extras.coding.mini-surround" },-- surround: add/change/delete brackets, quotes, tags
    { import = "lazyvim.plugins.extras.coding.neogen" },      -- generate docstrings for functions/classes
    { import = "lazyvim.plugins.extras.editor.dial" },        -- smart increment (booleans, dates, etc.)
    { import = "lazyvim.plugins.extras.editor.inc-rename" },  -- live rename preview via LSP
    { import = "lazyvim.plugins.extras.editor.illuminate" },  -- highlight other occurrences of word under cursor
    { import = "lazyvim.plugins.extras.editor.harpoon2" },    -- bookmark files and jump between them instantly
    { import = "lazyvim.plugins.extras.editor.aerial" },      -- symbol browser sidebar (functions, classes, etc.)
    { import = "lazyvim.plugins.extras.editor.refactoring" }, -- extract function/variable, inline variable
    { import = "lazyvim.plugins.extras.ui.treesitter-context" },-- pin current function/class at top when scrolled
    { import = "lazyvim.plugins.extras.ui.indent-blankline" },-- indent guide lines
    { import = "lazyvim.plugins.extras.ui.mini-animate" },    -- smooth scroll + cursor + window animations

    -- ── Linting & formatting ──────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.linting.eslint" },     -- ESLint as LSP (JS/TS inline errors)

    -- ── Debugging ────────────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.dap.core" },           -- debugger UI: breakpoints, step, variable inspector

    -- ── Utilities ────────────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.util.rest" },          -- HTTP client: write .http files, send requests inline

    -- ── AI ────────────────────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.ai.claudecode" },      -- Claude Code integration

    -- ── Language extras (additional) ──────────────────────────────────────
    { import = "lazyvim.plugins.extras.lang.yaml" },          -- YAML LSP + SchemaStore (k8s, GH Actions, etc.)
    { import = "lazyvim.plugins.extras.lang.toml" },          -- TOML LSP (Cargo.toml, pyproject.toml, etc.)
    { import = "lazyvim.plugins.extras.lang.markdown" },      -- markdown render + preview + linting
    { import = "lazyvim.plugins.extras.lang.docker" },        -- Dockerfile LSP + treesitter
    { import = "lazyvim.plugins.extras.lang.sql" },           -- SQL LSP + vim-dadbod database UI

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

  rocks = {
    enabled = false, -- no plugins require luarocks; disables hererocks install
  },

  performance = {
    rtp = {
      -- Treesitter installs parsers here; lazy.nvim's rtp reset strips it by default
      paths = { vim.fn.stdpath("data") .. "/site" },
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
