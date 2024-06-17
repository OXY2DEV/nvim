local utils = require("utils");
local window = {};

window.defaults = {
	window_options = {
		float = {
			relative = "editor",

			row = 10, col = 10,
			width = 30, height = 10,

			border = "none",
			winblend = 0
		},

		split = {
			win = 0,
			width = 10, height = 10,
			split = "left"
		}
	},

	animation = {
		type = "width",
		timing = "linear",
		steps = 15,

		step_delay = 25
	}
};

window.setup = function (config)
	window.defaults = vim.tbl_deep_extend("keep", config, window.defaults);
end

window.openFloat = function (buffer, window_config, animation_config)
	local win_conf = vim.tbl_deep_extend("keep", window_config, window.defaults.window_options.float);
	local ani_conf = vim.tbl_deep_extend("keep", animation_config, window.defaults.animation);

	local new_window;
	local timer = vim.uv.new_timer();

	if ani_conf.type == "width" then
		local widths = utils.createFrames(ani_conf.timing, 1, win_conf.width, ani_conf.steps, true)

		new_window = vim.api.nvim_open_win(buffer, true, {
			relative = win_conf.relative,

			row = win_conf.row, col = win_conf.col,
			width = 1, height = win_conf.height,

			border = win_conf.border
		});

		vim.api.nvim_set_option_value("winblend", win_conf.winblend, {win = new_window });

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #widths == 0 then
				if ani_conf.on_complete ~= nil then
					ani_conf.on_complete();
				end

				timer:stop();
				return;
			end

			vim.api.nvim_win_set_width(new_window, table.remove(widths, 1));
		end))
	elseif ani_conf.type == "height" then
		local heights = utils.createFrames(ani_conf.timing, 1, win_conf.height, ani_conf.steps, true)

		new_window = vim.api.nvim_open_win(buffer, true, {
			relative = win_conf.relative,

			row = win_conf.row, col = win_conf.col,
			width = win_conf.width, height = 1,

			border = win_conf.border
		});

		vim.api.nvim_set_option_value("winblend", win_conf.winblend, { win = new_window });

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #heights == 0 then
				if ani_conf.on_complete ~= nil then
					ani_conf.on_complete();
				end

				timer:stop();
				return;
			end

			vim.api.nvim_win_set_height(new_window, table.remove(heights, 1));
		end))
	elseif ani_conf.type == "expand" then
		local widths = utils.createFrames(ani_conf.timing, 1, win_conf.width, ani_conf.steps, true)
		local heights = utils.createFrames(ani_conf.timing, 1, win_conf.height, ani_conf.steps, true)

		new_window = vim.api.nvim_open_win(buffer, true, {
			relative = win_conf.relative,

			row = win_conf.row, col = win_conf.col,
			width = 1, height = 1,

			border = win_conf.border
		});

		vim.api.nvim_set_option_value("winblend", win_conf.winblend, { win = new_window });

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #widths == 0 then
				if ani_conf.on_complete ~= nil then
					ani_conf.on_complete();
				end

				timer:stop();
				return;
			end

			vim.api.nvim_win_set_width(new_window, table.remove(widths, 1));
			vim.api.nvim_win_set_height(new_window, table.remove(heights, 1));
		end))
	elseif ani_conf.type == "opacity" then
		local winblends = utils.createFrames(ani_conf.timing, 0, win_conf.winblend, ani_conf.steps, true)

		new_window = vim.api.nvim_open_win(buffer, true, {
			relative = win_conf.relative,

			row = win_conf.row, col = win_conf.col,
			width = win_conf.width, height = win_conf.height,

			border = win_conf.border
		});

		vim.api.nvim_set_option_value("winblend", 0, { win = new_window });

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #winblends == 0 then
				if ani_conf.on_complete ~= nil then
					ani_conf.on_complete();
				end

				timer:stop();
				return;
			end

			vim.api.nvim_set_option_value("winblend", table.remove(winblends), { win = new_window });
		end))
	elseif ani_conf.type == "opacity_col" then
		local cols = utils.createFrames(ani_conf.timing, win_conf.col_before or 0, win_conf.col, ani_conf.steps, true)
		local winblends = utils.createFrames(ani_conf.timing, 0, win_conf.winblend, ani_conf.steps, true)

		new_window = vim.api.nvim_open_win(buffer, true, {
			relative = win_conf.relative,

			row = win_conf.row, col = win_conf.col_before or 0,
			width = win_conf.width, height = win_conf.height,

			border = win_conf.border
		});

		vim.api.nvim_set_option_value("winblend", 0, { win = new_window });

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #winblends == 0 then
				if ani_conf.on_complete ~= nil then
					ani_conf.on_complete();
				end

				timer:stop();
				return;
			end

			vim.api.nvim_set_option_value("winblend", table.remove(winblends), { win = new_window });
			vim.api.nvim_win_set_config(new_window, {
				relative = win_conf.relative,

				row = win_conf.row, col = table.remove(cols, 1)
			});
		end))
	elseif ani_conf.type == "opacity_row" then
		local rows = utils.createFrames(ani_conf.timing, win_conf.row_before or 0, win_conf.row, ani_conf.steps, true)
		local winblends = utils.createFrames(ani_conf.timing, 0, win_conf.winblend, ani_conf.steps, true)

		new_window = vim.api.nvim_open_win(buffer, true, {
			relative = win_conf.relative,

			row = win_conf.row_before or 0, col = win_conf.col,
			width = win_conf.width, height = win_conf.height,

			border = win_conf.border
		});

		vim.api.nvim_set_option_value("winblend", 0, { win = new_window });

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #winblends == 0 then
				if ani_conf.on_complete ~= nil then
					ani_conf.on_complete();
				end

				timer:stop();
				return;
			end

			vim.api.nvim_set_option_value("winblend", table.remove(winblends), { win = new_window });
			vim.api.nvim_win_set_config(new_window, {
				relative = win_conf.relative,

				row = table.remove(rows, 1), col = win_conf.col,
			});
		end))
	end
end

window.closeFloat = function (window_to_use, window_config, animation_config)
	local win_conf = vim.tbl_deep_extend("keep", window_config, window.defaults.window_options.float);
	local ani_conf = vim.tbl_deep_extend("keep", animation_config, window.defaults.animation);

	local timer = vim.uv.new_timer();

	if ani_conf.type == "width" then
		local widths = utils.createFrames(ani_conf.timing, vim.api.nvim_win_get_width(window_to_use), win_conf.width, ani_conf.steps, true)

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #widths == 0 then
				if #vim.api.nvim_list_wins() > 1 then
					vim.api.nvim_win_close(window_to_use, false);
				end

				timer:stop();
				return;
			end

			vim.api.nvim_win_set_width(window_to_use, table.remove(widths, 1));
		end))
	elseif ani_conf.type == "height" then
	local heights = utils.createFrames(ani_conf.timing, vim.api.nvim_win_get_height(window_to_use), win_conf.height, ani_conf.steps, true)

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #heights == 0 then
				if #vim.api.nvim_list_wins() > 1 then
					vim.api.nvim_win_close(window_to_use, false);
				end

				timer:stop();
				return;
			end

			vim.api.nvim_win_set_height(window_to_use, table.remove(heights, 1));
		end))
	elseif ani_conf.type == "shrink" then
		local widths = utils.createFrames(ani_conf.timing, vim.api.nvim_win_get_width(window_to_use), win_conf.width, ani_conf.steps, true)
		local heights = utils.createFrames(ani_conf.timing, vim.api.nvim_win_get_height(window_to_use), win_conf.height, ani_conf.steps, true)

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #widths == 0 then
				if #vim.api.nvim_list_wins() > 1 then
					vim.api.nvim_win_close(window_to_use, false);
				end

				timer:stop();
				return;
			end

			vim.api.nvim_win_set_width(window_to_use, table.remove(widths, 1));
			vim.api.nvim_win_set_height(window_to_use, table.remove(heights, 1));
		end))
	elseif ani_conf.type == "opacity" then
		local winblends = utils.createFrames(ani_conf.timing, vim.api.nvim_get_option_value("winblend", { win = window_to_use }), win_conf.winblend, ani_conf.steps, true)

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #winblends == 0 then
				if #vim.api.nvim_list_wins() > 1 then
					vim.api.nvim_win_close(window_to_use, false);
				end

				timer:stop();
				return;
			end

			vim.api.nvim_set_option_value("winblend", table.remove(winblends, 1), { win = new_window });
		end))
	elseif ani_conf.type == "opacity_row" then
		local rows = utils.createFrames(ani_conf.timing, vim.api.nvim_win_get_position(window_to_use)[1], win_conf.row, ani_conf.steps, true)
		local winblends = utils.createFrames(ani_conf.timing, vim.api.nvim_get_option_value("winblend", { win = window_to_use }), win_conf.winblend, ani_conf.steps, true)

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #winblends == 0 then
				if #vim.api.nvim_list_wins() > 1 then
					vim.api.nvim_win_close(window_to_use, false);
				end

				timer:stop();
				return;
			end

			vim.api.nvim_set_option_value("winblend", table.remove(winblends, 1), { win = new_window });
			vim.api.nvim_win_set_config(window_to_use, {
				relative = win_conf.relative,
				--relative = vim.api.nvim_get_option_value("relative", { win = window_to_use }),

				row = table.remove(rows, 1), col = vim.api.nvim_win_get_position(window_to_use)[2]
			});
		end))
	elseif ani_conf.type == "opacity_col" then
		local cols = utils.createFrames(ani_conf.timing, vim.api.nvim_win_get_position(window_to_use)[2], win_conf.col, ani_conf.steps, true)
		local winblends = utils.createFrames(ani_conf.timing, vim.api.nvim_get_option_value("winblend", { win = window_to_use }), win_conf.winblend, ani_conf.steps, true)

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #winblends == 0 then
				if #vim.api.nvim_list_wins() > 1 then
					vim.api.nvim_win_close(window_to_use, false);
				end

				timer:stop();
				return;
			end

			vim.api.nvim_set_option_value("winblend", table.remove(winblends, 1), { win = new_window });
			vim.api.nvim_win_set_config(window_to_use, {
				relative = win_conf.relative,
				--relative = vim.api.nvim_get_option_value("relative", { win = window_to_use }),

				row = vim.api.nvim_win_get_position(window_to_use)[1], col = table.remove(cols, 1)
			});
		end))
	end
end

window.openSplit = function (buffer, window_config, animation_config)
	local win_conf = vim.tbl_deep_extend("keep", window_config, window.defaults.window_options.split);
	local ani_conf = vim.tbl_deep_extend("keep", animation_config, window.defaults.animation);

	local new_window;
	local timer = vim.uv.new_timer();

	if ani_conf.type == "width" then
		local widths = utils.createFrames(ani_conf.timing, 1, win_conf.width, ani_conf.steps, true)

		new_window = vim.api.nvim_open_win(buffer, true, {
			win = win_conf.win,

			split = win_conf.split,
			width = 1, height = win_conf.height
		});

		vim.api.nvim_set_option_value("winblend", win_conf.winblend, {win = new_window });

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #widths == 0 then
				if ani_conf.on_complete ~= nil then
					ani_conf.on_complete();
				end

				timer:stop();
				return;
			end

			vim.api.nvim_win_set_width(new_window, table.remove(widths, 1));
		end))
	elseif ani_conf.type == "height" then
		local heights = utils.createFrames(ani_conf.timing, 1, win_conf.height, ani_conf.steps, true)

		new_window = vim.api.nvim_open_win(buffer, true, {
			split = win_conf.split,
			width = win_conf.width, height = 1
		});

		vim.api.nvim_set_option_value("winblend", win_conf.winblend, {win = new_window });

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #heights == 0 then
				if ani_conf.on_complete ~= nil then
					ani_conf.on_complete();
				end

				timer:stop();
				return;
			end

			vim.api.nvim_win_set_height(new_window, table.remove(heights, 1));
		end))
	end

	return new_window;
end

window.closeSplit = function (window_to_use, window_config, animation_config)
	local win_conf = vim.tbl_deep_extend("keep", window_config, window.defaults.window_options.split);
	local ani_conf = vim.tbl_deep_extend("keep", animation_config, window.defaults.animation);

	local timer = vim.uv.new_timer();

	if ani_conf.type == "width" then
		local widths = utils.createFrames(ani_conf.timing, vim.api.nvim_win_get_width(window_to_use), win_conf.width, ani_conf.steps, true)

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #widths == 0 then
				if #vim.api.nvim_list_wins() > 1 then
					vim.api.nvim_win_close(window_to_use, false);
				end

				timer:stop();
				return;
			end

			vim.api.nvim_win_set_width(window_to_use, table.remove(widths, 1));
		end))
	elseif ani_conf.type == "height" then
		local heights = utils.createFrames(ani_conf.timing, vim.api.nvim_win_get_height(window_to_use), win_conf.height, ani_conf.steps, true)

		timer:start(0, ani_conf.step_delay, vim.schedule_wrap(function ()
			if #heights == 0 then
				if #vim.api.nvim_list_wins() > 1 then
					vim.api.nvim_win_close(window_to_use, false);
				end

				timer:stop();
				return;
			end

			vim.api.nvim_win_set_height(window_to_use, table.remove(heights, 1));
		end))
	end
end

window.to = function (window_to_use, resizeConfig)
	local rows, cols, widths, heights, winblends;
	local ease, steps, step_delay, start_delay = "linear", 10, 15, 0;

	for key, value in pairs(resizeConfig) do
		if key == "ease" then
			ease = value;
		elseif key == "steps" then
			steps = value;
		elseif key == "step_delay" then
			step_delay = value;
		elseif key == "start_delay" then
			start_delay = value;
		elseif key == "width" then
			rows = utils.createFrames(ease, vim.api.nvim_win_get_width(window_to_use), value );
		end
	end
end

return window;
