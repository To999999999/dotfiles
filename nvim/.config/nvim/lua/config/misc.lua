------------------------------------------------------------
-- which-key
------------------------------------------------------------

require("which-key").setup({
	icons = {
		-- Enable Nerd Font icons if available.
		mappings = vim.g.have_nerd_font,

		-- Fallback icons when Nerd Fonts aren't available.
		keys = vim.g.have_nerd_font and {} or {
			Up = "<Up> ",
			Down = "<Down> ",
			Left = "<Left> ",
			Right = "<Right> ",
			C = "<C-…> ",
			M = "<M-…> ",
			D = "<D-…> ",
			S = "<S-…> ",
			CR = "<CR> ",
			Esc = "<Esc> ",
			ScrollWheelDown = "<ScrollWheelDown> ",
			ScrollWheelUp = "<ScrollWheelUp> ",
			NL = "<NL> ",
			BS = "<BS> ",
			Space = "<Space> ",
			Tab = "<Tab> ",
			F1 = "<F1>",
			F2 = "<F2>",
			F3 = "<F3>",
			F4 = "<F4>",
			F5 = "<F5>",
			F6 = "<F6>",
			F7 = "<F7>",
			F8 = "<F8>",
			F9 = "<F9>",
			F10 = "<F10>",
			F11 = "<F11>",
			F12 = "<F12>",
		},
	},

	------------------------------------------------------------
	-- Leader groups
	------------------------------------------------------------

	spec = {
		{ "<leader>c", group = "[C]omment", mode = { "n", "x" } },
		{ "<leader>b", group = "[B]lock comment", mode = { "n", "x" } },
		{ "<leader>f", group = "[F]ind" },
		{ "<leader>e", group = "[E]xplore file tree" },
		{ "<leader>a", group = "[A]I (ChatGPT)" },
		{ "<leader>o", group = "[O]penCode" },
		{ "<leader>g", group = "[G]it" },
		{ "<leader>s", group = "[S]yntax / Treesitter" },
		{ "<leader>l", group = "[L]SP" },
	},
})

------------------------------------------------------------
-- Comment.nvim
------------------------------------------------------------

require("Comment").setup({
	-- Toggle comments.
	toggler = {
		line = "<leader>cc",
		block = "<leader>bb",
	},

	-- Operator-pending mappings.
	opleader = {
		line = "<leader>c",
		block = "<leader>b",
	},

	-- Extra mappings.
	extra = {
		above = "<leader>cO",
		below = "<leader>co",
		eol = "<leader>cA",
	},
})

------------------------------------------------------------
-- Flash.nvim
------------------------------------------------------------

require("flash").setup({
	modes = {
		search = {
			enabled = true,
		},

		char = {
			jump_labels = true,
		},
	},
})

------------------------------------------------------------
-- Flash keymaps
------------------------------------------------------------

-- Jump anywhere on screen.
vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })

-- Jump using Treesitter nodes.
vim.keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })

-- Remote operator jump.
vim.keymap.set("o", "r", function()
	require("flash").remote()
end, { desc = "Remote Flash" })

-- Treesitter search.
vim.keymap.set({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Treesitter Search" })

-- Toggle Flash integration inside '/' search.
vim.keymap.set("c", "<C-s>", function()
	require("flash").toggle()
end, { desc = "Toggle Flash Search" })

------------------------------------------------------------
-- Snacks.nvim
------------------------------------------------------------

local snacks = require("snacks")

snacks.setup({
	input = {
		enabled = true,
	},

	picker = {
		enabled = true,
	},

	notifier = {
		enabled = true,
	},
})

-- Enable enhanced vim.ui.input().
snacks.input.enable()

-- Replace vim.ui.select() and picker functionality.
snacks.picker.setup()

-- Notification history creates :Messages(uses snacks) and :message links to it
vim.api.nvim_create_user_command("Messages", function()
	snacks.notifier.show_history()
end, {
	desc = "Show notification history",
})

vim.cmd([[
cnoreabbrev <expr> messages getcmdtype() == ':' && getcmdline() ==# 'messages'
	\ ? 'Messages'
	\ : 'messages'
]])
