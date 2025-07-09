---@diagnostic disable: undefined-field

--- Relative path to absolute path.
---@param path string
---@return string
local function to_absolute(path)
	return vim.fn.fnamemodify(path, ":p")
end

--- Gets current config
---@return table
local function get_config ()
	---|fS

	--- Config file.
	local file = io.open(to_absolute("~/.config/tree-sitter/config.json"), "r");

	if not file then
		-- No config file.
		return {};
	end

	---@type string Current config.
	local content = file:read("*a");
	file:close();

	return vim.json.decode(content) or {};

	---|fE
end

------------------------------------------------------------------------------

--- Regenerates tree-sitter config.
local regen = {};

---@type table Default config.
regen.config = {
	["parser-directories"] = {
		to_absolute("~/.config/nvim/parsers/"),
		to_absolute("~/github"),
		to_absolute("~/src"),
		to_absolute("~/source"),
		to_absolute("~/projects"),
		to_absolute("~/dev"),
		to_absolute("~/git")
	},
	theme = {},
};

regen.regenerate_ts_config = function (user_config)
	--- New config.
	local config = {
		["parser-directories"] = {},
		theme = {}
	};

	--- Current configuration.
	local current = get_config();
	local not_in_config = {};

	for _, path in ipairs(current["parser-directories"] or {}) do
		if vim.list_contains(config["parser-directories"] or {}, path) == false then
			-- Add non-existing paths.
			table.insert(not_in_config, path);
		end
	end

	-- Note: User paths have higher precedence.
	config["parser-directories"] = vim.list_extend(not_in_config, config["parser-directories"]);

	-- User config takes highest precedence.
	config = vim.tbl_extend("force", config, user_config or {});

	---@type string[] Tree-sitter highlight group names.
	local groups = vim.fn.getcompletion("@", "highlight");

	for _, group in ipairs(groups) do
		local value = vim.api.nvim_get_hl(0, { name = group, link = false });

		---@type string Tree-sitter theme group name.
		local ts_group = string.match(group, "^@(.+)$");

		config.theme[ts_group] = {
			-- Use hexadecimal values.
			color = value.fg and string.format("#%06x", value.fg) or nil,

			italic = value.italic,
			bold = value.bold,
			underline = value.underline,
		};
	end

	local has_dir = vim.uv.fs_stat(to_absolute("~/.config/tree-sitter/"));

	if not has_dir then
		-- Create the `~/.config/tree-eitter/` directory.
		vim.uv.fs_mkdir(to_absolute("~/.config/tree-sitter/"), 493);
	end

	---@type string JSON
	local JSON = vim.json.encode(config);
	JSON = vim.fn.system("jq ", JSON);

	local file = io.open(to_absolute("~/.config/tree-sitter/config.json"), "w");

	if not file then
		return;
	end

	file:write(JSON);
	file:close();
end

regen.setup = function (user_config)
	if type(user_config) == "table" then
		regen.config = user_config;
	end

	vim.api.nvim_create_user_command("TSRegen", function ()
		regen.regenerate_ts_config(regen.config);
	end, {
		desc = "Regenerate tree-sitter config"
	});
end

return regen;
