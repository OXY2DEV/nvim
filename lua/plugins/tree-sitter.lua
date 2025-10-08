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
			---|fS

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

			---|fE
		end

		---|fS "config: Parser info"

		local update_stack = {};

		---@class parser_register_opts
		---
		---@field language string Language name.
		---@field parser_name? string Custom name of parser `directory` or `repository`.

		---@param opts parser_register_opts
		local function register_parser (opts)
			---|fS

			local parsers = require("nvim-treesitter.parsers");

			if type(parsers.get_parser_configs) ~= "function" then
				local config = {
					install_info = {
						url = "https://github.com/OXY2DEV/tree-sitter-" .. (opts.parser_name or opts.language),
						path = vim.fn.stdpath("config") .. "/parsers/tree-sitter-" .. (opts.parser_name or opts.language),

						queries = "queries/"
					},
				};

				update_stack[opts.language] = config;
			else
				local config = {
					install_info = {
						url = get_path(
							"https://github.com/OXY2DEV/" .. (opts.parser_name or opts.language),
							vim.fn.stdpath("config") .. "/parsers/tree-sitter-" .. (opts.parser_name or opts.language)
						),

						queries = "queries/"
					},
					filetype = opts.language
				};

				require("nvim-treesitter.parsers").get_parser_configs()[opts.language] = config;
			end

			if opts.parser_name and opts.parser_name ~= opts.language then
				vim.treesitter.language.register(opts.parser_name, opts.language);
			end

			---|fE
		end

		register_parser({ language = "doctext" });
		register_parser({ language = "comment", parser_name = "doctext" });
		register_parser({ language = "lua_patterns" });
		register_parser({ language = "vhs" });
		register_parser({ language = "qf" });
		register_parser({ language = "kitty" });

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
