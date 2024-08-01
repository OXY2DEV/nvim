---+ name: Nvim-treesitter; |ts| ##plugin##
---
---_

return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",

	config = function ()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"c",
				"vim",
				"lua",
				"html",
				"css",
				"javascript",

				"regex",
				"markdown",
				"markdown_inline",
				"bash",

				"vimdoc",
				"query"
			},

		    highlight = {
				enable = true,
				additional_vim_regex_highlighting = false
			},
			--indent = {
			--	enable = false
			--}
		});
	end
}
