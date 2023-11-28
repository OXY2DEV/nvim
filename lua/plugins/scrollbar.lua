require("scrollbar").setup({
	--set_highlights = false,
	handle = {
		text = " ",
		color = "#45475a"
	},
	marks = {
		Cursor = {
			text = "▃",
			color = "#585b70"
		},


		Search = {
			text = {
				"━", "─"
			},
			color = "#94e2d5"
		},
		Error = {
			text = {
				"─"
			},

			color = "#f38ba8"
		},
		Warn = {
			text = {
				"─"
			},

			color = "#fab387"
		},
		Info = {
			text = {
				"~"
			},

			color = "#b4befe"
		},
		Hint = {
			text = {
				"━"
			},

			color = "#a6e3a1"
		},

		Misc = {
			text = {
				"?"
			},

			color = "#f5e0dc"
		}
	},

	autocmd = {
		render = {
			"BufWinEnter",
      "TabEnter",
      "TermEnter",
      "WinEnter",
      "CmdwinLeave",
      "TextChanged",
      "VimResized",
		}
	}
})
require("scrollbar.handlers.search").setup()
