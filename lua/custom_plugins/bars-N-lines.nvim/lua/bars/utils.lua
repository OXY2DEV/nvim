local utils = {}

---+ Title: "Turns color tables to hex color codes"
---@param color { r: number, g: number, b: number } Table containing the color
---@return string # Hexadecimal color code
utils.toStr = function (color)
	local R = #string.format("%x", color.r) == 1 and "0" .. string.format("%x", color.r) or string.format("%x", color.r);
	local G = #string.format("%x", color.g) == 1 and "0" .. string.format("%x", color.g) or string.format("%x", color.g);
	local B = #string.format("%x", color.b) == 1 and "0" .. string.format("%x", color.b) or string.format("%x", color.b);

	return "#" .. R .. G .. B;
end
---_

---+ Icon: " " Title: "rgb number to table converter" BorderL: " " BorderR: " "
--- @param color number Number returned by "nvim_get_hl()"
--- @return table # Table with r, g, b values
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
--- @param color string Hexadecimal color code
--- @return table
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
--- @param ease string The name of the easing function to use
--- @param from number Starting value
--- @param to number Final value
--- @param position number % position from the start value to the final value
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
		easeValue = position < 0.5 and 2 * (position ^ 2) or 1 - (((-2 * position + 2) ^ 2) / 2);
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

return utils;
