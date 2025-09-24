return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	priority = 200,

	branch = "main",

	config = function ()
		--- Gets the path(or URL) for the parser.
		---@param path string
		---@param url string
		---@return string
		local function get_path(path, url)
			---@type table Path stat.
			local stat = vim.uv.fs_stat(vim.fn.stdpath("config") .. path);
			local parsers = require("nvim-treesitter.parsers");

			if type(parsers.get_parser_configs) ~= "function" then
				return url;
			elseif stat and stat.type == "directory" then
				return vim.fn.stdpath("config") .. path;
			else
				return url;
			end
		end

		---|fS "config: Parser info"

		local update_stack = {};

		local function new_parser (name, opts)
			local parsers = require("nvim-treesitter.parsers");

			if type(parsers.get_parser_configs) ~= "function" then
				opts.install_info.path = vim.fn.stdpath("config") .. "/parsers/tree-sitter-" .. name;
				opts.install_info.queries = "queries/";
				opts.install_info.generate = true;

				update_stack[name] = opts;
			else
				require("nvim-treesitter.parsers").get_parser_configs()[name] = opts;
			end
		end

		new_parser("doctext", {
			install_info = {
				url = get_path("/parsers/tree-sitter-doctext", "https://github.com/OXY2DEV/tree-sitter-doctext"),
				files = { "src/parser.c" }
			}
		});

		new_parser("lua_patterns", {
			install_info = {
				url = get_path("/parsers/tree-sitter-lua_patterns", "https://github.com/OXY2DEV/tree-sitter-lua_patterns"),
				files = { "src/parser.c" }
			}
		});

		new_parser("vhs", {
			install_info = {
				url = get_path("/parsers/tree-sitter-vhs", "https://github.com/OXY2DEV/tree-sitter-vhs"),
				files = { "src/parser.c" }
			}
		});

		new_parser("qf", {
			install_info = {
				url = get_path("/parsers/tree-sitter-qf", "https://github.com/OXY2DEV/tree-sitter-qf"),
				files = { "src/parser.c" }
			},
		});

		new_parser("kitty", {
			install_info = {
				url = get_path("/parsers/tree-sitter-kitty", "https://github.com/OXY2DEV/tree-sitter-kitty"),
				files = { "src/parser.c" }
			},
		});

		---@type string[]
		local use_parsers = {
			"vim",
			"lua",

			"vimdoc",
			"luadoc",
			"doctext",

			"lua_patterns",
			"regex",

			"html",
			"markdown",
			"markdown_inline",
			"yaml",

			"query",
			"vhs",
		};

		---|fE

		if require("nvim-treesitter.parsers").get_parser_configs == nil then
			vim.api.nvim_create_autocmd("User", {
				pattern = "TSUpdate",
				callback = function ()
					for k, v in pairs(update_stack) do
						require("nvim-treesitter.parsers")[k] = v;
					end
				end
			});
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
