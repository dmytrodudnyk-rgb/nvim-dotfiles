return {
  "coder/claudecode.nvim",
  opts = {
    terminal = {
      snacks_win_opts = {
        keys = {
          -- Disable snacks' double-escape handler so <Esc> passes straight
          -- through to Claude. Use jk (or <C-\><C-n>) to exit terminal mode.
          term_normal = false,
        },
      },
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
