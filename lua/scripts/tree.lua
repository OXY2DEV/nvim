---|fS "doc: Type definitions"

---@class inspect.stringify.opts Options for `tree.stringify()`.
---
---@field named? boolean Only show **named TSNodes**?
---
---@field depth? integer Current parsing depth. **USED INTERNALLY!**
---
---@field injection_maps? table<string, inspect.stringify.injection> Mapping of `TSNode`s ID to injected `TSTree`s.
---@field injection_depth? integer Current injection depth.. **USED INTERNALLY!**
---
---@field language? string Node language name.


---@class inspect.stringify.data Data of a `TSNode` given by `tree.stringify()`.
---
---@field depth integer Node depth.
---@field injection_depth? integer Injection depth.
---
---@field language? string Language of a `TSNode`.
---@field injection? inspect.stringify.injection Injection for a `TSNode`.
---
---@field kind string Node `type`.
---@field id string Unique ID(a **string**, not an 'integer').
---@field range integer[] Node range as `{ row_start, col_start, row_end, col_end }`.
---@field height integer Number of lines a `TSNode` covers in the inspector window.
---
---@field node TSNode
---
---@field missing boolean Is it a *missing* node?
---@field named boolean Is it a *named* node?
---@field extra boolean Is it a *extra* node?
---@field has_error boolean Does the `TSNode` contain any *errors*?


---@class inspect.stringify.injection Object representing an injected `TSTree`.
---
---@field language string Language of the injected `TSTree`.
---@field root TSNode The injected `TSTree`.


---@class inspect.config Configuration for the inspector.
---
---@field indent string Text used for *indentation* of the `TSTree`.
---@field named_only boolean Should only *named* nodes be shown by default?
---
---@field named inspect.config.opts Configuration for *named* `TSNode`s.
---@field anonymous inspect.config.opts Configuration for *anonymous* `TSNode`s.
---
---@field injections inspect.config.opts Configuration for *injected* `TSTree`s.


---@class inspect.config.opts
---
---@field default table
---@field [string] table

---|fE

------------------------------------------------------------------------------

--[[ Evaluates `val`. ]]
---@param val any
---@param ... any
---@return any
local function eval (val, ...)
	---|fS

	if type(val) ~= "function" then
		return val;
	end

	local can_eval, evaled = pcall(val, ...);

	if can_eval then
		return evaled;
	end

	---|fE
end

--[[ Gets a single value from a `list` of values. ]]
---@param list any
---@param index any
---@return any
local function from_list (list, index)
	---|fS

	local _list = eval(list);

	if type(_list) ~= "table" then
		return _list;
	elseif #_list == 0 then
		return;
	end

	return (type(index) == "number" and _list[index] ~= nil) and _list[index] or _list[#_list];

	---|fE
end

--[[ Gets the value of `key` from `map`. ]]
---@param map table | fun(): table
---@param key string
---@return any
local function match (map, key)
	---|fS

	---@type table
	local _map = eval(map);

	if type(_map) ~= "table" then
		return;
	end

	return (key ~= nil and _map[key]) and _map[key] or _map.default;

	---|fE
end

------------------------------------------------------------------------------

--[[
A customisable version of `:InspectTree` with,

* Custom `TSNode` icons & highlights.
* `gd` support.
* Toggle between `named only` & `all` nodes.
* Injection highlighting.
* Debounced `TSNode` range highlighter.

## Usage:

```lua
-- Creates the `:Tree` command
require("tree").setup();

-- Creates a new inspector for the current window
require("tree").new_inspector(0);
```

]]
local tree = {};

---@type integer Namespace used by this script.
tree.ns = vim.api.nvim_create_namespace("inspect");

---@type inspect.config User configuration.
tree.config = {
	indent = "\t";
	named_only = false,

	named = require("scripts.tree_maps").named,
	anonymous = require("scripts.tree_maps").anon,

	injections = require("scripts.tree_maps").injections
};

--[[ Maps `TSNode`s in the `parser` to the `injected TSTrees` they contain. ]]
---@param parser vim.treesitter.LanguageTree
---@return table<string, inspect.stringify.injection>
tree.injection_map = function (parser)
	---|fS

	--[[ Checks if `b` is inside `a`. ]]
	---@param a integer[]
	---@param b integer[]
	---@return boolean
	local function within (a, b)
		---|fS

		local root_row_start = a[1];
		local child_row_start = b[1];

		local root_col_start = a[2];
		local child_col_start = b[2];

		local root_row_end = a[3];
		local child_row_end = b[3];

		local root_col_end = a[4];
		local child_col_end = b[4];

		if child_row_start < root_row_start then
			-- Child node starts before `root`.
			return false;
		elseif child_row_end > root_row_end then
			-- Child node ends after `root`.
			return false;
		elseif child_row_start == root_row_start and child_col_start < root_col_start then
			-- Child node's column start before `root`.
			return false;
		elseif child_row_end == root_row_end and child_col_end > root_col_end then
			-- Child node's column ends after `root`.
			return false;
		end

		return true;

		---|fE
	end

	local map = {};

	parser:for_each_tree(function (TSTree, LanguageTree)
		local main_root = TSTree:root();
		local main_range = { main_root:range() };

		--[[
			Iterate over each `Language`'s trees and find the
			corresponding `TSNode` in the **main tree** that
			contains the `root` of the injected language.
		]]
		for _, childLanguage in pairs(LanguageTree:children()) do
			for _, childTSTree in pairs(childLanguage:trees()) do
				local sub_root = childTSTree:root();
				local sub_range = { sub_root:range() };

				if within(main_range, sub_range) then
					local container = main_root:named_descendant_for_range(unpack(sub_range));

					if container then
						map[container:id()] = {
							language = childLanguage:lang(),
							root = sub_root
						};
					end
				end
			end
		end
	end);

	return map;

	---|fE
end

--[[ Turns `TSNode` objects into `query` strings. ]]
---@param node TSNode
---@param opts inspect.stringify.opts
---@return string[]
---@return inspect.stringify.data[]
tree.stringify = function (node, opts)
	---|fS

	local function escape_str (str)
		local escaped = string.gsub(str, "\\", "\\\\");
		escaped = string.gsub(escaped, '"', '\\"');

		return escaped;
	end

	if not node then
		-- No `TSNode`.
		return {}, {};
	elseif opts.named == true and node:named() == false then
		-- Not a `named` node.
		return {}, {};
	end

	opts.depth = opts.depth or 1;
	opts.injection_depth = opts.injection_depth or 1;

	local kind = node:type();
	local ID = node:id();

	local range = { node:range() };

	---@type string[], inspect.stringify.data[]
	local lines, line_data = {}, {};

	---|fS "chunk: Parent node"

	table.insert(line_data, {
		language = opts.language or "",
		injection = opts.injection_maps and opts.injection_maps[ID] or nil,

		depth = opts.depth or 1,
		injection_depth = opts.injection_depth or 1,

		id = ID,
		kind = kind,
		range = range,
		height = 1,

		node = node,

		missing = node:missing(),
		named = node:named(),
		extra = node:extra(),
		has_error = node:has_error(),
	});

	if node:named() then
		table.insert(
			lines,
			string.format(
				"(%s ; [ %d, %d ] - [ %d, %d ]",
				kind,

				range[1],
				range[2],

				range[3],
				range[4]
			)
		);
	else
		table.insert(
			lines,
			string.format(
				"%s ; [ %d, %d ] - [ %d, %d ]",
				'"' .. escape_str(kind) .. '"',

				range[1],
				range[2],

				range[3],
				range[4]
			)
		);
	end

	---|fE

	---|fS "chunk: Injection"

	if opts.injection_maps and opts.injection_maps[ID] then
		opts.injection_depth = (opts.injection_depth or 0) + 1;

		---@type inspect.stringify.injection
		local injected = opts.injection_maps[ID];
		local injected_lines, injected_data = tree.stringify(
			injected.root,
			vim.tbl_extend("force", opts, {
				depth = (opts.depth or 0) + 1
			})
		);

		for l, line in ipairs(injected_lines) do
			injected_lines[l] = (tree.config.indent or "\t") .. line;
		end

		lines = vim.list_extend(lines, injected_lines);
		line_data = vim.list_extend(line_data, injected_data);
	end

	---|fE

	---|fS "chunk: Child nodes"

	for child_node, field_name in node:iter_children() do
		local node_lines, node_data = tree.stringify(
			child_node,
			vim.tbl_extend("force", opts, {
				depth = (opts.depth or 0) + 1
			})
		);

		if #node_lines == 0 then
			goto ignore;
		end

		if field_name then
			node_lines[1] = field_name .. ": " .. node_lines[1];
		end

		for l, line in ipairs(node_lines) do
			node_lines[l] = (tree.config.indent or "\t") .. line;
		end

		lines = vim.list_extend(lines, node_lines);
		line_data = vim.list_extend(line_data, node_data);

		::ignore::
	end

	---|fE

	if node:named() then
		-- Add closing `)`. We do this by adding `)` between the
		-- node text & the comment.

		local text, comment = string.match(lines[#lines], "^(.*) ;(.*)$");
		lines[#lines] = text .. ") ;" .. comment;
	end

	line_data[1].height = #lines;
	return lines, line_data;

	---|fE
end

------------------------------------------------------------------------------

--[[ An instance of the `inspector`. ]]
---@class inspect.instance
---
---@field __index inspect.instance
---
---@field source integer The `buffer` this inspector is attached to.
---@field config inspect.config Configuration used by this inspector.
---
---@field buffer integer The `buffer` containing the viewer.
---@field window integer The `window` showing the `buffer`.
---
---
---@field __prepare fun(self: inspect.instance): nil Preparation steps(e.g. set `config`, `buffer`, `filetype` etc.)
---@field __hide_node fun(self: inspect.instance, node: TSNode): nil Hides/Conceals `node`.
---
---@field __named fun(self: inspect.instance, node: TSNode): nil Handler for *named* TSNodes.
---@field __anon fun(self: inspect.instance, node: TSNode): nil Handler for *anonymous* TSNodes.
---
---@field __injection fun(self: inspect.instance, lnum: integer, data: inspect.stringify.data): nil Handler for *injected* TSTrees.
---
---
---@field close fun(self: inspect.instance): nil Closes the inspector window.
---@field change_mode fun(self: inspect.instance): nil Changes between showing `named only` and `all` TSNodes.
---
---@field highlight_node fun(self: inspect.instance): nil Highlights the `TSNode` under cursor in the `source` buffer.
---@field goto_node fun(self: inspect.instance): nil Goes to the `TSNode` in the `source` buffer.
---
---@field open fun(self: inspect.instance): nil Opens the inspector window.
---
---@field set_keymaps fun(self: inspect.instance): nil Sets `keymaps` for the inspector `buffer`.
---@field set_autocmds fun(self: inspect.instance): nil Creates `autocmds` for the inspector `window`.
local instance = {};
instance.__index = instance;

instance.source = nil;
instance.config = nil;

instance.buffer = nil;
instance.window = nil;

function instance:__prepare ()
	---|fS

	if not self.config then
		self.config = vim.deepcopy(tree.config);
	end

	if not self.buffer or not vim.api.nvim_buf_is_valid(self.buffer) then
		self.buffer = vim.api.nvim_create_buf(false, true);
	end

	vim.bo[self.buffer].filetype = "query";

	---|fE
end

function instance:__hide_node (node)
	---|fS

	local range = { node:range() };

	vim.api.nvim_buf_set_extmark(self.buffer, tree.ns, range[1], range[2], {
		end_col = range[4],
		end_row = range[3],

		conceal = ""
	});

	---|fE
end

function instance:__named (node)
	---|fS

	local range = { node:range() };
	local field = node:field("name")[1];

	local node_name = "";

	if field then
		node_name = vim.treesitter.get_node_text(field, self.buffer);
	end

	local default_config = self.config.named.default or {};
	local node_config = vim.tbl_extend(
		"force",
		default_config,
		match(self.config.named, node_name)
	);

	vim.api.nvim_buf_set_extmark(self.buffer, tree.ns, range[1], range[2], {
		end_col = range[2] + #node_name,

		virt_text_pos = "inline",
		virt_text = {
			{ node_config.icon or "", node_config.icon_hl or node_config.hl }
		},

		hl_group = node_config.hl,
	});

	---|fE
end

function instance:__anon (node)
	---|fS

	local range = { node:range() };
	local field = node:field("name")[1];

	local node_name = "";

	if field then
		node_name = vim.treesitter.get_node_text(field, self.buffer);
		node_name = string.sub(node_name, 2, #node_name - 1);
	end

	local default_config = self.config.anonymous.default or {};
	local node_config = vim.tbl_extend(
		"force",
		default_config,
		match(self.config.anonymous, node_name)
	);

	vim.api.nvim_buf_set_extmark(self.buffer, tree.ns, range[1], range[2], {
		end_col = range[2] + #node_name,

		virt_text_pos = "inline",
		virt_text = {
			{ node_config.icon or "", node_config.icon_hl or node_config.hl }
		},

		hl_group = node_config.hl,
	});

	---|fE
end

function instance:__injection (lnum, data)
	---|fS

	if not data.injection then
		return;
	end

	local language = data.injection.language;

	local default_config = self.config.injections.default or {};
	local lang_config = vim.tbl_extend(
		"force",
		default_config,
		match(self.config.injections, language)
	);

	vim.api.nvim_buf_set_extmark(self.buffer, tree.ns, lnum, 0, {
		end_row = (lnum - 1) + (data.height - 1),

		line_hl_group = from_list(lang_config.hl, data.injection_depth or 0),
		hl_mode = "combine",

		virt_text_pos = "right_align",
		virt_text = {
			{ lang_config.icon or "", lang_config.icon_hl },
			{ lang_config.text or language, lang_config.text_hl },
		},
	});

	---|fE
end

------------------------------------------------------------------------------

function instance:close ()
	pcall(vim.api.nvim_win_close, self.window, true);
end

function instance:change_mode ()
	---|fS

	local cursor = vim.api.nvim_win_get_cursor(self.window);
	local old_data = self.__data[cursor[1]];

	self.config.named_only = not self.config.named_only;
	self:render();

	for d, line_data in ipairs(self.__data) do
		if line_data.node:equal(old_data.node) then
			pcall(vim.api.nvim_win_set_cursor, self.window, { d, cursor[2] });
			break;
		end
	end

	---|fE
end

function instance:highlight_node ()
	---|fS

	vim.api.nvim_buf_clear_namespace(self.source, tree.ns, 0, -1);

	local cursor = vim.api.nvim_win_get_cursor(self.window);
	if not self.__data[cursor[1]] then return; end

	local range = self.__data[cursor[1]].range;

	vim.api.nvim_buf_set_extmark(self.source, tree.ns, range[1], range[2], {
		end_row = range[3],
		end_col = range[4],

		hl_group = "Visual"
	});

	---|fE
end

function instance:goto_node ()
	---|fS

	local cursor = vim.api.nvim_win_get_cursor(self.window);
	if not self.__data[cursor[1]] then return; end

	local source_wins = vim.fn.win_findbuf(self.source);
	if not source_wins[1] then return; end

	local range = self.__data[cursor[1]].range;

	pcall(vim.api.nvim_win_set_cursor, source_wins[1], { range[1] + 1, range[2] });
	pcall(vim.api.nvim_set_current_win, source_wins[1]);

	---|fE
end

function instance:render ()
	---|fS

	local parser = vim.treesitter.get_parser(self.source or 0, nil, {});
	if not parser then return; end

	vim.bo[self.buffer].modifiable = true;

	local TSTree = parser:parse(true)[1];
	local lines, data = tree.stringify(
		TSTree:root(),
		{
			language = parser:lang(),
			injection_maps = tree.injection_map(parser),

			named = self.config.named_only
		}
	);

	-- Temporarily store the `tree data`.
	self.__data = data;

	vim.api.nvim_buf_clear_namespace(self.buffer, tree.ns, 0, -1);
	vim.api.nvim_buf_set_lines(self.buffer, 0, -1, false, lines);

	vim.bo[self.buffer].modifiable = false;

	-------------------------------------------------------------------------

	---|fS "chunk: Tree-sitter highlighting"

	local inspect_parser = vim.treesitter.get_parser(self.buffer, nil, {});
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
	]]);

	for id, node, _, _ in query:iter_captures(inspect_root, self.buffer) do
		local name = query.captures[id];

		if name == "paren" then
			self:__hide_node(node);
		elseif name == "named" and self.config.named then
			self:__named(node);
		elseif name == "anon" and self.config.anonymous then
			self:__anon(node);
		end
	end

	---|fE

	for lnum, line_data in ipairs(data) do
		self:__injection(lnum, line_data);
	end

	---|fE
end

function instance:open ()
	---|fS

	self:__prepare();

	if not pcall(vim.treesitter.get_parser, self.source) then
		self:close();
		return;
	end

	self:render();

	if self.window and vim.api.nvim_win_is_valid(self.window) then
		pcall(vim.api.nvim_set_current_win, self.window);
	else
		self.window = vim.api.nvim_open_win(self.buffer, true, {
			split = "below"
		});
	end

	vim.wo[self.window].conceallevel = 3;
	vim.wo[self.window].concealcursor = "nvc";

	vim.wo[self.window].statuscolumn = " ";

	self:highlight_node();

	---|fE
end

function instance:set_keymaps ()
	---|fS

	vim.api.nvim_buf_set_keymap(self.buffer, "n", "a", "", {
		desc = "Toggle between `all nodes` & `named nodes`.",
		callback = function ()
			self:change_mode();
		end
	});

	vim.api.nvim_buf_set_keymap(self.buffer, "n", "gd", "", {
		desc = "Go to `TSNode` declaration.",
		callback = function ()
			self:goto_node();
		end
	});

	---|fE
end

function instance:set_autocmds ()
	---|fS

	---@diagnostic disable-next-line: undefined-field
	local hl_timer = vim.uv.new_timer();

	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = self.buffer,
		callback = function ()
			hl_timer:stop();
			hl_timer:start(100, 0, vim.schedule_wrap(function ()
				self:highlight_node();
			end));
		end
	});

	vim.api.nvim_create_autocmd({
		"WinLeave",
		"WinClosed"
	}, {
		callback = function ()
			pcall(vim.api.nvim_buf_clear_namespace, self.source, tree.ns, 0, -1);
		end
	});

	---|fE
end

------------------------------------------------------------------------------

--[[ Creates a new `inspector`. ]]
---@param source? integer Source buffer.
---@return inspect.instance
tree.new_inspector = function (source)
	---|fS

	source = source or vim.api.nvim_get_current_buf();
	local new_instance = setmetatable({}, instance);
	new_instance.source = source;

	new_instance:open();
	new_instance:set_keymaps();
	new_instance:set_autocmds();

	return new_instance;

	---|fE
end

---@type table<integer, table>
tree.instances = {};

--[[ Sets up `:Tree` and updates `config`. ]]
---@param config? inspect.config
tree.setup = function (config)
	---|fS

	if type(config) == "table" then
		tree.config = vim.tbl_extend("force", tree.config, config);
	end

	vim.api.nvim_create_user_command("Tree", function ()
		local buffer = vim.api.nvim_get_current_buf();

		if tree.instances[buffer] then
			tree.instances[buffer]:open();
		else
			tree.instances[buffer] = tree.new_inspector(buffer);
		end
	end, {});

	---|fE
end

return tree;
