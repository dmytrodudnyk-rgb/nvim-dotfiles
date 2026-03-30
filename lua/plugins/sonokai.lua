return {
	"sainnhe/sonokai",
	lazy = false,
	config = function()
		vim.g.sonokai_style = "andromeda"
		vim.g.sonokai_cursor = "auto"
		vim.g.sonokai_diagnostic_text_highlight = 1
		vim.g.sonokai_diagnostic_virtual_text = "colored"
		vim.g.sonokai_inlay_hints_background = "dimmed"
	end,
}
