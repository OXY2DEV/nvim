local MiniMap = require("mini.map")

require("mini.animate").setup({
	cursor = {
		enable = true
	},

	scroll = {
		enable = true
	}
})
require("mini.map").setup({
	symbols = {
		encode = MiniMap.gen_encode_symbols.dot("4x2"),

		scroll_line = "┡",
		scroll_view = "┊"
	},
	window = {
		width = 30,
		focusable = false
	},

	integrations = {
		MiniMap.gen_integration.gitsigns(),
		MiniMap.gen_integration.diagnostic(),
		MiniMap.gen_integration.builtin_search()
	}
})
require("mini.indentscope").setup({
	symbol = "│"
})

MiniMap.gen_integration.gitsigns()

