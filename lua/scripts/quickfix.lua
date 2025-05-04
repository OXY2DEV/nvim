--- Custom quickfix menu for Neovim.
local quickfix = {};

quickfix.config = {
	context_lines = 0,
	decorations = function (i, item)
		---|fS

		local separator = {
			virt_text_pos = "overlay",
			virt_text = {
				{ string.rep("─", vim.o.columns - 2), "@comment" }
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
			default = {
				{ "  Unknown ", "@comment" },
				{ " " }
			},

			I = {
				{ " 󰀨 Info ", "DiagnosticVirtualTextsInfo" },
				{ " " }
			},
			H = {
				{ " 󰁨 Hint ", "DiagnosticVirtualTextsHint" },
				{ " " }
			},
			W = {
				{ "  Warn ", "DiagnosticVirtualTextWarn" },
				{ " " }
			},
			E = {
				{ " 󰅙 Error ", "DiagnosticVirtualTextError" },
				{ " " }
			},
		};

		top.virt_text = vim.list_extend(
			type_configs[item.type] or type_configs.default,
			top.virt_text
		);

		-- Add text Range.
		table.insert(top.virt_text, 1, {
			string.format(" %d,%d-%d,%d ", item.lnum, item.col, item.end_lnum, item.end_col),
			"@comment"
		})

		return top, i ~= #quickfix.items and separator or nil, nil;

		---|fE
	end,
};

---@type integer, integer
quickfix.buffer, quickfix.window = nil, nil;
---@type integer
quickfix.ns = vim.api.nvim_create_namespace("fancy-quickfix");

quickfix.items = {};

---@type [ integer, integer ][] A map between the line number and the underlying quickfix data.
quickfix.item_data = {};

quickfix.context_lines = {};

quickfix.prepare = function ()
	---|fS

	local function goto_buf (buffer)
		---|fS

		local wins = vim.fn.win_findbuf(buffer);

		if wins[1] then
			vim.api.nvim_set_current_win(wins[1]);
		else
			vim.api.nvim_open_win(buffer, true, vim.tbl_extend("force", {
				win = -1,
				split = "right"
			}, quickfix.config.open_winconfig or {}));
		end

		---|fE
	end

	local function apply_change (src, src_from, src_to, qf_from, qf_to)
		local src_txt = vim.api.nvim_buf_get_lines(src, src_from, src_to + (src_from == src_to and 1 or 0), false);
		local qf_txt = vim.api.nvim_buf_get_lines(quickfix.buffer, qf_from, qf_to, false);

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
	end

	if not quickfix.buffer or not vim.api.nvim_buf_is_valid(quickfix.buffer) then
		quickfix.buffer = vim.api.nvim_create_buf(false, true);

		vim.bo[quickfix.buffer].ft = "markdown";
		vim.bo[quickfix.buffer].bt = "acwrite";

		vim.b[quickfix.buffer].bars_statuscolumn = false;

		vim.api.nvim_buf_set_name(quickfix.buffer, "quickfix")
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

						local change = apply_change(qfx_item.bufnr, src_from, src_to, start[1], stop[1] + 1)

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

		vim.api.nvim_buf_set_keymap(quickfix.buffer, "n", "<CR>", "", {
			callback = function ()
				---|fS

				local cursor = vim.api.nvim_win_get_cursor(quickfix.window);
				cursor[1] = cursor[1] - 1;

				for i, item in ipairs(quickfix.item_data) do
					local start = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[1], {});
					local stop  = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[2], {});

					if cursor[1] >= start[1] and cursor[1] <= stop[1] then
						local qfx_item = quickfix.items[i];

						goto_buf(qfx_item.bufnr);
						vim.api.nvim_win_set_cursor(
							vim.api.nvim_get_current_win(),
							{ qfx_item.lnum, qfx_item.col - 1 }
						);
						break;
					end
				end

				---|fE
			end
		});

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

				pcall(vim.api.nvim_win_set_config, quickfix.window, { height = L });
				pcall(vim.api.nvim_win_set_cursor, quickfix.window, { cursor[1] + 1, cursor[2] });

				---|fE
			end
		});

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

				pcall(vim.api.nvim_win_set_config, quickfix.window, { height = L });
				pcall(vim.api.nvim_win_set_cursor, quickfix.window, { cursor[1] + 1, cursor[2] });

				---|fE
			end
		});
	end

	---|fE
end

quickfix.render = function ()
	quickfix.item_data = {};
	local L = 0;

	local function process_item (i, item)
		---|fS

		---@type integer, integer
		local start_delimier_ext, end_delimiter_ext;
		local context_lines = quickfix.context_lines[i] or 0;

		local has_decors, top, bottom, middle = pcall(quickfix.config.decorations, i, item);

		local buffer = item.bufnr;
		vim.fn.bufload(buffer);

		local ft = vim.bo[buffer].ft or "";
		local start_delimiter = string.format("```%s", ft);

		-- Creates the start delimiter for fenced
		-- code block.
		vim.api.nvim_buf_set_lines(quickfix.buffer, L, -1, false, {
			start_delimiter
		});

		-- Hide the text and apply text decorations.
		start_delimier_ext = vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L, 0, {
			end_col = #start_delimiter,
			conceal = "",
		});

		-- Add top decorations.
		if has_decors and type(top) == "table" then
			vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L, 0, vim.tbl_extend("keep", {
				end_col = #start_delimiter
			}, top));
		end

		local line_count = vim.api.nvim_buf_line_count(buffer);
		local lines = vim.api.nvim_buf_get_lines(
			buffer,

			math.max((item.lnum - 1) - context_lines, 0),
			math.min(item.end_lnum + (item.lnum == item.end_lnum and 0 or -1) + context_lines, line_count),

			false
		);
		table.insert(lines, "```")

		L = L + 1;
		vim.api.nvim_buf_set_lines(quickfix.buffer, L, -1, false, lines);

		-- Add range decorations.
		if has_decors and type(middle) == "table" then
			vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L - 1, 0, vim.tbl_extend("keep", {
				end_row = L + #lines;
			}, middle));
		end

		L = L + #lines;

		end_delimiter_ext = vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L - 1, 0, {
			end_col = 3,
			conceal = "",
		});

		-- Add bottom decorations.
		if has_decors and type(bottom) == "table" then
			vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L - 1, 0, vim.tbl_extend("keep", {
				end_col = 3;
			}, bottom));
		end

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

	vim.bo[quickfix.buffer].modified = false;
	vim.bo[quickfix.buffer].undolevels = 100;

	return L;
end

quickfix.open = function (items)
	quickfix.context_lines = {};
	quickfix.items = items or vim.fn.getqflist();

	if #quickfix.items == 0 then
		-- No item available.
		quickfix.close();
		return;
	end

	local L = quickfix.render();
	local win_config = {
		split = "below",
		height = math.min(10, L),
	};

	if quickfix.window and vim.api.nvim_win_is_valid(quickfix.window) then
		vim.api.nvim_win_set_config(quickfix.window, win_config)
	else
		quickfix.window = vim.api.nvim_open_win(quickfix.buffer, false, win_config);
	end

	vim.api.nvim_set_current_win(quickfix.window);

	vim.wo[quickfix.window].conceallevel = 3;
	vim.wo[quickfix.window].concealcursor = "nvc";

	vim.wo[quickfix.window].list = false;
	vim.wo[quickfix.window].cursorline = false;

	vim.wo[quickfix.window].wrap = true;
	vim.wo[quickfix.window].linebreak = true;
	vim.wo[quickfix.window].breakindent = true;
end

quickfix.close = function ()
	if quickfix.window and vim.api.nvim_win_is_valid(quickfix.window) then
		vim.api.nvim_win_close(quickfix.window, true);
		quickfix.window = nil;
	end
end

quickfix.setup = function ()
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
	vim.api.nvim_set_keymap("n", "L", "", {
		callback = function ()
			quickfix.open(
				vim.fn.getloclist(vim.api.nvim_get_current_win())
			);
		end
	});
end

return quickfix;
