return {
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
		keys = {
			{ "<leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "Diff working tree" },
			{ "<leader>gD", "<Cmd>DiffviewClose<CR>", desc = "Close diffview" },
			{ "<leader>gf", "<Cmd>DiffviewFileHistory %<CR>", desc = "File history (current)" },
			{ "<leader>gF", "<Cmd>DiffviewFileHistory<CR>", desc = "File history (all)" },
		},
		opts = {
			enhanced_diff_hl = true,
			keymaps = {
				view = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diffview" } } },
				file_panel = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diffview" } } },
				file_history_panel = { { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diffview" } } },
			},
		},
	},
}
