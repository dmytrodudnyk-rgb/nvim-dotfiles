-- ============================================================
-- Extra LSP servers not covered by LazyVim language extras:
--   • sourcekit   — Swift (macOS only, requires Xcode)
--   • kotlin_language_server — Kotlin (Mason auto-installs)
-- ============================================================

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Swift LSP
        -- Requires: Xcode installed on macOS (sourcekit-lsp ships with the Swift toolchain)
        -- On Linux: install a Swift toolchain from https://www.swift.org/install/
        sourcekit = {
          filetypes = { "swift", "objective-c", "objective-cpp" },
        },

        -- Kotlin LSP
        -- Mason auto-installs kotlin-language-server when this entry is present.
        kotlin_language_server = {},
      },
    },
  },

  -- Ensure Mason installs kotlin-language-server
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "kotlin-language-server",
      })
    end,
  },
}
