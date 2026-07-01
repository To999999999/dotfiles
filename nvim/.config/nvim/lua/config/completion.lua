------------------------------------------------------------
-- Completion plugins
------------------------------------------------------------

local cmp = require("cmp")
local luasnip = require("luasnip")

------------------------------------------------------------
-- Snippets
------------------------------------------------------------

-- Load VS Code-style snippets from installed plugins.
-- Example: rafamadriz/friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

------------------------------------------------------------
-- nvim-cmp setup
------------------------------------------------------------

cmp.setup({
	------------------------------------------------------------
	-- Completion menu behavior
	------------------------------------------------------------

	completion = {
		completeopt = "menu,menuone,preview,noselect",
	},

	------------------------------------------------------------
	-- Snippet engine integration
	------------------------------------------------------------

	snippet = {
		-- Tell nvim-cmp how to expand snippets.
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	------------------------------------------------------------
	-- Completion keymaps
	------------------------------------------------------------

	mapping = cmp.mapping.preset.insert({
		["<C-k>"] = cmp.mapping.select_prev_item(), -- Previous suggestion
		["<C-j>"] = cmp.mapping.select_next_item(), -- Next suggestion
		["<C-b>"] = cmp.mapping.scroll_docs(-4), -- Scroll docs up
		["<C-f>"] = cmp.mapping.scroll_docs(4), -- Scroll docs down
		["<C-s>"] = cmp.mapping.complete(), -- Manually open completion menu
		["<C-c>"] = cmp.mapping.abort(), -- Close completion menu
		["<CR>"] = cmp.mapping.confirm({ select = false }), -- Confirm selected item only
	}),

	------------------------------------------------------------
	-- Completion sources
	------------------------------------------------------------

	sources = cmp.config.sources({
		{ name = "codeium" }, -- AI completion
		{ name = "nvim_lsp" }, -- Language Server suggestions
		{ name = "luasnip" }, -- Snippets
		{ name = "buffer" }, -- Words from current buffer
		{ name = "path" }, -- File system paths
	}),
})

------------------------------------------------------------
-- Codeium
------------------------------------------------------------

-- Setup Codeium completion source.
require("codeium").setup({})
