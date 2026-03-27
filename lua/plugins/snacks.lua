-- Show hidden/dotfiles by default in explorer and file picker.
-- Gitignored files are already dimmed (SnacksPickerPathIgnored -> NonText).
return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = true,
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
