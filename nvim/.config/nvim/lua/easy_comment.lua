return {
	{
		"numToStr/Comment.nvim",
			opts = {
				---LHS of toggle mappings in NORMAL mode
					toggler = {
						line = "<leader>cc",
						block = "<leader>bb",
					},
				---LHS of operator-pending mappings in NORMAL and VISUAL mode
					opleader = {
						line = "<leader>c",
						block = "<leader>b",
					},
				---LHS of extra mappings
					extra = {
						---Add comment on the line above
							above = "<leader>cO",
						---Add comment on the line below
							below = "<leader>co",
						---Add comment at the end of line
							eol = "<leader>cA",
					},
			},
			lazy = false,
	},
}
