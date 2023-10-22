local config = require("nvim-treesitter.configs")

config.setup({
	ensure_installed = {
		"c",
		"vim",
		"lua",
		"html",
		"css",
		"javascript",

		"regex",
		"markdown",
		"bash",
	},
	autotag = {
		enable = true,
		enable_rename = true,
		enable_close = true,
		enable_close_on_slash = true
	}
})


