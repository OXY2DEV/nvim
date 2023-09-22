local config = require("nvim-treesitter.configs")

config.setup({
	ensure_installed = {
		"c",
		"vim",
		"lua",
		"html",
		"css",
		"javascript"
	},
})
