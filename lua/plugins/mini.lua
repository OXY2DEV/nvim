local MiniMap = require("mini.map")

require("mini.animate").setup()
require("mini.map").setup({
	symbols = {
		encode = MiniMap.gen_encode_symbols.dot("4x2"),

		scroll_line = "┡",
		scroll_view = "┊"
	},
	window = {
		width = 30
	}
})
require("mini.indentscope").setup()

