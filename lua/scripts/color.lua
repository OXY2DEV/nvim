---@class color.config Configuration for `color.lua`.
---
---@field debounce integer Debounce delay.
---@field patterns table<string, color.config.pattern> Color patterns.


---@class color.config.pattern
---
---@field pattern string Pattern used to detect 
---@field hl? fun(buffer: integer, str: string, lnum: integer, index: integer): color.hl Turns `pattern` into a `highlight group`.
---@field render? fun(buffer: integer, hl: string, lnum: integer, start: integer, stop: integer): nil Renders a `highlight group`.


---@class color.hl
---
---@field name string Name of the highlight group.
---@field value table Value to be passed to `nvim_set_hl()`.

------------------------------------------------------------------------------

--[[ Color highlighter for `Neovim`. ]]
local color = {};

color.ns = vim.api.nvim_create_namespace("color.hover");

---@type color.config
color.config = {
	debounce = 100,

	patterns = {
		hex = {
			pattern = "#[0-9a-fA-F]\\{3,6}"
		},
		rgb = {
			pattern = "rgb(\\d\\{1,3},\\s*\\d\\{1,3},\\s*\\d\\{1,3})",
			hl = function (buffer, str, lnum, index)
				local faded_bg = vim.api.nvim_get_hl(0, { name = "FadedBg" }).bg;

				local __R, __G, __B = string.match(str, "rgb%((%d+),%s*(%d+),%s*(%d+)%)");
				local R = math.max(math.min(255, tonumber(__R)), 0);
				local G = math.max(math.min(255, tonumber(__G)), 0);
				local B = math.max(math.min(255, tonumber(__B)), 0);

				return {
					name = string.format("HL%d%d%d", buffer, lnum, index),
					value = {
						fg = string.format("#%02x%02x%02x", R, G, B),
						bg = faded_bg
					}
				};
			end
		},
	}
};

---@param buffer integer
---@param str string
---@param lnum integer
---@param index integer
---@return table
local function default_hl (buffer, str, lnum, index)
	---|fS

	local faded_bg = vim.api.nvim_get_hl(0, { name = "FadedBg" }).bg;

	return {
		name = string.format("HL%d%d%d", buffer, lnum, index),
		value = { fg = str, bg = faded_bg }
	};

	---|fE
end

--[[ Default renderer for colors. ]]
---@param buffer integer
---@param hl string
---@param lnum integer
---@param start integer
---@param stop integer
local function default_render (buffer, hl, lnum, start, stop)
	---|fS

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

	---|fE
end

--[[ Colors the current line of `win`. ]]
---@param win integer
color.color = function (win)
	---|fS

	local buffer = vim.api.nvim_win_get_buf(win);
	local cursor = vim.api.nvim_win_get_cursor(win);

	local line = vim.api.nvim_buf_get_lines(buffer, cursor[1] - 1, cursor[1], false)[1] or "";

	---@type string[]
	local pattern_keys = vim.tbl_keys(color.config.patterns);
	table.sort(pattern_keys);

	---@type integer How many `patterns` have we matched yet?
	local matched = 0;

	--[[ Colorizes current line with `pattern_config`. ]]
	---@param pattern_config color.config.pattern
	---@param start integer
	---@param stop integer
	local function colorize (pattern_config, start, stop)
		---|fS

		local _color = string.sub(line, start + 1, stop);
		---@type color.hl
		local hl;

		if pattern_config.hl then
			hl = pattern_config.hl(buffer, _color, cursor[1] - 1, matched);
		else
			hl = default_hl(buffer, _color, cursor[1] - 1, matched)
		end

		vim.api.nvim_set_hl(
			0,
			hl.name,
			hl.value
		);

		if pattern_config.render then
			pcall(pattern_config.render, buffer, hl.name, cursor[1] - 1, start, stop)
		else
			default_render(buffer, hl.name, cursor[1] - 1, start, stop);
		end

		---|fE
	end

	-- Clear the current line of `old decorations`.
	vim.api.nvim_buf_clear_namespace(buffer, color.ns, cursor[1] - 1, cursor[1]);

	for _, key in ipairs(pattern_keys) do
		---@type color.config.pattern
		local pattern = color.config.patterns[key];

		local c = 0;
		local iter = 1;

		--[[ Regex pattern object. ]]
		local regex = vim.regex(pattern.pattern);

		while c < #line do
			local start, stop = regex:match_line(buffer, cursor[1] - 1, c);
			iter = iter + 1;

			if not start or not stop then
				break;
			end

			start = start + c;
			stop = stop + c;

			colorize(pattern, start, stop);

			c = stop;
			matched = matched + 1;
		end
	end

	---|fE
end

color.setup = function ()
	---|fS

	---@diagnostic disable-next-line: undefined-field
	local timer = vim.uv.new_timer();

	vim.api.nvim_create_autocmd("ModeChanged", {
		callback = function ()
			local win = vim.api.nvim_get_current_win();
			local buf = vim.api.nvim_win_get_buf(win);

			vim.api.nvim_buf_clear_namespace(buf, color.ns, 0, -1);

			if vim.api.nvim_get_mode().mode == "n" then
				color.color(win);
			end
		end
	});

	vim.api.nvim_create_autocmd("CursorMoved", {
		callback = function ()
			timer:stop();

			if vim.fn.reg_executing() ~= "" or vim.fn.reg_recording() ~= "" then
				return;
			end

			timer:start(color.config.debounce or 100, 0, vim.schedule_wrap(function ()
				local win = vim.api.nvim_get_current_win();
				local buf = vim.api.nvim_win_get_buf(win);

				vim.api.nvim_buf_clear_namespace(buf, color.ns, 0, -1);

				if vim.api.nvim_get_mode().mode == "n" then
					color.color(win);
				end
			end));
		end,
	});

	---|fE
end

return color;
