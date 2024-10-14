return {
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		dependencies = {
			"mason.nvim",
			{
				"williamboman/mason-lspconfig.nvim",
				config = function() end,
			},
		},
		opts = function()
			local ret = {
				-- options for vim.diagnostic.config()
				---@type vim.diagnostic.Opts
				diagnostics = {
					underline = true,
					update_in_insert = false,
					virtual_text = {
						spacing = 4,
						source = "if_many",
						prefix = "●",
						-- this will set set the prefix to a function that returns the diagnostics icon based on the severity
						-- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
						-- prefix = "icons",
					},
					severity_sort = true,
					-- signs = {
					-- text = {
					-- [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
					-- [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
					-- [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
					-- [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
					-- },
					-- },
				},
				-- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
				-- Be aware that you also will need to properly configure your LSP server to
				-- provide the inlay hints.
				inlay_hints = {
					enabled = true,
					exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
				},
				-- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
				-- Be aware that you also will need to properly configure your LSP server to
				-- provide the code lenses.
				codelens = {
					enabled = false,
				},
				-- Enable lsp cursor word highlighting
				document_highlight = {
					enabled = true,
				},
				-- add any global capabilities here
				capabilities = {
					workspace = {
						fileOperations = {
							didRename = true,
							willRename = true,
						},
					},
				},
				-- options for vim.lsp.buf.format
				-- `bufnr` and `filter` is handled by the LazyVim formatter,
				-- but can be also overridden when specified
				format = {
					formatting_options = nil,
					timeout_ms = nil,
				},
				-- LSP Server Settings
				---@type lspconfig.options
				servers = {
					lua_ls = {
						-- mason = false, -- set to false if you don't want this server to be installed with mason
						-- Use this to add any additional keymaps
						-- for specific lsp servers
						-- ---@type LazyKeysSpec[]
						-- keys = {},
						settings = {
							Lua = {
								workspace = {
									checkThirdParty = false,
								},
								codeLens = {
									enable = true,
								},
								completion = {
									callSnippet = "Replace",
								},
								doc = {
									privateName = { "^_" },
								},
								hint = {
									enable = true,
									setType = false,
									paramType = true,
									paramName = "Disable",
									semicolon = "Disable",
									arrayIndex = "Disable",
								},
							},
						},
					},
				},
				-- you can do any additional lsp server setup here
				-- return true if you don't want this server to be setup with lspconfig
				---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
				setup = {
					-- example to setup with typescript.nvim
					-- tsserver = function(_, opts)
					--   require("typescript").setup({ server = opts })
					--   return true
					-- end,
					-- Specify * to use this function as a fallback for any server
					-- ["*"] = function(server, opts) end,
				},
			}
			return ret
		end,
		config = function(_, opts)
			local servers = {
				"cssls",
				"eslint",
				"html",
				"svelte",
				"jsonls",
				"ts_ls",
				"lua_ls",
				"clangd",
				"tailwindcss",
			}

			local on_attach = function(client, buffer)
				vim.keymap.set("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp Info" })
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition", has = "definition" })
				vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References", nowait = true })
				vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
				vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto T[y]pe Definition" })
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
				vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
				vim.keymap.set(
					"n",
					"gK",
					vim.lsp.buf.signature_help,
					{ desc = "Signature Help", has = "signatureHelp" }
				)
				vim.keymap.set(
					"n",
					"<c-k>",
					vim.lsp.buf.signature_help,
					{ mode = "i", desc = "Signature Help", has = "signatureHelp" }
				)
				vim.keymap.set(
					"n",
					"<leader>ca",
					vim.lsp.buf.code_action,
					{ desc = "Code Action", mode = { "n", "v" }, has = "codeAction" }
				)
				vim.keymap.set(
					"n",
					"<leader>cc",
					vim.lsp.codelens.run,
					{ desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" }
				)
				vim.keymap.set(
					"n",
					"<leader>cC",
					vim.lsp.codelens.refresh,
					{ desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" }
				)
				-- vim.keymap.set( { "<leader>cR", LazyVim.lsp.rename_file, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
				vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename", has = "rename" })
				-- vim.keymap.set( { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
				-- { "]]", function() LazyVim.lsp.words.jump(vim.v.count1) end, has = "documentHighlight",
				--   desc = "Next Reference", cond = function() return LazyVim.lsp.words.enabled end },
				-- { "[[", function() LazyVim.lsp.words.jump(-vim.v.count1) end, has = "documentHighlight",
				--   desc = "Prev Reference", cond = function() return LazyVim.lsp.words.enabled end },
				-- { "<a-n>", function() LazyVim.lsp.words.jump(vim.v.count1, true) end, has = "documentHighlight",
				--   desc = "Next Reference", cond = function() return LazyVim.lsp.words.enabled end },
				-- { "<a-p>", function() LazyVim.lsp.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
				--   desc = "Prev Reference", cond = function() return LazyVim.lsp.words.enabled end },
				--
			end

			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup({
				ensure_installed = servers,
			})

			local lsp = require("lspconfig")
			for key, value in pairs(servers) do
				lsp[value].setup({
					on_attach = on_attach,
				})
			end
		end,
	},
	{

		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {
				"stylua",
				"prettier",
				"eslint_d",
			},
		},
	},
}
