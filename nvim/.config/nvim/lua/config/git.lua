------------------------------------------------------------
-- gitsigns.nvim
------------------------------------------------------------

-- Display Git changes directly in the sign column.
require("gitsigns").setup({
	signs = {
		add = { text = "+" }, -- Added line
		change = { text = "~" }, -- Modified line
		delete = { text = "_" }, -- Deleted line
		topdelete = { text = "‾" }, -- Deleted line at top of file
		changedelete = { text = "~" }, -- Modified then deleted line
	},
})

------------------------------------------------------------
-- gitsigns.nvim keymaps
------------------------------------------------------------

-- Preview the current Git hunk.
vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", {
	desc = "Preview Git hunk",
})

-- Toggle inline blame for the current line.
vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<CR>", {
	desc = "Toggle Git blame",
})

------------------------------------------------------------
-- Neogit
------------------------------------------------------------

-- Setup Neogit using the default configuration.
require("neogit").setup()

------------------------------------------------------------
-- Neogit keymaps
------------------------------------------------------------

-- No custom keymaps.
--
-- Open with:
--   :Neogit
--
-- Once open, press '?' to display all available Neogit keybindings.
