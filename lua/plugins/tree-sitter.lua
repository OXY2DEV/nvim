return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	priority = 200,

	--- `opts` doesn't work for this plugin
	opts = {},

	config = function ()
		--- Gets the path(or URL) for the parser.
		---@param path string
		---@param url string
		---@return string
		local function get_path(path, url)
			---@type table Path stat.
			local stat = vim.uv.fs_stat(vim.fn.stdpath("config") .. path);

			if stat and stat.type == "directory" then
				return vim.fn.stdpath("config") .. path;
			else
				return url;
			end
		end

		local parser_configs = require("nvim-treesitter.parsers").get_parser_configs();

		parser_configs.lua_patterns = {
			install_info = {
				url = get_path("/parsers/tree-sitter-lua_patterns", "https://github.com/OXY2DEV/tree-sitter-lua_patterns.git"),
				files = { "src/parser.c" }
			}
		};

		parser_configs.vhs = {
			install_info = {
				url = get_path("/parsers/tree-sitter-vhs", "https://github.com/OXY2DEV/tree-sitter-vhs.git"),
				files = { "src/parser.c" }
			}
		};

		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"vim",
				"lua",

				"regex",
				"html",
				"markdown",
				"markdown_inline",
				"yaml",

				"vimdoc",
				"query",

				"lua_patterns",
				"vhs",

				"python"
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false
			},
		});
	end
}
