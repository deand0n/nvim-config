if true then
	return {}
end
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
				"clangd",
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

		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		local on_attach = function(client, bufnr)
			if client.server_capabilities.inlayHintProvider then
				-- vim.lsp.inlay_hint.enable(true)
			end
		end

		local lsp = require("lspconfig")

		lsp.cssls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
		lsp.eslint.setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
		lsp.html.setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
		lsp.svelte.setup({ on_attach = on_attach, capabilities = capabilities })
		lsp.jsonls.setup({ on_attach = on_attach, capabilities = capabilities })
		lsp.ts_ls.setup({
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = { "ts", "tsx", "typescript", "typescriptreact", "typescript.tsx" },
		})
		lsp.lua_ls.setup({ on_attach = on_attach, capabilities = capabilities })
		lsp.clangd.setup({ on_attach = on_attach, capabilities = capabilities })
		lsp.tailwindcss.setup({ on_attach = on_attach, capabilities = capabilities })
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
