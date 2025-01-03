return {
	"catppuccin/nvim",
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		local catppuccin = require("catppuccin")
		catppuccin.setup({
			flavour = "auto", -- latte, frappe, macchiato, mocha
			background = { -- :h background
				light = "latte",
				dark = "frappe",
			},
		})
		-- load the colorscheme here
		vim.cmd([[colorscheme catppuccin]])
	end,
}
