-- ============================================================
-- render-markdown overrides.
-- HTML comments stay concealed, but an icon is inlined in their place
-- so a `gcc`-commented markdown line reads as commented instead of
-- silently vanishing.
-- ============================================================

return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    html = {
      comment = {
        conceal = true,
        text = " ",
      },
    },
  },
}
