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
-- Plugin build hooks
------------------------------------------------------------

-- To update/install telescope-fzf-native we need to compile it.
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(event)
		local data = event.data

		if data.spec.name == "telescope-fzf-native.nvim" and (data.kind == "install" or data.kind == "update") then
			vim.system({ "make" }, { cwd = data.path })
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
	{ src = gh("nvim-lua/plenary.nvim"), version = "master" }, -- Lua utility dependency used by many plugins
}

------------------------------------------------------------
-- UI plugins
------------------------------------------------------------

local ui_plugins = {
	{ src = gh("projekt0n/github-nvim-theme"), version = "main" }, -- GitHub colorscheme
	{ src = gh("nvim-lualine/lualine.nvim"), version = "master" }, -- Statusline/winbar
}

------------------------------------------------------------
-- Misc plugins
------------------------------------------------------------

local misc_plugins = {
	{ src = gh("folke/which-key.nvim"), version = "main" }, -- Keymap hints popup
	{ src = gh("folke/snacks.nvim"), version = "main" }, -- Picker/input/notifier helpers
	{ src = gh("folke/flash.nvim"), version = "main" }, -- Fast cursor jumping
	{ src = gh("numToStr/Comment.nvim"), version = "master" }, -- Comment toggling
	{ src = gh("tpope/vim-surround"), version = "master" }, -- Surround text objects
}

------------------------------------------------------------
-- File plugins
------------------------------------------------------------

local file_plugins = {
	{ src = gh("nvim-tree/nvim-tree.lua"), version = "master" }, -- File explorer
	{ src = gh("nvim-tree/nvim-web-devicons"), version = "master" }, -- File icons
	{ src = gh("chrishrb/gx.nvim"), version = "main" }, -- Open URLs/files with gx
	{ src = gh("tpope/vim-sleuth"), version = "master" }, -- Detect indentation settings
	{ src = gh("christoomey/vim-tmux-navigator"), version = "master" }, -- Navigate tmux panes from Vim
}

------------------------------------------------------------
-- Git plugins
------------------------------------------------------------

local git_plugins = {
	{ src = gh("lewis6991/gitsigns.nvim"), version = "main" }, -- Git signs in gutter
	{ src = gh("NeogitOrg/neogit"), version = "master" }, -- Git interface
	{ src = gh("sindrets/diffview.nvim"), version = "main" }, -- Git diff views
}

------------------------------------------------------------
-- Telescope plugins
------------------------------------------------------------

local telescope_plugins = {
	{ src = gh("nvim-telescope/telescope.nvim"), version = "master" }, -- Fuzzy finder
	{ src = gh("nvim-telescope/telescope-fzf-native.nvim"), version = "main" }, -- Faster Telescope sorter
}

------------------------------------------------------------
-- Treesitter plugins
------------------------------------------------------------

local treesitter_plugins = {
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" }, -- Syntax parsing/highlighting
	{ src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" }, -- Treesitter textobjects
}

------------------------------------------------------------
-- LSP plugins
------------------------------------------------------------

local lsp_plugins = {
	{ src = gh("neovim/nvim-lspconfig"), version = "master" }, -- LSP server configs
	{ src = gh("williamboman/mason.nvim"), version = "main" }, -- External tool installer
	{ src = gh("williamboman/mason-lspconfig.nvim"), version = "main" }, -- Mason/LSP bridge
	{ src = gh("WhoIsSethDaniel/mason-tool-installer.nvim"), version = "main" }, -- Ensure tools are installed
	{ src = gh("folke/neodev.nvim"), version = "main" }, -- LuaLS support for Neovim APIs
	{ src = gh("antosha417/nvim-lsp-file-operations"), version = "master" }, -- LSP file rename/move support
}

------------------------------------------------------------
-- Completion plugins
------------------------------------------------------------

local completion_plugins = {
	{ src = gh("hrsh7th/nvim-cmp"), version = "main" }, -- Completion engine
	{ src = gh("hrsh7th/cmp-buffer"), version = "main" }, -- Buffer completion source
	{ src = gh("hrsh7th/cmp-path"), version = "main" }, -- Path completion source
	{ src = gh("hrsh7th/cmp-nvim-lsp"), version = "main" }, -- LSP completion source
	{ src = gh("L3MON4D3/LuaSnip"), version = "master" }, -- Snippet engine
	{ src = gh("saadparwaiz1/cmp_luasnip"), version = "master" }, -- LuaSnip completion source
	{ src = gh("rafamadriz/friendly-snippets"), version = "main" }, -- Snippet collection
	{ src = gh("Exafunction/codeium.nvim"), version = "main" }, -- Codeium completion source
}

------------------------------------------------------------
-- AI plugins
------------------------------------------------------------

local ai_plugins = {
	{ src = gh("nickjvandyke/opencode.nvim"), version = "main" }, -- OpenCode integration
}

------------------------------------------------------------
-- ChatGPT plugins
------------------------------------------------------------

local chatgpt_plugins = {
	{ src = gh("jackMort/ChatGPT.nvim"), version = "main" }, -- ChatGPT commands/UI
	{ src = gh("MunifTanjim/nui.nvim"), version = "main" }, -- ChatGPT UI dependency
	{ src = gh("folke/trouble.nvim"), version = "main" }, -- ChatGPT diagnostics dependency
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
