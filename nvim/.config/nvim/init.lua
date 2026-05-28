------------------------------------------------------------
require("options")

vim.g.mapleader = " " --Change the leader key (default is \)

------------------------------------------------------------
--Add the lazy nvim plugin manager :

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.fn.isdirectory(lazypath) == 0 then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
--Add the plugins :
require("lazy").setup({

	require("color_scheme"),
	require("file_tree"),
	'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
	require("git_stuff"),
	require("keymaps_infos"),
	require("treesitter_stuff"),
	require("telescope_stuff"),
	require("autocompletion"),
	require("codium_ai"),
	require("easy_comment"),
	'tpope/vim-surround',
	require("bar_line"),
	require("lsp_server_stuff"),
	require("chatGPT"),
})

------------------------------------------------------------

