------------------------------------------------------------
-- Colorscheme
------------------------------------------------------------

-- Use the GitHub light colorscheme.
vim.cmd.colorscheme("github_light")

------------------------------------------------------------
-- Status line
------------------------------------------------------------

-- Hide the default statusline.
-- Lualine will use the winbar instead.
vim.o.laststatus = 0

require("lualine").setup({
	options = {
		theme = "ayu_light",
	},

	-- Active window.
	winbar = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},

	-- Inactive windows.
	inactive_winbar = {
		lualine_c = { "filename" },
	},

	-- Disable the normal statusline.
	sections = {},
	inactive_sections = {},
})
