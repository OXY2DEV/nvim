--- *Dynamic* highlight group related methods
--- for `markview.nvim`.
--- 
local highlights = {};

--- Clamps a value between a range
---@param val number
---@param min number
---@param max number
---@return number
local function clamp (val, min, max)
	return math.min(math.max(val, min), max);
end

---|fS${func, Helper functions}

--- Returns RGB value from the provided input.
--- Supported input types,
---     • Hexadecimal values(`#FFFFFF` & `FFFFFF`).
---     • Number value of the hexadecimal color(from `nvim_get_hl()`).
---     • Color name(e.g. `red`, `green`).
--- 
---@param input string | number[]
---@return number[]?
highlights.rgb = function (input)
	---|fS${func}

	--- Lookup table for the regular color names.
	--- For example,
	---     • `red` → `#FF0000`.
	---     • `green` → `#00FF00`.
	--- 
	---@type { [string]: string }
	local lookup = {
		---|fS ${class, Color name lookup table}
		["red"] = "#FF0000",        ["lightred"] = "#FFBBBB",      ["darkred"] = "#8B0000",
		["green"] = "#00FF00",      ["lightgreen"] = "#90EE90",    ["darkgreen"] = "#006400",    ["seagreen"] = "#2E8B57",
		["blue"] = "#0000FF",       ["lightblue"] = "#ADD8E6",     ["darkblue"] = "#00008B",     ["slateblue"] = "#6A5ACD",
		["cyan"] = "#00FFFF",       ["lightcyan"] = "#E0FFFF",     ["darkcyan"] = "#008B8B",
		["magenta"] = "#FF00FF",    ["lightmagenta"] = "#FFBBFF",  ["darkmagenta"] = "#8B008B",
		["yellow"] = "#FFFF00",     ["lightyellow"] = "#FFFFE0",   ["darkyellow"] = "#BBBB00",   ["brown"] = "#A52A2A",
		["grey"] = "#808080",       ["lightgrey"] = "#D3D3D3",     ["darkgrey"] = "#A9A9A9",
		["gray"] = "#808080",       ["lightgray"] = "#D3D3D3",     ["darkgray"] = "#A9A9A9",
		["black"] = "#000000",      ["white"] = "#FFFFFF",
		["orange"] = "#FFA500",     ["purple"] = "#800080",        ["violet"] = "#EE82EE"
		---|fE
	};

	--- Lookup table for the Neovim-specific color names.
	--- For example,
	---     • `nvimdarkblue` → `#004C73`.
	---     • `nvimdarkred` → `#590008`.
	--- 
	---@type { [string]: string }
	local lookup_nvim = {
		---|fS ${class, Neovim's color lookup table}
		["nvimdarkblue"] = "#004C73",    ["nvimlightblue"] = "#A6DBFF",
		["nvimdarkcyan"] = "#007373",    ["nvimlightcyan"] = "#8CF8F7",
		["nvimdarkgray1"] = "#07080D",   ["nvimlightgray1"] = "#EEF1F8",
		["nvimdarkgray2"] = "#14161B",   ["nvimlightgray2"] = "#E0E2EA",
		["nvimdarkgray3"] = "#2C2E33",   ["nvimlightgray3"] = "#C4C6CD",
		["nvimdarkgray4"] = "#4F5258",   ["nvimlightgray4"] = "#9B9EA4",
		["nvimdarkgrey1"] = "#07080D",   ["nvimlightgrey1"] = "#EEF1F8",
		["nvimdarkgrey2"] = "#14161B",   ["nvimlightgrey2"] = "#E0E2EA",
		["nvimdarkgrey3"] = "#2C2E33",   ["nvimlightgrey3"] = "#C4C6CD",
		["nvimdarkgrey4"] = "#4F5258",   ["nvimlightgrey4"] = "#9B9EA4",
		["nvimdarkgreen"] = "#005523",   ["nvimlightgreen"] = "#B3F6C0",
		["nvimdarkmagenta"] = "#470045", ["nvimlightmagenta"] = "#FFCAFF",
		["nvimdarkred"] = "#590008",     ["nvimlightred"] = "#FFC0B9",
		["nvimdarkyellow"] = "#6B5300",  ["nvimlightyellow"] = "#FCE094",
		---|fE
	};

	if type(input) == "string" then
		---|fS${lua}

		--- Match cases,
		---     • RR GG BB, # is optional.
		---     • R G B, # is optional.
		---     • Color name.
		---     • HSL values(as `{ h, s, l }`)

		if input:match("^%#?(%x%x?)(%x%x?)(%x%x?)$") then
			--- Pattern explanation:
			---     #? RR? GG? BB?
			--- String should have **3** parts & each part
			--- should have a minimum of *1* & a maximum
			--- of *2* characters.
			---
			--- # is optional.
			---
			---@type string, string, string
			local r, g, b = input:match("^%#?(%x%x?)(%x%x?)(%x%x?)$");

			return { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) };
		elseif lookup[input] then
			local r, g, b = lookup[input]:match("(%x%x)(%x%x)(%x%x)$");

			return { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) };
		elseif lookup_nvim[input] then
			local r, g, b = lookup_nvim[input]:match("(%x%x)(%x%x)(%x%x)$");

			return { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) };
		end

		---|fE
	elseif type(input) == "number" then
		---|fS${lua}

		--- Format the number into a hexadecimal string.
		--- Then get the **r**, **g**, **b** parts.
		--- 
		---@type string, string, string
		local r, g, b = string.format("%06x", input):match("(%x%x)(%x%x)(%x%x)$");

		return { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) };

		---|fE
	end
	---|fE
end

--- Simple RGB *color-mixer* function.
--- Supports mixing colors by % values.
---
--- NOTE: `per_1` & `per_2` are between
--- **0** & **1**.
--- 
---@param c_1 number[]
---@param c_2 number[]
---@param per_1 number
---@param per_2 number
---@return number[]
highlights.mix = function (c_1, c_2, per_1, per_2)
	local _r = (c_1[1] * per_1) + (c_2[1] * per_2);
	local _g = (c_1[2] * per_1) + (c_2[2] * per_2);
	local _b = (c_1[3] * per_1) + (c_2[3] * per_2);

	return { math.floor(_r), math.floor(_g), math.floor(_b) };
end

--- RGB to hexadecimal string converter.
---
---@param color number[]
---@return string
highlights.rgb_to_hex = function (color)
	return string.format("#%02x%02x%02x", math.floor(color[1]), math.floor(color[2]), math.floor(color[3]))
end

--- RGB to HSL converter.
--- Input: `{ r, g, b }` where,
---   r ∈ [0, 255]
---   g ∈ [0, 255]
---   b ∈ [0, 255]
---
--- Return: `{ h, s, l }` where,
---   h ∈ [0, 360]
---   s ∈ [0, 1]
---   l ∈ [0, 1]
---
---@param color number[]
---@return number[]
highlights.rgb_to_hsl = function (color)
	---|fS${func}

	local nR, nG, nB = color[1] / 255, color[2] / 255, color[3] / 255;
	local min, max = math.min(nR, nG, nB), math.max(nR, nG, nB);

	local h, s, l;
	l = (min + max) / 2;

	if min == max then
		s = 0;
	elseif l <= 0.5 then
		s = (max - min) / (max + min);
	else
		s = (max - min) / (2 - max - min);
	end

	if max == nR then
		h = (nG - nB) / (max - min);
	elseif max == nG then
		h = 2 + (nB - nR) / (max - min);
	else
		h = 4 + (nR - nG) / (max - min);
	end

	if h < 0 then
		h = 1 - h;
	end

	return { h * 60, s, l };

	---|fE
end

--- HSL to RGB converter.
--- Input: `{ h, s, l }` where,
---   h ∈ [0, 360]
---   s ∈ [0, 1]
---   l ∈ [0, 1]
---
--- Return: `{ r, g, b }` where,
---   r ∈ [0, 255]
---   g ∈ [0, 255]
---   b ∈ [0, 255]
---
---@param color integer[]
highlights.hsl_to_rgb = function (color)
	---|fS${func}

	local h, s, l = color[1] / 360, color[2], color[3];

	if s == 0 then
		return { l * 255, l * 255, l * 255 };
	end

	local tmp_1, tmp_2;

	if l < 0.5 then
		tmp_1 = l * (1 + s);
	else
		tmp_1 = l + s - (l * s);
	end

	tmp_2 = (2 * l) - tmp_1;
	local tR, tG, tB;

	tR = h + 0.333;
	tG = h;
	tB = h - 0.333;

	tR = tR < 0 and tR + 1 or tR;
	tG = tG < 0 and tG + 1 or tG;
	tB = tB < 0 and tB + 1 or tB;

	local function checker (val)
		if 6 * val < 1 then
			return tmp_2 + (tmp_1 - tmp_2) * 6 * val;
		elseif 2 * val < 1 then
			return tmp_1;
		elseif 3 * val < 2 then
			return tmp_2 + (tmp_1 - tmp_2) * (0.666 - val) * 6;
		else
			return tmp_2;
		end
	end

	return {
		clamp(checker(tR) * 255, 0, 255),
		clamp(checker(tG) * 255, 0, 255),
		clamp(checker(tB) * 255, 0, 255),
	};

	---|fE
end

--- Gets the luminosity of a RGB value.
---
--- Input: `{ r, g, b }` where,
---   r ∈ [0, 255]
---   g ∈ [0, 255]
---   b ∈ [0, 255]
---
--- Return: `l` where,
---   l ∈ [0, 1]
---
---@param input number[]
---@return number
highlights.lumen = function (input)
	local min = math.min(input[1], input[2], input[3]);
	local max = math.max(input[1], input[2], input[3]);

	return (min + max) / 2;
end

--- Turns RGB color-space into XYZ.
---
--- Input: `{ r, g, b }` where,
---   r ∈ [0, 255]
---   g ∈ [0, 255]
---   b ∈ [0, 255]
---
---@param color number[]
---@return number[]
highlights.rgb_to_xyz = function (color)
	---|fS${func}

	local RGB = {};

	for c, channel in ipairs(color) do
		local _ch = channel / 255;

		if _ch <= 0.04045 then
			_ch = _ch / 12.92;
		else
			_ch = ((_ch + 0.055) / 1.055)^2.4;
		end

		RGB[c] = _ch;
	end

	local matrix = {
		0.4124504, 0.3575761, 0.1804375,
		0.2126729, 0.7151522, 0.0721750,
		0.0193339, 0.1191920, 0.9503041
	};

	return {
		(RGB[1] * matrix[1] + RGB[2] * matrix[2] + RGB[3] * matrix[3]) * 100,
		(RGB[1] * matrix[4] + RGB[2] * matrix[5] + RGB[3] * matrix[6]) * 100,
		(RGB[1] * matrix[7] + RGB[2] * matrix[8] + RGB[3] * matrix[9]) * 100
	}
	---|fE
end

--- Turns XYZ color-space into RGB.
---@param color number[]
---@return number[]
highlights.xyz_to_rgb = function (color)
	---|fS${func}

	local XYZ = color;

	for c, channel in ipairs(color) do
		local _ch = channel / 100;
		XYZ[c] = _ch;
	end

	local rev_matrix = {
		3.2404542, -1.5371385, -0.4985314,
		-0.9692660, 1.8760108, 0.0415560,
		0.0556434, -0.2040259, 1.0572252
	};

	local RGB = {
		XYZ[1] * rev_matrix[1] + XYZ[2] * rev_matrix[2] + XYZ[3] * rev_matrix[3],
		XYZ[1] * rev_matrix[4] + XYZ[2] * rev_matrix[5] + XYZ[3] * rev_matrix[6],
		XYZ[1] * rev_matrix[7] + XYZ[2] * rev_matrix[8] + XYZ[3] * rev_matrix[9]
	};

	for c, channel in ipairs(RGB) do
		local _ch = channel;

		if _ch <= 0.0031308 then
			_ch = _ch * 12.92;
		else
			_ch = (1.055 * (_ch^(1 / 2.4))) - 0.055;
		end

		RGB[c] = clamp(_ch * 255, 0, 255);
	end

	return RGB;
	---|fE
end

--- Turns XYZ color-space into Lab.
---@param color number[]
---@return number[]
highlights.xyz_to_lab = function (color)
	---|fS${func}

	local ref_point = { 95.047, 100, 108.883 };

	local f = function (t)
		if t > (6 / 29)^3 then
			return t^(1/3);
		else
			return ( (1 / 3) * t * ((6 / 29)^-2) ) + (4 / 29);
		end
	end

	return {
		( 116 * f(color[2] / ref_point[2]) ) - 16,
		500 * (  f(color[1] / ref_point[1]) - f(color[2] / ref_point[2]) ),
		200 * (  f(color[2] / ref_point[2]) - f(color[3] / ref_point[3]) )
	};
	---|fE
end

--- Turns Lab color-space into XYZ.
---@param color number[]
---@return number[]
highlights.lab_to_xyz = function (color)
	---|fS${func}

	local ref_point = { 95.047, 100, 108.883 };

	local f_inv = function (t)
		if t > (6 / 29) then
			return t^3;
		else
			return 3 * ((6 / 29)^2) * (t - (4 / 29));
		end
	end

	local tmp = (color[1] + 16) / 116;

	return {
		ref_point[1] * f_inv( tmp + (color[2] / 500) ),
		ref_point[2] * f_inv(tmp),
		ref_point[3] * f_inv( tmp - (color[3] / 200) )
	};
	---|fE
end

--- Turns RGB color-space into Lab.
---@param RGB number[]
---@return number[]
highlights.rgb_to_lab = function (RGB)
	local XYZ = highlights.rgb_to_xyz(RGB);
	return highlights.xyz_to_lab(XYZ);
end

--- Turns Lab color-space into RGB.
---@param Lab number[]
---@return number[]
highlights.lab_to_rgb = function (Lab)
	local XYZ = highlights.lab_to_xyz(Lab);
	return highlights.xyz_to_rgb(XYZ);
end
---|fE

--- Holds info about highlight groups.
---@type string[]
highlights.created = {};

--- Wrapper function for `nvim_set_hl()`.
---@param name string
---@param value table
highlights.set_hl = function (name, value)
	local success, err = pcall(vim.api.nvim_set_hl, 0, name, value);

	if success == false then
		-- health.notify("hl", {
		-- 	group = name,
		-- 	value = value,
		--
		-- 	message = err
		-- });
	end
end

--- Creates highlight groups from an array of tables
---@param array { [string]: config.hl | fun(): config.hl }
highlights.create = function (array)
	---|fS${lua}

	if type(array) == "string" then
		if not highlights[array] then
			return;
		end

		array = highlights[array];
	end

	local hls = vim.tbl_keys(array) or {};
	table.sort(hls);

	for _, hl in ipairs(hls) do
		local value = array[hl];

		if type(value) == "table" then
			highlights.set_hl(hl, value);
		else
			local val = value();

			if vim.islist(val) then
				for _, item in ipairs(val) do
					highlights.set_hl(item.group_name, item.value);
				end
			else
				highlights.set_hl(hl, val);
			end
		end
	end
	---|fE
end

--- Is the background "dark"?
--- Returns values based on this condition(when provided).
---@param on_light any
---@param on_dark any
---@return any
local is_dark = function (on_light, on_dark)
	return vim.o.background == "dark" and (on_dark or true) or (on_light or false);
end

--- Gets {property} from a list of highlight groups.
---@param property string
---@param groups string[]
---@param light any
---@param dark any
---@return any
highlights.get_property = function (property, groups, light, dark, strict)
	---|fS${lua}

	local val;

	for _, item in ipairs(groups) do
		if
			vim.fn.hlexists(item) and
			vim.api.nvim_get_hl(0, { name = item, link = false })[property]
		then
			val = vim.api.nvim_get_hl(0, { name = item, link = false })[property];
			break;
		end
	end

	if val then
		if vim.list_contains({ "fg", "bg", "sp" }, property) then
			local normal = vim.api.nvim_get_hl(0, { name = "normal", link = false })[property];

			if strict == true and val == normal then
				return highlights.rgb(is_dark(light, dark));
			else
				return highlights.rgb(val);
			end
		else
			return val;
		end
	end

	return vim.list_contains({ "fg", "bg", "sp" }, property) and highlights.rgb(is_dark(light, dark)) or is_dark(light, dark);
	---|fE
end

---@type { [string]: function }
highlights.groups = {
	["A0"] = function ()
		---|fS

		--- Main color
		local c1 = highlights.get_property("fg", {
			"Normal",
		}, "#7C7F93", "#9399B2");
		--- Background
		local c2 = highlights.get_property("bg", {
			"Normal",
		}, "#EFF1F5", "#1E1E2E");

		local lumen = highlights.lumen(c1);
		local FG = lumen > 0.5 and "#4C4F69" or "#CDD6F4";

		return {
			{
				group_name = "Palette0",
				value = {
					bg = highlights.rgb_to_hex(c1),
					fg = FG
				}
			},
			{
				group_name = "Palette0I",
				value = {
					fg = highlights.rgb_to_hex(c1),
				}
			},
			{
				group_name = "Palette0R",
				value = {
					fg = highlights.rgb_to_hex(c2),
					bg = highlights.rgb_to_hex(c1),
				}
			},
		};

		---|fE
	end,
	["A1"] = function ()
		---|fS

		--- Main color
		local c1 = highlights.get_property("fg", {
			"@diff.add", "@string"
		}, "#40A02B", "#A6E3A1", true);
		--- Background
		local c2 = highlights.get_property("bg", {
			"Normal",
		}, "#EFF1F5", "#1E1E2E");

		local lumen = highlights.lumen(c1);
		local FG = lumen > 0.5 and "#4C4F69" or "#CDD6F4";

		return {
			{
				group_name = "Palette1",
				value = {
					bg = highlights.rgb_to_hex(c1),
					fg = FG
				}
			},
			{
				group_name = "Palette1I",
				value = {
					fg = highlights.rgb_to_hex(c1),
				}
			},
			{
				group_name = "Palette1R",
				value = {
					fg = highlights.rgb_to_hex(c2),
					bg = highlights.rgb_to_hex(c1),
				}
			},
		};

		---|fE
	end,
	["A2"] = function ()
		---|fS

		--- Main color
		local c1 = highlights.get_property("fg", {
			"@function", "@diff.delta"
		}, "#1E66F5", "#89B4FA", true);
		--- Background
		local c2 = highlights.get_property("bg", {
			"Normal",
		}, "#EFF1F5", "#1E1E2E");

		local lumen = highlights.lumen(c1);
		local FG = lumen > 0.5 and "#4C4F69" or "#CDD6F4";

		return {
			{
				group_name = "Palette2",
				value = {
					bg = highlights.rgb_to_hex(c1),
					fg = FG
				}
			},
			{
				group_name = "Palette2I",
				value = {
					fg = highlights.rgb_to_hex(c1),
				}
			},
			{
				group_name = "Palette2R",
				value = {
					fg = highlights.rgb_to_hex(c2),
					bg = highlights.rgb_to_hex(c1),
				}
			},
		};

		---|fE
	end,
	["A3"] = function ()
		---|fS

		--- Main color
		local c1 = highlights.get_property("fg", {
			"@character.special", "Special"
		}, "#EA76CB", "#F5C2E7", true);
		--- Background
		local c2 = highlights.get_property("bg", {
			"Normal",
		}, "#EFF1F5", "#1E1E2E");

		local lumen = highlights.lumen(c1);
		local FG = lumen > 0.5 and "#4C4F69" or "#CDD6F4";

		return {
			{
				group_name = "Palette3",
				value = {
					bg = highlights.rgb_to_hex(c1),
					fg = FG
				}
			},
			{
				group_name = "Palette3I",
				value = {
					fg = highlights.rgb_to_hex(c1),
				}
			},
			{
				group_name = "Palette3R",
				value = {
					fg = highlights.rgb_to_hex(c2),
					bg = highlights.rgb_to_hex(c1),
				}
			},
		};

		---|fE
	end,
	["A4"] = function ()
		---|fS

		--- Main color
		local c1 = highlights.get_property("fg", {
			"@keyword", "Conditional"
		}, "#8839EF", "#CBA6F7", true);
		--- Background
		local c2 = highlights.get_property("bg", {
			"Normal",
		}, "#EFF1F5", "#1E1E2E");

		local lumen = highlights.lumen(c1);
		local FG = lumen > 0.5 and "#4C4F69" or "#CDD6F4";

		return {
			{
				group_name = "Palette4",
				value = {
					bg = highlights.rgb_to_hex(c1),
					fg = FG
				}
			},
			{
				group_name = "Palette4I",
				value = {
					fg = highlights.rgb_to_hex(c1),
				}
			},
			{
				group_name = "Palette4R",
				value = {
					fg = highlights.rgb_to_hex(c2),
					bg = highlights.rgb_to_hex(c1),
				}
			},
		};

		---|fE
	end,
	["A5"] = function ()
		---|fS

		--- Main color
		local c1 = highlights.get_property("fg", {
			"@constant", "Constant"
		}, "#FE640B", "#FAB387", true);
		--- Background
		local c2 = highlights.get_property("bg", {
			"Normal",
		}, "#EFF1F5", "#1E1E2E");

		local lumen = highlights.lumen(c1);
		local FG = lumen > 0.5 and "#4C4F69" or "#CDD6F4";

		return {
			{
				group_name = "Palette5",
				value = {
					bg = highlights.rgb_to_hex(c1),
					fg = FG

				}
			},
			{
				group_name = "Palette5I",
				value = {
					fg = highlights.rgb_to_hex(c1),
				}
			},
			{
				group_name = "Palette5R",
				value = {
					fg = highlights.rgb_to_hex(c2),
					bg = highlights.rgb_to_hex(c1),
				}
			},
		};

		---|fE
	end,

	["B1"] = function ()
		--- Background
		local BG = highlights.get_property("bg", {
			"Normal",
		}, "#EFF1F5", "#1E1E2E");

		local hslBG = highlights.rgb_to_hsl(BG);

		local l0 = vim.deepcopy(hslBG);
		local l1 = vim.deepcopy(hslBG);
		local l2 = vim.deepcopy(hslBG);

		if hslBG[3] > 0.5 then
			l0[3] = clamp(hslBG[3] - 0.05, 0.1, 0.9);
			l1[3] = clamp(hslBG[3] - 0.15, 0.1, 0.9);
			l2[3] = clamp(hslBG[3] - 0.25, 0.1, 0.9);
		else
			l0[3] = clamp(hslBG[3] + 0.05, 0.1, 0.9);
			l1[3] = clamp(hslBG[3] + 0.15, 0.1, 0.9);
			l2[3] = clamp(hslBG[3] + 0.25, 0.1, 0.9);
		end

		return {
			{
				group_name = "Layer0",
				value = {
					bg = highlights.rgb_to_hex( highlights.hsl_to_rgb(l0) )
				}
			},
			{
				group_name = "Layer0I",
				value = {
					fg = highlights.rgb_to_hex( highlights.hsl_to_rgb(l0) ),
					bg = highlights.rgb_to_hex(BG)
				}
			},
			{
				group_name = "Layer0R",
				value = {
					fg = highlights.rgb_to_hex(BG),
					bg = highlights.rgb_to_hex( highlights.hsl_to_rgb(l0) )
				}
			},


			{
				group_name = "Layer1",
				value = {
					bg = highlights.rgb_to_hex( highlights.hsl_to_rgb(l1) )
				}
			},
			{
				group_name = "Layer1I",
				value = {
					fg = highlights.rgb_to_hex( highlights.hsl_to_rgb(l1) ),
					bg = highlights.rgb_to_hex(BG)
				}
			},
			{
				group_name = "Layer1R",
				value = {
					fg = highlights.rgb_to_hex(BG),
					bg = highlights.rgb_to_hex( highlights.hsl_to_rgb(l1) )
				}
			},


			{
				group_name = "Layer2",
				value = {
					bg = highlights.rgb_to_hex( highlights.hsl_to_rgb(l2) )
				}
			},
			{
				group_name = "Layer2I",
				value = {
					fg = highlights.rgb_to_hex( highlights.hsl_to_rgb(l2) ),
					bg = highlights.rgb_to_hex(BG)
				}
			},
			{
				group_name = "Layer2R",
				value = {
					fg = highlights.rgb_to_hex(BG),
					bg = highlights.rgb_to_hex( highlights.hsl_to_rgb(l2) )
				}
			},
		};
	end
};

--- Setup function.
---@param opt { [string]: config.hl }?
highlights.setup = function (opt)
	if type(opt) == "table" then
		highlights.groups = vim.tbl_extend("force", highlights.groups, opt);
	end

	highlights.create(highlights.groups);
end

return highlights;
