local beaconSpace = vim.api.nvim_create_namespace("beacon");
local beaconTimer = vim.uv.new_timer();

---+ Icon: " " Title: "rgb number to table converter" BorderL: " " BorderR: " "
local rgbToTable = function (color)
	local hex = string.format("%x", color);

	return {
		r = tonumber(string.sub(hex, 1, 2), 16),
		g = tonumber(string.sub(hex, 3, 4), 16),
		b = tonumber(string.sub(hex, 5, 6), 16),
	};
end
--_

---+ Icon: " " Title: "hex color to table converter" BorderL: " " BorderR: " "
local hexToTable = function (color)
	local hex = string.gsub(color, "#", "");

	if #hex == 3 then
		return {
			r = tonumber(string.sub(hex, 1, 1), 16),
			g = tonumber(string.sub(hex, 2, 2), 16),
			b = tonumber(string.sub(hex, 3, 3), 16),
		};
	else
		return {
			r = tonumber(string.sub(hex, 1, 2), 16),
			g = tonumber(string.sub(hex, 3, 4), 16),
			b = tonumber(string.sub(hex, 5, 6), 16),
		};
	end
end
--_

---+ Icon: " " Title: "Do eased interpolation" BorderL: " " BorderR: " "
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

local gradient = function(from, to, steps, animationSteps, gradientEase, animationEase)
	local totalColors = {};
	local animationValues = {};

	local add = 1 / (steps - 1)
	for i = 0, steps - 1 do
		local R = ease(gradientEase, from.r, to.r, i * add);
		local G = ease(gradientEase, from.g, to.g, i * add);
		local B = ease(gradientEase, from.b, to.b, i * add);

		vim.api.nvim_set_hl(0, "Beacon_" .. i, { bg = string.format("#%x%x%x", R, G, B) });
		totalColors["Beacon_" .. i] =  string.format("#%x%x%x", R, G, B);
	end

	for groupName, color in pairs(totalColors) do
		local animCol = hexToTable(color);
		local animAdd = (1 / (animationSteps - 1));
		animationValues[groupName] = {};

		for j = 0, animationSteps - 1 do
			local R = ease(animationEase, animCol.r, to.r, j * animAdd);
			local G = ease(animationEase, animCol.g, to.g, j * animAdd);
			local B = ease(animationEase, animCol.b, to.b, j * animAdd);

			table.insert(animationValues[groupName], string.format("#%x%x%x", R, G, B));
		end
	end

	return totalColors, animationValues
end


local colCount = 5;
local normalBg =  vim.api.nvim_get_hl(0, { name = "Normal" }).bg;
local color = { r = 203, g = 166, b = 247 };

local startDelay = 750;
local loopDelay = 50;
local currentFrame = 1;

local animationSteps = 20;
local gradientEase = "linear";
local animationEase = "ease-out-sine";

local startColors, animationValues;


vim.api.nvim_create_user_command("Beacon", function(options)
	local posY, posX = vim.api.nvim_win_get_cursor(0)[1] - 1, vim.api.nvim_win_get_cursor(0)[2];
	local availableWidth = #table.concat(vim.api.nvim_buf_get_lines(0, posY, posY + 1, false));

	if availableWidth < 1 then
		return;
	end
	
	if options.fargs[1] ~= nil then
		colCount = tonumber(options.fargs[1]);
	else
		colCount = 6
	end

	if vim.o.cursorline == true then
		normalBg = vim.api.nvim_get_hl(0, { name = "CursorLine" }).bg;
	else
		normalBg =  vim.api.nvim_get_hl(0, { name = "Normal" }).bg
	end

	if options.fargs[2] ~= nil then
		color = hexToTable(options.fargs[2]);
	else
		color = { r = 203, g = 166, b = 247 }
	end

	if options.fargs[3] ~= nil then
		animationSteps = tonumber(options.fargs[3]);
	else
		animationSteps = 20;
	end

	if options.fargs[4] ~= nil then
		gradientEase = options.fargs[4];
	else
		gradientEase = "linear";
	end

	if options.fargs[5] ~= nil then
		animationEase = options.fargs[5];
	else
		animationEase = "ease-out-sine";
	end

	if options.fargs[6] ~= nil then
		startDelay = tonumber(options.fargs[6]);
	else
		startDelay = 500;
	end

	if options.fargs[7] ~= nil then
		loopDelay = tonumber(options.fargs[7]);
	else
		loopDelay = 50;
	end

	startColors, animationValues = gradient(color, rgbToTable(normalBg), colCount, animationSteps, gradientEase, animationEase);
	local extMove = (availableWidth - (posX + colCount)) > 0 and 1 or -1;

	for n = 0, colCount - 1 do
		if posX < 0 or posX > availableWidth then
			break;
		end

		vim.api.nvim_buf_set_extmark(0, beaconSpace, posY, posX, {
			end_col = posX + 1,
			hl_group = "Beacon_" .. n,

			priority = 200
		});

		n = n + 1;
		posX = posX + extMove;
	end


	beaconTimer:start(startDelay, loopDelay, vim.schedule_wrap(function ()
		for groupName, values in pairs(animationValues) do
    		if values[currentFrame] == nil then
    			vim.api.nvim_buf_clear_namespace(0, beaconSpace, posY, posY + 1);

				currentFrame = 1;
    			beaconTimer:stop();
    			return;
    		end

    		vim.api.nvim_set_hl(0, groupName, { bg = values[currentFrame] });
    	end

    	currentFrame = currentFrame + 1;
    end))

end, {
	nargs = "*",
	desc = "Show me where my cursor is!"
})
