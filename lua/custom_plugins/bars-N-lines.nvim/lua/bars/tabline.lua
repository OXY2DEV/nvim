local tabline = {};
local devicons = require("nvim-web-devicons");

--- Function that renders the text to the tabline
---@param list tabline_component[] List of components to render
---@param width number? Maximum character length
---@param separator_config separator_config? Configuration table for the separator
---@return string
tabline.renderer = function (list, width, separator_config)
	local max_len = width ~= nil and (separator_config ~= nil and width - vim.fn.strchars(separator_config.text) or width) or 999;
	local len = 0;

	local fitted_in_space = true;
	local _o = "";

	local exceeds_length = function (current_len, text)
		if text == nil then
			return false;
		end

		if current_len + vim.fn.strchars(text) > max_len then
			return true;
		end

		return false;
	end

	local truncate = function (text)
		if exceeds_length(len, text) then
			local short_len = max_len - len;

			fitted_in_space = false;
			len = len + short_len;
			return string.sub(text, 1, short_len);
		end

		len = len + vim.fn.strchars(text);
		return text;
	end

	for _, part in ipairs(list) do
		if part.prefix ~= nil then
			_o = _o .. part.prefix;
		end

		if part.click ~= nil then
			_o = _o .. "%@" .. part.click .. "@";
		end

		if part.bg ~= nil then
			_o = _o .. "%#" .. part.bg .. "#";
		end


		if exceeds_length(len, part.corner_left) == false and part.corner_left_hl ~= nil then
			_o = _o .. "%#" .. part.corner_left_hl .. "#";
		end

		if type(part.corner_left) == "string" then
			_o = _o .. truncate(part.corner_left);
		end


		if exceeds_length(len, part.padding_left) == false and part.padding_left_hl ~= nil then
			_o = _o .. "%#" .. part.padding_left_hl .. "#";
		end

		if type(part.padding_left) == "string" then
			_o = _o .. truncate(part.padding_left);
		end


		if exceeds_length(len, part.icon) == false and part.icon_hl ~= nil then
			_o = _o .. "%#" .. part.icon_hl .. "#";
		end

		if type(part.icon) == "string" then
			_o = _o .. truncate(part.icon);
		end

		if type(part.text) == "string" then
			_o = _o .. truncate(part.text);
		end


		if exceeds_length(len, part.padding_right) == false and part.padding_right_hl ~= nil then
			_o = _o .. "%#" .. part.padding_right_hl .. "#";
		end

		if type(part.padding_right) == "string" then
			_o = _o .. truncate(part.padding_right);
		end


		if exceeds_length(len, part.corner_right) == false and part.corner_right_hl ~= nil then
			_o = _o .. "%#" .. part.corner_right_hl .. "#";
		end

		if type(part.corner_right) == "string" then
			_o = _o .. truncate(part.corner_right);
		end

		if part.postfix ~= nil then
			_o = _o .. part.postfix;
		end
	end

	if separator_config ~= nil and separator_config.on_skip ~= nil and pcall(separator_config.on_skip) then
		separator_config.on_skip();
	end


	if fitted_in_space == false and separator_config ~= nil then
		local _s = "";

		if separator_config.condition ~= nil and pcall(separator_config.condition) == true and separator_config.condition() == false then
			goto separator_disabled;
		end

		if separator_config.hl ~= nil then
			_s = "%#" .. separator_config.hl .. "#";
		end

		_s = _s .. separator_config.text;

		if separator_config.direction == "after" or separator_config.direction == nil then
			_o = _o .. _s;
		elseif separator_config.direction == "before" then
			_o = _s .. _o;
		end

		if separator_config.on_complete ~= nil and pcall(separator_config.on_complete) then
			separator_config.on_complete();
		end

		::separator_disabled::
	end

	return _o;
end

---@type primary_user_options User configuration table for the tabline
tabline.config = {};

---@type boolean Default variable to control the rendering of separators from different components
tabline.separator_set = false;

--- Function to set the global tabline
---@param user_config primary_user_config
tabline.init = function (user_config)
	if user_config == nil or user_config.enabled == false then
		return;
	else
		tabline.config = user_config.options;
	end

	vim.o.tabline = "%!v:lua.require('bars/tabline').generateTabline()";
end

--- Function to show all the active tabs,like workspaces
---@param tab_config { width: number?, active: tabline_component?, inactive: tabline_component?, separator: separator_config? } User provided configuration table
---@return string
tabline.tabs = function (tab_config)
	local tabs = vim.api.nvim_list_tabpages();
	local current_tab = vim.api.nvim_get_current_tabpage();

	---@type { width: number?, active: tabline_component, inactive: tabline_component, separator: separator_config } Merged configuration table
	local merged_config = vim.tbl_deep_extend("keep", tab_config, {
		inactive = {
			corner_left = "", corner_left_hl = "Bars_tabline_tab_inactive",
			corner_right = "", corner_right_hl = "Bars_tabline_tab_inactive",

			padding_left = " ", padding_left_hl = "Bars_tabline_tab_inactive_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		active = {
			corner_left = "", corner_left_hl = "Bars_tabline_tab_active",
			corner_right = "", corner_right_hl = "Bars_tabline_tab_active",

			padding_left = " ", padding_left_hl = "Bars_tabline_tab_active_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		}
	});

	local tmp = {};
	for _, id in ipairs(tabs) do
		if id == current_tab then
			table.insert(tmp, 1, vim.tbl_extend("keep", merged_config.active, {
				prefix = "%" .. id .. "T", postfix = "%X",
				text = tostring(id)
			}));
		else
			table.insert(tmp, vim.tbl_extend("keep", merged_config.inactive, {
				prefix = "%" .. id .. "T", postfix = "%X",
				text = tostring(id)
			}));
		end
	end

	return tabline.renderer(tmp, merged_config.width or 25, merged_config.separator);
end

--- Adds gap between components, optionally allows colors
---@param gap_config { hl: string? }
---@return string
tabline.gap = function (gap_config)
	local _o = "";

	if gap_config.hl ~= nil then
		_o = _o .. "%#" .. gap_config.hl .. "#";
	end

	_o = _o .. "%=";

	return _o;
end

--- Function to show some text
---@param txt_config tabline_component
---@return string
tabline.text = function (txt_config)
	return tabline.renderer({ txt_config });
end

--- Shows all the opened buffers(ones that are in some window)
---@param buf_config { width: number?, active: tabline_component?, inactive: tabline_component?, separator: separator_config? } User provided configuration table
---@return string
tabline.buffers = function (buf_config)
	local this_tabpage = vim.api.nvim_get_current_tabpage();
	local windows = vim.api.nvim_tabpage_list_wins(this_tabpage);

	---@type { width: number?, active: tabline_component, inactive: tabline_component, separator: separator_config } Merged configuration table
	local merged_config = vim.tbl_deep_extend("keep", buf_config, {
		inactive = {
			corner_left = "", corner_left_hl = "Bars_tabline_tab_inactive",
			corner_right = "", corner_right_hl = "Bars_tabline_tab_inactive",

			padding_left = " ", padding_left_hl = "Bars_tabline_tab_inactive_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		active = {
			corner_left = "", corner_left_hl = "Bars_tabline_tab_active",
			corner_right = "", corner_right_hl = "Bars_tabline_tab_active",

			padding_left = " ", padding_left_hl = "Bars_tabline_tab_active_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		separator = {
			text = "", hl = "Bars_tabline_buf_inactive",
			direction = "after",

			condition = function ()
				if tabline.separator_set == true then
					return false;
				end

				return true
			end,

			on_complete = function ()
				tabline.separator_set = true;
			end,

			on_skip = function ()
				tabline.separator_set = false;
			end
		}
	})

	local tmp = {};
	local checked_bufs = {};

	for _, win in ipairs(windows) do
		local buffer = vim.api.nvim_win_get_buf(win);
		local buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":t");
		local icon, hl = devicons.get_icon(buffer_name, nil, { default = true })

		if buffer == vim.api.nvim_get_current_buf() and vim.list_contains(checked_bufs, buffer) == false then
			table.insert(tmp, 1, vim.tbl_extend("keep", merged_config.active, {
				icon = icon .. " ",
				text = buffer_name ~= "" and buffer_name or "No name"
			}));
		elseif buffer ~= vim.api.nvim_get_current_buf() then
			table.insert(tmp, vim.tbl_extend("keep", merged_config.inactive, {
				icon = icon .. " ",
				text = buffer_name ~= "" and buffer_name or "No name"
			}));
		end

		table.insert(checked_bufs, buffer);
	end

	return tabline.renderer(tmp, merged_config.width ~= nil and merged_config.width or vim.o.columns - 26, merged_config.separator);
end

---Lists all the buffers that have been loaded
---@param buf_config { width: number?, active: tabline_component?, inactive: tabline_component?, separator: separator_config? } User provided configuration table
---@return string
tabline.buffers_all = function (buf_config)
	---@type { width: number?, active: tabline_component, inactive: tabline_component, separator: separator_config } Merged configuration table
	local merged_config = vim.tbl_deep_extend("keep", buf_config, {
		inactive = {
			corner_left = "", corner_left_hl = "Bars_tabline_buf_inactive",
			corner_right = "", corner_right_hl = "Bars_tabline_buf_inactive",

			padding_left = " ", padding_left_hl = "Bars_tabline_buf_inactive_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		active = {
			corner_left = "", corner_left_hl = "Bars_tabline_buf_active",
			corner_right = "", corner_right_hl = "Bars_tabline_buf_active",

			padding_left = " ", padding_left_hl = "Bars_tabline_buf_active_alt",
			padding_right = " ", padding_right_hl = nil,

			bg = nil
		},

		separator = {
			text = "", hl = "Bars_tabline_buf_inactive",
			direction = "after",

			condition = function ()
				if tabline.separator_set == true then
					return false;
				end

				return true
			end,

			on_complete = function ()
				tabline.separator_set = true;
			end,

			on_skip = function ()
				tabline.separator_set = false;
			end
		}
	});

	local buffers = vim.api.nvim_list_bufs();
	local tmp = {};
	local checked_bufs = {};

	for _, buf in ipairs(buffers) do
		local buffer_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t");
		local icon, hl = devicons.get_icon(buffer_name, nil, { default = true });

		if buffer_name == "" or vim.api.nvim_buf_is_loaded(buf) == false then
			goto bufSkip;
		end

		if buf == vim.api.nvim_get_current_buf() and vim.list_contains(checked_bufs, buf) == false then
			table.insert(tmp, 1, vim.tbl_extend("keep", merged_config.active, {
				icon = icon .. " ",
				text = buffer_name ~= "" and buffer_name or "No name"
			}));
		elseif buf ~= vim.api.nvim_get_current_buf() then
			table.insert(tmp, vim.tbl_extend("keep", merged_config.inactive, {
				icon = icon .. " ",
				text = buffer_name ~= "" and buffer_name or "No name"
			}));
		end

		table.insert(checked_bufs, buf);
		::bufSkip::
	end

	return tabline.renderer(tmp, merged_config.width ~= nil and merged_config.width or vim.o.columns - 26, merged_config.separator);
end

tabline.generateTabline = function ()
	local _output = "";

	if tabline.config.default_hl ~= nil and tabline.config.default_hl ~= "" then
		_output = "%#" .. tabline.config.default_hl .. "#";
	end

	for _, component in ipairs(tabline.config.components or {}) do
		if component.type == "gap" then
			_output = _output .. tabline.gap(component);
		elseif component.type == "text" then
			_output = _output .. tabline.text(component);
		elseif component.type == "tabs" then
			--  return string.format("%%%d@v:lua.require'lualine.utils.fn_store'.call_fn@%s%%T", id, str)
			_output = _output .. tabline.tabs(component);
		elseif component.type == "buffers" then
			_output = _output .. tabline.buffers(component);
		elseif component.type == "buffers_all" then
			_output = _output .. tabline.buffers_all(component);
		end
	end

	return _output;
end

return tabline;
