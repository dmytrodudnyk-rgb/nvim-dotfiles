-- Show hidden/dotfiles by default in explorer and file picker.
-- Gitignored files are already dimmed (SnacksPickerPathIgnored -> NonText).
return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = true,
        ignored = true,
        exclude = {
          "node_modules",
          ".git",
          "dist",
          "build",
          ".next",
          "__pycache__",
        },
      },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
          files = {
            hidden = true,
          },
        },
      },
    },
  },
}
