local statuscolumn = {};

---@type primary_user_options A list of window specific configs
statuscolumn.window_config = {};


--- Function to return the value of a specific string/list
---@param property string | table The string/list that will be cut
---@param index number Length of the cut string/list
---@return any
local returnValue = function (property, index)
	if property == nil or index == nil then
		return;
	end

	if vim.islist(property) == false then
		return property;
	end

	if index > #property then
		return property[#property];
	end

	return property[index];
end


--- Initializes the statuscolumn for a window
---@param window number The window id
---@param user_config primary_user_config? The user configuration table
statuscolumn.init = function (window, user_config)
	if user_config == nil then
		statuscolumn.window_config[window] = {};
	elseif user_config.enabled == false then
		statuscolumn.window_config[window] = {};
		return;
	else
		statuscolumn.window_config[window] = user_config.options;

		if user_config.options.set_defaults == true then
			vim.wo[window].relativenumber = true;

			vim.wo[window].foldcolumn = "0";
			vim.wo[window].signcolumn = "no";
		end
	end

	vim.wo[window].statuscolumn = "%!v:lua.require('bars/statuscolumn').generateStatuscolumn(" .. window .. ")";
end

--- Component to add a gap to the statuscolumn
---@param gap_config gap_config_table The configuration options
---@return string
statuscolumn.gap = function (gap_config)
	local _output = "";

	if type(gap_config.hl) == "string" then
		_output = "%#" .. gap_config.hl .. "#"
	end

	_output = _output .. gap_config.text;

	return _output;
end

--- Component that adds a custom border to the statuscolumn
---@param border_config border_config_table The configuration options
---@return string
statuscolumn.border = function (border_config)
	local _output = "";

	if border_config.hl == nil then
		return border_config.text;
	end

	if vim.islist(border_config.hl) == true then
		if (vim.v.relnum + 1) < #border_config.hl then
			_output = "%#" .. border_config.hl[vim.v.relnum + 1] .. "#";
		else
			_output = "%#" .. border_config.hl[#border_config.hl] .. "#";
		end

		_output = _output .. border_config.text;
	else
		if vim.v.relnum >= border_config.hl.from and vim.v.relnum <= border_config.hl.to then
			_output = "%#" .. border_config.hl.prefix .. vim.v.relnum .. "#";
		else
			_output = "%#" .. border_config.hl.prefix .. border_config.hl.to .. "#";
		end

		_output = _output .. border_config.text
	end

	return _output;
end

--- Component that shows various types of line numbers.
---@param number_config number_config_table The configuration table
---@return string
statuscolumn.number = function (number_config)
	local _output, _color = "", "";

	if vim.islist(number_config.hl) == true then
		if (vim.v.relnum + 1) < #number_config.hl then
			_color = "%#" .. number_config.hl[vim.v.relnum + 1] .. "#";
		else
			_color = "%#" .. number_config.hl[#number_config.hl] .. "#";
		end
	elseif type(number_config.hl) == "table" then
		if vim.v.relnum >= number_config.hl.from and vim.v.relnum <= number_config.hl.to then
			_color = "%#" .. number_config.hl.prefix .. vim.v.relnum .. "#";
		else
			_color = "%#" .. number_config.hl.prefix .. number_config.hl.to .. "#";
		end
	end

	if number_config.mode == "normal" then
		_output = vim.v.lnum;
	elseif number_config.mode == "relative" then
		_output = vim.v.relnum;
	elseif number_config.mode == "hybrid" then
		_output = vim.v.relnum == 0 and vim.v.lnum or vim.v.relnum;
	end

	if number_config.right_align == true then
		return _color ~= "" and _color .. "%=%{" .. _output .. "}" or "%=%{ " .. _output .. "}";
	else
		return _color ~= "" and _color .. _output or _output;
	end
end

--- Component to show a custom fold column
---@param fold_config fold_config_table The configuration table
---@return string
statuscolumn.fold = function (fold_config)
	local _output = "";

	local foldlvl_before = vim.fn.foldlevel((vim.v.lnum - 1) >= 1 and (vim.v.lnum - 1) or 1);
	local foldlvl_current = vim.fn.foldlevel(vim.v.lnum);
	local foldlvl_after = vim.fn.foldlevel((vim.v.lnum + 1) <= vim.fn.line("$") and (vim.v.lnum + 1) or vim.fn.line("$"));

	local foldclosed = vim.fn.foldclosed(vim.v.lnum);

	if fold_config.mode == "simple" then
		if type(fold_config.hl.default) == "string" then
			_output = "%#" .. fold_config.hl.default .. "#";
		end

		-- Handle lines with no folds
		if foldlvl_current == 0 then
			_output = type(fold_config.space) == "string" and _output .. fold_config.space or _output .. " ";

			goto mark_added;
		end

		-- Handle lines with a closed fold
		if foldclosed ~= -1 and foldclosed == vim.v.lnum then
			_output = type(fold_config.hl.closed) == "string" and _output .. "%#" .. fold_config.hl.closed .. "#" or _output;
			_output = type(fold_config.text.closed) == "string" and _output .. fold_config.text.closed or _output .. ">";

			goto mark_added;
		end

		-- Handle lines with an open fold
		if foldlvl_current > foldlvl_before then
			_output = type(fold_config.hl.opened) == "string" and _output .. "%#" .. fold_config.hl.opened .. "#" or _output;
			_output = type(fold_config.text.opened) == "string" and _output .. fold_config.text.opened or _output .. "→";

			goto mark_added;
		end

		-- Lines that are inside the folds
		_output = type(fold_config.hl.scope) == "string" and _output .. "%#" .. fold_config.hl.scope .. "#" or _output;
		_output = type(fold_config.text.scope) == "string" and _output .. fold_config.text.scope or _output .. " ";
	elseif fold_config.mode == "line" then
		if type(fold_config.hl.default) == "string" then
			_output = "%#" .. fold_config.hl.default .. "#";
		end

		-- Handle lines with no folds
		if foldlvl_current == 0 then
			_output = type(fold_config.space) == "string" and _output .. fold_config.space or _output .. " ";

			goto mark_added;
		end

		local _color, _icon;

		-- Handle lines with a closed fold
		if foldclosed ~= -1 and foldclosed == vim.v.lnum then
			_color = returnValue(fold_config.hl.closed, foldlvl_current);
			_icon = returnValue(fold_config.text.closed, foldlvl_current);

			_output = type(_color) == "string" and _output .. "%#" .. _color .. "#" or _output;
			_output = type(_icon) == "string" and _output .. _icon or _output;

			goto mark_added;
		end

		-- Handle lines in an open fold
		if foldlvl_current > foldlvl_before or vim.v.lnum == 1 then
			_color = returnValue(fold_config.hl.opened, foldlvl_current);
			_icon = returnValue(fold_config.text.opened, foldlvl_current);

			_output = type(_color) == "string" and _output .. "%#" .. _color .. "#" or _output;
			_output = type(_icon) == "string" and _output .. _icon or _output;

			goto mark_added;
		elseif foldlvl_current > foldlvl_after or vim.v.lnum == vim.fn.line("$") then
			if foldlvl_after == 0 or vim.v.lnum == vim.fn.line("$") then
				_color = returnValue(fold_config.hl.edge, foldlvl_current);
				_icon = returnValue(fold_config.text.edge, foldlvl_current);
			else
				_color = returnValue(fold_config.hl.branch, foldlvl_current);
				_icon = returnValue(fold_config.text.branch, foldlvl_current);
			end

			_output = type(_color) == "string" and _output .. "%#" .. _color .. "#" or _output;
			_output = type(_icon) == "string" and _output .. _icon or _output;

			goto mark_added;
		else
			_color = returnValue(fold_config.hl.scope, foldlvl_current);
			_icon = returnValue(fold_config.text.scope, foldlvl_current);

			_output = type(_color) == "string" and _output .. "%#" .. _color .. "#" or _output;
			_output = type(_icon) == "string" and _output .. _icon or _output;

			goto mark_added;
		end
	end

	::mark_added::
	return _output;
end

--- Creates a statuscolumn for the given window
---@param win number The window id
---@return string
statuscolumn.generateStatuscolumn = function (win)
	local _output = "";
	local loaded_config = statuscolumn.window_config[win];

	-- Current window is one of the windows to skip
	if loaded_config == nil then
		return _output;
	end

	if loaded_config.default_hl ~= nil and loaded_config.default_hl ~= "" then
		_output = "%#" .. loaded_config.default_hl .. "#";
	end

	for _, component in ipairs(loaded_config.components or {}) do
		if component.type == "gap" then
			_output = _output .. statuscolumn.gap(component)
		elseif component.type == "border" then
			_output = _output .. statuscolumn.border(component)
		elseif component.type == "number" then
			_output = _output .. statuscolumn.number(component)
		elseif component.type == "fold" then
			_output = _output .. statuscolumn.fold(component)
		end
	end

	return _output;
end


return statuscolumn;
