------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local gh = function(plugin)
	return "https://github.com/" .. plugin
end

local function has(cmd)
	return vim.fn.executable(cmd) == 1
end

local function notify_missing(group, missing)
	vim.schedule(function()
		vim.notify(
			"Skipping " .. group .. ". Missing: " .. table.concat(missing, ", "),
			vim.log.levels.WARN,
			{ title = "Neovim plugins" }
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

local function add_group(enabled, plugins, opts)
	if enabled then
		vim.pack.add(plugins, opts)
	end
end

------------------------------------------------------------
-- Pack options
------------------------------------------------------------

local pack_opts = {
	load = true,
	confirm = false,
}

local dynamic_pack_opts = {
	load = function() end,
	confirm = false,
}

------------------------------------------------------------
-- Plugin build helpers
------------------------------------------------------------

local function get_pack_plugin_path(name)
	for _, plugin in ipairs(vim.pack.get()) do
		if plugin.spec and plugin.spec.name == name then
			return plugin.path
		end

		if plugin.path and plugin.path:match("/" .. name .. "$") then
			return plugin.path
		end
	end

	return nil
end

local function telescope_fzf_is_built(path)
	return path and vim.fn.filereadable(path .. "/build/libfzf.so") == 1
end

local function build_telescope_fzf_sync()
	local path = get_pack_plugin_path("telescope-fzf-native.nvim")

	if not path then
		return false
	end

	if telescope_fzf_is_built(path) then
		return true
	end

	vim.notify("Building telescope-fzf-native...", vim.log.levels.INFO, {
		title = "Neovim plugins",
	})

	local result = vim.system({ "make" }, { cwd = path }):wait()

	if result.code == 0 then
		vim.notify("Built telescope-fzf-native successfully", vim.log.levels.INFO, {
			title = "Neovim plugins",
		})
		return true
	end

	vim.notify(
		"Failed to build telescope-fzf-native:\n" .. (result.stderr or ""),
		vim.log.levels.ERROR,
		{ title = "Neovim plugins" }
	)

	return false
end

local function build_telescope_fzf_async(path)
	if not path or telescope_fzf_is_built(path) then
		return
	end

	vim.notify("Building telescope-fzf-native...", vim.log.levels.INFO, {
		title = "Neovim plugins",
	})

	vim.system({ "make" }, { cwd = path }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				vim.notify("Built telescope-fzf-native successfully", vim.log.levels.INFO, {
					title = "Neovim plugins",
				})
			else
				vim.notify(
					"Failed to build telescope-fzf-native:\n" .. (result.stderr or ""),
					vim.log.levels.ERROR,
					{ title = "Neovim plugins" }
				)
			end
		end)
	end)
end

------------------------------------------------------------
-- Plugin build hooks
------------------------------------------------------------

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(event)
		local data = event.data or {}

		if not data.spec or not data.spec.name then
			return
		end

		if data.spec.name == "telescope-fzf-native.nvim" and (data.kind == "install" or data.kind == "update") then
			build_telescope_fzf_async(data.path)
		end
	end,
})

------------------------------------------------------------
-- Dependency checks
------------------------------------------------------------

local HAS_GIT = check_deps("Shared dependency plugins", {
	"git",
})

local HAS_TELESCOPE = check_deps("Telescope plugins", {
	"git",
	"rg",
	"fd",
	"make",
	{ "gcc", "cc", "clang" },
})

local HAS_TREESITTER = check_deps("Treesitter plugins", {
	"git",
	"curl",
	"tar",
	"tree-sitter",
	{ "gcc", "cc", "clang" },
})

local HAS_LSP = check_deps("LSP plugins", {
	"git",
	{ "curl", "wget" },
	"unzip",
	"tar",
	"gzip",
})

local HAS_COMPLETION = check_deps("Completion plugins", {
	"git",
	"curl",
})

local HAS_AI = check_deps("AI plugins", {
	"git",
	"opencode",
})

local HAS_CHATGPT = check_deps("ChatGPT plugins", {
	"git",
	"curl",
})

------------------------------------------------------------
-- Shared dependency plugins
------------------------------------------------------------

local dependency_plugins = {
	{ src = gh("nvim-lua/plenary.nvim"), version = "master" },
}

------------------------------------------------------------
-- UI plugins
------------------------------------------------------------

local ui_plugins = {
	{ src = gh("projekt0n/github-nvim-theme"), version = "main" },
	{ src = gh("nvim-lualine/lualine.nvim"), version = "master" },
}

------------------------------------------------------------
-- Misc plugins
------------------------------------------------------------

local misc_plugins = {
	{ src = gh("folke/which-key.nvim"), version = "main" },
	{ src = gh("folke/snacks.nvim"), version = "main" },
	{ src = gh("folke/flash.nvim"), version = "main" },
	{ src = gh("numToStr/Comment.nvim"), version = "master" },
	{ src = gh("tpope/vim-surround"), version = "master" },
}

------------------------------------------------------------
-- File plugins
------------------------------------------------------------

local file_plugins = {
	{ src = gh("nvim-tree/nvim-tree.lua"), version = "master" },
	{ src = gh("nvim-tree/nvim-web-devicons"), version = "master" },
	{ src = gh("chrishrb/gx.nvim"), version = "main" },
	{ src = gh("tpope/vim-sleuth"), version = "master" },
	{ src = gh("christoomey/vim-tmux-navigator"), version = "master" },
}

------------------------------------------------------------
-- Git plugins
------------------------------------------------------------

local git_plugins = {
	{ src = gh("lewis6991/gitsigns.nvim"), version = "main" },
	{ src = gh("NeogitOrg/neogit"), version = "master" },
	{ src = gh("sindrets/diffview.nvim"), version = "main" },
}

------------------------------------------------------------
-- Telescope plugins
------------------------------------------------------------

local telescope_plugins = {
	{ src = gh("nvim-telescope/telescope.nvim"), version = "master" },
	{ src = gh("nvim-telescope/telescope-fzf-native.nvim"), version = "main" },
}

------------------------------------------------------------
-- Treesitter plugins
------------------------------------------------------------

local treesitter_plugins = {
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
	{ src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },
}

------------------------------------------------------------
-- LSP plugins
------------------------------------------------------------

local lsp_plugins = {
	{ src = gh("neovim/nvim-lspconfig"), version = "master" },
	{ src = gh("williamboman/mason.nvim"), version = "main" },
	{ src = gh("williamboman/mason-lspconfig.nvim"), version = "main" },
	{ src = gh("WhoIsSethDaniel/mason-tool-installer.nvim"), version = "main" },
	{ src = gh("folke/neodev.nvim"), version = "main" },
	{ src = gh("antosha417/nvim-lsp-file-operations"), version = "master" },
}

------------------------------------------------------------
-- Completion plugins
------------------------------------------------------------

local completion_plugins = {
	{ src = gh("hrsh7th/nvim-cmp"), version = "main" },
	{ src = gh("hrsh7th/cmp-buffer"), version = "main" },
	{ src = gh("hrsh7th/cmp-path"), version = "main" },
	{ src = gh("hrsh7th/cmp-nvim-lsp"), version = "main" },
	{ src = gh("L3MON4D3/LuaSnip"), version = "master" },
	{ src = gh("saadparwaiz1/cmp_luasnip"), version = "master" },
	{ src = gh("rafamadriz/friendly-snippets"), version = "main" },
	{ src = gh("Exafunction/codeium.nvim"), version = "main" },
}

------------------------------------------------------------
-- AI plugins
------------------------------------------------------------

local ai_plugins = {
	{ src = gh("nickjvandyke/opencode.nvim"), version = "main" },
}

------------------------------------------------------------
-- ChatGPT plugins
------------------------------------------------------------

local chatgpt_plugins = {
	{ src = gh("jackMort/ChatGPT.nvim"), version = "main" },
	{ src = gh("MunifTanjim/nui.nvim"), version = "main" },
	{ src = gh("folke/trouble.nvim"), version = "main" },
}

------------------------------------------------------------
-- Add plugins
------------------------------------------------------------

add_group(HAS_GIT, dependency_plugins, pack_opts)

vim.pack.add(ui_plugins, pack_opts)
vim.pack.add(misc_plugins, pack_opts)
vim.pack.add(file_plugins, pack_opts)

add_group(HAS_GIT, git_plugins, pack_opts)
add_group(HAS_TELESCOPE, telescope_plugins, pack_opts)
add_group(HAS_TREESITTER, treesitter_plugins, pack_opts)
add_group(HAS_LSP, lsp_plugins, pack_opts)
add_group(HAS_COMPLETION, completion_plugins, pack_opts)
add_group(HAS_AI, ai_plugins, pack_opts)
add_group(HAS_CHATGPT, chatgpt_plugins, dynamic_pack_opts)

if HAS_TELESCOPE then
	build_telescope_fzf_sync()
end

------------------------------------------------------------
-- Load plugin configuration
------------------------------------------------------------

require("config.ui")
require("config.misc")
require("config.files")

if HAS_GIT then
	require("config.git")
end

if HAS_TREESITTER then
	require("config.treesitter")
end

if HAS_TELESCOPE then
	require("config.telescope")
end

if HAS_COMPLETION then
	require("config.completion")
end

if HAS_LSP then
	require("config.lsp")
end

if HAS_CHATGPT then
	require("config.chatgpt")
end

if HAS_AI then
	require("config.ai")
end
