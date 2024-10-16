return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.6",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local actions = require("telescope.actions")
		require("telescope").setup({
			defaults = {
				file_ignore_patterns = { "node_modules" },
				mappings = {
					i = {
						["<esc>"] = actions.close,
					},
				},
			},
		})

		-- set keymaps
		local keymap = vim.keymap

		keymap.set("n", "<leader>tf", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>tg", "<cmd>Telescope live_grep<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>tb", "<cmd>Telescope buffers<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>ts", "<cmd>Telescope git_status<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>tc", "<cmd>Telescope git commits<cr>", { desc = "Find todos" })
	end,
}
