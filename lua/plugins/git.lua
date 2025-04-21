return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add          = { text = "┃" },
				change       = { text = "┃" },
				delete       = { text = "_" },
				topdelete    = { text = "‾" },
				changedelete = { text = "~" },
				untracked    = { text = "┆" },
			},
			signs_staged = {
				add          = { text = "┃" },
				change       = { text = "┃" },
				delete       = { text = "_" },
				topdelete    = { text = "‾" },
				changedelete = { text = "~" },
				untracked    = { text = "┆" },
			},
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text_pos = "right_align",
			},
			current_line_blame_formatter = " <author>, 󰔚 <author_time:%R> |  <summary>",
			update_debounce = 200,
		}
	}
};
