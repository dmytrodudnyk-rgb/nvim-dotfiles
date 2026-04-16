return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
        custom_filter = function(buf)
          return vim.bo[buf].buftype ~= "terminal"
        end,
      },
    },
  },
}
