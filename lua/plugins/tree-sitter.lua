local update = {};

---@class treesitter.parser.opts
---
---@field name? string
---@field owner? string
---
---@field path? string
---@field url? string
---
---@field maintainers? string[]
---@field requires? string[]
---
---@field revision? string
---@field branch? string
---
---@field location? string
---@field queries? string
---
---@field register? boolean
---@field filetype? string

---@param name string
---@param owner string
---@return string
---@return "path" | "url"
local function path_or_url(name, owner)
	---|fS

	local path = vim.fs.joinpath(
		vim.fn.stdpath("config"),
		"parsers",
		string.format("tree-sitter-%s", name)
	);
	local url = string.format(
		"https://github.com/%s/tree-sitter-%s",
		owner or "OXY2DEV",
		name
	);

	---@diagnostic disable-next-line: undefined-field
	local path_stat = vim.uv.fs_stat(path);

	if path_stat and path_stat.type == "directory" then
		return path, "path";
	else
		return url, "url";
	end

	---|fE
end

---@param language string
---@param opts treesitter.parser.opts
local function new_parser(language, opts)
	---|fS

	local parsers = require("nvim-treesitter.parsers");

	local path, path_type = path_or_url(
		opts.name or language,
		opts.owner
	);

	if type(parsers.get_parser_configs) ~= "function" then
		-- `main` branch
		update[language] = {
			install_info = {
				url = path_type == "url" and path or nil,
				path = path_type == "path" and path or nil,

				requires = opts.requires,

				revision = opts.revision,
				location = opts.location,
				queries = opts.queries or "queries/",
			},
		};
	else
		require("nvim-treesitter.parsers").get_parser_configs()[language] = {
			install_info = {
				url = path,

				location = opts.location,
				queries = opts.queries or "queries/"
			},
			filetype = language
		};
	end

	if opts.register then
		vim.treesitter.language.register(opts.filetype, language);
	end

	---|fE
end


return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	priority = 200,

	branch = "main",

	config = function ()
		---|fS "config: Parser info"

		new_parser("comment", {});
		new_parser("lua_patterns", {});
		new_parser("vhs", {});
		new_parser("qf", {});
		new_parser("kitty", {});

		new_parser("asciidoc", {
			owner = "cathaysia",
			requires = { "asciidox_inline" },
		});
		new_parser("asciidoc_inline", {
			owner = "cathaysia",
		});

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
					for k, v in pairs(update) do
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
