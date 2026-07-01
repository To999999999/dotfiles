-- Esc exits Terminal mode and returns to Normal mode.
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true })
-- Esc clears search highlighting (:nohlsearch).
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Create and navigate tabs with Ctrl-w bindings. (similar to tmux)
vim.keymap.set("n", "<C-w>t", "<cmd>tabnew<CR>", {
	desc = "New tab",
})
vim.keymap.set("n", "<C-w>n", "<cmd>tabnext<CR>", {
	desc = "Next tab",
})
vim.keymap.set("n", "<C-w>p", "<cmd>tabprevious<CR>", {
	desc = "Previous tab",
})
for i = 1, 9 do
	vim.keymap.set("n", "<C-w>" .. i, i .. "gt", {
		desc = "Go to tab " .. i,
	})
end
