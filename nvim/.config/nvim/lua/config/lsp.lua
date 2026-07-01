------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function has(cmd)
	return vim.fn.executable(cmd) == 1
end

local function notify_missing(group, missing)
	vim.schedule(function()
		vim.notify(
			"Skipping " .. group .. ". Missing: " .. table.concat(missing, ", "),
			vim.log.levels.WARN,
			{ title = "Neovim LSP" }
		)
	end)
end

local function check_deps(group, deps)
	local missing = {}

	for _, dep in ipairs(deps) do
		if type(dep) == "string" then
			if not has(dep) then
				table.insert(missing, dep)
			end
		else
			local found = false

			for _, candidate in ipairs(dep) do
				if has(candidate) then
					found = true
					break
				end
			end

			if not found then
				table.insert(missing, table.concat(dep, " | "))
			end
		end
	end

	if #missing > 0 then
		notify_missing(group, missing)
		return false
	end

	return true
end

------------------------------------------------------------
-- Language / tool dependency checks
------------------------------------------------------------

local HAS_C_CPP = check_deps("C/C++ LSP support", {
	{ "gcc", "cc", "clang" },
})

local HAS_LUA = true

local HAS_PYTHON_TOOLS = check_deps("Python tools", {
	"python3",
	{ "pip3", "pip" },
})

local HAS_PYRIGHT = check_deps("Pyright", {
	{ "node", "nodejs" },
	"npm",
})

local HAS_NIX = check_deps("Nix LSP support", {
	"nix",
	"cargo",
})

local HAS_PRETTIER = check_deps("Prettier", {
	{ "node", "nodejs" },
	"npm",
})

------------------------------------------------------------
-- Neovim Lua development
------------------------------------------------------------

require("neodev").setup({})

------------------------------------------------------------
-- LSP file operations
------------------------------------------------------------

require("lsp-file-operations").setup()

------------------------------------------------------------
-- Import plugins
------------------------------------------------------------

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

------------------------------------------------------------
-- Mason setup
------------------------------------------------------------

mason.setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

------------------------------------------------------------
-- Mason packages to install
------------------------------------------------------------

local lsp_servers = {}
local tools = {}

if HAS_C_CPP then
	table.insert(lsp_servers, "clangd")
end

if HAS_LUA then
	table.insert(lsp_servers, "lua_ls")
	table.insert(tools, "stylua")
end

if HAS_PYRIGHT then
	table.insert(lsp_servers, "pyright")
end

if HAS_PYTHON_TOOLS then
	table.insert(tools, "isort")
	table.insert(tools, "black")
	table.insert(tools, "pylint")
end

if HAS_NIX then
	table.insert(lsp_servers, "nil_ls")
	table.insert(tools, "nixpkgs-fmt")
end

if HAS_PRETTIER then
	table.insert(tools, "prettier")
end

------------------------------------------------------------
-- Mason LSP setup
------------------------------------------------------------

mason_lspconfig.setup({
	ensure_installed = lsp_servers,
})

------------------------------------------------------------
-- Mason Tool Installer
------------------------------------------------------------

mason_tool_installer.setup({
	ensure_installed = tools,
})

------------------------------------------------------------
-- LSP capabilities
------------------------------------------------------------

local capabilities = cmp_nvim_lsp.default_capabilities()

------------------------------------------------------------
-- LSP keymaps
------------------------------------------------------------

local keymap = vim.keymap

local on_attach = function(_, bufnr)
	local opts = {
		noremap = true,
		silent = true,
		buffer = bufnr,
	}

	------------------------------------------------------------
	-- Navigation
	------------------------------------------------------------

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

	------------------------------------------------------------
	-- Code actions
	------------------------------------------------------------

	opts.desc = "See available code actions"
	keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)

	opts.desc = "Smart rename"
	keymap.set("n", "<leader>lR", vim.lsp.buf.rename, opts)

	------------------------------------------------------------
	-- Diagnostics
	------------------------------------------------------------

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

	------------------------------------------------------------
	-- Documentation / LSP control
	------------------------------------------------------------

	opts.desc = "Show documentation under cursor"
	keymap.set("n", "K", vim.lsp.buf.hover, opts)

	opts.desc = "Restart LSP"
	keymap.set("n", "<leader>ll", "<cmd>LspRestart<CR>", opts)
end

------------------------------------------------------------
-- Default config for all LSP servers
------------------------------------------------------------

vim.lsp.config("*", {
	capabilities = capabilities,
	on_attach = on_attach,
})

------------------------------------------------------------
-- lua_ls config
------------------------------------------------------------

if HAS_LUA then
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
end

------------------------------------------------------------
-- nil_ls config
------------------------------------------------------------

if HAS_NIX then
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
end

------------------------------------------------------------
-- Enable LSP servers
------------------------------------------------------------

vim.lsp.enable(lsp_servers)

------------------------------------------------------------
-- Diagnostics configuration
------------------------------------------------------------

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
