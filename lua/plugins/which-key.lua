return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		spec = {
			{
				mode = { "n", "v" },
				{ "<leader>c", group = "code" },
				{ "<leader>g", group = "git" },
				{ "<leader>gh", group = "hunks" },
				{ "<leader>t", group = "search" },
				{ "<leader>x", group = "diagnostics/quickfix" },
				{ "g", group = "goto" },
				{ "gs", group = "surround" },
				{ "<leader>f", group = "file/find" },
				{ "<leader><tab>", group = "tabs" },
				{ "[", group = "prev" },
				{ "]", group = "next" },
				{ "z", group = "fold" },
				{
					"<leader>b",
					group = "buffer",
					expand = function()
						return require("which-key.extras").expand.buf()
					end,
				},
				{
					"<leader>w",
					group = "windows",
					proxy = "<c-w>",
					expand = function()
						return require("which-key.extras").expand.win()
					end,
				},
				-- better descriptions
				{ "gx", desc = "Open with system app" },
			},
		},
	},
}
