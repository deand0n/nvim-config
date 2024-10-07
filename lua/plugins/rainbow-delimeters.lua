return {
	"HiPhish/rainbow-delimiters.nvim",
	config = function()
		require("rainbow-delimiters.setup").setup({
			strategy = {
				-- ...
			},
			query = {
				-- ...
			},
			highlight = {
				-- ...
			},
			blacklist = {
				"jsx",
				"tsx",
				"html",
				"svelte",
			},
		})
	end,
}
