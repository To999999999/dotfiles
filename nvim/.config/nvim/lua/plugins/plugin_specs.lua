------------------------------------------------------------
-- Module
------------------------------------------------------------

local plugin_specs = {}

------------------------------------------------------------
-- Shared dependency plugins
------------------------------------------------------------

plugin_specs.dependency_plugins = {
	{ src = "https://github.com/nvim-lua/plenary.nvim", version = "master" },
}

------------------------------------------------------------
-- UI plugins
------------------------------------------------------------

plugin_specs.ui_plugins = {
	{ src = "https://github.com/projekt0n/github-nvim-theme", version = "main" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim", version = "master" },
}

------------------------------------------------------------
-- Misc plugins
------------------------------------------------------------

plugin_specs.misc_plugins = {
	{ src = "https://github.com/folke/which-key.nvim", version = "main" },
	{ src = "https://github.com/folke/snacks.nvim", version = "main" },
	{ src = "https://github.com/folke/flash.nvim", version = "main" },
	{ src = "https://github.com/numToStr/Comment.nvim", version = "master" },
	{ src = "https://github.com/tpope/vim-surround", version = "master" },
}

------------------------------------------------------------
-- File plugins
------------------------------------------------------------

plugin_specs.file_plugins = {
	{ src = "https://github.com/nvim-tree/nvim-tree.lua", version = "master" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons", version = "master" },
	{ src = "https://github.com/chrishrb/gx.nvim", version = "main" },
	{ src = "https://github.com/tpope/vim-sleuth", version = "master" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator", version = "master" },
}

------------------------------------------------------------
-- Git plugins
------------------------------------------------------------

plugin_specs.git_plugins = {
	{ src = "https://github.com/nvim-lua/plenary.nvim", version = "master" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim", version = "main" },
	{ src = "https://github.com/NeogitOrg/neogit", version = "master" },
	{ src = "https://github.com/sindrets/diffview.nvim", version = "main" },
}

------------------------------------------------------------
-- Telescope plugins
------------------------------------------------------------

plugin_specs.telescope_plugins = {
	{ src = "https://github.com/nvim-lua/plenary.nvim", version = "master" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "master" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", version = "main" },
}

------------------------------------------------------------
-- Treesitter plugins
------------------------------------------------------------

plugin_specs.treesitter_plugins = {
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
}

------------------------------------------------------------
-- Completion plugins
------------------------------------------------------------

plugin_specs.completion_plugins = {
	{ src = "https://github.com/hrsh7th/nvim-cmp", version = "main" },
	{ src = "https://github.com/hrsh7th/cmp-buffer", version = "main" },
	{ src = "https://github.com/hrsh7th/cmp-path", version = "main" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp", version = "main" },
	{ src = "https://github.com/L3MON4D3/LuaSnip", version = "master" },
	{ src = "https://github.com/saadparwaiz1/cmp_luasnip", version = "master" },
	{ src = "https://github.com/rafamadriz/friendly-snippets", version = "main" },
	{ src = "https://github.com/Exafunction/codeium.nvim", version = "main" },
}

------------------------------------------------------------
-- LSP plugins
------------------------------------------------------------

plugin_specs.lsp_plugins = {
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp", version = "main" },
	{ src = "https://github.com/neovim/nvim-lspconfig", version = "master" },
	{ src = "https://github.com/williamboman/mason.nvim", version = "main" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim", version = "main" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", version = "main" },
	{ src = "https://github.com/folke/neodev.nvim", version = "main" },
	{ src = "https://github.com/antosha417/nvim-lsp-file-operations", version = "master" },
}

------------------------------------------------------------
-- AI plugins
------------------------------------------------------------

plugin_specs.ai_plugins = {
	{ src = "https://github.com/nvim-lua/plenary.nvim", version = "master" },
	{ src = "https://github.com/nickjvandyke/opencode.nvim", version = "main" },
}

------------------------------------------------------------
-- ChatGPT plugins
------------------------------------------------------------

plugin_specs.chatgpt_plugins = {
	{ src = "https://github.com/nvim-lua/plenary.nvim", version = "master" },
	{ src = "https://github.com/jackMort/ChatGPT.nvim", version = "main" },
	{ src = "https://github.com/MunifTanjim/nui.nvim", version = "main" },
	{ src = "https://github.com/folke/trouble.nvim", version = "main" },
}

------------------------------------------------------------
-- Module
------------------------------------------------------------

return plugin_specs
