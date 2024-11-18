return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		theme = "base16",
		sections = {
			lualine_b = { "diagnostics" },
			lualine_c = { "buffers" },
			lualine_y = {},
			lualine_z = {},
		},
	},
}
