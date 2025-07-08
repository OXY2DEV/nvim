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

hl.interpolate = function (f1, f2, f3, t1, t2, t3, y)
	return hl.lerp(f1, t1, y), hl.lerp(f2, t2, y), hl.lerp(f3, t3, y);
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

--- Gets visible foreground color
--- from luminosity.
---@param lumen number
---@return number
---@return number
---@return number
hl.visible_fg = function (lumen)
	---|fS

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

	---|fE
end

local Y = 0.15;
local D = 0.15;

---@type table<string, fun(): table[]>
hl.groups = {
	qf = function ()
		---|fS "style: Quickfix diagnostic groups."

		local iR, iG, iB = hl.num_to_rgb(
			hl.get_attr("bg", { "DiagnosticVirtualTextInfo" }) or hl.choice(14281459, 2633792)
		);

		local hR, hG, hB = hl.num_to_rgb(
			hl.get_attr("bg", { "DiagnosticVirtualTextHint" }) or hl.choice(14346476, 2699582)
		);

		local wR, wG, wB = hl.num_to_rgb(
			hl.get_attr("bg", { "DiagnosticVirtualTextWarn" }) or hl.choice(15591648, 3354938)
		);

		local eR, eG, eB = hl.num_to_rgb(
			hl.get_attr("bg", { "DiagnosticVirtualTextError" }) or hl.choice(15523043, 3287098)
		);

		return {
			{
				group_name = "QuickfixRangeInfo",
				value = { bg = string.format("#%02x%02x%02x", iR, iG, iB) }
			},
			{
				group_name = "QuickfixRangeHint",
				value = { bg = string.format("#%02x%02x%02x", hR, hG, hB) }
			},
			{
				group_name = "QuickfixRangeWarn",
				value = { bg = string.format("#%02x%02x%02x", wR, wG, wB) }
			},
			{
				group_name = "QuickfixRangeError",
				value = { bg = string.format("#%02x%02x%02x", eR, eG, eB) }
			}
		};

		---|fE
	end,

	---|fS "style: Diagnostic"

	def = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@comment" }) or hl.choice(8159123, 9673138)
			)
		);

		---@type number, number, number Background color.
		local SL, SA, SB = hl.interpolate(BL, BA, BB, FL, FA, FB, D + 0.05);

		return {
			{
				group_name = "DgDefault",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(FL, FA, FB)),
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(SL, SA, SB))
				},
			},

			{
				group_name = "DgDefaultBg",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(FL, FA, FB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(BL, BA, BB))
				},
			},
			{
				group_name = "DgDefaultPad",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(SL, SA, SB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(BL, BA, BB))
				},
			},
		};

		---|fE
	end,

	err = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "DiagnosticError", "Error" }) or hl.choice(13766457, 15961000)
			)
		);

		---@type number, number, number Background color.
		local SL, SA, SB = hl.interpolate(BL, BA, BB, FL, FA, FB, D);

		return {
			{
				group_name = "DgError",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(FL, FA, FB)),
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(SL, SA, SB))
				},
			},

			{
				group_name = "DgErrorBg",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(FL, FA, FB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(BL, BA, BB))
				},
			},
			{
				group_name = "DgErrorPad",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(SL, SA, SB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(BL, BA, BB))
				},
			},
		};

		---|fE
	end,

	hnt = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "DiagnosticHint" }) or hl.choice(1544857, 9757397)
			)
		);

		---@type number, number, number Background color.
		local SL, SA, SB = hl.interpolate(BL, BA, BB, FL, FA, FB, D);

		return {
			{
				group_name = "DgHint",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(FL, FA, FB)),
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(SL, SA, SB))
				},
			},

			{
				group_name = "DgHintBg",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(FL, FA, FB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(BL, BA, BB))
				},
			},
			{
				group_name = "DgHintPad",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(SL, SA, SB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(BL, BA, BB))
				},
			},
		};

		---|fE
	end,

	nte = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "DiagnosticNote" }) or hl.choice(1544857, 9757397)
			)
		);

		---@type number, number, number Background color.
		local SL, SA, SB = hl.interpolate(BL, BA, BB, FL, FA, FB, D);

		return {
			{
				group_name = "DgNote",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(FL, FA, FB)),
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(SL, SA, SB))
				},
			},

			{
				group_name = "DgNoteBg",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(FL, FA, FB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(BL, BA, BB))
				},
			},
			{
				group_name = "DgNotePad",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(SL, SA, SB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(BL, BA, BB))
				},
			},
		};

		---|fE
	end,

	wrn = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "DiagnosticWarn" }) or hl.choice(14650909, 16376495)
			)
		);

		---@type number, number, number Background color.
		local SL, SA, SB = hl.interpolate(BL, BA, BB, FL, FA, FB, D);

		return {
			{
				group_name = "DgWarn",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(FL, FA, FB)),
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(SL, SA, SB))
				},
			},

			{
				group_name = "DgWarnBg",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(FL, FA, FB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(BL, BA, BB))
				},
			},
			{
				group_name = "DgWarnPad",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(SL, SA, SB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(BL, BA, BB))
				},
			},
		};

		---|fE
	end,

	---|fE

	---|fS "style: Highlight group for completions"

	completion_default = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@comment" }) or hl.choice(8159123, 9673138)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionDefault",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionDefaultBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_function = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@function" }) or hl.choice(992437, 9024762)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionFunction",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionFunctionBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_const = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@constant" }) or hl.choice(16671755, 16429959)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionConst",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionConstBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_interface = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@define" }) or hl.choice(15365835, 16106215)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionInterface",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionInterfaceBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_method = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@function" }) or hl.choice(992437, 9024762)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionMethod",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionMethodBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_constructor = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@constructor" }) or hl.choice(2138037, 7353356)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionConstructor",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionConstructorBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_field = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@field" }) or hl.choice(7505917, 11845374)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionField",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionFieldBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_variable = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@variable" }) or hl.choice(5001065, 13489908)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionVariable",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionVariableBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_class = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@function" }) or hl.choice(992437, 9024762)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionClass",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionClassBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_module = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@module" }) or hl.choice(7505917, 11845374)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionModule",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionModuleBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_property = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@property" }) or hl.choice(7505917, 11845374)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionProperty",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionPropertyBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_unit = function ()
		---|fS

		return {
			{
				group_name = "CompletionUnit",
				value = {
					link = "CompletionConst"
				}
			},
			{
				group_name = "CompletionUnitBg",
				value = {
					link = "CompletionConstBg"
				}
			}
		};

		---|fE
	end,

	completion_value = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@constant" }) or hl.choice(16671755, 16429959)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionValue",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionValueBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_enum = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@keyword.type" }) or hl.choice(8927727, 13346551)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionEnum",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionEnumBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_keyword = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@keyword" }) or hl.choice(8927727, 13346551)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionKeyword",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionKeywordBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_snippet = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@comment" }) or hl.choice(8159123, 9673138)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionSnippet",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionSnippetBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_color = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@string" }) or hl.choice(4235307, 10937249)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionColor",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionColorBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_file = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@keyword.import" }) or hl.choice(8927727, 13346551)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionFile",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionFileBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_reference = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@string.special.url" }) or hl.choice(14453368, 16113884)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionReference",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionReferenceBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_folder = function ()
		---|fS

		return {
			{
				group_name = "CompletionFolder",
				value = {
					link = "CompletionFile"
				}
			},
			{
				group_name = "CompletionFolderBg",
				value = {
					link = "CompletionFileBg"
				}
			}
		};

		---|fE
	end,

	completion_struct = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@variable.member" }) or hl.choice(7505917, 11845374)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionStruct",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionStructBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_operator = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@keyword.operator" }) or hl.choice(304613, 9034987)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionOperator",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionOperatorBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	completion_type = function ()
		---|fS

		local bL, bA, bB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@type" }) or hl.choice(14650909, 16376495)
			)
		);

		local fL, fA, fB = hl.visible_fg(bL);

		return {
			{
				group_name = "CompletionType",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(fL, fA, fB)),
				}
			},
			{
				group_name = "CompletionTypeBg",
				value = {
					fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(bL, bA, bB)),
				}
			}
		};

		---|fE
	end,

	---|fE

	---|fS "style: Highlight group for inspect-tree"

	injection_0 = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@comment" }) or hl.choice(8159123, 9673138)
			)
		);

		return {
			{
				group_name = "Injection0",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(
							hl.interpolate(BL, BA, BB, FL, FA, FB, Y)
						)
					)
				},
			},
		};

		---|fE
	end,

	injection_1 = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "DiagnosticError", "Error" }) or hl.choice(13766457, 15961000)
			)
		);

		return {
			{
				group_name = "Injection1",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(
							hl.interpolate(BL, BA, BB, FL, FA, FB, Y)
						)
					)
				},
			},
		};

		---|fE
	end,

	injection_2 = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@constant", "Constant" }) or hl.choice(16671755, 16429959)
			)
		);

		return {
			{
				group_name = "Injection2",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(
							hl.interpolate(BL, BA, BB, FL, FA, FB, Y)
						)
					)
				},
			},
		};

		---|fE
	end,

	injection_3 = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "DiagnosticWarn" }) or hl.choice(14650909, 16376495)
			)
		);

		return {
			{
				group_name = "Injection3",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(
							hl.interpolate(BL, BA, BB, FL, FA, FB, Y)
						)
					)
				},
			},
		};

		---|fE
	end,

	injection_4 = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "DiagnosticOk" }) or hl.choice(4235307, 10937249)
			)
		);

		return {
			{
				group_name = "Injection4",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(
							hl.interpolate(BL, BA, BB, FL, FA, FB, Y)
						)
					)
				},
			},
		};

		---|fE
	end,

	injection_5 = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@function", "Function" }) or hl.choice(1992437, 9024762)
			)
		);

		return {
			{
				group_name = "Injection5",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(
							hl.interpolate(BL, BA, BB, FL, FA, FB, Y)
						)
					)
				},
			},
		};

		---|fE
	end,

	injection_6 = function ()
		---|fS

		---@type number, number, number Background color.
		local BL, BA, BB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("bg", { "Normal" }) or hl.choice(15725045, 1973806)
			)
		);

		---@type number, number, number Background color.
		local FL, FA, FB = hl.rgb_to_oklab(
			hl.num_to_rgb(
				hl.get_attr("fg", { "@module", "@property" }) or hl.choice(7505917, 11845374)
			)
		);

		return {
			{
				group_name = "Injection6",
				value = {
					bg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(
							hl.interpolate(BL, BA, BB, FL, FA, FB, Y)
						)
					)
				},
			},
		};

		---|fE
	end,

	---|fE
};

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
