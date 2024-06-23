return {
	"shellRaining/hlchunk.nvim",
	event = { "BufReadPre", "BufNewFile" },

	config = function ()
		require("hlchunk").setup({
			exclude_filetypes = {
				help = true,
			},

			chunk = {
				enable = true,
				style = {
					{ fg = "#89B5FA" },
					{ fg = "#F38BA8" }
				},
				chars = {
				    horizontal_line = "─",
				    vertical_line = "│",
				    left_top = "╭",
				    left_bottom = "╰",
				    right_arrow = "┤",
				},

				duration = 200,
				delay = 300,
			},

			indent = {
				enable = true,
				style = {
					{ fg = "#585a6f" },
					{ fg = "#4e5064" },
					{ fg = "#444659" },
					{ fg = "#3a3c4e" },
					{ fg = "#313244" }
				}
			},

			line_num = { enable = false }
		});
	end
}
