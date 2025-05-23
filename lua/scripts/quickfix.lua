--- Custom quickfix menu for Neovim.
local quickfix = {};

--- Shortens path segment length.
---@param path string
---@return string
local function shorten_path (path)
	---|fS

	local sep = string.sub(package.config, 1, 1);
	local as_raw = {
		"nvim$",
	};

	local function is_raw (str)
		for _, pattern in ipairs(as_raw) do
			if string.match(str, pattern) then
				return true;
			end
		end

		return false;
	end

	local parts = vim.split(path, sep, { trimempty = true });
	local shortened = {};

	for p, part in ipairs(parts) do
		if is_raw(part) or p == 1 or p == #parts then
			table.insert(shortened, part);
		elseif string.match(part, "^%.") then
			table.insert(shortened, vim.fn.strcharpart(part, 0, 2));
		else
			table.insert(shortened, vim.fn.strcharpart(part, 0, 1));
		end
	end

	return table.concat(shortened, sep);

	---|fE
end

--- Creates range text between a & b.
---@param a number
---@param b number
---@return string
local function range_text (a, b)
	---|fS

	if a ~= b then
		return tostring(a) .. "-" .. tostring(b);
	else
		return tostring(a);
	end

	---|fE
end

--- Centers text.
---@param text string
---@param width integer
---@return string
local function center (text, width)
	---|fS

	local text_width = vim.fn.strdisplaywidth(text);
	local before, after = math.floor((width - text_width) / 2), math.ceil((width - text_width) / 2);

	return string.rep(" ", before) .. text .. string.rep(" ", after);

	---|fE
end

---@type "quickfix" | "location" Currently visible list type.
quickfix.list = nil;

---@type integer Decoration namespace.
quickfix.ns = vim.api.nvim_create_namespace("quickfix");

---@type integer The buffer showing the quickfix list.
quickfix.buffer = nil;

---@type integer
quickfix.winid = nil;

------------------------------------------------------------------------------

--- Text to show for the location list.
---@param data any
---@return string[]
quickfix.loc_text = function (data) ---@diagnostic disable-line
	---|fS

	local items = vim.fn.getloclist(data.winid, { id = data.id, items = 0 }).items;
	local infos = {};

	local p_width, s_width = 0, 0;

	for i = data.start_idx, data.end_idx do
		---|fS "doc: Quickfix item to information table"

		local item = items[i];
		local buf = item.bufnr;

		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":~:.");
		name = shorten_path(name);

		local row, col = range_text(item.lnum, item.end_lnum), range_text(item.col, item.end_col);

		p_width = math.max(p_width, vim.fn.strdisplaywidth(name));
		s_width = math.max(s_width, vim.fn.strdisplaywidth(row .. " col " .. col));

		if vim.api.nvim_buf_is_loaded(buf) then
			---|fS

			local ft = vim.bo[buf].ft;

			table.insert(infos, {
				path = name,
				filetype = ft ~= "" and ft or nil,

				row = row,
				col = col,

				text = item.text
			});

			---|fE
		else
			---|fS

			local ft;

			if string.match(quickfix.last_command or "", "grep") then
				-- Only add filetype for searches.
				ft = vim.filetype.match({ filename = name });
			end

			table.insert(infos, {
				path = name,
				filetype = ft ~= "" and ft or nil,

				row = row,
				col = col,

				text = item.text
			});

			---|fE
		end

		---|fE
	end

	---@type string[]
	local lines = {};

	for _, info in ipairs(infos) do
		---|fS "doc: Turns info to line"

		local line = string.format(" %" .. p_width .. "s", info.path);
		line = line .. " | ";

		line = line .. center(info.row .. " col " .. info.col, s_width);
		line = line .. " |";

		if info.filetype then
			line = line .. string.format(">!%s!< %s", info.filetype, info.text);
		else
			line = line .. " ".. info.text;
		end

		table.insert(lines, line);

		---|fE
	end

	return lines;

	---|fE
end

--- Text to show for the quickfix list.
---@param data any
---@return string[]
quickfix.qf_text = function (data)
	---|fS

	local items = vim.fn.getqflist({ id = data.id, items = 0 }).items;
	local infos = {};

	local p_width, s_width = 0, 0;

	for i = data.start_idx, data.end_idx do
		---|fS "doc: Quickfix item to information table"

		local item = items[i];
		local buf = item.bufnr;

		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":~:.");
		name = shorten_path(name);

		local row, col = range_text(item.lnum, item.end_lnum), range_text(item.col, item.end_col);

		p_width = math.max(p_width, vim.fn.strdisplaywidth(name));
		s_width = math.max(s_width, vim.fn.strdisplaywidth(row .. " col " .. col));

		if vim.api.nvim_buf_is_loaded(buf) then
			---|fS

			local ft = vim.bo[buf].ft;
			local line = vim.api.nvim_buf_get_lines(buf, item.lnum - 1, item.lnum, false)[1];

			table.insert(infos, {
				path = name,
				filetype = ft ~= "" and ft or nil,

				row = row,
				col = col,

				text = line
			});

			---|fE
		else
			---|fS

			local ft;

			if string.match(quickfix.last_command or "", "grep") then
				-- Only add filetype for searches.
				ft = vim.filetype.match({ filename = name });
			end

			table.insert(infos, {
				path = name,
				filetype = ft ~= "" and ft or nil,

				row = row,
				col = col,

				text = item.text
			});

			---|fE
		end

		---|fE
	end

	---@type string[]
	local lines = {};

	for _, info in ipairs(infos) do
		---|fS "doc: Turns info to line"

		local line = string.format(" %" .. p_width .. "s", info.path);
		line = line .. " | ";

		line = line .. center(info.row .. " col " .. info.col, s_width);
		line = line .. " |";

		if info.filetype then
			line = line .. string.format(">!%s!< %s", info.filetype, info.text);
		else
			line = line .. " ".. info.text;
		end

		table.insert(lines, line);

		---|fE
	end

	return lines;

	---|fE
end

--- Text to show in the quickfix window.
---@param data any
---@return string[]
quickfix.text = function (data)
	---|fS

	if data.quickfix == 1 then
		quickfix.list = "quickfix";
		return quickfix.qf_text(data);
	else
		quickfix.list = "location";
		return quickfix.loc_text(data);
	end

	---|fE
end

------------------------------------------------------------------------------

--- Adds decorations for the given node.
---@param name string
---@param TSNode table
quickfix.add_decor = function (name, TSNode)
	---|fS

	local line_count = vim.api.nvim_buf_line_count(quickfix.buffer);

	local callbacks = {
		qf_filename = function ()
			---|fS

			local text = vim.treesitter.get_node_text(TSNode, quickfix.buffer, {});
			local whitespaces = string.match(text, "^%s*");

			local range = { TSNode:range() };

			if not package.loaded["icons"] then
				return;
			end

			local icon = package.loaded["icons"].get(
				vim.fn.fnamemodify(text, ":e"),
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

			vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, range[1], range[2] + #whitespaces, {
				end_col = range[4],

				virt_text_pos = "inline",
				virt_text = {
					{ icon.icon, icon.hl }
				},

				hl_group = icon.hl
			});

			---|fE
		end,

		qf_separator = function ()
			---|fS

			local text = vim.treesitter.get_node_text(TSNode, quickfix.buffer, {});
			local whitespaces = string.match(text, "^%s*");

			local range = { TSNode:range() };
			local char = "│";

			if range[1] == 0 then
				char = "╷";
			elseif range[1] == line_count - 1 then
				char = "╵";
			end

			vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, range[1], range[2] + #whitespaces, {
				end_col = range[4],
				hl_mode = "combine",

				virt_text_pos = "overlay",
				virt_text = {
					{ char }
				},
			});

			---|fE
		end,

		qf_content = function ()
			---|fS

			local text = vim.treesitter.get_node_text(TSNode, quickfix.buffer, {});
			local whitespaces = string.match(text, "^%s*");

			local range = { TSNode:range() };

			local kinds = {
				default = { "󱈤 ", "@function" },
				loc = { " ", "@conditional" },

				w = { " ", "DiagnosticWarn" },
				e = { "󰅙 ", "DiagnosticError" },
				i = { "󰀨 ", "DiagnosticInfo" },
				n = { "󰁨 ", "DiagnosticHint" },
			};
			local virt_text = kinds.default;

			if quickfix.list == "location" then
				virt_text = kinds.loc;
			else
				local qflist = vim.fn.getqflist();

				if qflist[range[1] + 1] then
					local item = qflist[range[1] + 1];
					local type = string.lower(item.type or "");

					virt_text = kinds[type] or kinds.default;

					if item.text and item.text ~= "" and text ~= " " .. item.text then
						---|fS

						-- Show the actual message below if the buffer
						-- text is being shown instead of the message.
						vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, range[1], range[2], {
							virt_lines = {
								{
									{ " ╰╴", "@comment" },
									{ item.text, virt_text[2] }
								}
							},
						});

						---|fE
					elseif item.text and item.text ~= "" then
						-- Unloaded buffer's show the item text.
						-- Change the icon as an indicator.
						virt_text = {
							"󰵅 ", virt_text[2]
						};
					end
				end
			end

			---@type boolean Are there whitespace before this node?
			local has_space = #whitespaces > 0;

			vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, range[1], range[2] + (has_space and 1 or 0), {
				virt_text_pos = "inline",
				virt_text = {
					{ has_space and "" or " " },
					virt_text
				},
			});

			if not TSNode:prev_sibling() then
				vim.api.nvim_buf_set_extmark(quickfix.buffer, quickfix.ns, range[1], range[2] + #whitespaces, {
					end_col = range[4],
					hl_group = "@comment"
				});
			end

			---|fE
		end
	};

	if callbacks[name] then
		local can_call, err = pcall(callbacks[name]);

		if can_call == false then
			vim.print(err);
		end
	end

	---|fE
end

--- Decorates quickfix menu.
---@param from integer Start.
---@param to integer End.
quickfix.decorate = function (from, to)
	---|fS

	local function get_tstree ()
		---|fS

		local parser = vim.treesitter.get_parser(quickfix.buffer, "qf", { error = false });

		if not parser then
			return;
		end

		local TSTrees = parser:parse(true);

		if not TSTrees then
			return;
		elseif TSTrees[1]:root():type() ~= "quickfix_list" then
			return;
		end

		return TSTrees[1];

		---|fE
	end

	if not quickfix.buffer or not vim.api.nvim_buf_is_valid(quickfix.buffer) then
		return;
	end

	vim.api.nvim_buf_clear_namespace(quickfix.buffer, quickfix.ns, 0, -1);
	local TSTree = get_tstree();

	if not TSTree then
		return;
	end

	local queries = vim.treesitter.query.parse("qf", [[
		(filename) @qf_filename

		[ "|" ] @qf_separator

		(code_block
			(content) @qf_content)
	]]);

	for id, node in queries:iter_captures(TSTree:root(), quickfix.buffer, from, to) do
		local name = queries.captures[id];
		quickfix.add_decor(name, node);
	end

	---|fE
end

------------------------------------------------------------------------------

--- Setup function for the quickfix menu.
quickfix.setup = function ()
	---|fS

	-- Custom quickfix text function.
	vim.o.quickfixtextfunc = "{ item -> v:lua.require('scripts.quickfix').text(item) }";

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "qf",
		callback = function (event)
			---|fS

			quickfix.buffer = event.buf;

			---|fS "fix: tree-sitter highlight update"

			--- BUG, Quickfix menu doesn't update it's
			--- tree-sitter highlighting.
			--- So, we rewrite the entire buffer.
			vim.bo[quickfix.buffer].modifiable = true;

			local lines = vim.api.nvim_buf_get_lines(quickfix.buffer, 0, -1, false);
			vim.api.nvim_buf_set_lines(quickfix.buffer, 0, -1, false, lines);

			vim.bo[quickfix.buffer].modifiable = false;
			vim.bo[quickfix.buffer].modified = false;

			---|fE

			local win = vim.fn.win_findbuf(quickfix.buffer)[1];
			local H = math.floor(vim.o.columns * 0.5);

			if win then
				vim.wo[win].conceallevel = 3;
				vim.wo[win].concealcursor = "nc";

				H = vim.api.nvim_win_get_height(win);
			end

			quickfix.decorate(0, H);

			---|fE
		end
	});

	vim.api.nvim_create_autocmd("QuickfixCmdPre", {
		callback = function (event)
			quickfix.last_command = event.match;
		end
	});

	vim.api.nvim_create_autocmd("CursorMoved", {
		callback = function ()
			---|fS

			local buf = vim.api.nvim_get_current_buf();

			if buf ~= quickfix.buffer then
				return;
			end

			local win = vim.api.nvim_get_current_win();
			local H = vim.api.nvim_win_get_height(win);

			local cursor = vim.api.nvim_win_get_cursor(win);
			local lines = vim.api.nvim_buf_line_count(buf);

			quickfix.decorate(
				math.max(0, cursor[1] - H),
				math.min(lines, cursor[1] + H)
			);

			---|fE
		end
	});

	---|fE
end

return quickfix;
