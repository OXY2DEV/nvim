local messages = {};

local file = io.open("test.log", "w");

messages.logs = {};

---@class messages.msg
---
---@field kind
---| ""
---| "confirm"
---| "confirm_sub"
---| "emsg"
---| "echo"
---| "echomsg"
---| "echoerr"
---| "lua_error"
---| "rpc_error"
---| "return_prompt"
---| "quickfix"
---| "search_count"
---| "wmsg"
---
---@field content [ integer, string ][]
---
---@field timer? table

---@diagnostic disable:undefined-global

--- Evaluates {val}.
---@param val any
---@param ... any
---@return any
local function get (val, ...)
	---|fS

	if type(val) ~= "function" then
		return val;
	end

	local can_call, new_val = pcall(val, ...);

	if can_call then
		return new_val
	else
		return nil;
	end

	---|fE
end

--- Matches 1 key from
--- a table using {with}.
---@param from table
---@param with string
---@param fallback function
---@return function
local function match(from, with, fallback)
	---|fS

	if type(from) ~= "table" then
		return fallback;
	end

	local keys = vim.tbl_keys(from);
	table.sort(keys);

	for _, key in ipairs(keys) do
		if string.match(with, key) then
			return from[key];
		end
	end

	return from.default or fallback;

	---|fE
end

--- Turns {content} into a string.
---@param content [ integer, string ][]
---@return string
local function totext(content)
	---|fS

	local _text = "";

	for _, part in ipairs(content) do
		_text = _text .. part[2];
	end

	return _text;

	---|fE
end

local function virtWidth(content)
	---|fS

	local _w = 0;

	for _, part in ipairs(content) do
		_w = _w + vim.fn.strdisplaywidth(part[1]);
	end

	return _w;
	---|fE
end

local function escape(input)
	---|fS
	input = input:gsub("%%", "%%%%");

	input = input:gsub("%(", "%%(");
	input = input:gsub("%)", "%%)");

	input = input:gsub("%.", "%%.");
	input = input:gsub("%+", "%%+");
	input = input:gsub("%-", "%%-");
	input = input:gsub("%*", "%%*");
	input = input:gsub("%?", "%%?");
	input = input:gsub("%^", "%%^");
	input = input:gsub("%$", "%%$");

	input = input:gsub("%[", "%%[");
	input = input:gsub("%]", "%%]");

	return input;
	---|fE
end

---@param str string
---@return "number" | "boolean" | "string"
local function strType(str)
	if tonumber(str) then
		return "number";
	elseif str == "true" or str == "false" then
		return "boolean";
	else
		return "string";
	end
end

--- Highlight group name from attribute.
---@param attr_id integer
---@return string
local function attr_to_hl(attr_id)
	return vim.fn.synIDattr(vim.fn.synIDtrans(attr_id), "name");
end

---@type integer Last messages ID.
messages.last = nil;
---@type boolean Is this module enabled?
messages.__enabled = false;

messages.history_provider = "builtin";

--- History.
---@type table<integer, messages.msg>
messages.history = {};

--- History(but cached).
---@type table<integer, messages.msg>
messages.__history = {};

--- Visible messages.
---@type table<integer, messages.msg>
messages.visible = {};



---@class messages.processors
---
---@field default fun(as: "notif" | "history", txt: string, msg: messages.msg): [ string, string | nil ][] | nil
---@field [string] fun(as: "notif" | "history", txt: string, msg: messages.msg): [ string, string | nil ][] | nil



---@class messages.config
---
---@field delay? number | fun(msg: messages.msg): number
---
---@field width? integer | fun(): integer
---@field height? integer | fun(): integer
---
---@field processors { default: fun(as: "notif" | "history", txt: string, msg: messages.msg): ( nil | [ string, string | nil ][] ), [string]: messages.processors }
messages.config = {
	---|fS

	hist_winopts = function ()
		return {
			split = "below",
			height = math.floor((vim.o.lines - vim.o.cmdheight) * 0.4),

			style = "minimal"
		};
	end,

	height = 5,
	width = function ()
		return math.ceil(vim.o.columns * 0.4);
	end,

	processors = {
		default = function (_, _, msg)
			local _ext = {
				{ " ", "@comment" },
			};

			for _, entry in ipairs(msg.content) do
				table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
			end

			return _ext;
		end,

		[""] = {
			---|fS

			default = function (_, _, msg)
				if string.match(msg.content[1][2], "^?") then
					return nil;
				end

				local _ext = {
					{ "󰚢 ", "@comment" },
				};

				for _, entry in ipairs(msg.content) do
					table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
				end

				return _ext;
			end,

			["^%s+%w-%="] = function (_, text)
				local opt, val = string.match(text, "^%s*(%w-)=(.*)$");
				local vHL;

				if strType(val) == "number" or strType(val) == "nil" then
					vHL = "@constant";
					val = tonumber(val);
				elseif strType(val) == "boolean" then
					vHL = "@boolean";
					val = val == "true";
				elseif strType(val) == "string" then
					vHL = "@string";
				else
					vHL = "@property";
				end

				local _ext = {
					{ " ", "@comment" },
					{ opt, "@property" },
					{ ": " },
					{ vim.inspect(val), vHL }
				};

				return _ext;
			end,

			---|fE
		},

		emsg = {
			default = function (_, _, msg)
				local _ext = {
					{ " ", "DiagnosticError" },
				};

				for _, entry in ipairs(msg.content) do
					table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
				end

				return _ext;
			end,
		},
		echo = {
			default = function (_, _, msg)
				local _ext = {
					{ "󱜠 ", "@comment" },
				};

				for _, entry in ipairs(msg.content) do
					table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
				end

				return _ext;
			end,
		},
		["echomsg"] = {
			---|fS

			default = function (_, _, msg)
				local _ext = {
					{ " ", "@comment" },
				};

				for _, entry in ipairs(msg.content) do
					table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
				end

				return _ext;
			end,

			["^%[lspconfig%]"] = function (_, text)
				---|fS

				local hl = "DiagnosticVirtualTextWarn";
				local _ext = {};

				if string.match(text, "cmd not defined for") then
					local cmd = string.match(text, 'cmd not defined for (%S*)');
					hl = "DiagnosticVirtualTextError";

					_ext = {
						{ "󰒋 󰘳 Undefined CMD:", hl },
						{
							" " .. cmd .. " ",
							"DiagnosticVirtualTextHint"
						}
					};
				elseif string.match(text, "unable to run cmd: (%S*)") then
					local cmd = string.match(text, 'unable to run cmd: (%S*)');
					hl = "DiagnosticVirtualTextError";

					_ext = {
						{ "󰒋 󰘳 Can't run:", hl },
						{
							" " .. cmd .. " ",
							"DiagnosticVirtualTextHint"
						}
					};
				elseif string.match(text, "cmd failed with code") then
					local code = string.match(text, 'cmd failed with code (%d*)');
					hl = "DiagnosticVirtualTextError";

					_ext = {
						{ "󰒋 󰘳 CMD error:", hl },
						{
							" " .. code .. " ",
							"DiagnosticVirtualTextHint"
						}
					};
				elseif string.match(text, "config %S+ not found") then
					local server = string.match(text, 'config "?([^%s%"]+)"? not found');

					_ext = {
						{ "󰒋 󱏏 No config:", hl },
						{
							" " .. server .. " ",
							"DiagnosticVirtualTextHint"
						}
					};
				else
					local message = string.match(text, '^%[lspconfig%]%s*(.*)$');

					_ext = {
						{ "󰒋 LSP-config:", hl },
						{
							" " .. message .. " ",
							"DiagnosticVirtualTextHint"
						}
					};
				end

				table.insert(_ext, 1, { " ", hl });
				table.insert(_ext, { " ", hl });

				return _ext;
				---|fE
			end,

			---|fE
		},
		echoerr = {
			default = function (_, _, msg)
				local _ext = {
					{ "󱜠 ", "DiagnosticError" },
				};

				for _, entry in ipairs(msg.content) do
					table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
				end

				return _ext;
			end,
		},

		confirm = {
			default = function (_, _, msg)
				local _ext = {
					{ "󰍕 ", "DiagnosticOk" },
				};

				for _, entry in ipairs(msg.content) do
					table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
				end

				return _ext;
			end,
		},
		confirm_sub = {
			default = function (_, _, msg)
				local _ext = {
					{ " ", "DiagnosticOk" },
				};

				for _, entry in ipairs(msg.content) do
					table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
				end

				return _ext;
			end,
		},

		lua_error = {
			default = function (_, _, msg)
				local _ext = {
					{ " ", "DiagnosticError" },
				};

				for _, entry in ipairs(msg.content) do
					table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
				end

				return _ext;
			end,
		},
		rpc_error = {
			default = function (_, _, msg)
				local _ext = {
					{ "? ", "DiagnosticError" },
				};

				for _, entry in ipairs(msg.content) do
					table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
				end

				return _ext;
			end,
		},

		wmsg = {
			default = function (_, _, msg)
				local _ext = {
					{ " ", "DiagnosticWarn" },
				};

				for _, entry in ipairs(msg.content) do
					table.insert(_ext, { entry[2], attr_to_hl(entry[1]) });
				end

				return _ext;
			end,
		}
	}

	---|fE
};

---@type integer
messages.buffer = nil;
---@type integer
messages.window = nil;
---@type integer
messages.namespace = vim.api.nvim_create_namespace("messages");

messages.hist_buf = nil;
messages.hist_win = nil;

--- Closes message window.
messages.close = function ()
	---|fS
	pcall(vim.api.nvim_win_close, messages.window, true);
	messages.window = nil;

	vim.api.nvim__redraw({
		flush = true,
	});
	---|fE
end

--- Creates lines to show in the
--- message buffer.
---@param content [ integer, string ][]
---@return [ integer, string ][][]
messages.__msg_lines = function (content)
	---|fS
	if vim.islist(content) == false then
		return {};
	end

	---@type [ integer, string ][][]
	local _out = {};

	for _, part in ipairs(content) do
		local text;

		if type(part[1]) == "number" then
			text = part[2];
		else
			text = part[1];
		end

		if string.match(text, "\n") then
			if string.match(text, "[^\n]$") then
				text = text .. "\n";
			end

			for line in string.gmatch(text, "[^\n]*\n") do
				text = string.gsub(text, escape(line), "", 1);
				line = line:gsub("^%s*", ""):gsub("%s*$", "");

				--- Create a new line.
				if type(part[1]) == "number" then
					table.insert(_out, {
						{ line, attr_to_hl(part[1]) }
					});
				else
					table.insert(_out, {
						{ line, part[2] }
					});
				end
			end

			--- Remove trailing whitespace(s) as there shouldn't
			--- be any whitespace at the start of a line.
			-- text = text:gsub("^%s*", ""):gsub("%s*$", "");
			-- table.insert(_out, {});
			--
			-- if text ~= "" then
			-- 	if type(part[1]) == "number" then
			-- 		table.insert(_out[#_out], { text, attr_to_hl(part[1]) });
			-- 	else
			-- 		table.insert(_out[#_out], { text, part[2] });
			-- 	end
			-- end
		else
			if #_out < 1 then
				--- Create a new line if there
				--- isn't one.
				table.insert(_out, {});
			end

			if type(part[1]) == "number" then
				table.insert(_out[#_out], { text, attr_to_hl(part[1]) });
			else
				table.insert(_out[#_out], { text, part[2] });
			end
		end
	end

	return _out;
	---|fE
end

--- Creates lines of messages.
---@param src table[]
---@param as "notif" | "history"
---@return string[]
---@return table[]
---@return integer
messages.create_lines = function (src, as)
	---|fS

	---@type ( [ string, string | nil ] | [ integer, string ] )[][]
	local _lines = {};
	local max_w = 1;

	for _, item in ipairs(src) do
		---@type string
		local _text = totext(item.content);

		---@type function
		---@diagnostic disable-next-line
		local processor = match(messages.config.processors[item.kind] or {}, _text, messages.config.processors.default);
		local can_call, val = pcall(processor, as, _text, item);

		if can_call == false or val == nil then
			--- Ignore unprocessed messages.
			goto continue;
		end

		---@type ( [ string, string | nil ] | [ integer, string ] )[][]
		local lines = messages.__msg_lines(can_call == true and val or item.content)

		for _, line in ipairs(lines) do
			table.insert(_lines, line);
			max_w = math.max(max_w, virtWidth(line));
		end

	    ::continue::
	end

	local _txt = {};
	local _ext = {};

	for _, line in ipairs(_lines) do
		local _hl = {};
		local txt = "";

		for _, segmant in ipairs(line) do
			table.insert(_hl, { #txt, #txt + #( segmant[1] or ""), segmant[2] });
			txt = txt .. segmant[1];
		end

		table.insert(_txt, txt);
		table.insert(_ext, _hl);
	end

	return _txt, _ext, max_w;
	---|fE
end

--- Redraws message window.
messages.redraw = function ()
	---|fS

	if not messages.buffer or vim.api.nvim_buf_is_valid(messages.buffer) == false then
		--- Create message buffer if necessary.
		messages.buffer = vim.api.nvim_create_buf(false, true);
	end

	--- Clear decorations & text.
	vim.api.nvim_buf_clear_namespace(messages.buffer, messages.namespace, 0, -1);
	vim.api.nvim_buf_set_lines(messages.buffer, 0, -1, false, {});

	---|fS

	--- Visible message ID(s).
	---@type integer[]
	local IDs = vim.tbl_keys(messages.visible);
	table.sort(IDs);

	local _tmp = {};

	for _, ID in ipairs(IDs) do
		---@type messages.msg
		local message = messages.visible[ID];

		table.insert(_tmp, message);
	end

	local _txt, _ext, width = messages.create_lines(_tmp, "notif");


	---|fE

	if #_txt < 1 then
		messages.close();
		return;
	end

	---@type integer, integer
	local W, H = get(messages.config.width) or 20, get(messages.config.height) or 10;
	H = math.max(math.min(#_txt, H), 1);
	W = math.max(math.min(width, W), 1);

	---|fS
	if not messages.window or vim.api.nvim_win_is_valid(messages.window) == false then
		messages.window = vim.api.nvim_open_win(messages.buffer, false, {
			relative = "editor",
			anchor = "SE",

			row = vim.o.lines - 1 - vim.o.cmdheight,
			col = vim.o.columns,

			width = W,
			height = H,

			style = "minimal"
		});

		vim.wo[messages.window].winhl = "Normal:Normal";
	else
		vim.api.nvim_win_set_config(messages.window, {
			relative = "editor",
			anchor = "SE",

			row = vim.o.lines - 1 - vim.o.cmdheight,
			col = vim.o.columns,

			width = W,
			height = H,

			style = "minimal"
		});
	end
	---|fE

	vim.api.nvim_buf_set_lines(messages.buffer, 0, -1, false, _txt);

	for e, ext in ipairs(_ext) do
		for _, hl in ipairs(ext) do
			vim.api.nvim_buf_set_extmark(messages.buffer, messages.namespace, e - 1, hl[1], {
				end_col = hl[2],
				hl_group = hl[3]
			})
		end
	end

	vim.api.nvim__redraw({
		flush = true,
	});

	---|fE
end

--- Creates a new message.
---@param msg messages.msg
---@param delay number
---@param replace boolean
messages.new = function (msg, delay, replace)
	---|fS

	delay = delay or 20;

	if replace == true and messages.last and messages.visible[messages.last] then
		---|fS

		local last = messages.last;

		---@type table
		local last_timer = messages.visible[last].timer;
		last_timer:stop();

		messages.visible[last] = vim.tbl_extend("force", messages.visible[last], msg);
		messages.history[last] = vim.tbl_extend("force", messages.history[last], msg);

		messages.redraw();

		if delay < 0 then return; end

		last_timer:start(delay, 0, vim.schedule_wrap(function ()
			messages.visible[last] = nil;
			messages.redraw();
		end));

		---|fE
	else
		---|fS

		local ID = #messages.history + 1;
		messages.last = ID;

		---@type table
		local timer = vim.uv.new_timer();

		messages.visible[ID] = vim.tbl_extend("force", msg, { timer = timer });
		messages.history[ID] = msg;

		messages.redraw();

		if delay < 0 then return; end

		timer:start(delay, 0, vim.schedule_wrap(function ()
			messages.visible[ID] = nil;
			messages.redraw();
		end));

		---|fE
	end

	---|fE
end

messages.handlers = {
	__history_provider = nil,

	__confirmation = function (content)
		local confirm_buf = vim.api.nvim_create_buf(false, true);
		local _txt, _ext, width = messages.create_lines({
			{
				kind = "confirmation",
				content = content
			}
		}, "notif");

		vim.api.nvim_buf_set_lines(confirm_buf, 0, -1, false, _txt);

		for e, ext in ipairs(_ext) do
			for _, hl in ipairs(ext) do
				vim.api.nvim_buf_set_extmark(confirm_buf, messages.namespace, e - 1, hl[1], {
					end_col = hl[2],
					hl_group = hl[3]
				})
			end
		end

		local confirm_win = vim.api.nvim_open_win(confirm_buf, true, {
			relative = "editor",

			width = width,
			height = #_txt,

			row = 5,
			col = 5,

			border = "rounded"
		});

		vim.api.nvim__redraw({
			flush = true,
		});

		vim.fn.on_key(function (char)
			file:write("here")

			pcall(vim.api.nvim_win_close, confirm_win, true);
			vim.api.nvim_feedkeys(char)
		end)
	end,

	msg_show = function (kind, content, replace_last)
		---|fS
		if kind == "confirm" or kind == "confirm_sub" then
			--- Do not handle confirmations as messages.
			messages.handlers.__confirmation(content);
			return;
		elseif kind == "search_count" then
			--- Do not handle search count as messages.
			return;
		elseif kind == "return_prompt" then
			--- Hit `<ESC>` on hit-enter prompts.
			--- or else we get stuck.
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false);
			return;
		end

		--- How long should the message stay up?
		---@type number
		local delay = get(messages.config.delay or function ()
			if vim.list_contains({ "emsg", "echoerr", "lua_error", "rpc_error" }, kind) then
				return 2500;
			elseif kind == "wmsg" then
				return 5000;
			else
				return 1500;
			end
		end, kind, content, replace_last);

		messages.new({
			kind = kind,
			content = content,
		}, delay, replace_last);

		---|fE
	end,

	msg_history_show = function (history)
		---|fS

		--- Set the current history provider.
		messages.handlers.__history_provider = messages.handlers.__history_provider or "builtin";

		---|fS
		if not messages.hist_buf or vim.api.nvim_buf_is_valid(messages.hist_buf) == false then
			messages.hist_buf = vim.api.nvim_create_buf(false, true);

			vim.api.nvim_buf_set_keymap(messages.hist_buf, "n", "q", "", {
				callback = function ()
					pcall(vim.api.nvim_win_close, messages.hist_win, true);
				end
			});

			vim.api.nvim_buf_set_keymap(messages.hist_buf, "n", "t", "", {
				callback = function ()
					messages.handlers.__history_provider = messages.handlers.__history_provider == "builtin" and "cached" or "builtin"
					messages.handlers.msg_history_show(history);
				end
			});
		end
		---|fE

		vim.bo[messages.hist_buf].modifiable = true;

		vim.api.nvim_buf_clear_namespace(messages.hist_buf, messages.namespace, 0, -1);
		vim.api.nvim_buf_set_lines(messages.hist_buf, 0, -1, false, {});

		---|fS

		local _tmp = {};

		if messages.handlers.__history_provider == "builtin" then
			if history then
				for _, entry in ipairs(history) do
					table.insert(_tmp, {
						kind = entry[1],
						content = entry[2]
					});
				end

				messages.__history = _tmp;
			else
				_tmp = messages.__history;
			end
		else
			_tmp = messages.history;
		end

		---|fE

		local _txt, _ext, width = messages.create_lines(_tmp, "history");
		local winopts = get(messages.config.hist_winopts or { split = "below", height = 10 }, _txt, width);

		---|fS
		if not messages.hist_win or vim.api.nvim_win_is_valid(messages.hist_win) == false then
			messages.hist_win = vim.api.nvim_open_win(messages.hist_buf, true, winopts);
		else
			vim.api.nvim_win_set_config(messages.hist_win, winopts);
		end
		---|fE

		vim.api.nvim_buf_set_lines(messages.hist_buf, 0, -1, false, _txt);

		---|fS

		vim.bo[messages.hist_buf].modifiable = false;
		vim.wo[messages.hist_win].spell = false;

		for e, ext in ipairs(_ext) do
			for _, hl in ipairs(ext) do
				vim.api.nvim_buf_set_extmark(messages.hist_buf, messages.namespace, e - 1, hl[1], {
					end_col = hl[2],
					hl_group = hl[3]
				})
			end
		end

		vim.api.nvim__redraw({
			flush = true,
		});

		---|fE

		---|fE
	end
};

messages.attach = function ()
	vim.o.cmdheight = 0;
	messages.__enabled = true;

	vim.ui_attach(messages.namespace, { ext_messages = true, ext_cmdline = false }, function (event, ...)
			file:write(event .. "\n")
		if not messages.handlers[event] then
			return;
		end

		local args = { ... };

		---@type boolean, string | nil
		---@diagnostic disable-next-line
		local success, error = pcall(messages.handlers[event], unpack(args));

		if success == false then
			table.insert(messages.logs, { vim.uv.hrtime(), error });
		end
	end);

	vim.api.nvim_create_autocmd("VimResized", {
		group = messages.__augroup,

		callback = function ()
			if not messages.window or vim.api.nvim_win_is_valid(messages.window) == false then
				return;
			end

			messages.__redraw = true;
		end
	});
end

messages.detach = function ()
	vim.ui_detach(messages.namespace);
end

--- Setup function.
---@param user_config? table
messages.setup = function (user_config)
	messages.config = vim.tbl_deep_extend("force", messages.config, user_config or {})
	messages.attach();

	vim.api.nvim_create_user_command("Msg", function ()
		if messages.__enabled == true then
			messages.detach();
		else
			messages.attach();
		end
	end, {
		desc = "Custom messages toggle"
	})
end

return messages;
