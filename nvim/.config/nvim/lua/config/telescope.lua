------------------------------------------------------------
-- Imports
------------------------------------------------------------

local telescope = require("telescope")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

------------------------------------------------------------
-- Telescope setup
------------------------------------------------------------

telescope.setup({
	defaults = {
		path_display = { "truncate" },

		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous,
				["<C-j>"] = actions.move_selection_next,
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
			},
		},
	},
})

------------------------------------------------------------
-- fzf-native extension
------------------------------------------------------------

local ok_fzf = pcall(telescope.load_extension, "fzf")

if not ok_fzf then
	vim.schedule(function()
		vim.notify(
			"Telescope: fzf-native unavailable, using default sorter",
			vim.log.levels.WARN,
			{ title = "Telescope" }
		)
	end)
end

------------------------------------------------------------
-- Keymaps
------------------------------------------------------------

local keymap = vim.keymap

keymap.set("n", "<leader>ff", builtin.find_files, {
	desc = "Fuzzy find files in cwd",
})

keymap.set("n", "<leader>fg", builtin.live_grep, {
	desc = "Find string in cwd",
})

keymap.set("n", "<leader>fs", builtin.grep_string, {
	desc = "Find string under cursor in cwd",
})

keymap.set("n", "<leader>fr", builtin.oldfiles, {
	desc = "Fuzzy find recent files",
})

keymap.set("n", "<leader>fb", builtin.buffers, {
	desc = "Fuzzy find open buffers",
})

keymap.set("n", "<leader>fh", builtin.help_tags, {
	desc = "Search help",
})

keymap.set("n", "<leader>fk", builtin.keymaps, {
	desc = "Search keymaps",
})

keymap.set("n", "<leader>fd", builtin.diagnostics, {
	desc = "Search diagnostics",
})

keymap.set("n", "<leader>sr", builtin.resume, {
	desc = "Resume last Telescope search",
})

keymap.set("n", "<leader>s/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, {
	desc = "Search in open files",
})

keymap.set("n", "<leader>sn", function()
	builtin.find_files({
		cwd = vim.fn.stdpath("config"),
	})
end, {
	desc = "Search Neovim files",
})
