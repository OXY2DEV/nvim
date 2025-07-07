---|fS "doc: Type definitions"

--- Configuration for diagnostics.
---@class diagnostics.config
---
---@field width integer | fun(items: table[]): integer Width for the diagnostics window.
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
	max_height = function ()
		return math.floor(vim.o.lines * 0.4);
	end,

	decorations = {
		---|fS

		[vim.diagnostic.severity.INFO] = {
			width = 3,

			line_hl_group = function (_, current)
				return current and "DiagnosticInfo" or "@comment";
			end,
			icon = function (_, current)
				return {
					{ "▍󰀨 ", current and "DiagnosticInfo" or "@comment" }
				}
			end,
			padding = function (_, current)
				return {
					{ "▍  ", current and "DiagnosticInfo" or "@comment" }
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
					{ "▍󰁨 ", current and "DiagnosticHint" or "@comment" }
				}
			end,
			padding = function (_, current)
				return {
					{ "▍  ", current and "DiagnosticHint" or "@comment" }
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
					{ "▍ ", current and "DiagnosticWarn" or "@comment" }
				}
			end,
			padding = function (_, current)
				return {
					{ "▍  ", current and "DiagnosticWarn" or "@comment" }
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
					{ "▍󰅙 ", current and "DiagnosticError" or "@comment" }
				}
			end,
			padding = function (_, current)
				return {
					{ "▍  ", current and "DiagnosticError" or "@comment" }
				}
			end
		},

		---|fE
	},

	---|fE
};

--- Evaluates `val`.
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

--- Gets decorations.
---@param level integer | vim.diagnostic.Severity
---@param ... any
---@return diagnostics.decorations__static
local function get_decorations (level, ...)
	---|fS

	local output = {};

	for k, v in pairs(diagnostics.config.decorations[level]) do
		output[k] = eval(v, ...);
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

--- Prepares the buffer for the diagnostics window.
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

---@param window integer
---@param w integer
---@param h integer
---@return  string | string[]
---@return "editor" | "cursor"
---@return "NE" | "NW" | "SE" | "SW"
---@return integer
---@return integer
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

---@param text string
---@param W integer
---@return integer
---@return string[]
diagnostics.__wrap = function (text, W)
	---|fS

	diagnostics.__prepare();

	local text_lines = vim.split(text, "\n", { trimempty = true });
	local final_lines = {};

	vim.bo[diagnostics.scratch_buffer].tw = W or vim.o.columns;

	for _, line in ipairs(text_lines) do
		vim.api.nvim_buf_set_lines(diagnostics.scratch_buffer, 0, -1, false, { line });

		if string.match(line, "[`~%[%]%-%+%*]") then
			vim.bo[diagnostics.scratch_buffer].ft = "markdown";
		else
			vim.bo[diagnostics.scratch_buffer].ft = "plaintext";
		end

		vim.api.nvim_buf_call(diagnostics.scratch_buffer, function ()
			vim.api.nvim_command("silent %normal gqq");

			final_lines = vim.list_extend(
				final_lines,

				vim.api.nvim_buf_get_lines(
					diagnostics.scratch_buffer,
					0, -1,
					false
				)
			);
		end);
	end

	return #final_lines, final_lines;

	---|fE
end

------------------------------------------------------------------------------

--- Closes diagnostics window.
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

	if #items == 0 then
		-- No diagnostics available.
		diagnostics.__close();
		return;
	end

	---@type boolean Is the window already open?
	local already_open = diagnostics.window and vim.api.nvim_win_is_valid(diagnostics.window);

	if diagnostics.quad then
		-- If the old quadrant wasn't free we
		-- free it here.
		diagnostics.update_quad(diagnostics.quad, false)
	end

	diagnostics.__prepare();
	vim.bo[diagnostics.buffer].ft = "markdown";

	-- Clear old decorations.
	vim.api.nvim_buf_clear_namespace(diagnostics.buffer, diagnostics.ns, 0, -1);
	vim.api.nvim_buf_set_lines(diagnostics.buffer, 0, -1, false, {});

	local W = eval(diagnostics.config.width, items)
	local D = 0;
	local H = 0;

	local cursor_y;
	local ranges = {};

	for i, item in ipairs(items) do
		---|fS

		local from = i == 1 and 0 or -1;

		local wrapped_height, lines = diagnostics.__wrap(
			item.message,
			W
		);

		local start = item.col;
		local stop = item.end_col;
		local current = false;

		if cursor[2] >= start and cursor[2] <= stop then
			cursor_y = math.max(H, 1);
			current = true;
		end

		vim.api.nvim_buf_set_lines(diagnostics.buffer, from, -1, false, lines);
		local decorations = get_decorations(item.severity, item, current);

		D = math.max(D, decorations.width or 0);

		for l = H, H + (wrapped_height - 1), 1 do
			ranges[l] = {
				item.lnum + 1,
				item.col
			};
			vim.api.nvim_buf_set_extmark(diagnostics.buffer, diagnostics.ns, l, 0, {
				virt_text_pos = "inline",
				virt_text = l == H and decorations.icon or (decorations.padding or decorations.icon),

				right_gravity = false,
				line_hl_group = decorations.line_hl_group,
			});
		end

		H = H + wrapped_height;

		---|fE
	end

	H = math.min(H, eval(diagnostics.config.max_height, items) or 0);
	W = W + D;

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

	local border, relative, anchor, row, col = diagnostics.__win_args(window, W, H);
	local win_config = {
		relative = relative or "cursor",

		row = row or 0, col = col or 0,
		width = W, height = H,

		anchor = anchor,
		border = border or "none",
		style = "minimal"
	};

	if not diagnostics.window or not vim.api.nvim_win_is_valid(diagnostics.window) then
		diagnostics.window = vim.api.nvim_open_win(diagnostics.buffer, false, win_config);
	else
		vim.api.nvim_win_set_config(diagnostics.window, win_config);
	end

	if already_open then
		vim.api.nvim_set_current_win(diagnostics.window);
	end

	-- Update quadrant state.
	diagnostics.update_quad(diagnostics.quad, true);

	-- Set necessary options.
	vim.wo[diagnostics.window].signcolumn = "no";
	vim.wo[diagnostics.window].conceallevel = 3;
	vim.wo[diagnostics.window].concealcursor = "ncv";

	vim.wo[diagnostics.window].winhl = "FloatBorder:@comment,Normal:Normal";
	vim.api.nvim_win_set_cursor(diagnostics.window, { cursor_y or 1, 0 })

	-- Markdown rendering.
	if package.loaded["markview"] then
		package.loaded["markview"].render(diagnostics.buffer, {
			enable = true,
			hybrid_mode = false
		});
	end

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
