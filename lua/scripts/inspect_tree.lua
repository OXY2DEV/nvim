---@class inspect.data Parsed TSNose data.
---
---@field language string Language name
---@field injected? inspect.injection Injected TSTree.
---
---@field depth integer Depth of a TSNode.
---@field injection_depth integer Depth of injection.
---
---@field type string TSNode type.
---@field range integer[] TSNode range, { row_start, col_start, row_end, col_end }.
---@field node TSNode
---
---@field missing boolean Is the node a missing node?
---@field named boolean Is the mode a named node?
---@field extra boolean Is the node an extra node?
---
---@field has_error boolean Does the node have error?
---@field lines integer Number of lines this node's children take.


---@class inspect.injection An injected tree.
---
---@field language string Language name.
---@field root TSNode Root of the injected tree.


------------------------------------------------------------------------------


local inspect = {};

inspect.map = {};

inspect.config = {
	named_only = false,
	indent_size = 4,

	injections = require("scripts.tree_maps").injections,

	anonymous_nodes = require("scripts.tree_maps").anon,
	named_nodes = require("scripts.tree_maps").named,
};

---@param node TSNode
---@param language string
---@param injection_map table<integer, inspect.injection>
---@param depth integer
---@param injection_depth integer
---@param named_only boolean
---@return string[]
---@return inspect.data[]
inspect.tostring = function (node, language, injection_map, depth, injection_depth, named_only)
	if not node then
		return {}, {};
	elseif named_only and not node:named() then
		return {}, {};
	end

	local n_type = node:type();
	local id = node:id();
	local lines, datas = {}, {};

	table.insert(datas, {
		language = language,
		injected = injection_map[id],

		depth = depth,

		type = node:type(),
		range = { node:range() },
		node = node,

		missing = node:missing(),
		named = node:named(),
		extra = node:extra(),
		has_error = node:has_error(),
	});

	if node:named() then
		table.insert(lines, string.format("(%s", n_type))
	else
		local escaped = '"' .. n_type:gsub('"', '\\"') .. '"';
		table.insert(lines, escaped);
	end

	if injection_map[id] then
		injection_depth = injection_depth + 1;
		datas[1].injection_depth = injection_depth;

		local inj = injection_map[id];
		local inj_lines, inj_datas = inspect.tostring(inj.root, inj.language, injection_map, depth + 1, injection_depth, named_only);

		for l, line in ipairs(inj_lines) do
			inj_lines[l] = "\t" .. line;
		end

		lines = vim.list_extend(lines, inj_lines);
		datas = vim.list_extend(datas, inj_datas);
	end

	for child, field_name in node:iter_children() do
		local child_lines, child_datas = inspect.tostring(child, language, injection_map, depth + 1, injection_depth, named_only);

		if #child_lines == 0 then
			goto ignore;
		end

		if field_name then
			child_lines[1] = field_name .. ": " .. child_lines[1];
		end

		for l, line in ipairs(child_lines) do
			child_lines[l] = "\t" .. line;
		end

		lines = vim.list_extend(lines, child_lines);
		datas = vim.list_extend(datas, child_datas);

		::ignore::
	end

	if node:named() then
		lines[#lines] = lines[#lines] .. ")";
	end

	datas[1].lines = #lines;
	return lines, datas;
end

---@param parser vim.treesitter.LanguageTree
---@return table<integer, inspect.injection>
inspect.injected = function (parser)
	local function contains (a, b)
		local a_rs, a_cs, a_re, a_ce = unpack(a);
		local b_rs, b_cs, b_re, b_ce = unpack(b);

		if b_rs < a_rs or b_re > a_re then
			return false;
		elseif a_rs == b_rs and a_cs > b_cs then
			return false;
		elseif a_re == b_re and b_ce > a_ce then
			return false;
		end

		return true
	end

	local output = {};

	parser:for_each_tree(function (TSTree, LanguageTree)
		local main_root = TSTree:root();
		local main_range = { main_root:range() };

		for _, childTree in pairs(LanguageTree:children()) do
			for _, subTSTree in pairs(childTree:trees()) do
				local sub_root = subTSTree:root();
				local sub_range = { sub_root:range() };

				if contains(main_range, sub_range) then
					local container = main_root:named_descendant_for_range(unpack(sub_range));

					if container then
						output[container:id()] = {
							language = childTree:lang(),
							root = sub_root
						};
					end
				end
			end
		end
	end);

	return output;
end

inspect.ns = vim.api.nvim_create_namespace("Inspect");

inspect.decorator_ns = vim.api.nvim_create_namespace("inspect.decor")

inspect.parse = function (buffer, named_only)
	local parser = vim.treesitter.get_parser(buffer or 0, nil, {});
	if not parser then return; end

	local TSTree = parser:parse(true)[1];
	local injected_nodes = inspect.injected(parser);

	local lines, data = inspect.tostring(TSTree:root(), parser:lang(), injected_nodes, 0, 0, named_only);

	for l, line in ipairs(lines) do
		local line_data = data[l];
		lines[l] = line .. string.format(" ; [%d, %d] to [%d, %d]", unpack(line_data.range));
	end

	return lines, data;
end

---@param src table<string, any>
---@param text string
---@return any
local function match (src, text)
	for k, v in pairs(src) do
		if string.match(text, k) then
			return v;
		end
	end

	return src.default or {};
end


------------------------------------------------------------------------------


local inspector = {
	buffer = nil,
	window = nil,
};
inspector.__index = inspector;

function inspector:__hide_params (node)
	local range = { node:range() };

	vim.api.nvim_buf_set_extmark(self.buf, inspect.decorator_ns, range[1], range[2], {
		end_col = range[4],
		conceal = ""
	});
end

function inspector:__highlight_named (node)
	local range = { node:range() };

	local line_data = self.parsed_data[range[1] + 1] or {};
	local lang = line_data.language;

	local node_name = string.match(
		vim.treesitter.get_node_text(node, self.buf),
		"^%(([%w_]+)"
	);

	local default_config = inspect.config.named_nodes.default or {};

	local node_config = vim.tbl_extend(
		"force",
		default_config,
		match(inspect.config.named_nodes[lang] or {}, node_name) or {}
	);

	vim.api.nvim_buf_set_extmark(self.buf, inspect.decorator_ns, range[1], range[2] + 1, {
		end_col = range[2] + 1 + #node_name,

		virt_text_pos = "inline",
		virt_text = {
			{ node_config.icon or "", node_config.icon_hl or node_config.hl }
		},

		hl_group = node_config.hl,
		hl_mode = "combine",
	});
end

function inspector:__highlight_injections ()
	---@param list any[]
	---@param index integer
	---@return any
	local function from_list (list, index)
		if vim.islist(list) == false then
			return list;
		end

		local mod = index % #list;
		if mod == 0 then mod = #list; end

		return list[index] or list[mod];
	end

	local injections = {};

	-- Color injected regions.
	for l, _ in ipairs(self.lines) do
		---@type inspect.data
		local line_data = self.parsed_data[l];

		if line_data.injected then
			local language = line_data.injected.language;

			local default_config = inspect.config.injections.default or {};
			local lang_config = vim.tbl_extend(
				"force",
				default_config,
				match(inspect.config.injections, language)
			);

			vim.api.nvim_buf_set_extmark(self.buf, inspect.decorator_ns, l, 0, {
				end_row = (l - 2) + line_data.lines,
				line_hl_group = from_list(lang_config.hl, line_data.injection_depth),
				hl_mode = "combine",

				virt_text_pos = "right_align",
				virt_text = {
					{ lang_config.icon or "", lang_config.icon_hl },
					{ lang_config.text or line_data.injected.language, lang_config.text_hl },
				},
			});

			for s = l, (l - 2) + line_data.lines do
				injections[s + 1] = from_list(lang_config.hl, line_data.injection_depth);
			end
		end
	end

	vim.b[self.buf].injections = injections;
end

function inspector:decorate ()
	self:__highlight_injections();

	local inspect_parser = vim.treesitter.get_parser(self.buf, nil, {});
	if not inspect_parser then return; end

	local inspect_tree = inspect_parser:parse(true)[1];
	local inspect_root = inspect_tree:root();

	local query = vim.treesitter.query.parse("query", [[
		[
			"("
			")"
		] @paren

		(named_node) @named
		(anonymous_node) @anon
		; (missing_node) @missing
		; (field_definition) @field
	]]);

	for id, node, _, _ in query:iter_captures(inspect_root, self.buf) do
		local name = query.captures[id];
		local range = { node:range() };

		if name == "paren" then
			self:__hide_params(node);
		elseif name == "named" and inspect.config.named_nodes then
			self:__highlight_named(node);
		elseif name == "anon" and inspect.config.anonymous_nodes then
			local node_name = string.match(
				vim.treesitter.get_node_text(node, self.buf),
				'(".*")'
			);

			local default_config = inspect.config.anonymous_nodes.default or {};
			local node_config = vim.tbl_extend(
				"force",
				default_config,
				match(inspect.config.anonymous_nodes, node_name)
			);

			vim.api.nvim_buf_set_extmark(self.buf, inspect.ns, range[1], range[2], {
				end_col = range[2] + #node_name,

				virt_text_pos = "inline",
				virt_text = {
					{ node_config.icon or "", node_config.icon_hl or node_config.hl }
				},

				hl_group = node_config.hl,
			});
		end
	end
end

function inspector:switch_state ()
	self.named_only = not self.named_only;

	local cursor = vim.api.nvim_win_get_cursor(self.win);
	local Y, X = cursor[1], cursor[2];
	local item = self.parsed_data[Y] or {};

	if self.named_only then
		while item and item.named == false do
			Y = Y - 1;
			item = self.parsed_data[Y];
		end
	end

	self.lines, self.parsed_data = inspect.parse(self.source, self.named_only);
	vim.print(item)

	vim.bo[self.buf].modifiable = true;
	vim.api.nvim_buf_clear_namespace(self.buf, inspect.ns, 0, -1);
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, self.lines);
	vim.bo[self.buf].modifiable = false;

	self:decorate();
	if not item then return; end

	local _Y = 0;

	for _, data in ipairs(self.parsed_data) do
		if self.named_only and data.named then
			_Y = _Y + 1;
		elseif self.named_only == false then
			_Y = _Y + 1;
		end

		if self.named_only and data.named and data.node:equal(item.node) then
			pcall(vim.api.nvim_win_set_cursor, self.win, { _Y, X });
			break;
		elseif data.node:equal(item.node) then
			pcall(vim.api.nvim_win_set_cursor, self.win, { _Y, X });
			break;
		end
	end
end

function inspector:set_movements ()
	---@diagnostic disable-next-line: undefined-field
	local debouncer = vim.uv.new_timer();

	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = self.buf,
		callback = function ()
			debouncer:stop();
			debouncer:start(inspect.config.debounce or 100, 0, vim.schedule_wrap(function ()
				vim.api.nvim_buf_clear_namespace(self.source, inspect.ns, 0, -1);

				local win = vim.api.nvim_get_current_win();
				if win ~= self.win then return; end

				local cursor = vim.api.nvim_win_get_cursor(self.win);
				if not self.parsed_data[cursor[1]] then return; end

				local range = self.parsed_data[cursor[1]].range;

				vim.api.nvim_buf_set_extmark(self.source, inspect.ns, range[1], range[2], {
					end_row = range[3],
					end_col = range[4],

					hl_group = "Visual"
				});
			end));
		end
	});

	vim.api.nvim_buf_set_keymap(self.buf, "n", "a", "", {
		callback = function ()
			self:switch_state();
		end
	});

	local win = vim.fn.bufwinid(self.source) or 0;

	vim.api.nvim_buf_set_keymap(self.buf, "n", "gd", "", {
		callback = function ()
			local cursor = vim.api.nvim_win_get_cursor(self.win);

			local data = self.parsed_data[cursor[1]];
			if not data then return; end

			pcall(vim.api.nvim_win_set_cursor, win, { data.range[1] + 1, data.range[2] });
			pcall(vim.api.nvim_set_current_win, win);
		end
	});
end

function inspector:open (buf)
	self.source = buf or vim.api.nvim_get_current_buf();

	if self.named_only == nil then
		self.named_only = inspect.config.named_only == true;
	end

	self.lines, self.parsed_data = inspect.parse(self.source, self.named_only);
	if not self.lines or not self.parsed_data then return; end

	if type(self.buf) ~= "number" or vim.api.nvim_buf_is_valid(self.buf) == false then
		self.buf = vim.api.nvim_create_buf(false, true);
		self:set_movements();
	end

	vim.bo[self.buf].ft = "query";

	vim.bo[self.buf].modifiable = true;
	vim.api.nvim_buf_clear_namespace(self.buf, inspect.decorator_ns, 0, -1);
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, self.lines);
	vim.bo[self.buf].modifiable = false;

	self:decorate();

	if type(self.win) ~= "number" or vim.api.nvim_win_is_valid(self.win) == false then
		self.win = vim.api.nvim_open_win(self.buf, true, { split = "below", style = "minimal" });
	else
		pcall(vim.api.nvim_set_current_win, self.win);
	end

	vim.wo[self.win].conceallevel = 3;
	vim.wo[self.win].concealcursor = "nvc";
	vim.wo[self.win].signcolumn = "no";
	vim.wo[self.win].list = true;

	inspect.map[self.source] = self;
	vim.w[self.win].inspecttree_window = true;

	local win = vim.fn.bufwinid(self.source) or 0;
	local source_cursor = vim.api.nvim_win_get_cursor(win);
	local source_node = vim.treesitter.get_node({
		bufnr = self.source,
		ignore_injections = false,

		pos = { source_cursor[1] - 1, source_cursor[2] },
	});

	if not source_node then
		return;
	end

	local Y = 0;

	for _, data in ipairs(self.parsed_data) do
		if self.named_only and data.named then
			Y = Y + 1;
		elseif self.named_only == false then
			Y = Y + 1;
		end

		if self.named_only and data.named and data.node:equal(source_node) then
			pcall(vim.api.nvim_win_set_cursor, self.win, { Y, data.depth });
			break;
		elseif data.node:equal(source_node) then
			pcall(vim.api.nvim_win_set_cursor, self.win, { Y, data.depth });
			break;
		end
	end
end

function inspector:new ()
	return setmetatable({}, inspector);
end


------------------------------------------------------------------------------


inspect.setup = function ()
	vim.api.nvim_create_user_command("Is", function ()
		local buf = vim.api.nvim_get_current_buf();

		if inspect.map[buf] then
			inspect.map[buf]:open(buf);
			return;
		end

		local ab = inspector:new();
		ab:open(buf)
	end, {});
end

return inspect;
-- vim:foldmethod=indent:
