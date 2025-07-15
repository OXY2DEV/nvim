return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	priority = 200,

	-- branch = "main",

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

		local parsers = require("nvim-treesitter.parsers");
		local is_on_main = type(parsers.get_parser_configs) ~= "function";

		local parser_configs = parsers.get_parser_configs and parsers.get_parser_configs() or parsers;

		parser_configs.doctext = {
			install_info = {
				url = get_path("/parsers/tree-sitter-doctext", "https://github.com/OXY2DEV/tree-sitter-doctext.git"),
				files = { "src/parser.c" }
			}
		};

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

		parser_configs.qf = {
			install_info = {
				url = get_path("/parsers/tree-sitter-qf", "https://github.com/OXY2DEV/tree-sitter-qf.git"),
				files = { "src/parser.c" }
			},
			filetype = "qf"
		};

		local use_parsers = {
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
		};

		if is_on_main then
			require("nvim-treesitter").install(use_parsers);

			vim.api.nvim_create_autocmd("Filetype", {
				callback = function ()
					pcall(vim.treesitter.start);
				end
			});
		else
			require("nvim-treesitter.configs").setup({
				ensure_installed = use_parsers,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false
				},
			});
		end
	end
}
