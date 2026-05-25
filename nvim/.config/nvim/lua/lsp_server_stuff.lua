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
			"hrsh7th/cmp-nvim-lsp", -- Autocompletion for LSP
			"neovim/nvim-lspconfig", -- Core LSP configuration
			{ "antosha417/nvim-lsp-file-operations", config = true }, -- Handles file operations like renaming
		},
		config = function()
			-- Import required plugins
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local mason_tool_installer = require("mason-tool-installer")
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			----------------------------------------------------------------
			-- Setup Mason
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
			-- Setup Mason-LSPConfig (v2): ensure servers are installed
			-- NOTE: automatic_installation + setup_handlers are removed in v2
			----------------------------------------------------------------
			mason_lspconfig.setup({
				ensure_installed = {
					"clangd",
					"lua_ls",
					"pyright",
				},
			})

			----------------------------------------------------------------
			-- Setup Mason-Tool-Installer
			----------------------------------------------------------------
			mason_tool_installer.setup({
				ensure_installed = {
					"prettier", -- prettier formatter
					"stylua", -- lua formatter
					"isort", -- python formatter
					"black", -- python formatter
					"pylint", -- python linter
				},
			})

			----------------------------------------------------------------
			-- Setup LSP capabilities and on_attach function
			----------------------------------------------------------------
			local capabilities = cmp_nvim_lsp.default_capabilities()
			local keymap = vim.keymap
			local opts = { noremap = true, silent = true }

			local on_attach = function(_, bufnr)
				opts.buffer = bufnr

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
				keymap.set("n", "<leader>lp", vim.diagnostic.goto_prev, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "<leader>ln", vim.diagnostic.goto_next, opts)

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>ll", ":LspRestart<CR>", opts)
			end

			----------------------------------------------------------------
			-- Neovim 0.11+ native LSP config (replaces setup_handlers)
			----------------------------------------------------------------

			-- Default config for all servers
			vim.lsp.config("*", {
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- Custom config for lua_ls
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
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
			-- Diagnostic symbols in the sign column
			----------------------------------------------------------------
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end
		end,
	},
}
