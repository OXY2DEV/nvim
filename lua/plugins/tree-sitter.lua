return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",

	--- `opts` doesn't work for this plugin
	opts = {},

	config = function ()
		local parser_configs = require("nvim-treesitter.parsers").get_parser_configs();

		parser_configs.lua_patterns = {
			install_info = {
				url = vim.fn.stdpath("config") .. "/parsers/tree-sitter-lua_patterns",
				files = { "src/parser.c" }
			}
		};

		require("nvim-treesitter.configs").setup({
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
		});
	end
}
