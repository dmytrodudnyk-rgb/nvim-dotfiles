return {
  "coder/claudecode.nvim",
  opts = {
    terminal = {
      provider = "native",
    },
    diff_opts = {
      open_in_new_tab = true,
      keep_terminal_focus = true,
    },
  },
  keys = {
    { "<leader>ac", "<Cmd>ClaudeCode<CR>",                                       desc = "Claude Code" },
    { "<leader>aS", "<Cmd>ClaudeCode --dangerously-skip-permissions<CR>",        desc = "Claude Code (skip permissions)" },
  },
}
