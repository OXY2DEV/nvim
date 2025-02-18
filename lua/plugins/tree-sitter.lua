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
	},

	config = function ()
		local parser_configs = require("nvim-treesitter.parsers").get_parser_configs();

		parser_configs.lua_patterns = {
			install_info = {
				url = vim.fn.stdpath("config") .. "/parsers/tree-sitter-lua_patterns",
				files = { "src/parser.c" }
			}
		};
	end
}
