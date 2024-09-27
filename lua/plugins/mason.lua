return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"williamboman/mason.nvim",
		"neovim/nvim-lspconfig",
	},
	config = function()
		require("mason").setup()

		require("mason-lspconfig").setup({
			automatic_installation = true,
			ensure_installed = {
				"cssls",
				"eslint",
				"html",
				"svelte",
				"jsonls",
				"ts_ls",
				"lua_ls",
				-- "clang",
				-- "pyright",
				"tailwindcss",
			},
		})

		require("mason-tool-installer").setup({
			ensure_installed = {
				"prettier",
				"stylua", -- lua formatter
				"eslint_d",
			},
		})

		local lsp = require("lspconfig")
		lsp.lua_ls.setup({})
		lsp.cssls.setup({})
		lsp.html.setup({})
		lsp.svelte.setup({})
		lsp.ts_ls.setup({})
		lsp.tailwindcss.setup({})
	end,
	opts = {
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	},
}
