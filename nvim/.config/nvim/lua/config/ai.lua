------------------------------------------------------------
-- OpenCode options
------------------------------------------------------------

-- Global options passed to opencode.nvim.
-- Empty table = use the plugin defaults.
vim.g.opencode_opts = {}

-- Automatically reload files when they are changed outside Neovim.
-- Useful because OpenCode may edit files externally.
vim.o.autoread = true

------------------------------------------------------------
-- OpenCode keymaps
------------------------------------------------------------

-- Ask OpenCode about the current file/selection.
vim.keymap.set({ "n", "x" }, "<leader>oa", function()
	require("opencode").ask("@this: ")
end, { desc = "Ask OpenCode…" })

-- Open OpenCode's selection UI.
vim.keymap.set({ "n", "x" }, "<leader>os", function()
	require("opencode").select()
end, { desc = "Select OpenCode…" })

-- Operator-pending mapping:
-- Example: `goap` sends a paragraph, `goiw` sends inner word, etc.
vim.keymap.set({ "n", "x" }, "go", function()
	return require("opencode").operator("@this ")
end, { desc = "Append range to OpenCode", expr = true })

-- Line shortcut:
-- `goo` sends the current line to OpenCode.
vim.keymap.set("n", "goo", function()
	return require("opencode").operator("@this ") .. "_"
end, { desc = "Append line to OpenCode", expr = true })

------------------------------------------------------------
-- OpenCode session commands
------------------------------------------------------------

-- Start a new OpenCode session.
vim.keymap.set("n", "<leader>on", function()
	require("opencode").command("session.new")
end, { desc = "New OpenCode session" })

-- Select/switch between OpenCode sessions.
vim.keymap.set("n", "<leader>oS", function()
	require("opencode").command("session.select")
end, { desc = "Select OpenCode session" })

-- Interrupt the currently running OpenCode response.
vim.keymap.set("n", "<leader>oi", function()
	require("opencode").command("session.interrupt")
end, { desc = "Interrupt OpenCode" })

------------------------------------------------------------
-- OpenCode window scrolling
------------------------------------------------------------

-- Scroll the OpenCode panel half a page up.
vim.keymap.set("n", "<S-C-u>", function()
	require("opencode").command("session.half.page.up")
end, { desc = "Scroll OpenCode up" })

-- Scroll the OpenCode panel half a page down.
vim.keymap.set("n", "<S-C-d>", function()
	require("opencode").command("session.half.page.down")
end, { desc = "Scroll OpenCode down" })
