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
		config = function()
			function dump(o)
				if type(o) == "table" then
					local s = "{ "
					for k, v in pairs(o) do
						if type(k) ~= "number" then
							k = '"' .. k .. '"'
						end
						s = s .. "[" .. k .. "] = " .. dump(v) .. ","
					end
					return s .. "} "
				else
					return tostring(o)
				end
			end

			local get_clients = function(opts)
				local ret = {} ---@type vim.lsp.Client[]
				if vim.lsp.get_clients then
					ret = vim.lsp.get_clients(opts)
				else
					---@diagnostic disable-next-line: deprecated
					ret = vim.lsp.get_active_clients(opts)
					if opts and opts.method then
						---@param client vim.lsp.Client
						ret = vim.tbl_filter(function(client)
							return client.supports_method(opts.method, { bufnr = opts.bufnr })
						end, ret)
					end
				end
				return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
				-- 	local ret = {}
				-- 	if vim.lsp.get_clients then
				-- 		ret = vim.lsp.get_clients()
				-- 	else
				-- 		---@diagnostic disable-next-line: deprecated
				-- 		ret = vim.lsp.get_active_clients()
				-- 		if opts and opts.method then
				-- 			ret = vim.tbl_filter(function(client)
				-- 				return client.supports_method(opts.method, { bufnr = opts.bufnr })
				-- 			end, ret)
				-- 		end
				-- 	end
				--
				-- 	print(dump(ret))
				-- 	return vim.tbl_filter(ret) or ret
			end

			local on_rename = function(from, to, rename)
				local changes = {
					files = { {
						oldUri = vim.uri_from_fname(from),
						newUri = vim.uri_from_fname(to),
					} },
				}

				local clients = get_clients()
				for _, client in ipairs(clients) do
					if client.supports_method("workspace/willRenameFiles") then
						local resp = client.request_sync("workspace/willRenameFiles", changes, 1000, 0)
						if resp and resp.result ~= nil then
							vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
						end
					end
				end

				if rename then
					rename()
				end

				for _, client in ipairs(clients) do
					if client.supports_method("workspace/didRenameFiles") then
						client.notify("workspace/didRenameFiles", changes)
					end
				end
			end

			local realpath = function(path)
				if path == "" or path == nil then
					return nil
				end
				path = vim.uv.fs_realpath(path) or path
				-- return LazyVim.norm(path)
				return path
			end

			local bufpath = function(buf)
				return realpath(vim.api.nvim_buf_get_name(assert(buf)))
			end

			local detectors = {
				cwd = function()
					return { vim.uv.cwd() }
				end,
				lsp = function(buf)
					local bufpath = bufpath(buf)
					if not bufpath then
						return {}
					end
					local roots = {} ---@type string[]
					local clients = get_clients({ bufnr = buf })
					clients = vim.tbl_filter(function(client)
						return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
					end, clients)
					for _, client in pairs(clients) do
						local workspace = client.config.workspace_folders
						for _, ws in pairs(workspace or {}) do
							roots[#roots + 1] = vim.uri_to_fname(ws.uri)
						end
						if client.root_dir then
							roots[#roots + 1] = client.root_dir
						end
					end
					return vim.tbl_filter(function(path)
						-- path = LazyVim.norm(path)
						return path and bufpath:find(path, 1, true) == 1
					end, roots)
				end,
				pattern = function(buf, patterns)
					patterns = type(patterns) == "string" and { patterns } or patterns
					local path = bufpath(buf) or vim.uv.cwd()
					local pattern = vim.fs.find(function(name)
						for _, p in ipairs(patterns) do
							if name == p then
								return true
							end
							if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then
								return true
							end
						end
						return false
					end, { path = path, upward = true })[1]
					return pattern and { vim.fs.dirname(pattern) } or {}
				end,
			}

			local resolve = function(spec)
				if detectors[spec] then
					return detectors[spec]
				elseif type(spec) == "function" then
					return spec
				end
				return function(buf)
					return detectors.pattern(buf, spec)
				end
			end
			---@param opts? { buf?: number, spec?: LazyRootSpec[], all?: boolean }
			local detect = function(opts)
				opts = opts or {}
				-- print("asdf")
				-- print(dump(vim.g.root_spec))
				-- print("333")
				opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec
				opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf
				-- print(dump(opts))

				local ret = {}
				for _, spec in ipairs(opts.spec) do
					print(dump(opts.buf))
					local paths = resolve(spec)(opts.buf)
					paths = paths or {}
					paths = type(paths) == "table" and paths or { paths }
					local roots = {} ---@type string[]
					for _, p in ipairs(paths) do
						local pp = realpath(p)
						if pp and not vim.tbl_contains(roots, pp) then
							roots[#roots + 1] = pp
						end
					end
					table.sort(roots, function(a, b)
						return #a > #b
					end)
					if #roots > 0 then
						ret[#ret + 1] = { spec = spec, paths = roots }
						if opts.all == false then
							break
						end
					end
				end
				return ret
			end
			-- returns the root directory based on:
			-- * lsp workspace folders
			-- * lsp root_dir
			-- * root pattern of filename of the current buffer
			-- * root pattern of cwd
			local get = function(opts)
				opts = opts or {}
				local buf = opts.buf or vim.api.nvim_get_current_buf()
				if not ret then
					local roots = detect({ all = false, buf = buf })
					ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
				end
				if opts and opts.normalize then
					return ret
				end
				return ret
			end

			local rename_file = function()
				local buf = vim.api.nvim_get_current_buf()
				local old = assert(realpath(vim.api.nvim_buf_get_name(buf)))
				local root = assert(realpath(get({ normalize = true })))
				assert(old:find(root, 1, true) == 1, "File not in project root")

				local extra = old:sub(#root + 2)

				vim.ui.input({
					prompt = "New File Name: ",
					default = extra,
					completion = "file",
				}, function(new)
					if not new or new == "" or new == extra then
						return
					end
					-- new = LazyVim.norm(root .. "/" .. new)
					new = root .. "/" .. new
					vim.fn.mkdir(vim.fs.dirname(new), "p")
					on_rename(old, new, function()
						vim.fn.rename(old, new)
						vim.cmd.edit(new)
						vim.api.nvim_buf_delete(buf, { force = true })
						vim.fn.delete(old)
					end)
				end)
			end

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
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
				vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References", nowait = true })
				vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
				vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto T[y]pe Definition" })
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
				vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
				vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
				vim.keymap.set("n", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
				vim.keymap.set("n", "<leader>cc", vim.lsp.codelens.run, { desc = "Run Codelens" })
				vim.keymap.set("n", "<leader>cC", vim.lsp.codelens.refresh, { desc = "Refresh & Display Codelens" })
				vim.keymap.set("n", "<leader>cR", rename_file, { desc = "Rename File" })
				vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
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
				if value == "lua_ls" then
					lsp.lua_ls.setup({
						on_attach = on_attach,
						settings = {
							Lua = {
								runtime = {
									-- Tell the language server which version of Lua you're using
									-- (most likely LuaJIT in the case of Neovim)
									version = "LuaJIT",
								},
								diagnostics = {
									-- Get the language server to recognize the `vim` global
									globals = {
										"vim",
										"require",
									},
								},
								workspace = {
									-- Make the server aware of Neovim runtime files
									library = vim.api.nvim_get_runtime_file("", true),
								},
								-- Do not send telemetry data containing a randomized but unique identifier
								telemetry = {
									enable = false,
								},
							},
						},
					})
					goto continue
				end

				lsp[value].setup({
					on_attach = on_attach,
				})
				::continue::
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
				-- "clang-format",
			},
		},
	},
}
