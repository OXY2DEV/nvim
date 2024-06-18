local colors = {};
local utils = require("bars/utils");

---@class hl_opts Table that turns into a highlight group when used in "nvim_set_hl()"
---@field fg (string | number)? Foreground color
---@field bg (string | number)? Background color
---@field sp (string | number)?
---@field blend number? Opacity
---@field bold boolean? Makes the text bold
---@field italic boolean? Makes the text italic
---@field underline boolean? Adds underline to the text
---@field undercurl boolean? Adds a undercurl to the text, uses an underline when not supported by the terminal
---@field strikethrough boolean? Adds a strikethrough to the text
---@field link string? Highlight group to link to

---@class color Table containing configuration for highlight groups
---@field type string? Determines the type of color a table represents
---@field group_name string? Name of the highlight group, a "Bars_" prefix is added to the name
---@field value hl_opts? The settings for the specified highlight group
---@field name_prefix string? Prefix for the gradient, a "Bars_" prefix is added before the name and a number is added after it. Always starts from 0
---@field from string? The start color for the gradient
---@field to string? The stop color for the gradient
---@field steps number? The number of steps the gradient has

---@class color_user_config Configuration table structure for the setup function
---@field default color[] Default configuration table
---@field [string] color[] Various colorscheme specific configurations

---@type hl_opts[] Cached highlight group
colors.hls = {};

---@type table<string, color[]> Default colors
colors.default_config = {
	default = {
		-- For the statuscolumn
		{
			type = "gradient",

			name_prefix = "glow_",
			from = "#6583b6", to = "#585B70",
			steps = 8
		},
		{
			type = "gradient",

			name_prefix = "glow_num_",
			from = "#89B4FA", to = "#585B70",
			steps = 10
		},
		{
			type = "normal",
			group_name = "scope",
			value = { fg = "#45475A" }
		},

		-- For the statusline
		{
			type = "normal",
			group_name = "mode_normal",
			value = { fg = "#89B4FA", bg = "#313244" }
		},
		{
			type = "normal",
			group_name = "mode_normal_alt",
			value = { bg = "#89B4FA", fg = "#1E1E2E" }
		},

		{
			type = "normal",
			group_name = "mode_insert",
			value = { fg = "#BAC2DE", bg = "#313244" }
		},
		{
			type = "normal",
			group_name = "mode_insert_alt",
			value = { bg = "#BAC2DE", fg = "#1E1E2E" }
		},

		{
			type = "normal",
			group_name = "mode_visual",
			value = { fg = "#CBA6F7", bg = "#313244" }
		},
		{
			type = "normal",
			group_name = "mode_visual_alt",
			value = { bg = "#CBA6F7", fg = "#1E1E2E" }
		},
		{
			type = "normal",
			group_name = "mode_visual_block",
			value = { fg = "#EBA0AC", bg = "#313244" }
		},
		{
			type = "normal",
			group_name = "mode_visual_block_alt",
			value = { bg = "#EBA0AC", fg = "#1E1E2E" }
		},
		{
			type = "normal",
			group_name = "mode_visual_line",
			value = { fg = "#FAB387", bg = "#313244" }
		},
		{
			type = "normal",
			group_name = "mode_visual_line_alt",
			value = { bg = "#FAB387", fg = "#1E1E2E" }
		},

		{
			type = "normal",
			group_name = "mode_cmd",
			value = { fg = "#A6E3A1", bg = "#313244" }
		},
		{
			type = "normal",
			group_name = "mode_cmd_alt",
			value = { bg = "#A6E3A1", fg = "#1E1E2E" }
		},

		{
			type = "normal",
			group_name = "buf_name",
			value = { bg = "#313244" }
		},
		{
			type = "normal",
			group_name = "buf_name_alt",
			value = { fg = "#313244", bg = "#1E1E2E" }
		},

		{
			type = "normal",
			group_name = "cursor_position",
			value = { bg = "#CBA6F7", fg = "#1E1E2E" }
		},
		{
			type = "normal",
			group_name = "cursor_position_alt",
			value = { fg = "#CBA6F7", bg = "#1E1E2E" }
		},

		-- For the tabline
		{
			type = "normal",
			group_name = "tabline_tab_active",
			value = { fg = "#B4BEFE" }
		},
		{
			type = "normal",
			group_name = "tabline_tab_active_alt",
			value = { bg = "#B4BEFE", fg = "#1E1E2E" }
		},

		{
			type = "normal",
			group_name = "tabline_tab_inactive",
			value = { fg = "#313244" }
		},
		{
			type = "normal",
			group_name = "tabline_tab_inactive_alt",
			value = { bg = "#313244" }
		},

		{
			type = "normal",
			group_name = "tabline_buf_active",
			value = { fg = "#45475A" }
		},
		{
			type = "normal",
			group_name = "tabline_buf_active_alt",
			value = { bg = "#45475A" }
		},

		{
			type = "normal",
			group_name = "tabline_buf_inactive",
			value = { fg = "#313244" }
		},
		{
			type = "normal",
			group_name = "tabline_buf_inactive_alt",
			value = { bg = "#313244" }
		},
	};
};

--- Setup function for the colors
---@param color_config color_user_config? User configuration table
colors.setup = function (color_config)
	if color_config == nil then
		return;
	end

	---@type color_user_config
	local use_config = vim.tbl_deep_extend("force", colors.default_config, color_config);

	for colorscheme, values in pairs(use_config) do
		for _, color in ipairs(values) do
			if color.type == "normal" or color.type == nil then
				if vim.g.colors_name == colorscheme then
					vim.api.nvim_set_hl(0, "Bars_" .. color.group_name, color.value);
				elseif colorscheme == "default" then
					vim.api.nvim_set_hl(0, "Bars_" .. color.group_name, color.value);
				end

				if colors.hls["Bars_" .. color.group_name] == nil then
					colors.hls["Bars_" .. color.group_name] = {};
				end

				colors.hls["Bars_" .. color.group_name][colorscheme] = color.value;
			elseif color.type == "gradient" then
				local from = type(color.from) == "string" and utils.hexToTable(color.from) or color.from;
				local to = type(color.to) == "string" and utils.hexToTable(color.to) or color.to;

				for gr = 0, color.steps - 1 do
					local _r = utils.ease(color.ease or "linear", from.r, to.r, gr * (1 / (color.steps - 1)));
					local _g = utils.ease(color.ease or "linear", from.g, to.g, gr * (1 / (color.steps - 1)));
					local _b = utils.ease(color.ease or "linear", from.b, to.b, gr * (1 / (color.steps - 1)));

					local val = utils.toStr({ r = _r, g = _g, b = _b });

					if color.mode == "fg" or color.mode == nil then
						if vim.g.colors_name == colorscheme then
							vim.api.nvim_set_hl(0, "Bars_" .. color.name_prefix .. gr, { fg = val });
						elseif colorscheme == "default" then
							vim.api.nvim_set_hl(0, "Bars_" .. color.name_prefix .. gr, { fg = val });
						end

						if colors.hls["Bars_" .. color.name_prefix .. gr] == nil then
							colors.hls["Bars_" .. color.name_prefix .. gr] = {};
						end

						colors.hls["Bars_" .. color.name_prefix .. gr][colorscheme] = { fg = val };
					elseif color.mode == "bg" then
						if vim.g.colors_name == colorscheme then
							vim.api.nvim_set_hl(0, "Bars_" .. color.name_prefix .. gr, { bg = val });
						elseif colorscheme == "default" then
							vim.api.nvim_set_hl(0, "Bars_" .. color.name_prefix .. gr, { bg = val });
						end

						if colors.hls["Bars_" .. color.name_prefix .. gr] == nil then
							colors.hls["Bars_" .. color.name_prefix .. gr] = {};
						end

						colors.hls["Bars_" .. color.name_prefix .. gr][colorscheme] = { bg = val };
					elseif color.mode == "both" then
						if vim.g.colors_name == colorscheme then
							vim.api.nvim_set_hl(0, "Bars_" .. color.name_prefix .. gr, { fg = val, bg = val });
						elseif colorscheme == "default" then
							vim.api.nvim_set_hl(0, "Bars_" .. color.name_prefix .. gr, { fg = val, bg = val });
						end

						if colors.hls["Bars_" .. color.name_prefix .. gr] == nil then
							colors.hls["Bars_" .. color.name_prefix .. gr] = {};
						end

						colors.hls["Bars_" .. color.name_prefix .. gr][colorscheme] = { fg = val, bg = val };
					end
				end
			end
		end
	end

	vim.api.nvim_create_autocmd({ "ColorScheme" }, {
		pattern = "*",
		callback = function ()
			for name, value in pairs(colors.hls) do
				if use_config[vim.g.colors_name] ~= nil then
					vim.api.nvim_set_hl(0, name, value[vim.g.colors_name]);
				else
					vim.api.nvim_set_hl(0, name, value["default"]);
				end
			end
		end
	});
end

return colors;
