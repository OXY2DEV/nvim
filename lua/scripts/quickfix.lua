local quickfix = {};

quickfix.config = {
	location_format = "Ranege: %d-%d, %s",
	location_pos = "right_align",

	context_lines = 0,
	decorations = {
		default = {},

		E = {},
		W = {},
		I = {},
		N = {},
		C = {},
	},
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

	if not quickfix.buffer or not vim.api.nvim_buf_is_valid(quickfix.buffer) then
		quickfix.buffer = vim.api.nvim_create_buf(false, true);
		vim.bo[quickfix.buffer].ft = "markdown";

		vim.api.nvim_buf_set_keymap(quickfix.buffer, "n", "<CR>", "", {
			callback = function ()
				local cursor = vim.api.nvim_win_get_cursor(quickfix.window);
				cursor[1] = cursor[1] - 1;

				for i, item in ipairs(quickfix.item_data) do
					local start = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[1], {});
					local stop  = vim.api.nvim_buf_get_extmark_by_id(quickfix.buffer, quickfix.ns, item[2], {});

					if cursor[1] >= start[1] and cursor[1] <= stop[1] then
						vim.print(quickfix.items[i])
						break;
					end
				end
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

				quickfix.render();
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

				quickfix.render();
				pcall(vim.api.nvim_win_set_cursor, quickfix.window, { cursor[1] + 1, cursor[2] });

				---|fE
			end
		});
	end

	---|fE
end

quickfix.render = function ()
	local L = 0;

	local function process_item (i, item)
		---|fS

		---@type integer, integer
		local start_delimier_ext, end_delimiter_ext;
		local context_lines = quickfix.context_lines[i] or 0;

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
		L = L + 1;

		local line_count = vim.api.nvim_buf_line_count(buffer);
		local lines = vim.api.nvim_buf_get_lines(
			buffer,

			math.max((item.lnum - 1) - context_lines, 0),
			math.min(item.end_lnum + (item.lnum == item.end_lnum and 0 or -1) + context_lines, line_count),

			false
		);
		table.insert(lines, "```")

		vim.api.nvim_buf_set_lines(quickfix.buffer, L, -1, false, lines);
		L = L + #lines;

		end_delimiter_ext = vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, L - 1, 0, {
			end_col = 3,
			conceal = "",
		});

		table.insert(quickfix.item_data, { start_delimier_ext, end_delimiter_ext });

		---|fE
	end

	quickfix.prepare();

	vim.api.nvim_buf_clear_namespace(quickfix.buffer, quickfix.ns, 0, -1);
	vim.api.nvim_buf_set_lines(quickfix.buffer, 0, -1, false, {});

	for i, item in ipairs(quickfix.items) do
		if not quickfix.context_lines[i] then
			quickfix.context_lines[i] = quickfix.config.context_lines or 0;
		end

		process_item(i, item);
	end

	return L;
end

quickfix.open = function ()
	quickfix.context_lines = {};
	quickfix.item_data = {};
	quickfix.items = vim.fn.getqflist();

	if #quickfix.items == 0 then
		-- No item available.
		quickfix.close();
		return;
	end

	local L = quickfix.render();

	quickfix.window = vim.api.nvim_open_win(quickfix.buffer, false, {
		split = "below",
		height = math.min(10, L)
	});

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
end

return quickfix;
