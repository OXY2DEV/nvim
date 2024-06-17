local anim = require("scripts/animations");

local transitionEffect = function (ease_name, from, to, steps)
	local values = {};

	for i = 0, steps - 1 do
		table.insert(values, anim.ease(ease_name, from, to, i * (1 / (steps - 1))));
	end

	return values;
end

vim.api.nvim_create_user_command("Open", function (options)
	local window, animationValues, animationValues_2;
	local timer = vim.uv.new_timer();

	local params = options.fargs;

	local buf_load = tonumber(params[1]) or 0;
	local win_style = params[2] or "float";


	if win_style == "float" then
		local rel = params[3] or "win";

		local width = tonumber(params[4]) or 40;
		local height = tonumber(params[5]) or 20;

		local x = tonumber(params[6]) or 10;
		local y = tonumber(params[7]) or 10;
		
		local blend = tonumber(params[8]) or 100;

		local anim_style = params[9] or "winblend";

		local anim_steps = tonumber(params[9]) or 10;
		local anim_ease = params[10] or "linear";

		window = vim.api.nvim_open_win(buf_load, true, {
			relative = rel,

			row = anim_style ~= "y" and y or 0,
			col = anim_style ~= "x" and x or 0,

			width = (anim_style ~= "width" and anim_style ~= "both") and width or 1,
			height = (anim_style ~= "height" and anim_style ~= "both") and height or 1,
		})

		vim.wo.winblend = blend;

		if anim_style == "winblend" then
			vim.wo.winblend = 10;
			animationValues = transitionEffect(anim_ease, 10, blend, 10);

			timer:start(0, 50, vim.schedule_wrap(function ()
				if #animationValues == 0 then
					timer:stop();
					return;
				end

				vim.wo.winblend = math.floor(table.remove(animationValues));
			end))
		elseif anim_style == "width" then
			animationValues = transitionEffect(anim_ease, 0, width, 10);
			
			timer:start(0, 50, vim.schedule_wrap(function ()
				if #animationValues == 0 then
					timer:stop();
					return;
				end

				vim.api.nvim_win_set_width(window, math.floor(table.remove(animationValues, 1)))
			end))
		elseif anim_style == "height" then
			animationValues = transitionEffect(anim_ease, 0, height, 10);
			
			timer:start(0, 50, vim.schedule_wrap(function ()
				if #animationValues == 0 then
					timer:stop();
					return;
				end

				vim.api.nvim_win_set_height(window, math.floor(table.remove(animationValues, 1)))
			end))
		elseif anim_style == "both" then
			animationValues = transitionEffect(anim_ease, 0, width, 10);
			animationValues_2 = transitionEffect(anim_ease, 0, height, 10);
			
			timer:start(0, 50, vim.schedule_wrap(function ()
				if #animationValues == 0 then
					timer:stop();
					return;
				end

				vim.api.nvim_win_set_width(window, math.floor(table.remove(animationValues, 1)))
				vim.api.nvim_win_set_height(window, math.floor(table.remove(animationValues_2, 1)))
			end))
		end
	elseif win_style == "vertical" then
		local width = params[3] or 10;
		local sp_dir = params[4] or "left";

		local anim = params[5] or false;
		local anim_steps = params[6] or 10;
		local anim_ease = params[7] or "linear";

		window = vim.api.nvim_open_win(buf_load, true, {
			width = anim == false and width or 1,
			vertical = true,
			split = sp_dir
		})

		if anim == false then
			return;
		end

		animationValues = transitionEffect(anim_ease, 0, width, anim_steps);

		timer:start(0, 50, vim.schedule_wrap(function ()
			if #animationValues == 0 then
				timer:stop();
				return;
			end

			vim.api.nvim_win_set_width(window, math.floor(table.remove(animationValues, 1)))
		end))
	elseif win_style == "horizontal" then
		local height = params[3] or 10;
	end

end, {
	nargs = "*",
	desc = "Open up a new window"
});

