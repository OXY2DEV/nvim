local animations = {};
local helpers = require("window-animations/helpers");

animations.animatePosition = function (window, rows, columns, current_frame)
	local window_conf = vim.api.nvim_win_get_config(window);

	if not window_conf.zindex then
		print("Window isn't floating");
		return
	end

	local current_row = window_conf.row;
	local current_col = window_conf.col;

	-- Check for invalid window types
	if type(window) ~= "number" or vim.api.nvim_win_is_valid(window) == false then
		print("Window is either not a number or doesn't exist");
		return;
	end

	-- If the value isn't a table directly use it
	if vim.islist(rows) ~= true and type(rows) == "number" then
		current_row = rows;
	elseif vim.islist(rows) == true and vim.tbl_isempty(rows) == false then
		current_row = current_frame <= #rows and rows[current_frame] or rows[#rows];
	end

	if vim.islist(columns) ~= true and type(columns) == "number" then
		current_col = columns;
	elseif vim.islist(columns) == true and vim.tbl_isempty(columns) == false then
		current_col = current_frame <= #columns and columns[current_frame] or columns[#columns];
	end

	-- vim.print(current_row)


	vim.api.nvim_win_set_config(window, {
		relative = "editor",

		row = current_row,
		col = current_col
	});
end

animations.animateDimension = function (window, widths, heights, current_frame)
	local current_width = vim.api.nvim_win_get_width(window);
	local current_height = vim.api.nvim_win_get_height(window);

	-- Check for invalid window types
	if type(window) ~= "number" or vim.api.nvim_win_is_valid(window) == false then
		print("Window is either not a number or doesn't exist");
		return;
	end

	-- If the value isn't a table directly use it
	if vim.islist(widths) ~= true and type(widths) == "number" then
		current_width = widths;
	elseif vim.islist(widths) == true and vim.tbl_isempty(widths) == false then
		current_width = current_frame <= #widths and widths[current_frame] or widths[#widths];
	end

	if vim.islist(heights) ~= true and type(heights) == "number" then
		current_height = heights;
	elseif vim.islist(heights) == true and vim.tbl_isempty(heights) == false then
		current_height = current_frame <= #heights and heights[current_frame] or heights[#heights];
	end


	vim.api.nvim_win_set_width(window, math.floor(current_width));
	vim.api.nvim_win_set_height(window, math.floor(current_height));
end

animations.animateOpacity = function (window, winblends, border_type, border_colors, current_frame)
	local window_conf = vim.api.nvim_win_get_config(window);

	local current_winblend;
	local current_border;

	if not window_conf.zindex then
		print("Window isn't floating");
		return
	end

	if vim.tbl_isempty(winblends) == true then
		goto noBlend;
	end

	current_winblend = vim.wo[window].winblend

	if vim.islist(winblends) ~= true and type(winblends) == "number" then
		current_winblend = winblends;
	elseif vim.islist(winblends) == true and vim.tbl_isempty(winblends) == false then
		current_winblend = current_frame <= #winblends and winblends[current_frame] or winblends[#winblends];
	end

	vim.wo[window].winblend = current_winblend;

	::noBlend::

	if border_colors == nil or vim.tbl_isempty(border_colors) == true then
		return;
	end

	if current_frame == 1 then
		vim.wo[window].winhighlight = "FloatBorder:FloatBorder_" .. window;
	end

	if vim.islist(border_colors) ~= true then
		current_border = border_colors;
	elseif vim.islist(border_colors) == true and vim.tbl_isempty(border_colors) == false then
		current_border = current_frame <= #border_colors and border_colors[current_frame] or border_colors[#border_colors];
	end

	vim.print(current_border)


	vim.api.nvim_set_hl(0, "FloatBorder_" .. window, {
		fg = current_border;
	})
end

animations.animate = function (window, table, frames)
	local frame = 1;
	local max_frames = frames or 10;

	local timer = vim.uv.new_timer();
	local merged_config = vim.tbl_extend("keep", table, {
		timeout = 0, delay = 20,

		row = {}, col = {},
		width = {}, height = {},

		winblend = {}, border_color = {}
	});

	if type(table.on_start) == "function" then
		table.on_start();
	end

	timer:start(merged_config.timeout, merged_config.delay, vim.schedule_wrap(function ()

		animations.animatePosition(window, merged_config.row, merged_config.col, frame);
		animations.animateDimension(window, merged_config.width, merged_config.height, frame);
		animations.animateOpacity(window, merged_config.winblend, merged_config.border or "single", merged_config.border_color, frame);

		if frame > max_frames then
			if type(table.on_complete) == "function" then
				table.on_complete();
			end

			timer:stop();
			return;
		end

		frame = frame + 1;
	end))
end

--- Function to animate to a state
---@param window number Window ID
---@param options table Table with animation options
animations.to = function (window, options)
	local animation_table = {};

	if type(options.frames) ~= "number" then
		options.frames = 10
	end

	for key, value in pairs(options) do
		if key == "row" then
			animation_table[key] = helpers.createFrames("linear", vim.api.nvim_win_get_config(window)["row"], value, options.frames)
		elseif key == "col" then
			animation_table[key] = helpers.createFrames("linear", vim.api.nvim_win_get_config(window)["col"], value, options.frames)
		elseif key == "width" then
			animation_table[key] = helpers.createFrames("linear", vim.api.nvim_win_get_width(window), value, options.frames)
		elseif key == "height" then
			animation_table[key] = helpers.createFrames("linear", vim.api.nvim_win_get_height(window), value, options.frames)
		elseif key == "winblend" then
			animation_table[key] = helpers.createFrames("linear", vim.wo[window].winblend, value, options.frames, true)
		elseif key == "border_color" then
			animation_table[key] = helpers.createColors("linear", vim.tbl_isempty(vim.api.nvim_get_hl(0, { name = "FloatBorder_" .. window })) and vim.api.nvim_get_hl(0, { name = "FloatBorder" }).fg or vim.api.nvim_get_hl(0, { name = "FloatBorder_" .. window }).fg, value, options.frames)
		end
	end

	if options.on_complete then
		animation_table.on_complete = options.on_complete;
	end

	if options.on_start then
		animation_table.on_complete = options.on_start;
	end

	animations.animate(window, animation_table, 10);
end

return animations;
