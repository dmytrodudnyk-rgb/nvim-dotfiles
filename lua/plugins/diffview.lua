return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: working changes" },
      { "<leader>gD", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: file history" },
    },
    opts = {},
  },
}
