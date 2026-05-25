return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					path_display = { "truncate " },
					mappings = {
						i = {
							["<C-k>"] = actions.move_selection_previous, -- move to prev result
							["<C-j>"] = actions.move_selection_next, -- move to next result
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
						},
					},
				},
			})

			telescope.load_extension("fzf")

			-- set keymaps
			local keymap = vim.keymap -- for conciseness

			keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
			keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
			keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
			keymap.set("n", "<leader>fs", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
			keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Fuzzy find open buffers" })

			-- keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
			-- keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
			-- keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
			-- keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
			-- keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
			--
			--
			-- -- It's also possible to pass additional configuration options.
			-- --  See `:help telescope.builtin.live_grep()` for information about particular keys
			-- vim.keymap.set('n', '<leader>s/', function()
			-- 	builtin.live_grep {
			-- 		grep_open_files = true,
			-- 		prompt_title = 'Live Grep in Open Files',
			-- 	}
			-- end, { desc = '[S]earch [/] in Open Files' })
			--
			-- -- Shortcut for searching your Neovim configuration files
			-- vim.keymap.set('n', '<leader>sn', function()
			-- 	builtin.find_files { cwd = vim.fn.stdpath 'config' }
			-- end, { desc = '[S]earch [N]eovim files' })

		end,










	},
}
