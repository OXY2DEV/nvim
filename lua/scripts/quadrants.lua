local quadrants = {};

--- Stores the state of various
--- quadrants
---@class quadrants.state
---
---@field top_left boolean
---@field top_right boolean
---
---@field bottom_left boolean
---@field bottom_right boolean
---
---@field center boolean
quadrants.available = {
	top_left = true,
	top_right = true,

	bottom_left = true,
	bottom_right = true,

	center = true
};

--- Checks if the top left quadrant is empty or not.
---@param width integer | nil
---@param height integer | nil
---@param x integer | nil
---@param y integer | nil
---@return boolean
quadrants.__top_left_available = function (width, height, x, y)
	if quadrants.available.top_left ~= true then
		return false;
	end

	width = type(width) == "number" and width or 1;
	height = type(height) == "number" and height or 1;

	x = type(x) == "number" and x or 1;
	y = type(y) == "number" and y or 1;

	if vim.o.winbar ~= "" then
		y = y + 1;
	end

	if y < height then
		--- There's not enough space above
		--- the window.
		return false;
	elseif x >= width then
		return true;
	else
		--- There's not enough space before
		--- the window.
		return false;
	end
end

--- Checks if the top right quadrant is empty or not.
---@param width integer | nil
---@param height integer | nil
---@param x integer | nil
---@param y integer | nil
---@return boolean
quadrants.__top_right_available = function (width, height, x, y)
	if quadrants.available.top_left ~= true then
		return false;
	end

	width = type(width) == "number" and width or 1;
	height = type(height) == "number" and height or 1;

	x = type(x) == "number" and x or 1;
	y = type(y) == "number" and y or 1;

	if vim.o.winbar ~= "" then
		y = y + 1;
	end

	if y < height then
		--- There's not enough space above
		--- the window.
		return false;
	elseif (x + width) <= vim.o.columns then
		return true;
	else
		--- There's not enough space after
		--- the window.
		return false;
	end
end

--- Checks if the bottom left quadrant is empty or not.
---@param width integer | nil
---@param height integer | nil
---@param x integer | nil
---@param y integer | nil
---@return boolean
quadrants.__bottom_left_available = function (width, height, x, y)
	if quadrants.available.top_left ~= true then
		return false;
	end

	width = type(width) == "number" and width or 1;
	height = type(height) == "number" and height or 1;

	x = type(x) == "number" and x or 1;
	y = type(y) == "number" and y or 1;

	local editor_height = vim.o.lines - vim.o.cmdheight;

	if vim.o.showtabline == 2 then
		editor_height = editor_height - 1;
	elseif vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1 then
		editor_height = editor_height - 1;
	end

	if vim.o.winbar ~= "" then
		y = y + 1;
	end

	if (y + height) > editor_height then
		--- There's not enough space below
		--- the window.
		return false;
	elseif x >= width then
		return true;
	else
		--- There's not enough space before
		--- the window.
		return false;
	end
end

--- Checks if the bottom right quadrant is empty or not.
---@param width integer | nil
---@param height integer | nil
---@param x integer | nil
---@param y integer | nil
---@return boolean
quadrants.__bottom_right_available = function (width, height, x, y)
	if quadrants.available.top_left ~= true then
		return false;
	end

	width = type(width) == "number" and width or 1;
	height = type(height) == "number" and height or 1;

	x = type(x) == "number" and x or 1;
	y = type(y) == "number" and y or 1;

	local editor_height = vim.o.lines - vim.o.cmdheight;

	if vim.o.showtabline == 2 then
		editor_height = editor_height - 1;
	elseif vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1 then
		editor_height = editor_height - 1;
	end

	if vim.o.winbar ~= "" then
		y = y + 1;
	end

	if (y + height) > editor_height then
		--- There's not enough space below
		--- the window.
		return false;
	elseif (x + width) <= vim.o.columns then
		return true;
	else
		--- There's not enough space after
		--- the window.
		return false;
	end
end

--- Gets available quadrant.
---@param preference ( "top_left" | "top_right" | "bottom_left" | "bottom_right" )[]
---@param width integer
---@param height integer
---@param x integer
---@param y integer
---@return
---| "center"
---| "top_left" 
---| "top_right"
---| "bottom_left"
---| "bottom_right"
quadrants.get_available_quadrant = function (preference, width, height, x, y)
	preference = vim.islist(preference) and preference or { "bottom_right", "top_right", "bottom_left", "top_left" };

	for _, item in ipairs(preference) do
		local callable, result = pcall(quadrants["__" .. item .. "_available"], width, height, x, y);

		if callable == true and result == true then
			return item;
		end
	end

	return "center";
end

--- Registers to a quadrant.
---@param quadrant
---| "center"
---| "top_left" 
---| "top_right"
---| "bottom_left"
---| "bottom_right"
quadrants.register = function (quadrant)
	if not quadrant or not quadrants.available[quadrant] then
		vim.api.nvim_echo({
			{ " 󱇚 Quadrants ", "DiagnosticVirtualTextWarn" },
			{ ": " },
			{ "Quadrant not available!", "Comment" }
		}, true, { verbose = false });
	elseif quadrants.available[quadrant] ~= true then
		vim.api.nvim_echo({
			{ " 󱇚 Quadrants ", "DiagnosticVirtualTextWarn" },
			{ ": " },
			{ "Quadrant occupied!", "Comment" }
		}, true, { verbose = false });
	else
		quadrants.available[quadrant] = false;
	end
end

--- Clears given quadrants.
---@param ...
---| "center"
---| "top_left" 
---| "top_right"
---| "bottom_left"
---| "bottom_right"
quadrants.clear = function (...)
	for _, quadrant in ipairs({ ... } or vim.tbl_keys(quadrants.available)) do
		if quadrants.available[quadrant] ~= nil then
			--- Only clear quadrants that exist.
			quadrants.available[quadrant] = true;
		end
	end
end

return quadrants;
