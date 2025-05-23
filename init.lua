---@type string[] Main runtime files.
_G.BASE_RUNTIME = vim.tbl_filter(function (item)
	return string.match(item, "runtime$") ~= nil;
end, vim.api.nvim_get_runtime_file("", true));

--- Checks if Neovim is within Termux.
---@return boolean
_G.is_within_termux = function ()
	---|fS

	--- $PREFIX may not be set.
	--- $HOME should be set.
	local HOME = vim.fn.getenv("HOME") or "";
	local TERMUX_VERSION = vim.fn.getenv("TERMUX_APP__APP_VERSION_NAME");

	if string.match(HOME, "com%.termux") then
		--- $HOME has `com.termux` in it's
		--- path.
		return true;
	elseif TERMUX_VERSION ~= vim.NIL then
		--- Termux version variable detected.
		return true;
	else
		return false;
	end

	---|fE
end

--- Disables highlight group properties.
---@param ignore string[] | nil
---@param properties table | nil
_G.disable_properties = function (ignore, properties)
	---|fS

	if _G.is_within_termux() == false then
		--- Only run inside Termux.
		return;
	end

	ignore = ignore or {
		"catppuccin-frappe", "catppuccin-latte",
		"catppuccin-mocha", "catppuccin-macchiato"
	};
	properties = properties or {
		cterm = { italic = false },
		italic = false
	};

	local colorscheme = vim.g.colors_name;

	if vim.list_contains(ignore, colorscheme) then
		--- Colorscheme is ignored.
		return;
	end

	--- Checks if given properties exist in a table
	--- or not.
	---@param val table
	---@return table | nil
	local function change_properties (val, tmp_properties)
		tmp_properties = tmp_properties or properties;

		local has_key = false;
		local _o = {};

		for key, value in pairs(val) do
			if type(value) == "table" and tmp_properties[key] then
				local _n = change_properties(value, tmp_properties[key]);

				if _n ~= nil then
					has_key = true;
					_o[key] = _n;
				end
			elseif tmp_properties[key] ~= nil and tmp_properties[key] ~= value then
				has_key = true;
				_o[key] = tmp_properties[key];
			else
				_o[key] = value;
			end
		end

		return has_key == true and _o or nil;
	end

	local groups = vim.fn.getcompletion("", "highlight");

	for _, group in ipairs(groups) do
		local val = vim.api.nvim_get_hl(0, {
			name = group
		});

		if val.link then
			--- Linked group. Do
			--- not modify.
			goto continue;
		end

		local _m = change_properties(val);

		if _m ~= nil then
			--- Only apply changes if
			--- we have modified the value.
			pcall(vim.api.nvim_set_hl, 0, group, _m);
		end

	    ::continue::
	end

	---|fE
end

-- Load the options first;
require("editor.options");
require("editor.keymaps");
require("editor.ts_directives");

-- Hover, Diagnostics & Quickfix should be loaded first.
require("scripts.lsp_hover").setup();
require("scripts.diagnostics").setup();
require("scripts.quickfix").setup();

-- Now, we load the plugins.
require("editor.lazy");

--- Load scripts that rely on plugins.
require("scripts.highlights").setup();
require("scripts.color_sync");

-- Autocmd for the custom dynamic highlight groups.
vim.api.nvim_create_autocmd({
	"VimEnter",
	"ColorScheme"
}, {
	callback = function ()
		_G.disable_properties();
		require("scripts.highlights").setup();
	end
});

