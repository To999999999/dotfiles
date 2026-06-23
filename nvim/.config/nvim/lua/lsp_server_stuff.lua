return {
	-- Neodev: enhance lua-language-server for Neovim config/runtime
	{
		"folke/neodev.nvim",
		opts = {}, -- default options load Neovim runtime, plugins, types
	},

	{
		"williamboman/mason-lspconfig.nvim",

		dependencies = {
			"williamboman/mason.nvim", -- Mason to manage LSP servers
			"WhoIsSethDaniel/mason-tool-installer.nvim", -- Tool installer for managing additional tools
			"hrsh7th/cmp-nvim-lsp", -- LSP completion capabilities
			"neovim/nvim-lspconfig", -- Core LSP config
			{ "antosha417/nvim-lsp-file-operations", config = true }, -- File operations support
		},

		config = function()
			----------------------------------------------------------------
			-- Import plugins
			----------------------------------------------------------------
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local mason_tool_installer = require("mason-tool-installer")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			----------------------------------------------------------------
			-- Mason setup
			----------------------------------------------------------------
			mason.setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			----------------------------------------------------------------
			-- Mason LSP setup
			----------------------------------------------------------------
			mason_lspconfig.setup({
				ensure_installed = {
					"clangd",
					"lua_ls",
					"pyright",
					"nil_ls",
				},
			})

			----------------------------------------------------------------
			-- Mason Tool Installer
			----------------------------------------------------------------
			mason_tool_installer.setup({
				ensure_installed = {
					"prettier",
					"stylua",
					"isort",
					"black",
					"pylint",
					"nixpkgs-fmt",
				},
			})

			----------------------------------------------------------------
			-- LSP capabilities
			----------------------------------------------------------------
			local capabilities = cmp_nvim_lsp.default_capabilities()

			----------------------------------------------------------------
			-- LSP keymaps
			----------------------------------------------------------------
			local keymap = vim.keymap

			local on_attach = function(_, bufnr)
				local opts = {
					noremap = true,
					silent = true,
					buffer = bufnr,
				}

				opts.desc = "Show LSP references"
				keymap.set("n", "<leader>lr", "<cmd>Telescope lsp_references<CR>", opts)

				opts.desc = "Go to declaration"
				keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, opts)

				opts.desc = "Show LSP definitions"
				keymap.set("n", "<leader>ld", "<cmd>Telescope lsp_definitions<CR>", opts)

				opts.desc = "Show LSP implementations"
				keymap.set("n", "<leader>li", "<cmd>Telescope lsp_implementations<CR>", opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "<leader>lt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>lR", vim.lsp.buf.rename, opts)

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>lC", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>lc", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "<leader>lp", function()
					vim.diagnostic.jump({
						count = -1,
						float = true,
					})
				end, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "<leader>ln", function()
					vim.diagnostic.jump({
						count = 1,
						float = true,
					})
				end, opts)

				opts.desc = "Show documentation under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>ll", ":LspRestart<CR>", opts)
			end

			----------------------------------------------------------------
			-- Default config for all servers
			----------------------------------------------------------------
			vim.lsp.config("*", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			----------------------------------------------------------------
			-- lua_ls specific config
			----------------------------------------------------------------
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				on_attach = on_attach,

				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},

						workspace = {
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})

			----------------------------------------------------------------
			-- nil_ls specific config
			----------------------------------------------------------------
			vim.lsp.config("nil_ls", {
				capabilities = capabilities,
				on_attach = on_attach,

				settings = {
					["nil"] = {
						formatting = {
							command = { "nixpkgs-fmt" },
						},
					},
				},
			})

			----------------------------------------------------------------
			-- Diagnostics configuration
			----------------------------------------------------------------
			vim.diagnostic.config({
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = "󰠠 ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},

				virtual_text = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})
		end,
	},
}
