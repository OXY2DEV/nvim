local utils = {};

---+ Icon: " " Title: "rgb number to table converter" BorderL: " " BorderR: " "
--- @param color = number
--- @return table
utils.rgbToTable = function (color)
	local hex = string.format("%x", color);

	return {
		r = tonumber(string.sub(hex, 1, 2), 16),
		g = tonumber(string.sub(hex, 3, 4), 16),
		b = tonumber(string.sub(hex, 5, 6), 16),
	};
end
--_

---+ Icon: " " Title: "hex color to table converter" BorderL: " " BorderR: " "
--- @param color string
--- @rwturn table
utils.hexToTable = function (color)
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
--- @param ease string
--- @param from number
--- @param to number
--- @param position number
--- @return number
utils.ease = function(ease, from, to, position)
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

utils.createFrames = function (ease_name, from, to, steps, floor)
	local frames = {};

	for f = 0, (steps - 1) do
		if floor == true then
			table.insert(frames, math.floor(utils.ease(ease_name, from, to, f * (1 / (steps - 1)))));
		else
			table.insert(frames, utils.ease(ease_name, from, to, f * (1 / (steps - 1))));
		end
	end

	return frames;
end

utils.createColors = function (ease_name, from, to, steps, floor)
	local frames = {};

	local start = utils.rgbToTable(from);
	local stop = utils.hexToTable(to);

	for f = 0, (steps - 1) do
		local r, g, b;

		if floor == true then
			r = math.floor(utils.ease(ease_name, start.r, stop.r, f * (1 / (steps - 1))))
			g = math.floor(utils.ease(ease_name, start.g, stop.g, f * (1 / (steps - 1))))
			b = math.floor(utils.ease(ease_name, start.b, stop.b, f * (1 / (steps - 1))))

			table.insert(frames, string.format("#%x%x%x", r, g, b));
		else
			r = utils.ease(ease_name, start.r, stop.r, f * (1 / (steps - 1)))
			g = utils.ease(ease_name, start.g, stop.g, f * (1 / (steps - 1)))
			b = utils.ease(ease_name, start.b, stop.b, f * (1 / (steps - 1)))

			table.insert(frames, string.format("#%x%x%x", r, g, b));
		end
	end

	return frames;
end

return utils;
