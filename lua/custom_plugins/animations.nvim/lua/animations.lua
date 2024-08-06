local animations = {};
local utils = require("animations.utils");

animations.window = {
	to = function (window, config, animation_controls)
		if not window or not vim.api.nvim_win_is_valid(window) then
			error("Window is not valid! Aborting.", 2);
		end

		if not animation_controls then
			animation_controls = { delay = 0, interval = 50, default = { "linear", 10 } };
		else
			animation_controls = vim.tbl_extend("keep", animation_controls, { delay = 0, interval = 50, default = { "linear", 10 } });
		end

		local win_conf = vim.api.nvim_win_get_config(window);
		local frames = utils.frameGenerator(win_conf, config, animation_controls);
		local max_frames = utils.get_maxlen(frames);

		local iteration = 1;
		local timer = vim.uv.new_timer();

		timer:start(animation_controls.delay, animation_controls.interval, vim.schedule_wrap(function ()
			if iteration == max_frames then
				timer:stop();
			end

			if pcall(vim.api.nvim_win_set_config, window, utils.get_current_frame(frames, iteration, animation_controls)) then
				vim.api.nvim_win_set_config(window, utils.get_current_frame(frames, iteration, animation_controls));
			end

			if iteration == max_frames and type(animation_controls.on_complete) == "function" then
				animation_controls.on_complete(window);
			else
				iteration = iteration + 1;
			end
		end));
	end,

	fromTo = function (buffer, enter, from, to, animation_controls)
		if not buffer or not vim.api.nvim_buf_is_valid(buffer) then
			error("Buffer is not valid! Aborting.", 2);
		end

		if not animation_controls then
			animation_controls = { delay = 0, interval = 50, default = { "linear", 10 } };
		else
			animation_controls = vim.tbl_extend("keep", animation_controls, { delay = 0, interval = 50, default = { "linear", 10 } });
		end

		local win = vim.api.nvim_open_win(buffer, enter, from);
		local frames = utils.frameGenerator(from, to, animation_controls);
		local max_frames = utils.get_maxlen(frames);

		local iteration = 1;
		local timer = vim.uv.new_timer();

		if animation_controls.on_init then
			if animation_controls.__pcall_init == false then
				animation_controls.on_init(win);
			elseif pcall(animation_controls.on_init, win) then
				animation_controls.on_init(win);
			end
		end

		timer:start(animation_controls.delay, animation_controls.interval, vim.schedule_wrap(function ()
			if iteration == max_frames then
				timer:stop();
			end

			if pcall(vim.api.nvim_win_set_config, win, utils.get_current_frame(frames, iteration, animation_controls)) then
				vim.api.nvim_win_set_config(win, utils.get_current_frame(frames, iteration, animation_controls));
			end

			if iteration == max_frames and type(animation_controls.on_complete) == "function" then
				if animation_controls.__pcall_complete == false then
					animation_controls.on_complete(win);
				elseif pcall(animation_controls.on_complete, win) then
					animation_controls.on_complete(win);
				end
			else
				iteration = iteration + 1;
			end
		end));

		return win;
	end
};

animations.cursor = {
	y = function (window, to, animation_controls)
		if not animation_controls then
			animation_controls = { delay = 0, interval = 50, ease = "linear", steps = 10 };
		else
			animation_controls = vim.tbl_extend("keep", animation_controls, { delay = 0, interval = 50, ease = "linear", steps = 10 });
		end

		local current_pos = vim.api.nvim_win_get_cursor(window);
		local frames = utils.scrollFrameGenerator_y(current_pos[1], to, animation_controls);
		local max_frames = #frames;

		-- vim.print(frames)

		local iteration = 1;
		local timer = vim.uv.new_timer();

		if animation_controls.on_init then
			if animation_controls.__pcall_init == false then
				animation_controls.on_init(window);
			elseif pcall(animation_controls.on_init, window) then
				animation_controls.on_init(window);
			end
		end

		timer:start(animation_controls.delay, animation_controls.interval, vim.schedule_wrap(function ()
			if iteration == max_frames then
				timer:stop();
			end

			if pcall(vim.api.nvim_win_set_cursor, window, { frames[iteration], current_pos[2] }) then
				vim.api.nvim_win_set_cursor(window, { frames[iteration], current_pos[2] });
			end

			if iteration == max_frames and type(animation_controls.on_complete) == "function" then
				if animation_controls.__pcall_complete == false then
					animation_controls.on_complete(win);
				elseif pcall(animation_controls.on_complete, win) then
					animation_controls.on_complete(win);
				end
			else
				iteration = iteration + 1;
			end
		end));
	end,
	to = function (window, to, animation_controls)
		if not animation_controls then
			animation_controls = { delay = 0, interval = 50, default = { "linear", 10 } };
		else
			animation_controls = vim.tbl_extend("keep", animation_controls, { delay = 0, interval = 50, default = { "linear", 10 } });
		end

		local current_pos = vim.api.nvim_win_get_cursor(window);
		local frames = utils.frameGenerator(current_pos, to, animation_controls);
		local max_frames = utils.list_get_maxlen(frames);

		local iteration = 1;
		local timer = vim.uv.new_timer();

		timer:start(animation_controls.delay, animation_controls.interval, vim.schedule_wrap(function ()
			if iteration == max_frames then
				timer:stop();
			end

			if pcall(vim.api.nvim_win_set_cursor, window, utils.get_current_frame(frames, iteration)) then
				vim.api.nvim_win_set_cursor(window, utils.get_current_frame(frames, iteration));
			end
			iteration = iteration + 1;
		end));
	end
};

animations.color = {
	to = function (ns_id, hl_group, to, animation_controls)
		local start = vim.api.nvim_get_hl(ns_id, { name = hl_group });

		if not animation_controls then
			animation_controls = { delay = 0, interval = 50, default = { "linear", 10 } };
		else
			animation_controls = vim.tbl_extend("keep", animation_controls, { delay = 0, interval = 50, default = { "linear", 10 } });
		end

		local iteration = 1;
		local timer = vim.uv.new_timer();

		local frames = utils.colorframeGenerator(start, to, animation_controls);
		local max_frames = utils.get_maxlen(frames);

		-- vim.print(frames);
		timer:start(animation_controls.delay, animation_controls.interval, vim.schedule_wrap(function ()
			if iteration == max_frames then
				-- vim.print("Here")
				timer:stop();
			end

			if pcall(vim.api.nvim_set_hl, ns_id, hl_group, utils.get_current_frame(frames, iteration)) then
				vim.api.nvim_set_hl(ns_id, hl_group, utils.get_current_frame(frames, iteration))
			end
			iteration = iteration + 1;
		end));
	end
}

return animations;
