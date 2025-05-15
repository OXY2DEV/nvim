--- Custom quickfix menu for Neovim.
local quickfix = {};

------------------------------------------------------------------------------

---@class quickfix.config
---
---@field min_height? integer Minimum height of the window.
---@field max_height? integer Maximum height of the window.
---
---@field context_lines? integer Default number of context lines to show per entry.
---@field decorations? fun(i: integer, item: table): table
---
---@field open_winconfig? table Configuration for opening new buffers.

------------------------------------------------------------------------------

---@type quickfix.config
quickfix.config = {
	min_height = 10,
	context_lines = 0,

	decorations = function (i, item)
		---|fS

		local separator = {
			virt_text_pos = "overlay",
			virt_text = {
				{ string.rep("─", vim.o.columns), "@comment" }
			}
		};

		local buffer = item.bufnr;
		local path = vim.fn.fnamemodify(
			vim.api.nvim_buf_get_name(buffer),
			":~:."
		);

		local top = {
			virt_text_pos = "right_align",
			virt_text = {
				{ path or "", "@string.special.path" }
			}
		};

		---|fS "style: Handle file icon & hl"
		if package.loaded["icons"] then
			local icon = package.loaded["icons"].get(
				vim.fn.fnamemodify(path, ":e"),
				{
					"@comment",
					"DiagnosticError",
					"@constant",
					"DiagnosticWarn",
					"DiagnosticOk",
					"@function",
					"@property"
				}
			);

			top.virt_text = {
				{ icon.icon, icon.hl },
				{ path or "", icon.hl }
			};
		else
			top.virt_text = {
				{ " ", "@string.special.path" },
				{ path or "", "@string.special.path" }
			};
		end
		---|fE

		local type_configs = {
			---|fS

			default = {
				{ " Unknown", "@comment" },
				{ " " },
			},

			I = {
				{ "󰀨 Info", "DiagnosticInfo" },
				{ " " },
			},
			H = {
				{ "󰁨 Hint", "DiagnosticHint" },
				{ " " },
			},
			W = {
				{ " Warn", "DiagnosticWarn" },
				{ " " },
			},
			E = {
				{ "󰅙 Error", "DiagnosticError" },
				{ " " },
			},

			---|fE
		};
		local type_hls = {
			---|fS

			default = "QuickfixRangeInfo",

			I = "QuickfixRangeInfo",
			H = "QuickfixRangeHint",
			W = "QuickfixRangeWarn",
			E = "QuickfixRangeError",

			---|fE
		};

		-- Hints have type `N`.
		type_configs.N = type_configs.H;
		type_hls.N = type_hls.H;

		top.virt_text = vim.list_extend(
			type_configs[item.type] or type_configs.default,
			top.virt_text
		);

		-- Add text Range.
		table.insert(top.virt_text, 1, {
			string.format(" %d,%d-%d,%d ", item.lnum, item.col, item.end_lnum, item.end_col),
			"@comment"
		})

		return {
			top = top,
			bottom = i ~= #quickfix.items and separator or nil,

			line = { line_hl_group = type_hls[item.type] or type_hls.default, invalidate = true }
		};

		---|fE
	end,

	open_winconfig = { win = -1, split = "above" };
};

---@type integer, integer
quickfix.buffer, quickfix.window = nil, nil;

---@type integer
quickfix.ns = vim.api.nvim_create_namespace("fancy-quickfix");

---@type table[]
quickfix.items = {};

---@type [ integer, integer ][] A map between the line number and the underlying quickfix data.
quickfix.item_data = {};

---@type integer[] Number of context line each has.
quickfix.context_lines = {};

------------------------------------------------------------------------------

--- Prepares the buffer & sets keymaps.
quickfix.prepare = function ()
	---|fS

	--- Goes to given buffer.
	---@param buffer integer
	---@param row integer
	---@param col integer
	local function goto_buf (buffer, row, col)
		---|fS

		local wins = vim.fn.win_findbuf(buffer);
		local win;

		if wins[1] then
			vim.api.nvim_set_current_win(wins[1]);
			win = wins[1];
		else
			win = vim.api.nvim_open_win(buffer, true, vim.tbl_extend("force", {
				win = -1,
				split = "right"
			}, quickfix.config.open_winconfig or {}));
		end

		vim.api.nvim_win_set_cursor(win, { row, col });

		---|fE
	end

	--- Gets changes to apply.
	---@param src integer
	---@param src_from integer
	---@param src_to integer
	---@param qf_from integer
	---@param qf_to integer
	---@return table | nil
	local function get_change (src, src_from, src_to, qf_from, qf_to)
		---|fS

		local src_txt = vim.api.nvim_buf_get_lines(src, src_from, src_to + (src_from == src_to and 1 or 0), false);
		local qf_txt = vim.api.nvim_buf_get_lines(quickfix.buffer, qf_from, qf_to, false);

		-- Remove the start & end delimiters
		-- of the code blocks.
		table.remove(qf_txt, 1);
		table.remove(qf_txt);

		if vim.deep_equal(src_txt, qf_txt) == false then
			return {
				buf = src,

				from = src_from,
				to = src_to + (src_from == src_to and 1 or 0),

				lines = qf_txt
			}
		end

		---|fE
	end

	if not quickfix.buffer or not vim.api.nvim_buf_is_valid(quickfix.buffer) then
		---@type integer The quickfix buffer.
		quickfix.buffer = vim.api.nvim_create_buf(false, true);

		-- Use markdown as we want injections
		-- syntax highlighting to work too.
		vim.bo[quickfix.buffer].ft = "markdown";
		-- `acwrite` buffer is used so that
		-- saving changes trigger the `BufWriteCmd`
		-- callback.
		vim.bo[quickfix.buffer].bt = "acwrite";

		-- Do not add statuscolumn & winbar from `bars.nvim`.
		vim.b[quickfix.buffer].bars_statuscolumn = false;
		vim.b[quickfix.buffer].bars_winbar = false;

		-- A name is needed for the `BufWriteCmd` to work
		vim.api.nvim_buf_set_name(quickfix.buffer, "quickfix");
		vim.api.nvim_create_autocmd("BufWriteCmd", {
			buffer = quickfix.buffer,
			callback = function ()
				---|fS

				vim.bo[quickfix.buffer].modified = false;
				local changes = {};

				for i, item in ipairs(quickfix.item_data) do
					local start = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[1], {});
					local stop  = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[2], {});

					if start[1] and stop[1] then
						local qfx_item = quickfix.items[i];

						local context_lines = quickfix.context_lines[i];
						local line_count = vim.api.nvim_buf_line_count(qfx_item.bufnr);

						local src_from = math.max((qfx_item.lnum - 1) - context_lines, 0);
						local src_to = math.min(qfx_item.end_lnum + (qfx_item.lnum == qfx_item.end_lnum and 0 or -1) + context_lines, line_count);

						local change = get_change(qfx_item.bufnr, src_from, src_to, start[1], stop[1] + 1)

						if change then
							table.insert(changes, change);
						end
					end
				end

				for _, entry in ipairs(changes) do
					vim.api.nvim_buf_set_lines(entry.buf, entry.from, entry.to, false, entry.lines);
					vim.api.nvim_buf_call(entry.buf, function ()
						vim.cmd("write");
					end);
				end

				---|fE
			end
		});

		---|fS "feat: Add keymaps"

		-- If the fancy diagnostics is available then map it to `D`.
		if package.loaded["scripts.diagnostics"] then
			vim.api.nvim_buf_set_keymap(quickfix.buffer, "n", "D", "", {
				callback = package.loaded["scripts.diagnostics"].hover
			});
		end

		-- Use `<Enter>` to go to the entry under cursor.
		vim.api.nvim_buf_set_keymap(quickfix.buffer, "n", "<CR>", "", {
			callback = function ()
				---|fS

				---@type [ integer, integer ]
				local cursor = vim.api.nvim_win_get_cursor(quickfix.window);
				cursor[1] = cursor[1] - 1;

				for i, item in ipairs(quickfix.item_data) do
					local start = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[1], {});
					local stop  = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[2], {});

					if cursor[1] >= start[1] and cursor[1] <= stop[1] then
						local qfx_item = quickfix.items[i];

						goto_buf(qfx_item.bufnr, qfx_item.lnum, qfx_item.col - 1);
						break;
					end
				end

				---|fE
			end
		});

		-- Use `q` to exit out of quickfix.
		vim.api.nvim_buf_set_keymap(quickfix.buffer, "n", "q", "", {
			callback = function ()
				pcall(vim.api.nvim_win_close, quickfix.window, true);
			end
		});

		-- Use `L` to increase context lines.
		vim.api.nvim_buf_set_keymap(quickfix.buffer, "n", "L", "", {
			callback = function ()
				---|fS

				local cursor = vim.api.nvim_win_get_cursor(quickfix.window);
				cursor[1] = cursor[1] - 1;

				for i, item in ipairs(quickfix.item_data) do
					local start = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[1], {});
					local stop  = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[2], {});

					if cursor[1] >= start[1] and cursor[1] <= stop[1] then
						quickfix.context_lines[i] = quickfix.context_lines[i] + 1;
						break;
					end
				end

				local L = quickfix.render();
				local height = math.max(
					L,
					math.min(quickfix.config.max_height or math.floor(vim.o.lines * 0.4), L),
					quickfix.config.min_height or 3
				)

				pcall(vim.api.nvim_win_set_config, quickfix.window, { height = height });
				pcall(vim.api.nvim_win_set_cursor, quickfix.window, { cursor[1] + 1, cursor[2] });

				---|fE
			end
		});

		-- Use `R` to decrease context lines.
		vim.api.nvim_buf_set_keymap(quickfix.buffer, "n", "R", "", {
			callback = function ()
				---|fS

				local cursor = vim.api.nvim_win_get_cursor(quickfix.window);
				cursor[1] = cursor[1] - 1;

				for i, item in ipairs(quickfix.item_data) do
					local start = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[1], {});
					local stop  = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[2], {});

					if cursor[1] >= start[1] and cursor[1] <= stop[1] then
						quickfix.context_lines[i] = math.max(0, quickfix.context_lines[i] - 1);
						break;
					end
				end

				local L = quickfix.render();
				local height = math.max(
					L,
					math.min(quickfix.config.max_height or math.floor(vim.o.lines * 0.4), L),
					quickfix.config.min_height or 3
				)

				pcall(vim.api.nvim_win_set_config, quickfix.window, { height = height });
				pcall(vim.api.nvim_win_set_cursor, quickfix.window, { cursor[1] + 1, cursor[2] });

				---|fE
			end
		});

		---|fE
	end

	---|fE
end

--- Renders the quickfix menu.
---@return integer L The line count of the quickfix buffer 
quickfix.render = function ()
	---|fS

	quickfix.item_data = {};
	local L = 0;

	local diagnostics = {};

	--- Gets severity.
	---@param level "E" | "W" | "H" | "I" | string
	---@return integer
	local function get_severity (level)
		---|fS

		if level == "E" then
			return vim.diagnostic.severity.ERROR;
		elseif level == "W" then
			return vim.diagnostic.severity.WARN;
		elseif level == "H" then
			return vim.diagnostic.severity.HINT;
		end

		return vim.diagnostic.severity.INFO;

		---|fE
	end

	--- Processes quickfix items.
	---@param i integer
	---@param item vim.quickfix.entry
	local function process_item (i, item)
		---|fS

		if not item.bufnr then
			return;
		end

		---@type integer, integer
		local start_delimier_ext, end_delimiter_ext;
		local context_lines = quickfix.context_lines[i] or 0;

		local has_decors, decors = pcall(quickfix.config.decorations, i, item);

		---@type integer
		local buffer = item.bufnr;
		vim.fn.bufload(buffer);

		local ft = vim.bo[buffer].ft or "";
		local start_delimiter = string.format("```%s", ft);

		-- Creates the start delimiter for fenced
		-- code block.
		vim.api.nvim_buf_set_lines(quickfix.buffer, L, -1, false, {
			start_delimiter
		});

		---|fS "style: Top of the entry"

		-- Hide the text and apply text decorations.
		start_delimier_ext = vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L, 0, {
			end_col = #start_delimiter,
			conceal = "",
		});

		-- Add top decorations.
		if has_decors and type(decors.top) == "table" then
			vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L, 0, vim.tbl_extend("keep", {
				end_col = #start_delimiter
			}, decors.top));
		end

		---|fE

		local line_count = vim.api.nvim_buf_line_count(buffer);

		local code_start = math.max((item.lnum - 1) - context_lines, 0);
		local code_end = math.min(item.end_lnum + (item.lnum == item.end_lnum and 0 or -1) + context_lines, line_count);

		local lines = vim.api.nvim_buf_get_lines(
			buffer,

			code_start,
			code_end,

			false
		);
		table.insert(lines, "```")

		L = L + 1;
		vim.api.nvim_buf_set_lines(quickfix.buffer, L, -1, false, lines);

		---|fS "style: Line containing the error"

		-- Add range decorations.
		if has_decors and type(decors.line) == "table" then
			vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L + ((item.lnum - 1) - code_start), 0, decors.line);
		end

		table.insert(diagnostics, {
			bufnr = item.bufnr,

			lnum = L + ((item.lnum - 1) - code_start),
			end_lnum = L + ((item.end_lnum - 1) - code_start),

			col = item.col - 1,
			end_col = item.end_col - 1,

			severity = get_severity(item.type),

			namesace = quickfix.ns,
			source = "quickfix",

			message = item.text or "Hello"
		});

		---|fE

		L = L + #lines;

		---|fS "style: Bottom of the entry"

		end_delimiter_ext = vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L - 1, 0, {
			end_col = 3,
			conceal = "",
		});

		-- Add bottom decorations.
		if has_decors and type(decors.bottom) == "table" then
			vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L - 1, 0, vim.tbl_extend("keep", {
				end_col = 3;
			}, decors.bottom));
		end

		---|fE

		table.insert(quickfix.item_data, { start_delimier_ext, end_delimiter_ext });

		---|fE
	end

	quickfix.prepare();
	vim.bo[quickfix.buffer].undolevels = -1;

	vim.api.nvim_buf_clear_namespace(quickfix.buffer, quickfix.ns, 0, -1);
	vim.api.nvim_buf_set_lines(quickfix.buffer, 0, -1, false, {});

	for i, item in ipairs(quickfix.items) do
		if not quickfix.context_lines[i] then
			quickfix.context_lines[i] = quickfix.config.context_lines or 0;
		end

		process_item(i, item);
	end

	vim.diagnostic.reset(quickfix.ns, quickfix.buffer);
	vim.diagnostic.set(quickfix.ns, quickfix.buffer, diagnostics, {});

	vim.bo[quickfix.buffer].modified = false;
	vim.bo[quickfix.buffer].undolevels = 100;

	return L;

	---|fE
end

------------------------------------------------------------------------------

--- Opens the quickfix menu with `items`.
---@param items? vim.quickfix.entry[]
quickfix.open = function (items)
	---|fS

	quickfix.context_lines = {};
	quickfix.items = vim.tbl_filter(function (item)
		-- Do not include items from the quickfix window itself.
		return item.bufnr ~= quickfix.buffer;
	end, items or vim.fn.getqflist());

	if #quickfix.items == 0 then
		-- No item available.
		quickfix.close();
		return;
	end

	local L = quickfix.render();
	local win_config = {
		split = "below",
		height = math.max(
			math.min(quickfix.config.max_height or math.floor(vim.o.lines * 0.4), L),
			quickfix.config.min_height or 3
		)
	};

	if quickfix.window and vim.api.nvim_win_is_valid(quickfix.window) then
		vim.api.nvim_win_set_config(quickfix.window, win_config)
	else
		quickfix.window = vim.api.nvim_open_win(quickfix.buffer, false, win_config);
	end

	vim.api.nvim_set_current_win(quickfix.window);

	---|fS "style: Change quickfix window appearance"

	-- Get rid of the statuscolumn.
	vim.wo[quickfix.window].number = false;
	vim.wo[quickfix.window].relativenumber = false;
	vim.wo[quickfix.window].signcolumn = "no";
	vim.wo[quickfix.window].foldcolumn = "0";

	-- Set up concealing.
	vim.wo[quickfix.window].conceallevel = 3;
	vim.wo[quickfix.window].concealcursor = "nvc";

	-- Hide listchars & cursorline.
	vim.wo[quickfix.window].list = false;
	vim.wo[quickfix.window].cursorline = false;

	---|fE

	---|fE
end

--- Closes any open quickfix menu.
quickfix.close = function ()
	---|fS

	if quickfix.window and vim.api.nvim_win_is_valid(quickfix.window) then
		vim.api.nvim_win_close(quickfix.window, true);
		quickfix.window = nil;
	end

	quickfix.items = {};
	quickfix.item_data = {};
	quickfix.context_lines = {};

	pcall(vim.diagnostic.reset, quickfix.ns, quickfix.buffer);

	---|fE
end

------------------------------------------------------------------------------

--- Setup function for the quickfix menu.
---@param config? quickfix.config
quickfix.setup = function (config)
	---|fS

	if type(config) == "table" then
		quickfix.config = vim.tbl_extend("force", quickfix.config, config or {});
	end

	vim.api.nvim_set_keymap("n", "Q", "", {
		callback = function ()
			vim.fn.setqflist(
				vim.diagnostic.toqflist(
					vim.diagnostic.get()
				)
			);
			quickfix.open();
		end
	});

	---|fE
end

return quickfix;
