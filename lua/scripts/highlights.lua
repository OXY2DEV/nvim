--- Dynamic highlight groups.
--- Maintainer: MD. Mouinul Hossain
local hl = {};

local function clamp (val, min, max)
	return math.max(math.min(val, max), min);
end

--- Gets attribute from highlight groups.
---@param attr string
---@param from string[]
---@return number | boolean | string | nil
hl.get_attr = function (attr, from)
	---|fS

	attr = attr or "bg";
	from = from or { "Normal" };

	for _, group in ipairs(from) do
		---@type table
		local _hl = vim.api.nvim_get_hl(0, {
			name = group,
			link = false, create = false
		});

		if _hl[attr] then
			return _hl[attr];
		end
	end

	---|fE
end

--- Chooses a color based on 'background'.
---@param light any
---@param dark any
---@return any
hl.choice = function (light, dark)
	return vim.o.background == "dark" and dark or light;
end

--- Linear-interpolation.
---@param a number
---@param b number
---@param x number
---@return number
hl.lerp = function (a, b, x)
	x = x or 0;
	return a + ((b - a) * x);
end

------------------------------------------------------------------------------

--- Turns numeric color code to RGB
---@param num number
---@return integer
---@return integer
---@return integer
hl.num_to_rgb = function(num)
	---|fS

	local hex = string.format("%06x", num)
	local r, g, b = string.match(hex, "^(%x%x)(%x%x)(%x%x)");

	return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16);

	---|fE
end

--- Gamma correction.
---@param c number
---@return number
hl.gamma_to_linear = function (c)
	return c >= 0.04045 and math.pow((c + 0.055) / 1.055, 2.4) or c / 12.92;
end

--- Reverse gamma correction.
---@param c number
---@return number
hl.linear_to_gamma = function (c)
	return c >= 0.0031308 and 1.055 * math.pow(c, 1 / 2.4) - 0.055 or 12.92 * c;
end

--- RGB to OKLab.
---@param r number
---@param g number
---@param b number
---@return number
---@return number
---@return number
hl.rgb_to_oklab = function (r, g, b)
	---|fS

	local R, G, B = hl.gamma_to_linear(r / 255), hl.gamma_to_linear(g / 255), hl.gamma_to_linear(b / 255);

	local L = math.pow(0.4122214708 * R + 0.5363325363 * G + 0.0514459929 * B, 1 / 3);
	local M = math.pow(0.2119034982 * R + 0.6806995451 * G + 0.1073969566 * B, 1 / 3);
	local S = math.pow(0.0883024619 * R + 0.2817188376 * G + 0.6299787005 * B, 1 / 3);

	return
		L *  0.2119034982 + M *  0.7936177850 + S * -0.0040720468,
		L *  1.9779984951 + M * -2.4285922050 + S *  0.4505937099,
		L *  0.0259040371 + M *  0.7827717662 + S * -0.8086757660
	;

  ---|fE
end

--- OKLab to RGB.
---@param l number
---@param a number
---@param b number
---@return number
---@return number
---@return number
hl.oklab_to_rgb = function (l, a, b)
	---|fS

	local L = math.pow(l + a *  0.3963377774 + b *  0.2158037573, 3);
	local M = math.pow(l + a * -0.1055613458 + b * -0.0638541728, 3);
	local S = math.pow(l + a * -0.0894841775 + b * -1.2914855480, 3);

	local R = L *  4.0767416621 + M * -3.3077115913 + S *  0.2309699292;
	local G = L * -1.2684380046 + M *  2.6097574011 + S * -0.3413193965;
	local B = L * -0.0041960863 + M * -0.7034186147 + S *  1.7076147010;

	R = clamp(255 * hl.linear_to_gamma(R), 0, 255);
	G = clamp(255 * hl.linear_to_gamma(G), 0, 255);
	B = clamp(255 * hl.linear_to_gamma(B), 0, 255);

  return R, G, B;

  ---|fE
end

------------------------------------------------------------------------------

hl.visible_fg = function (lumen)
	local BL, BA, BB = hl.rgb_to_oklab(
		hl.num_to_rgb(
			hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
		)
	);

	local FL, FA, FB = hl.rgb_to_oklab(
		hl.num_to_rgb(
			hl.get_attr("fg", { "Normal" }) or hl.choice(5001065, 13489908)
		)
	);

	if lumen < 0.5 then
		if BL > FL then
			return BL, BA, BB;
		else
			return FL, FA, FB;
		end
	else
		if BL < FL then
			return BL, BA, BB;
		else
			return FL, FA, FB;
		end
	end
end

---@type table<string, fun(): table[]>
hl.groups = {};

hl.setup = function ()
	for _, entry in pairs(hl.groups) do
		---@type boolean, table[]?
		local can_call, val = pcall(entry);

		if can_call and val then
			for _, _hl in ipairs(val) do
				assert(
					pcall(vim.api.nvim_set_hl, 0, _hl.group_name, _hl.value)
				);
			end
		end
	end
end

return hl;
