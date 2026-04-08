return {
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    opts = {
      kind = "floating",
      graph_style = "unicode",
      integrations = { diffview = true },
      sections = {
        untracked = { folded = false },
        unstaged  = { folded = false },
        staged    = { folded = false },
        stashes   = { folded = true  },
        recent    = { folded = false },
        unpulled_upstream = { folded = true  },
        unmerged_upstream = { folded = false },
      },
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
  },
}
