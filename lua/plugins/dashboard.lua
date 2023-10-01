local ascii = require("ascii")

require("dashboard").setup({
	theme = "hyper",
	config = {
		header = ascii.get_random("text", "neovim")
	}
})

