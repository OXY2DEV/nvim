---|fS "doc: Type definitions"

---@class color.config Configuration for `color.lua`.
---
---@field debounce integer Debounce delay.
---@field max_lines integer
---@field color_style color.config.style Changes how colors are highlighted.
---@field patterns table<string, color.config.pattern> Color patterns.


---@alias color.config.style
---| "simple"
---| "virt_text"


---@class color.config.pattern
---
---@field pattern string Pattern used to detect 
---@field color_style? color.config.style Changes how colors are highlighted.
---@field hl? fun(buffer: integer, str: string, style: color.config.style, lnum: integer, index: integer): color.hl Turns `pattern` into a `highlight group`.
---@field render? fun(buffer: integer, hl: string, style: color.config.style, lnum: integer, start: integer, stop: integer): nil Renders a `highlight group`.


---@class color.hl
---
---@field name string Name of the highlight group.
---@field value table Value to be passed to `nvim_set_hl()`.

---|fE

------------------------------------------------------------------------------

--[[
Color highlighter for `Neovim` focusing on *performance* & *customizability*.

Usage,
```lua
require("color").setup();
```
]]
local color = {};

---@param r integer
---@param g integer
---@param b integer
---@return string|integer
local function get_fg (r, g, b)
	---|fS

	local fg;

	if package.loaded["scripts.highlights"] then
		local hl = require("scripts.highlights");
		---@type { [1]: integer, [2]: integer, [3]: integer } Foreground color in `OKLab`.
		local tmp = {
			hl.visible_fg(
				hl.rgb_to_oklab(
					r, g, b
				)
			)
		};

		fg = string.format("#%02x%02x%02x", hl.oklab_to_rgb(tmp[1], tmp[2], tmp[3]));
	else
		local normal = vim.api.nvim_get_hl(0, { name = "Normal" });
		local brightness = ( (r * 299) + (g * 587) + (b * 114) ) / 1000;

		if brightness > 128 then
			fg = normal.bg or "#1E1E2E";
		else
			fg = normal.fg or "#CDD6F4";
		end
	end

	return fg;

	---|fE
end

---@param buffer integer
---@param str string
---@param style color.config.style
---@param lnum integer
---@param index integer
---@return color.hl
local function default_hl (buffer, str, style, lnum, index)
	---|fS

	if style == "virt_text" then
		local faded_bg = vim.api.nvim_get_hl(0, { name = "FadedBg" }).bg;

		return {
			name = string.format("HL%d%d%d", buffer, lnum, index),
			value = { fg = str, bg = faded_bg }
		};
	else
		local __R, __G, __B = string.match(str, "#(%x%x?)(%x%x?)(%x%x?)");

		local R = math.max(math.min(255, tonumber(__R, 16)), 0);
		local G = math.max(math.min(255, tonumber(__G, 16)), 0);
		local B = math.max(math.min(255, tonumber(__B, 16)), 0);

		return {
			name = string.format("HL%d%d%d", buffer, lnum, index),
			value = {
				bg = string.format("#%02x%02x%02x", R, G, B),
				fg = get_fg(R, G, B)
			}
		};
	end

	---|fE
end

--[[ Default renderer for colors. ]]
---@param buffer integer
---@param hl string
---@param style color.config.style
---@param lnum integer
---@param start integer
---@param stop integer
local function default_render (buffer, hl, style, lnum, start, stop)
	---|fS

	if style == "virt_text" then
		vim.api.nvim_buf_set_extmark(buffer, color.ns, lnum, start, {
			end_col = stop,

			virt_text_pos = "inline",
			virt_text = {
				{ " ", "FadedBg" },
				{ " ", hl },
			},

			hl_group = "FadedBg",
		});
		vim.api.nvim_buf_set_extmark(buffer, color.ns, lnum, stop, {
			virt_text_pos = "inline",
			virt_text = {
				{ " ", "FadedBg" },
			},
		});
	elseif style == "simple" then
		vim.api.nvim_buf_set_extmark(buffer, color.ns, lnum, start, {
			end_col = stop,
			hl_group = hl,
		});
	end

	---|fE
end

--[[ Evaluates `value` with provided `arguments`. ]]
---@param value any
---@param ... any
---@return any
local function evaluate (value, ...)
	if type(value) ~= "function" then return value; end

	local success, result = pcall(value, ...);
	return success and result or nil;
end

------------------------------------------------------------------------------

color.ns = vim.api.nvim_create_namespace("color.hover");

---@type color.config
color.config = {
	max_lines = 500,
	debounce = 100,
	color_style = "simple",

	patterns = {
		hex = {
			pattern = "#[0-9a-fA-F]\\{3,6}"
		},
		num = {
			pattern = "#\\@<!\\(\\d\\{6,8}\\)",
			hl = function (buffer, str, style, lnum, index)
				local hex = string.format("#%06x", tonumber(str));
				return default_hl(buffer, hex, style, lnum, index);
			end
		},
		rgb = {
			pattern = "rgb(\\d\\{1,3},\\s*\\d\\{1,3},\\s*\\d\\{1,3})",
			hl = function (buffer, str, style, lnum, index)
				local __R, __G, __B = string.match(str, "rgb%((%d+),%s*(%d+),%s*(%d+)%)");

				local R = math.max(math.min(255, tonumber(__R)), 0);
				local G = math.max(math.min(255, tonumber(__G)), 0);
				local B = math.max(math.min(255, tonumber(__B)), 0);

				local hex = string.format("#%02x%02x%02x", R, G, B);

				return default_hl(buffer, hex, style, lnum, index);
			end
		},
	}
};

------------------------------------------------------------------------------

--[[ Colors `lnum` numbered line in `buffer`. ]]
---@param buffer integer
---@param lnum integer 0-indexed.
color.color_line = function (buffer, lnum)
	---|fS

	---@type string line text.
	local text = vim.api.nvim_buf_get_lines(
		buffer,
		lnum,
		lnum + 1,
		false
	)[1] or "";

	---@type string[] Pattern names.
	local pattern_keys = vim.tbl_keys(color.config.patterns);
	table.sort(pattern_keys);

	local ID = 0;

	local function color_pattern_ranges (key)
		---@type color.config.pattern
		local pattern = color.config.patterns[key]
		if not pattern then return {}; end

		local style = evaluate(pattern.color_style or color.config.color_style, buffer);
		local hl = pattern.hl or default_hl;
		local render = pattern.render or default_render;

		local regex = vim.regex(pattern.pattern or "");
		local current_column = 0;

		while current_column < #text do
			local col_start, col_end = regex:match_line(buffer, lnum, current_column);
			if not col_start or not col_end then return; end

			col_start = current_column + col_start;
			col_end   = current_column + col_end;

			local match = string.sub(text, col_start + 1, col_end);
			local found_hl, group = pcall(
				hl,

				buffer,
				match,
				style,
				lnum,
				ID
			);

			if found_hl then
				pcall(vim.api.nvim_set_hl, 0, group.name, group.value);
				pcall(
					render,

					buffer,
					group.name,
					style,

					lnum,
					col_start,
					col_end
				);
			end

			current_column = col_end;
			ID = ID + 1;
		end
	end

	-- Clear the current line of `old decorations`.
	vim.api.nvim_buf_clear_namespace(buffer, color.ns, lnum, lnum + 1);

	for _, key in ipairs(pattern_keys) do
		color_pattern_ranges(key);
	end

	---|fE
end

color.setup = function ()
	---|fS

	---@diagnostic disable-next-line: undefined-field
	local timer = vim.uv.new_timer();

	local function callback ()
		local win = vim.api.nvim_get_current_win();
		local buf = vim.api.nvim_win_get_buf(win);

		local lines = vim.api.nvim_buf_line_count(buf);

		vim.api.nvim_buf_clear_namespace(buf, color.ns, 0, -1);

		if vim.api.nvim_get_mode().mode ~= "n" then
			return;
		end

		if lines < (color.config.max_lines or 100) then
			for l = 0, lines, 1 do
				color.color_line(buf, l);
			end
		else
			local cursor = vim.api.nvim_win_get_cursor(win);
			color.color_line(buf, cursor[1] - 1);
		end
	end

	vim.api.nvim_create_autocmd({
		"ModeChanged",
		"CursorMoved",
		"BufWinEnter",
	}, {
		callback = function (event)
			timer:stop();

			if vim.fn.reg_executing() ~= "" or vim.fn.reg_recording() ~= "" then
				return;
			end

			timer:start(color.config.debounce or 100, 0, vim.schedule_wrap(function ()
				callback(event.event)
			end));
		end
	});

	---|fE
end

return color;
