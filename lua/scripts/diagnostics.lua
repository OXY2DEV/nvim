---|fS "doc: Type definitions"

--- Configuration for diagnostics.
---@class diagnostics.config
---
---@field width integer | fun(items: table[]): integer Width for the diagnostics window.
---@field decoration_width integer Width of the decorations.
---
---@field max_height integer | fun(items: table[]): integer Maximum height for the diagnostics window.
---
---@field decorations table<integer, diagnostics.decorations> Decorations for each diagnostic severity.


---@class diagnostics.decorations
---
---@field width integer Width of the decoration.
---
---@field line_hl_group? string | fun(item: table, current: boolean): string Highlight group for the line.
---
---@field icon diagnostics.decoration_fragment[] | fun(item: table, current: boolean): diagnostics.decoration_fragment[] Decoration for the start line.
---@field padding? diagnostics.decoration_fragment[] | fun(item: table, current: boolean): diagnostics.decoration_fragment[] Decoration for the other line(s).


---@class diagnostics.decorations__static
---
---@field width integer Width of the decoration.
---
---@field line_hl_group? string Highlight group for the line.
---@field icon diagnostics.decoration_fragment[] Decoration for the start line.
---@field padding? diagnostics.decoration_fragment[] Decoration for the other line(s).


---@class diagnostics.decoration_fragment Virtual text fragment.
---
---@field [1] string
---@field [2] string?

---|fE

------------------------------------------------------------------------------

--- Custom diagnostics viewer for Neovim.
local diagnostics = {};

---@class diagnostics.config
diagnostics.config = {
	---|fS

	width = function (items)
		local max_w = math.floor(vim.o.columns * 0.4);
		local W = 1

		for _, item in ipairs(items) do
			local width = vim.fn.strdisplaywidth(item.message or "");

			if width >= max_w then
				return max_w;
			else
				W = math.max(W, width);
			end
		end

		return W;
	end,
	decoration_width = 4,

	max_height = function ()
		return math.floor(vim.o.lines * 0.4);
	end,

	beacon = {
		default = {
			from = function ()
				local fg = vim.api.nvim_get_hl(0, { name = "@comment", link = false }).fg;
				return fg and string.format("#%06x", fg) or "#9399b2";
			end,
			to = function ()
				local bg = vim.api.nvim_get_hl(0, { name = vim.o.statusline and "Cursorline" or "Normal", link = false }).bg;
				return bg and string.format("#%06x", bg) or "#1e1e2e";
			end,

			steps = 10,
			interval = 100,
		},

		[vim.diagnostic.severity.INFO] = {
			from = function ()
				local fg = vim.api.nvim_get_hl(0, { name = "DgInfoDisabledIcon", link = false }).fg;
				return fg and string.format("#%06x", fg) or "#94e2d5";
			end
		},
		[vim.diagnostic.severity.HINT] = {
			from = function ()
				local fg = vim.api.nvim_get_hl(0, { name = "DgHintDisabledIcon", link = false }).fg;
				return fg and string.format("#%06x", fg) or "#94e2d5";
			end
		},
		[vim.diagnostic.severity.WARN] = {
			from = function ()
				local fg = vim.api.nvim_get_hl(0, { name = "DgWarnDisabledIcon", link = false }).fg;
				return fg and string.format("#%06x", fg) or "#f9e2af";
			end
		},
		[vim.diagnostic.severity.ERROR] = {
			from = function ()
				local fg = vim.api.nvim_get_hl(0, { name = "DgErrorDisabledIcon", link = false }).fg;
				return fg and string.format("#%06x", fg) or "#f38ba8";
			end
		},
	},

	decorations = {
		---|fS

		[vim.diagnostic.severity.INFO] = {
			width = 3,

			line_hl_group = function (_, current)
				return current and "DiagnosticInfo" or "@comment";
			end,
			icon = function (_, current)
				return {
					{ "▌", current and "DgInfo" or "DgInfoDisabled" },
					{ "󰀨 ", current and "DgInfo" or "DgInfoDisabledIcon" },
					{ " " },
				}
			end,
			padding = function (_, current)
				return {
					{ "▌",  current and "DgInfo" or "DgInfoDisabled" },
					{ "  ", current and "DgInfo" or "DgInfoDisabled" },
					{ " " },
				}
			end
		},
		[vim.diagnostic.severity.HINT] = {
			width = 3,

			line_hl_group = function (_, current)
				return current and "DiagnosticHint" or "@comment";
			end,
			icon = function (_, current)
				return {
					{ "▌", current and "DgHint" or "DgHintDisabled" },
					{ "󰁨 ", current and "DgHint" or "DgHintDisabledIcon" },
					{ " " },
				}
			end,
			padding = function (_, current)
				return {
					{ "▌",  current and "DgHint" or "DgHintDisabled" },
					{ "  ", current and "DgHint" or "DgHintDisabled" },
					{ " " },
				}
			end
		},
		[vim.diagnostic.severity.WARN] = {
			width = 3,

			line_hl_group = function (_, current)
				return current and "DiagnosticWarn" or "@comment";
			end,
			icon = function (_, current)
				return {
					{ "▌", current and "DgWarn" or "DgWarnDisabled" },
					{ " ", current and "DgWarn" or "DgWarnDisabledIcon" },
					{ " " },
				}
			end,
			padding = function (_, current)
				return {
					{ "▌",  current and "DgWarn" or "DgWarnDisabled" },
					{ "  ", current and "DgWarn" or "DgWarnDisabled" },
					{ " " },
				}
			end
		},
		[vim.diagnostic.severity.ERROR] = {
			width = 3,

			line_hl_group = function (_, current)
				return current and "DiagnosticError" or "@comment";
			end,
			icon = function (_, current)
				return {
					{ "▌", current and "DgError" or "DgErrorDisabled" },
					{ "󰅙 ", current and "DgError" or "DgErrorDisabledIcon" },
					{ " " },
				}
			end,
			padding = function (_, current)
				return {
					{ "▌",  current and "DgError" or "DgErrorDisabled" },
					{ "  ", current and "DgError" or "DgErrorDisabled" },
					{ " " },
				}
			end
		},

		---|fE
	},

	---|fE
};

--[[ Evaluates `val`. ]]
---@param val any
---@param ... any
---@return any
local function eval(val, ...)
	---|fS

	if type(val) ~= "function" then
		return val;
	else
		local can_call, new_val = pcall(val, ...);

		if can_call and new_val ~= nil then
			return new_val;
		end
	end

	---|fE
end

--[[ Gets diagnostic item `decoration`. ]]
---@param level vim.diagnostic.Severity | "default" Diagnostic severity.
---@param ... any Extra arguments to be used for value evaluation.
---@return diagnostics.decorations__static decoration Static version of the diagnostic item's decoration.
local function get_decorations (level, ...)
	---|fS

	local output = {};

	for k, v in pairs(diagnostics.config.decorations[level]) do
		output[k] = eval(v, ...);
	end

	return output;

	---|fE
end

--[[ Gets `beacon` configuration. ]]
---@param level? vim.diagnostic.Severity | "default" Diagnostic level.
---@param ... any Extra arguments to be used for value evaluation.
---@return table?
local function get_beacon_config (level, ...)
	---|fS

	if not level or not diagnostics.config.beacon then
		return;
	end

	local output = {};

	for k, v in pairs(diagnostics.config.beacon[level]) do
		output[k] = eval(v, ...);
	end

	return output;

	---|fE
end

--[[ Turns given **virtual text** into **format string** for the statusline. ]]
---@param virt_text [ string, string? ][] Virtual text.
---@return string sign Virtual text as a sign(use in `statuscolumn`, `statusline`, `tabline` or `winbar`)
local function virt_text_to_sign (virt_text)
	---|fS

	local output = "";

	for _, item in ipairs(virt_text) do
		if type(item[2]) == "string" then
			output = output .. string.format("%%#%s#%s", item[2], item[1]) .. "%#Normal#";
		else
			output = output .. item[1];
		end
	end

	return output;

	---|fE
end

------------------------------------------------------------------------------

---@type integer Decoration namespace.
diagnostics.ns = vim.api.nvim_create_namespace("fancy_diagnostics");

---@type integer, integer Diagnostics buffer & window.
diagnostics.buffer, diagnostics.window = nil, nil;

---@type integer
diagnostics.scratch_buffer = nil

---@type "top_left" | "top_right" | "bottom_left" | "bottom_right" | "center"
diagnostics.quad = nil;

--- Information regarding signs.
diagnostics.sign_data = {};

--[[ Prepares the buffer for the diagnostics window. ]]
diagnostics.__prepare = function ()
	---|fS

	if not diagnostics.buffer or not vim.api.nvim_buf_is_valid(diagnostics.buffer) then
		diagnostics.buffer = vim.api.nvim_create_buf(false, true);
	end

	if not diagnostics.scratch_buffer or not vim.api.nvim_buf_is_valid(diagnostics.scratch_buffer) then
		diagnostics.scratch_buffer = vim.api.nvim_create_buf(false, true);
	end

	---|fE
end

--[[ Updates the state of the quadrants. ]]
---@param quad "top_left" | "top_right" | "bottom_left" | "bottom_right" | "center"
---@param state boolean
diagnostics.update_quad = function (quad, state)
	---|fS

	if not _G.__used_quads then
		_G.__used_quads = {
			top_left = false,
			top_right = false,

			bottom_left = false,
			bottom_right = false
		};
	end

	_G.__used_quads[quad] = state;

	---|fE
end

--[[ Returns `{opts}` for `nvim_open_win()` based on the parameters. ]]
---@param window integer Window ID.
---@param w integer Window width.
---@param h integer Window height.
---@return  string | string[] border Window border.
---@return "editor" | "cursor" relative Relative position for floating window.
---@return "NE" | "NW" | "SE" | "SW" anchor Anchor position.
---@return integer row Window position in Y-axis.
---@return integer col Window position in X-axis.
diagnostics.__win_args = function (window, w, h)
	---|fS

	---@type [ integer, integer ]
	local cursor = vim.api.nvim_win_get_cursor(window);
	---@type table<string, integer>
	local screenpos = vim.fn.screenpos(window, cursor[1], cursor[2]);

	local screen_width = vim.o.columns - 2;
	local screen_height = vim.o.lines - vim.o.cmdheight - 2;

	local quad_pref = { "bottom_right", "top_right", "bottom_left", "top_left" };
	local quads = {
		---|fS

		center = {
			relative = "editor",
			anchor = "NW",

			row = math.ceil((vim.o.lines - h) / 2),
			col = math.ceil((vim.o.columns - w) / 2),
			border = "rounded"
		},

		top_left = {
			condition = function ()
				if h >= screenpos.row then
					-- Not enough space above.
					return false;
				elseif screenpos.curscol <= w then
					-- Not enough space before.
					return false;
				end

				return true;
			end,

			relative = "cursor",
			border = { "╭", "─", "╮", "│", "┤", "─", "╰", "│" },
			anchor = "SE",
			row = 0,
			col = 1
		},
		top_right = {
			condition = function ()
				if h >= screenpos.row then
					-- Not enough space above.
					return false;
				elseif screenpos.curscol + w > screen_width then
					-- Not enough space after.
					return false;
				end

				return true;
			end,

			relative = "cursor",
			border = { "╭", "─", "╮", "│", "╯", "─", "├", "│" },
			anchor = "SW",
			row = 0,
			col = 0
		},

		bottom_left = {
			condition = function ()
				if screenpos.row + h > screen_height then
					-- Not enough space below.
					return false;
				elseif screenpos.curscol <= w then
					-- Not enough space before.
					return false;
				end

				return true;
			end,

			relative = "cursor",
			border = { "╭", "─", "┤", "│", "╯", "─", "╰", "│" },
			anchor = "NE",
			row = 1,
			col = 1
		},
		bottom_right = {
			condition = function ()
				if screenpos.row + h > screen_height then
					-- Not enough space below.
					return false;
				elseif screenpos.curscol + w > screen_width then
					-- Nor enough space after.
					return false;
				end

				return true;
			end,

			relative = "cursor",
			border = { "├", "─", "╮", "│", "╯", "─", "╰", "│" },
			anchor = "NW",
			row = 1,
			col = 0
		}

		---|fE
	};

	for _, pref in ipairs(quad_pref) do
		if _G.__used_quads and _G.__used_quads[pref] == true then
			goto continue;
		end

		if not quads[pref] then
			goto continue;
		end

		local quad = quads[pref];
		local ran_cond, cond = pcall(quad.condition);

		if ran_cond and cond then
			diagnostics.quad = pref;
			return quad.border, quad.cursor, quad.anchor, quad.row, quad.col;
		end

		::continue::
	end

	diagnostics.quad = "center";
	local fallback = quads.center;
	return fallback.border, fallback.cursor, fallback.anchor, fallback.row, fallback.col;

	---|fE
end

------------------------------------------------------------------------------

--[[ Closes diagnostics window. ]]
diagnostics.__close = function ()
	---|fS

	if diagnostics.window and vim.api.nvim_win_is_valid(diagnostics.window) then
		pcall(vim.api.nvim_win_close, diagnostics.window, true);
		diagnostics.window = nil;

		if diagnostics.quad then
			diagnostics.update_quad(diagnostics.quad, false);
			diagnostics.quad = nil;
		end
	end

	---|fE
end

---@type beacon.instance
diagnostics.__beacon = nil;

--[[ External integrations. ]]
---@param window integer Window Id.
---@param beacon_config beacon.instance.config Configuration for `beacon`.
diagnostics.__integration = function (window, beacon_config)
	---|fS

	-- Markdown rendering.
	if package.loaded["markview"] then
		package.loaded["markview"].render(diagnostics.buffer, {
			enable = true,
			hybrid_mode = false
		});
	end

	-- Beacon.
	if package.loaded["scripts.beacon"] then
		if not diagnostics.__beacon then
			diagnostics.__beacon = require("scripts.beacon").new(window, beacon_config);
		else
			diagnostics.__beacon:update(window, beacon_config);
		end

		diagnostics.__beacon:start();
	end

	---|fE
end

--- Custom statuscolumn.
---@return string
_G.__diagnostics_statuscolumn = function ()
	---|fS

	if vim.tbl_isempty(diagnostics.sign_data) then
		return "";
	end

	local lnum = vim.v.lnum;

	local data = diagnostics.sign_data[lnum];
	local start = data.start_row;

	if not data then
		return "";
	elseif vim.v.virtnum == 0 and start == lnum then
		return virt_text_to_sign(data.icon);
	else
		return virt_text_to_sign(data.padding or data.icon);
	end

	---|fE
end

--- Hover function for diagnostics.
---@param window integer
diagnostics.hover = function (window)
	---|fS

	window = window or vim.api.nvim_get_current_win();

	---@type integer Source buffer.
	local buffer = vim.api.nvim_win_get_buf(window);
	---@type [ integer, integer ]
	local cursor = vim.api.nvim_win_get_cursor(window);

	local items = vim.diagnostic.get(buffer, { lnum = cursor[1] - 1 });

	---@type boolean Is the window already open?
	local already_open = diagnostics.window and vim.api.nvim_win_is_valid(diagnostics.window);

	if #items == 0 then
		-- No diagnostics available.
		diagnostics.__close();
		return;
	elseif already_open then
		vim.api.nvim_set_current_win(diagnostics.window);
		return;
	end

	if diagnostics.quad then
		-- If the old quadrant wasn't freed, we
		-- free it here.
		diagnostics.update_quad(diagnostics.quad, false)
	end

	diagnostics.__prepare();
	vim.bo[diagnostics.buffer].ft = "markdown";

	-- Clear old decorations.
	vim.api.nvim_buf_clear_namespace(diagnostics.buffer, diagnostics.ns, 0, -1);
	vim.api.nvim_buf_set_lines(diagnostics.buffer, 0, -1, false, {});

	local W = eval(diagnostics.config.width, items);
	local D = eval(diagnostics.config.decoration_width, items);

	---@type table Configuration used for calculating window height.
	local height_calc_config = {
		relative = "editor",

		row = 0, col = 1,
		width = W - D, height = 2,

		style = "minimal",
		hide = true,
	};

	if not diagnostics.window or not vim.api.nvim_win_is_valid(diagnostics.window) then
		diagnostics.window = vim.api.nvim_open_win(diagnostics.buffer, false, height_calc_config);
	else
		vim.api.nvim_win_set_config(diagnostics.window, height_calc_config);
	end

	vim.wo[diagnostics.window].wrap = true;
	vim.wo[diagnostics.window].linebreak = true;
	vim.wo[diagnostics.window].breakindent = true;

	local diagnostic_lines = 0;

	---@type integer Line where the cursor should be placed.
	local cursor_y = 1;
	local ranges = {};

	local start_row = 1;
	---@type vim.diagnostic.Severity | nil
	local level;

	diagnostics.sign_data = {};

	for i, item in ipairs(items) do
		---|fS

		local from = i == 1 and 0 or -1;
		local lines = vim.split(item.message, "\n", { trimempty = true })

		local start = item.col;
		local stop = item.end_col;

		local current = false;

		if cursor[2] >= start and cursor[2] <= stop then
			cursor_y = i;
			current = true;
		end

		vim.api.nvim_buf_set_lines(diagnostics.buffer, from, -1, false, lines);
		local decorations = get_decorations(item.severity, item, current);

		ranges[i] = { item.lnum, item.col };

		vim.api.nvim_buf_set_extmark(diagnostics.buffer, diagnostics.ns, diagnostic_lines, 0, {
			end_row = diagnostic_lines + #lines,
			line_hl_group = decorations.line_hl_group,
		});

		diagnostic_lines = diagnostic_lines + #lines;

		if current == true and ( not level or item.severity < level ) then
			level = item.severity;
		end

		for _ = 1, #lines do
			-- Signs
			table.insert(diagnostics.sign_data, {
				start_row = start_row,

				current = current,
				width = decorations.width,

				icon = decorations.icon,
				line_hl_group = decorations.line_hl_group,
				padding = decorations.padding,
			});
		end

		start_row = start_row + #lines;

		---|fE
	end

	local beacon_config = vim.tbl_extend("force",
		get_beacon_config("default", {}, true),
		get_beacon_config(level, {}, true) or {}
	);

	local H = vim.api.nvim_win_text_height(diagnostics.window, { start_row = 0, end_row = -1 }).all;

	local _, relative, anchor, row, col = diagnostics.__win_args(window, W, H);

	local win_config = {
		relative = relative or "cursor",

		row = row or 0, col = col or 0,
		width = W, height = H,

		anchor = anchor,
		border = "none",

		style = "minimal",
		hide = false,
	};

	vim.api.nvim_win_set_config(diagnostics.window, win_config);
	vim.api.nvim_win_set_cursor(diagnostics.window, { cursor_y, 0 });

	-- Update quadrant state.
	diagnostics.update_quad(diagnostics.quad, true);

	-- Set necessary options.
	vim.wo[diagnostics.window].signcolumn = "no";
	vim.wo[diagnostics.window].statuscolumn = "%!v:lua.__diagnostics_statuscolumn()";

	vim.wo[diagnostics.window].conceallevel = 3;
	vim.wo[diagnostics.window].concealcursor = "ncv";

	vim.wo[diagnostics.window].winhl = "FloatBorder:@comment,Normal:Normal";

	diagnostics.__integration(window, beacon_config);

	---|fS


	vim.api.nvim_buf_set_keymap(diagnostics.buffer, "n", "<CR>", "", {
		desc = "Go to diagnostic location",
		callback = function ()
			---|fS

			local _cursor = vim.api.nvim_win_get_cursor(diagnostics.window);

			if ranges[_cursor[1] - 1] then
				vim.api.nvim_win_set_cursor(window, ranges[_cursor[1] - 1]);
				vim.api.nvim_set_current_win(window);

				diagnostics.__close();
			end

			---|fE
		end
	});

	vim.api.nvim_buf_set_keymap(diagnostics.buffer, "n", "q", "", {
		desc = "Exit diagnostics window",
		callback = function ()
			pcall(vim.api.nvim_set_current_win, window);
			diagnostics.__close();
		end
	});

	---|fE

	---|fE
end

--- Configuration for the diagnostics module.
---@param config? diagnostics.config
diagnostics.setup = function (config)
	---|fS

	if type(config) == "table" then
		diagnostics.config = vim.tbl_extend("force", diagnostics.config, config);
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function (ev)
			vim.api.nvim_buf_set_keymap(ev.buf, "n", "D", "", {
				callback = diagnostics.hover
			});
		end
	});

	vim.api.nvim_create_autocmd({
		"CursorMoved", "CursorMovedI"
	}, {
		callback = function ()
			local win = vim.api.nvim_get_current_win();

			if diagnostics.window and win ~= diagnostics.window then
				diagnostics.__close();

				if diagnostics.quad then
					diagnostics.update_quad(diagnostics.quad, false);
					diagnostics.quad = nil;
				end
			end
		end
	});

	---|fE
end

return diagnostics;
