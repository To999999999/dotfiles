------------------------------------------------------------
-- nvim-tree
------------------------------------------------------------

-- Disable netrw.
-- nvim-tree recommends disabling it completely since it replaces it.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Enable true-color support.
vim.opt.termguicolors = true

-- Setup nvim-tree with default settings.
require("nvim-tree").setup()

------------------------------------------------------------
-- nvim-tree keymaps
------------------------------------------------------------

-- Toggle the file explorer.
vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", {
	desc = "Toggle file explorer",
})

-- Open the explorer and focus the current file.
vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", {
	desc = "Toggle file explorer on current file",
})

-- Collapse all expanded folders.
vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", {
	desc = "Collapse file explorer",
})

-- Refresh the tree.
vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", {
	desc = "Refresh file explorer",
})

------------------------------------------------------------
-- gx.nvim
------------------------------------------------------------

-- Disable netrw's built-in gx mapping.
-- gx.nvim provides a much more capable replacement.
vim.g.netrw_nogx = 1

-- Setup gx.nvim with default settings.
require("gx").setup()

------------------------------------------------------------
-- gx.nvim keymaps
------------------------------------------------------------

-- Open the URL or file under the cursor.
vim.keymap.set({ "n", "x" }, "gx", "<cmd>Browse<CR>", {
	desc = "Browse link",
})
