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

local function get_missing_deps(deps)
	local missing = {}

	for _, dep in ipairs(deps) do
		local t = type(dep)

		if t == "string" then
			if not has(dep) then
				table.insert(missing, dep)
			end

		elseif t == "table" then
			-- Named custom check
			if dep.check then
				if not dep.check() then
					table.insert(missing, dep.name)
				end
			else
				-- Alternative executables
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
	end

	return missing
end

local function deps_available(deps)
	return #get_missing_deps(deps) == 0
end

local function notify_unavailable(group, executable, missing_deps)
	local missing = {}

	if executable then
		table.insert(missing, "executable: " .. executable)
	end

	if missing_deps and #missing_deps > 0 then
		table.insert(missing, "dependencies: " .. table.concat(missing_deps, ", "))
	end

	notify_missing(group, missing)
end

local function add_server(server_name, executable, mason_servers, enabled_servers, install_deps)
	if has(executable) then
		table.insert(enabled_servers, server_name)
		return
	end

	local missing_deps = get_missing_deps(install_deps or {})

	if #missing_deps == 0 then
		table.insert(mason_servers, server_name)
		table.insert(enabled_servers, server_name)
	else
		notify_unavailable(server_name, executable, missing_deps)
	end
end

local function add_tool(tool_name, executable, mason_tools, install_deps)
	if has(executable) then
		return
	end

	local missing_deps = get_missing_deps(install_deps or {})

	if #missing_deps == 0 then
		table.insert(mason_tools, tool_name)
	else
		notify_unavailable(tool_name, executable, missing_deps)
	end
end

------------------------------------------------------------
-- Dependency groups
------------------------------------------------------------

local NODE_DEPS = {
	{ "node", "nodejs" },
	"npm",
}

local PYTHON_DEPS = {
	"python3",
	{ "pip3", "pip" },

	{
		name = "python3 venv/ensurepip",

		check = function()
			return vim.fn.system({
				"python3",
				"-c",
				"import venv, ensurepip",
			}) == ""
		end,
	},
}

local NIX_DEPS = {
	"nix",
	"cargo",
}

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
-- Mason packages to install / LSP servers to enable
------------------------------------------------------------

local mason_servers = {}
local enabled_servers = {}
local tools = {}

-- C/C++
--
-- clangd is system-only here because Mason does not support clangd
-- on some ARM platforms.
if has("clangd") then
	table.insert(enabled_servers, "clangd")
else
	notify_unavailable("C/C++ LSP support", "clangd", {})
end

-- Lua
add_server("lua_ls", "lua-language-server", mason_servers, enabled_servers, {})
add_tool("stylua", "stylua", tools, {})

-- Python
add_server("pyright", "pyright-langserver", mason_servers, enabled_servers, NODE_DEPS)
add_tool("isort", "isort", tools, PYTHON_DEPS)
add_tool("black", "black", tools, PYTHON_DEPS)
add_tool("pylint", "pylint", tools, PYTHON_DEPS)

-- Nix
add_server("nil_ls", "nil", mason_servers, enabled_servers, NIX_DEPS)
add_tool("nixpkgs-fmt", "nixpkgs-fmt", tools, NIX_DEPS)

-- Web / general formatting
add_tool("prettier", "prettier", tools, NODE_DEPS)

------------------------------------------------------------
-- Mason LSP setup
------------------------------------------------------------

mason_lspconfig.setup({
	ensure_installed = mason_servers,
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

------------------------------------------------------------
-- nil_ls config
------------------------------------------------------------

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

------------------------------------------------------------
-- Enable LSP servers
------------------------------------------------------------

vim.lsp.enable(enabled_servers)

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
