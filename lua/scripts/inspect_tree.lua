---@class inspect.data
---
---@field language string
---@field injected? table
---
---@field depth integer
---@field injection_depth integer
---
---@field type string
---@field range integer[]
---@field node TSNode
---
---@field missing boolean
---@field named boolean
---@field extra boolean
---
---@field has_error boolean
---@field lines integer


---@class inspect.injection
---
---@field language string
---@field root TSNode


------------------------------------------------------------------------------


local inspect = {};

inspect.config = {
	named_only = false,
	indent_size = 4,

	injections = {
		default = {
			scope_hl = "MarkviewCode",
			icon = "󱏒 ",

			text = nil,
			hl = { "MarkviewCode", "CursorLine" },

			icon_hl = "@constant",
			text_hl = "@constant",
		},

		luadoc = {
			icon = " ",
			text = "LuaDoc",
		}
	},

	anonymous_nodes = {
		default = {
			icon = "󰌪 ",
			icon_hl = "DiagnosticWarn"
		},
	},

	named_nodes = {
		default = {
			icon = "󰌪 ",
			icon_hl = "DiagnosticOk"
		},

		["comment"] = {
			icon = "󰔌 ",
		},
	}
};

---@param node TSNode
---@param language string
---@param injection_map table<integer, inspect.injection>
---@param depth integer
---@param injection_depth integer
---@return string[]
---@return inspect.data[]
inspect.tostring = function (node, language, injection_map, depth, injection_depth)
	if not node then
		return {}, {};
	elseif inspect.config.named_only and not node:named() then
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
		local inj_lines, inj_datas = inspect.tostring(inj.root, inj.language, injection_map, depth + 1, injection_depth)

		for l, line in ipairs(inj_lines) do
			inj_lines[l] = "    " .. line;
		end

		lines = vim.list_extend(lines, inj_lines);
		datas = vim.list_extend(datas, inj_datas);
	end

	for child, field_name in node:iter_children() do
		local child_lines, child_datas = inspect.tostring(child, language, injection_map, depth + 1, injection_depth);

		if #child_lines == 0 then
			goto ignore;
		end

		if field_name then
			child_lines[1] = field_name .. ": " .. child_lines[1];
		end

		for l, line in ipairs(child_lines) do
			child_lines[l] = "    " .. line;
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

inspect.parse = function (buffer)
	local parser = vim.treesitter.get_parser(buffer or 0, nil, {});
	if not parser then return; end

	local TSTree = parser:parse(true)[1];
	local injected_nodes = inspect.injected(parser);

	local lines, data = inspect.tostring(TSTree:root(), parser:lang(), injected_nodes, 0, 0);

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

function inspector:__hide_params (node)
	local range = { node:range() };

	vim.api.nvim_buf_set_extmark(self.buf, inspect.ns, range[1], range[2], {
		end_col = range[4],
		conceal = ""
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

			vim.api.nvim_buf_set_extmark(self.buf, inspect.ns, l, 0, {
				end_row = (l - 2) + line_data.lines,
				line_hl_group = from_list(lang_config.hl, line_data.injection_depth),
				hl_mode = "combine",

				virt_text_pos = "right_align",
				virt_text = {
					{ lang_config.icon or "", lang_config.icon_hl },
					{ lang_config.text or line_data.injected.language, lang_config.text_hl },
				},
			});
		end
	end
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
			local node_name = string.match(
				vim.treesitter.get_node_text(node, self.buf),
				"^%(([%w_]+)"
			);

			local default_config = inspect.config.named_nodes.default or {};
			local node_config = vim.tbl_extend(
				"force",
				default_config,
				match(inspect.config.named_nodes, node_name)
			);

			vim.api.nvim_buf_set_extmark(self.buf, inspect.ns, range[1], range[2] + 1, {
				end_col = range[2] + 1 + #node_name,

				virt_text_pos = "inline",
				virt_text = {
					{ node_config.icon or "", node_config.icon_hl or node_config.hl }
				},

				hl_group = node_config.hl,
			});
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

function inspector:open (buf)
	self.source = buf or vim.api.nvim_get_current_buf();

	self.lines, self.parsed_data = inspect.parse(self.source);
	if not self.lines or not self.parsed_data then return; end

	self.buf = vim.api.nvim_create_buf(false, true);
	vim.bo[self.buf].ft = "query";

	vim.bo[self.buf].modifiable = true;
	vim.api.nvim_buf_clear_namespace(self.buf, inspect.ns, 0, -1);
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, self.lines);
	vim.bo[self.buf].modifiable = false;

	self.win = vim.api.nvim_open_win(self.buf, true, { split = "below" });
	vim.wo[self.win].conceallevel = 3;
	vim.wo[self.win].concealcursor = "nvc";

	inspector:decorate();

	---@diagnostic disable-next-line: undefined-field
	local debouncer = vim.uv.new_timer();

	vim.api.nvim_create_autocmd("CursorMoved", {
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
end


------------------------------------------------------------------------------


inspect.setup = function ()
	vim.api.nvim_create_user_command("Is", function ()
		inspector:open();
	end, {});
end

return inspect;
-- vim:foldmethod=indent:
