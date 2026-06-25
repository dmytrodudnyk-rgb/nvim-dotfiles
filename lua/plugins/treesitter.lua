-- ============================================================
-- Extra treesitter grammars for the macOS/native stack.
-- LazyVim language extras already pull c/cpp/typescript/etc.;
-- swift and objc have no LazyVim extra, so add them here.
-- ============================================================

return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    vim.list_extend(opts.ensure_installed, {
      "swift",
      "objc",
    })
  end,
}
