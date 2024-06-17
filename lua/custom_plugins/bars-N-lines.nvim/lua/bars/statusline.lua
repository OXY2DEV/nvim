local statusline = {};
local devicons = require("nvim-web-devicons");

local getDefault = function (key, current_config, default_config)
	if current_config ~= nil and current_config[key] ~= nil then
		return current_config[key];
	end

	return default_config[key];
end

local colorizer = function (text, hl)
	if text == nil then
		return ""
	end

	if hl == nil then
		return text;
	end

	return "%#" .. hl .. "#" .. text;
end

statusline.window_config = {};

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

statusline.mode = function (mode_config)
	local mode = vim.api.nvim_get_mode().mode;
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

statusline.buf_name = function (window, buf_name_config)
	local buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(window)), ":t");
	local icon, hl = devicons.get_icon(buffer_name)

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

statusline.gap = function (gap_config)
	return "%=";
end

statusline.cursor_position = function (position_config)
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

statusline.generateStatusline = function (win)
	local _output = "";
	local loaded_config = statusline.window_config[win];

	-- Current window is one of the windows to skip
	 if loaded_config == nil then
	 	return _output;
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
