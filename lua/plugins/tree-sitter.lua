return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	priority = 200,

	branch = "main",

	config = function ()
		--- Gets the path(or URL) for the parser.
		---@param path string
		---@param url string
		---@return string, "path" | "url"
		local function get_path(path, url)
			---|fS

			---@type table Path stat.
			local stat = vim.uv.fs_stat(vim.fn.stdpath("config") .. path);
			local parsers = require("nvim-treesitter.parsers");

			if stat and stat.type == "directory" then
				return vim.fn.stdpath("config") .. path, "path";
			elseif type(parsers.get_parser_configs) ~= "function" then
				return url, "url";
			else
				return url, "url";
			end

			---|fE
		end

		---|fS "config: Parser info"

		local update_stack = {};
		local disable = {};

		---@class parser_register_opts
		---
		---@field language string Language name.
		---@field parser_name? string Custom name of parser `directory` or `repository`.
		---
		---@field url? string Custom URL for the parser.
		---@field path? string Custom path for the parser.
		---@field location? string Custom parser sub-directory.
		---@field requires? string[] Parser dependencies.
		---@field queries? string Query path.
		---
		---@field disable? boolean When `true`, gets rid of the parser config.

		---@param opts parser_register_opts
		local function register_parser (opts)
			---|fS

			local parsers = require("nvim-treesitter.parsers");
			local path, _type = get_path(
				opts.path or ( vim.fn.stdpath("config") .. "/parsers/tree-sitter-" .. (opts.parser_name or opts.language) ),
				opts.url or ( "https://github.com/OXY2DEV/tree-sitter-" .. (opts.parser_name or opts.language) )
			);

			if type(parsers.get_parser_configs) ~= "function" then
				local config = {
					install_info = {
						url = _type == "url" and path or nil,
						path = _type == "path" and path or nil,

						revision = "v0.6.0",
						location = opts.location,
						queries = opts.queries,
					},
				};

				if opts.disable then
					table.insert(disable, opts.language);
				else
					update_stack[opts.language] = config;
				end
			else
				local config = {
					install_info = {
						url = path,

						location = opts.location,
						queries = "queries/"
					},
					filetype = opts.language
				};

				if opts.disable then
					require("nvim-treesitter.parsers").get_parser_configs()[opts.language] = nil;
				else
					require("nvim-treesitter.parsers").get_parser_configs()[opts.language] = config;
				end
			end

			if opts.parser_name and opts.parser_name ~= opts.language then
				vim.treesitter.language.register(opts.parser_name, opts.language);
			end

			---|fE
		end

		register_parser({
			language = "asciidoc_inline",

			url = "https://github.com/cathaysia/tree-sitter-asciidoc",
			location = "tree-sitter-asciidoc_inline",

			queries = "tree-sitter-asciidoc_inline/queries",
		});
		register_parser({
			language = "asciidoc",

			url = "https://github.com/cathaysia/tree-sitter-asciidoc",
			location = "tree-sitter-asciidoc",

			queries = "tree-sitter-asciidoc/queries",
			requires = { "asciidoc_inline" }
		});
		register_parser({ language = "comment" });
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
			"comment",

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

					for _, lang in ipairs(disable) do
						require("nvim-treesitter.parsers")[lang] = nil;
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
