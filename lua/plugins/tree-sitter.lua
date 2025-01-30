return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",

	opts = {
		ensure_installed = {
			"vim",
			"lua",

			"regex",
			"markdown",
			"markdown_inline",
			"typst",
			"latex",
			"yaml",

			"vimdoc",
			"query"
		},
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false
		},
	}
}
