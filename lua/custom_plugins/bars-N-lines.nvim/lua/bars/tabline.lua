local tabline = {};
local devicons = require("nvim-web-devicons");

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

	if fitted_in_space == false and separator_config ~= nil then
		if separator_config.hl ~= nil then
			_o = _o .. "%#" .. separator_config.hl .. "#";
		end

		_o = _o .. separator_config.text;
	end

	return _o, len;
end

tabline.config = {};

tabline.init = function (user_config)
	if user_config == nil or user_config.enabled == false then
		return;
	else
		tabline.config = user_config.options;
	end

	vim.o.tabline = "%!v:lua.require('bars/tabline').generateTabline()";
end

tabline.tabs = function (tab_config)
	local tabs = vim.api.nvim_list_tabpages();
	local current_tab = vim.api.nvim_get_current_tabpage();

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

	return tabline.renderer(tmp, merged_config.width or 26);
end

tabline.gap = function (gap_config)
	local _o = "";

	if gap_config.bg ~= nil then
		_o = _o .. "%#" .. gap_config.bg .. "#";
	end

	_o = _o .. "%=";

	return _o;
end

tabline.separator = function (sep_config)
	local merged_config = vim.tbl_extend("keep", sep_config, {
		text = "",
		bg = "Bars_tabline_tab_inactive_alt",
	});

	return tabline.renderer({ merged_config });
end

tabline.buffers = function (buf_config)
	local this_tabpage = vim.api.nvim_get_current_tabpage();
	local windows = vim.api.nvim_tabpage_list_wins(this_tabpage);

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

	return tabline.renderer(tmp, merged_config.width ~= nil and merged_config.width or vim.o.columns - 26);
end

tabline.buffers_all = function (buf_config)
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
			text = "", hl = "Bars_tabline_buf_inactive"
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
		elseif component.type == "separator" then
			_output = _output .. tabline.separator(component);
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
