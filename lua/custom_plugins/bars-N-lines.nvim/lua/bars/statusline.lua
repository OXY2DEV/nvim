local statusline = {};
local devicons = require("nvim-web-devicons");
--- Search for key in a table, return the default value if not found
---@param key string The key to search
---@param current_config table Table where to search for the key
---@param default_config table Table that contains the default value
---@return any
local getDefault = function (key, current_config, default_config)
	if current_config ~= nil and current_config[key] ~= nil then
		return current_config[key];
	end

	return default_config[key];
end

--- Color the provided text
---@param text string? The text to color
---@param hl string? The highlight group to use
---@return string
local colorizer = function (text, hl)
	if text == nil then
		return ""
	end

	if hl == nil then
		return text;
	end

	return "%#" .. hl .. "#" .. text;
end

---@type table[] User configuration tables for the various windows
statusline.window_config = {};

--- Initializes the statusline for the specified window
---@param window number The window ID
---@param user_config primary_user_config? The statusline configuration
statusline.init = function (window, user_config)
	if user_config == nil then
		statusline.window_config[window] = {};
	elseif user_config.enabled == false then
		statusline.window_config[window] = {};
	else
		statusline.window_config[window] = user_config.options;

		if user_config.options.set_defaults == true then
			vim.o.cmdheight = 1;
			vim.o.laststatus = 2;
		end
	end

	vim.wo[window].statusline = "%!v:lua.require('bars/statusline').generateStatusline(" .. window .. ")";
end

--- Shows the current mode with icons
---@param mode_config mode_component User configuration for the component
---@return string
statusline.mode = function (mode_config)
	local mode = vim.api.nvim_get_mode().mode;

	---@type mode_component Table containing a merge of default options(ones that aren't provided) and user options(ones that are provided)
	local merged_config = vim.tbl_deep_extend("keep", mode_config or {}, {
		default = {
			icon = " ", icon_hl = nil,
			text = mode, text_hl = nil,

			corner_left = "", corner_left_hl = "Bars_mode_normal_alt",
			corner_right = "", corner_right_hl = "Bars_mode_normal",

			padding_left = " ", padding_left_hl = nil,
			padding_right = " ", padding_right_hl = nil,

			bg = "Bars_mode_normal_alt"
		},
		modes = {
			["n"] = { icon = " ", text = "Normal" },
			["i"] = { icon = " ", text = "Insert", bg = "Bars_mode_insert_alt", corner_left_hl = "Bars_mode_insert_alt", corner_right_hl = "Bars_mode_insert" },

			["v"] = { icon = "󰸿 ", text = "Visual", bg = "Bars_mode_visual_alt", corner_left_hl = "Bars_mode_visual_alt", corner_right_hl = "Bars_mode_visual" },
			[""] = { icon = "󰹀 ", text = "Visual", bg = "Bars_mode_visual_block_alt", corner_left_hl = "Bars_mode_visual_block_alt", corner_right_hl = "Bars_mode_visual_block" },
			["V"] = { icon = "󰸽 ", text = "Visual", bg = "Bars_mode_visual_line_alt", corner_left_hl = "Bars_mode_visual_line_alt", corner_right_hl = "Bars_mode_visual_line" },

			["c"] = { icon = " ", text = "Command", bg = "Bars_mode_cmd_alt", corner_left_hl = "Bars_mode_cmd_alt", corner_right_hl = "Bars_mode_cmd" },
		}
	});

	return table.concat({
		colorizer("", getDefault("bg", merged_config.modes[mode], merged_config.default)),
		colorizer(getDefault("corner_left", merged_config.modes[mode], merged_config.default), getDefault("corner_left_hl", merged_config.modes[mode], merged_config.default)),
		colorizer(getDefault("padding_left", merged_config.modes[mode], merged_config.default), getDefault("padding_left_hl", merged_config.modes[mode], merged_config.default)),
		colorizer(getDefault("icon", merged_config.modes[mode], merged_config.default), getDefault("icon_hl", merged_config.modes[mode], merged_config.default)),
		colorizer(getDefault("text", merged_config.modes[mode], merged_config.default), getDefault("text_hl", merged_config.modes[mode], merged_config.default)),
		colorizer(getDefault("padding_right", merged_config.modes[mode], merged_config.default), getDefault("padding_right_hl", merged_config.modes[mode], merged_config.default)),
		colorizer(getDefault("corner_right", merged_config.modes[mode], merged_config.default), getDefault("corner_right_hl", merged_config.modes[mode], merged_config.default)),
	})
end

--- Creates a component to show the buffer's file name
---@param window number Window ID
---@param buf_name_config component Configuration table for the component
---@return string
statusline.buf_name = function (window, buf_name_config)
	local buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(window)), ":t");
	local icon, hl = devicons.get_icon(buffer_name)

	---@type component Table containing a merge of default options(ones that aren't provided) and user options(ones that are provided)
	local merged_config = vim.tbl_deep_extend("keep", buf_name_config or {}, {
		corner_left = "", corner_left_hl = nil,
		corner_right = "", corner_right_hl = "Bars_buf_name_alt",

		padding_left = " ", padding_left_hl = nil,
		padding_right = " ", padding_right_hl = nil,

		bg = "Bars_buf_name",
	});

	return table.concat({
		colorizer("", merged_config.bg),
		colorizer(merged_config.corner_left, merged_config.corner_left_hl),
		colorizer(merged_config.padding_left, merged_config.padding_left_hl),
		icon or "",
		buffer_name == "" and "" or " ",
		buffer_name == "" and "No name" or buffer_name,
		colorizer(merged_config.padding_right, merged_config.padding_right_hl),
		colorizer(merged_config.corner_right, merged_config.corner_right_hl),
	});
end

--- Adds padding between components, optionally allows setting the highlight group for it
---@param gap_config { hl: string? } Configuration table for the component
---@return string
statusline.gap = function (gap_config)
	local _o = "";

	if gap_config ~= nil and gap_config.hl ~= nil then
		_o = _o .. "%#" .. gap_config.hl .. "#";
	end

	_o = _o .. "%=";

	return _o;
end

--- Shows the current cursor position, optionally allows custom text to be shown
---@param position_config component_type_2 User configuration table for the component
---@return string
statusline.cursor_position = function (position_config)
	---@type component_type_2 Table containing a merge of default options(ones that aren't provided) and user options(ones that are provided)
	local merged_config = vim.tbl_deep_extend("keep", position_config or {}, {
		corner_left = "", corner_left_hl = "Bars_cursor_position_alt",
		corner_right = "", corner_right_hl = nil,

		padding_left = " ", padding_left_hl = "Bars_cursor_position",
		padding_right = " ", padding_right_hl = nil,

		segmant_left = "%l", segmant_left_hl = nil,
		segmant_right = "%c", segmant_right_hl = nil,

		separator = "  ", separator_hl = nil,
		icon = "  ", icon_hl = nil,

		bg = "Bars_cursor_position"
	});

	return table.concat({
		colorizer("", merged_config.bg),
		colorizer(merged_config.corner_left, merged_config.corner_left_hl),
		colorizer(merged_config.padding_left, merged_config.padding_left_hl),
		colorizer(merged_config.icon, merged_config.icon_hl),
		colorizer(merged_config.segmant_left, merged_config.segmant_left_hl),
		colorizer(merged_config.separator, merged_config.separator_hl),
		colorizer(merged_config.segmant_right, merged_config.segmant_right_hl),
		colorizer(merged_config.padding_right, merged_config.padding_right_hl),
		colorizer(merged_config.corner_right, merged_config.corner_right_hl),
	})
end

--- Function to return the statusline for the specified window
---@param win number Window ID
---@return string
statusline.generateStatusline = function (win)
	local _output = "";
	local loaded_config = statusline.window_config[win];

	-- Current window is one of the windows to skip
	if loaded_config == nil then
		return _output;
	end

	if loaded_config.default_hl ~= nil and loaded_config.default_hl ~= "" then
		_output = "%#" .. loaded_config.default_hl .. "#";
	end


	for _, component in ipairs(loaded_config.components or {}) do
		if component.type == "mode" then
			_output = _output .. statusline.mode(component);
		elseif component.type == "buf_name" then
			_output = _output .. statusline.buf_name(win, component);
		elseif component.type == "gap" then
			_output = _output .. statusline.gap(component);
		elseif component.type == "cursor_position" then
			_output = _output .. statusline.cursor_position(component);
		end
	end

	return _output;
end

return statusline;
