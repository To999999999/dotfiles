------------------------------------------------------------
-- Parsers
------------------------------------------------------------

local parsers = {
	"bash",
	"c",
	"git_config",
	"gitcommit",
	"gitignore",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"nix",
	"objc",
	"python",
	"query",
	"regex",
	"rust",
	"swift",
	"toml",
	"vim",
	"vimdoc",
	"yaml",
}

------------------------------------------------------------
-- Treesitter setup
------------------------------------------------------------

local ts = require("nvim-treesitter")

ts.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Install parsers.
--
-- Dependency checks are already done in plugins.lua before this file is loaded.
ts.install(parsers)

------------------------------------------------------------
-- Enable Treesitter per filetype
------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		-- Start Treesitter highlighting for the current buffer.
		pcall(vim.treesitter.start)

		-- Use Treesitter-based indentation when available.
		pcall(function()
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end)
	end,
})

------------------------------------------------------------
-- Incremental selection
------------------------------------------------------------

-- Start a Treesitter selection at the current node.
vim.keymap.set("n", "<leader>ss", function()
	require("nvim-treesitter.incremental_selection").init_selection()
end, { desc = "Treesitter init selection" })

-- Expand selection to the next larger syntax node.
vim.keymap.set("x", "<leader>si", function()
	require("nvim-treesitter.incremental_selection").node_incremental()
end, { desc = "Treesitter expand node" })

-- Expand selection to the current scope.
vim.keymap.set("x", "<leader>sa", function()
	require("nvim-treesitter.incremental_selection").scope_incremental()
end, { desc = "Treesitter expand scope" })

-- Shrink selection back to the previous syntax node.
vim.keymap.set("x", "<leader>sd", function()
	require("nvim-treesitter.incremental_selection").node_decremental()
end, { desc = "Treesitter shrink node" })

------------------------------------------------------------
-- Textobjects
------------------------------------------------------------

local ok_textobjects, textobjects = pcall(require, "nvim-treesitter-textobjects")

if ok_textobjects then
	textobjects.setup({
		select = {
			-- Automatically jump forward to textobjects.
			lookahead = true,

			-- Selection mode per textobject type.
			selection_modes = {
				["@parameter.outer"] = "v",
				["@function.outer"] = "V",
				["@class.outer"] = "<c-v>",
			},

			-- Include surrounding whitespace when selecting textobjects.
			include_surrounding_whitespace = true,
		},
	})

	local select = require("nvim-treesitter-textobjects.select")

	------------------------------------------------------------
	-- Function textobjects
	------------------------------------------------------------

	vim.keymap.set({ "x", "o" }, "af", function()
		select.select_textobject("@function.outer", "textobjects")
	end, { desc = "Select outer function" })

	vim.keymap.set({ "x", "o" }, "if", function()
		select.select_textobject("@function.inner", "textobjects")
	end, { desc = "Select inner function" })

	------------------------------------------------------------
	-- Class textobjects
	------------------------------------------------------------

	vim.keymap.set({ "x", "o" }, "ac", function()
		select.select_textobject("@class.outer", "textobjects")
	end, { desc = "Select outer class" })

	vim.keymap.set({ "x", "o" }, "ic", function()
		select.select_textobject("@class.inner", "textobjects")
	end, { desc = "Select inner class" })

	------------------------------------------------------------
	-- Scope textobject
	------------------------------------------------------------

	vim.keymap.set({ "x", "o" }, "as", function()
		select.select_textobject("@local.scope", "locals")
	end, { desc = "Select language scope" })
else
	vim.schedule(function()
		vim.notify(
			"Treesitter textobjects skipped: plugin not available",
			vim.log.levels.INFO,
			{ title = "Treesitter" }
		)
	end)
end
