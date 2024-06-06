---+ Icon: " " Title: "Do eased interpolation" BorderL: " " BorderR: " "
--- @param ease string
--- @param from number
--- @param to number
--- @param position number
--- @return number
local ease = function(ease, from, to, position)
	local easeValue = 0;

	if ease == "linear" then
		easeValue = position;
	elseif ease == "ease-in-sine" then
		easeValue = 1 - math.cos((position * math.pi) / 2);
	elseif ease == "ease-out-sine" then
		easeValue = math.sin((position * math.pi) / 2);
	elseif ease == "ease-in-out-sine" then
		easeValue = -(math.cos(position * math.pi) - 1) / 2;
	elseif ease == "ease-in-quad" then
		easeValue = position ^ 2;
	elseif ease == "ease-out-quad" then
		easeValue = 1 - ((1 - position) ^ 2);
	elseif ease == "ease-in-out-quad" then
		easeValue = position < 0.5 and 2 * (y ^ 2) or 1 - (((-2 * position + 2) ^ 2) / 2);
	elseif ease == "ease-in-cubic" then
		easeValue = position ^ 3;
	elseif ease == "ease-out-cubic" then
		easeValue = 1 - ((1 - position) ^ 3);
	elseif ease == "ease-in-out-cubic" then
		easeValue = position < 0.5 and 4 * (position ^ 3) or 1 - (((-2 * position + 2) ^ 3) / 2);
	elseif ease == "ease-in-quart" then
		easeValue = position ^ 4;
	elseif ease == "ease-out-quart" then
		easeValue = 1 - ((1 - position) ^ 4);
	elseif ease == "ease-in-out-quart" then
		easeValue = position < 0.5 and 8 * (position ^ 4) or 1 - (((-2 * position + 2) ^ 4) / 2);
	elseif ease == "ease-in-quint" then
		easeValue = position ^ 5;
	elseif ease == "ease-out-quint" then
		easeValue = 1 - ((1 - position) ^ 5);
	elseif ease == "ease-in-out-quint" then
		easeValue = position < 0.5 and 16 * (position ^ 5) or 1 - (((-2 * position + 2) ^ 5) / 2);
	elseif ease == "ease-in-circ" then
		easeValue = 1 - math.sqrt(1 - (position ^ 2));
	elseif ease == "ease-out-circ" then
		easeValue = math.sqrt(1 - ((position - 1) ^ 2));
	elseif ease == "ease-in-out-circ" then
		easeValue = position < 0.5 and (1 - math.sqrt(1 - ((2 * y) ^ 2))) / 2 or (math.sqrt(1 - ((-2 * y + 2) ^ 2)) + 1) / 2;
	end

	return from + ((to - from) * easeValue);
end
--_



local jumpTimer = vim.uv.new_timer();



vim.api.nvim_create_user_command("Jump", function (options)
	local args = options.fargs;
	local currY, currX = vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_win_get_cursor(0)[2];
	local jumpY, jumpX = 0, 0;

	local steps = 5;
	local positions = {};

	if args[1] ~= nil then
		jumpX = tonumber(args[1]);
	end

	if args[2] ~= nil then
		jumpY = tonumber(args[2]);
	end

	for s = 0, steps - 1 do
		table.insert(positions, {
			ease("linear", currX, jumpX, (1 / (steps - 1)) * s),
			ease("linear", currY, jumpY, (1 / (steps - 1)) * s)
		});
	end

	jumpTimer:start(500, 100, vim.schedule_wrap(function ()
		if #positions == 0 then
			jumpTimer:stop();
			return;
		end


		local nowPos = table.remove(positions, 1);
		local maxY = vim.api.nvim_buf_line_count(0) - 1;
		local maxX = vim.fn.strchars(vim.api.nvim_buf_get_lines(0, nowPos.y - 1, nowPos.y, false));

		if nowPos.x > maxX then
			nowPos.x = maxX;
		end

		if nowPos.y > maxY then
			nowPos.y = maxY;
		end

		vim.print(nowPos)
		--vim.api.nvim_win_set_cursor(0, { 1, 5 });
	end));
end, {
	nargs = "*",
	desc = "Move the cursor with style"
});
