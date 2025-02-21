--- Experimental Custom cmdline.
local cmdline = {};

---|fS "Type definitions"


---@class cmdline.state
---
--- Cmdline content.
--- Currently unused.
---@field content? [ table, string ][]
---
--- Cursor position(in bytes).
---@field pos? integer
---
---@field firstc?
---| ":" Normal cmdline
---| "?" Search forward.
---| "/" Search backward.
---
--- Prompt text.
---@field prompt? string
---
--- Cmdline indentation.
--- Currently unused.
---@field indent? integer
---
--- Cmdline level.
--- Currently unused.
---@field level? integer


--- Options for the cmdline.
---@class cmdline.opts
---
--- Changes the 'winhighlight' of the cmdline
--- window.
---@field winhl? string | fun(state: cmdline.state, text: string): string
---
--- Highlight group for the cursor.
---@field cursor_hl? string | fun(state: cmdline.state, text: string): string
---
--- Virtual text position.
---@field cursor_pos? "inline" | "overlay" | fun(state: cmdline.state, text: string): ("inline" | "overlay")
---
--- Text to use for the fake cursor.
---
--- NOTE: This removes text under the
--- cursor.
---@field cursor? string | fun(state: cmdline.state, text: string): string
---
--- List of lines to show as title.
---@field title? ( [ string, string? ][] )[]
---
--- Icon to show on the left side of the
--- cmdline.
---@field icon? string | fun(state: cmdline.state, text: string): string
---
--- Highlight group for the icon.
---@field icon_hl? string | fun(state: cmdline.state, text: string): string
---
--- Filetype for the cmdline.
---@field filetype? string | fun(state: cmdline.state, text: string): string
---
--- Text offset. Used for hiding leading
--- text.
---@field offset? integer | fun(state: cmdline.state, text: string): string


--- Configuration for a cmdline style.
---@class cmdline.style
---
--- Condition for this style.
---@field condition fun(state: cmdline.state, text: string): boolean
---
--- Options for this style.
---@field opts cmdline.opts


--- Main configuration table.
---@class cmdline.config
---
--- Default options.
---@field default cmdline.opts
---
--- Custom styles.
---@field [string] cmdline.style

---|fE

--- Default configuration.
---@type cmdline.config
cmdline.config = {
	---|fS

	default = {
		icon = function ()
			return _G.is_within_termux() == true and "  " or " 󰘳 "
		end,
		icon_hl = "Color4",
		winhl = "Normal:Color4T",

		filetype = "vim",
		offset = 0
	},

	config_1A = {
		--- Lua value, `:=value`.
		condition = function (content)
			local text = content.text or "";
			return string.match(text, "^%=") ~= nil;
		end,
		opts = {
			icon = " 󰢱 ",
			icon_hl = "Color6",

			winhl = "Normal:Color6T",
			cursor_hl = "Color6R",

			filetype = "lua",
			offset = 1
		}
	},

	config_1B = {
		--- Lua command, `:lua command`.
		condition = function (content)
			local text = content.text or "";
			return string.match(text, "^lua%s") ~= nil;
		end,
		opts = {
			icon = "  ",
			icon_hl = "Color7",

			winhl = "Normal:Color7T",
			cursor_hl = "Color7R",

			filetype = "lua",
			offset = 4
		}
	},

	config_2A = {
		--- For `?`.
		condition = function (content)
			return content.firstc == "?";
		end,
		opts = {
			icon = " 󰧺 ",
			icon_hl = "Color3",

			winhl = "Normal:Color3T",

			filetype = "regex",
			cursor_hl = "Color3R"
		}
	},
	config_2B = {
		--- For `/`.
		condition = function (content)
			return content.firstc == "/";
		end,
		opts = {
			icon = " 󰧹 ",
			icon_hl = "Color2",

			winhl = "Normal:Color2T",

			filetype = "regex",
			cursor_hl = "Color2R"
		}
	},

	config_3 = {
		--- For `<C-r>=`.
		condition = function (content)
			return content.firstc == "=";
		end,
		opts = {
			icon = " 󰃬 ",
			icon_hl = "Color0",

			winhl = "Normal:Color0T",

			filetype = "text",
			cursor_hl = "Color0R"
		}
	},
	config_4 = {
		--- For prompts
		condition = function (content)
			return content.prompt ~= "";
		end,
		opts = {
			title = function (content)
				local title = {};
				local text = content.prompt or "";

				local LEN = vim.fn.strchars(text);
				local W = math.floor(vim.o.columns * 0.8) - 3;

				for l = 1, math.floor(LEN / W) + 1 do
					table.insert(title, {
						{
							l == 1 and " 󰌌 " or "   ",
							l == 1 and "Color8" or nil
						},
						{
							vim.fn.strcharpart(text, (l - 1) * W, l * W)
						}
					});
				end

				return title;
			end,

			filetype = "text"
		}
	},

	---|fE
};

--- Gets current cmdline configuration.
---@return cmdline.opts
cmdline.get_config = function ()
	---|fS

	---@param v any
	---@return any
	local function tostatic(v)
		local _v = v;

		if type(_v) == "function" then
			if pcall(_v, cmdline.__state) then
				_v = _v(cmdline.__state);
			else
				return;
			end
		end

		if type(_v) ~= "table" then
			return _v;
		end

		for key, value in pairs(_v) do
			if type(value) == "function" then
				if pcall(value, cmdline.__state) then
					_v[key] = value(cmdline.__state);
				else
					_v[key] = nil;
				end
			end
		end

		return _v;
	end

	---@type cmdline.opts
	local default = tostatic(cmdline.config.default);
	---@type string[]
	local keys = vim.tbl_keys(cmdline.config);
	table.sort(keys);

	keys = vim.tbl_filter(function (key)
		local val = cmdline.config[key];

		if type(val) ~= "table" then
			return false;
		elseif type(val.condition) ~= "function" then
			return false;
		end

		local can_call, cond = pcall(val.condition, cmdline.__state);

		return can_call == true and cond == true;
	end, keys);

	if #keys > 0 then
		return vim.tbl_extend(
			"force",
			default,
			tostatic(cmdline.config[keys[1]].opts or {})
		);
	else
		return default;
	end

	---|fE
end

---@type integer Namespace for the cmdline.
cmdline.namespace = vim.api.nvim_create_namespace("cmdline");
---@type integer Namespace for the cursor in cmdline.
cmdline.cursor_ns = vim.api.nvim_create_namespace("cmdline.cursor");

--- Cmdline buffer & window.
---@type integer, integer
cmdline.buffer, cmdline.window = nil, nil;

---@type cmdline.state
cmdline.__state = nil;

--- Is the statusline visible?
---@type boolean
cmdline.__statualine_visible = true;

--- Should the statusline be redrawn?
---@type boolean
cmdline.__redraw = false;

--- Updates cmdline state.
---@param new_state table
cmdline.__update_state = function (new_state)
	if type(cmdline.__state) ~= "table" then
		cmdline.__state = {};
	end

	for attr, val in pairs(new_state) do
		cmdline.__state[attr] = val;
	end
end

--- Gets state.
---@param state string
---@param fallback any
---@return any
cmdline.__get_state = function (state, fallback)
	if type(cmdline.__state) ~= "table" then
		cmdline.__state = {};
	end

	return cmdline.__state[state] or fallback;
end

-----------------------------------------------------------------------------

--- Update cmdline buffer text.
---@param config cmdline.opts
---@return integer
cmdline.__update_content = function (config)
	---|fS

	pcall(vim.api.nvim_buf_clear_namespace, cmdline.buffer, cmdline.namespace, 0, -1);

	local h = 0;
	local text = "";

	if config.title then
		for l, line in ipairs(config.title) do
			pcall(vim.api.nvim_buf_set_lines, cmdline.buffer, l == 1 and 0 or -1, -1, false, { "" });

			pcall(vim.api.nvim_buf_set_extmark, cmdline.buffer, cmdline.namespace, h, 0, {
				virt_text_pos = "inline",
				virt_text = line,

				hl_mode = "combine"
			});

			h = h + 1;
		end
	end

	for _, segmant in ipairs(cmdline.__get_state("content", {})) do
		text = text .. segmant[2];
	end

	if config.offset then
		local offset_size = string.len(vim.fn.strcharpart(text, 0, config.offset));
		local pos = cmdline.__get_state("pos", 0);

		if pos > offset_size then
			cmdline.__update_state({
				offset = offset_size
			});

			text = vim.fn.strcharpart(text, config.offset);
		else
			cmdline.__update_state({
				offset = 0
			});
		end
	end

	text = text .. " ";

	if h == 0 then
		pcall(vim.api.nvim_buf_set_lines, cmdline.buffer, 0, -1, false, { text });
	else
		pcall(vim.api.nvim_buf_set_lines, cmdline.buffer, -1, -1, false, { text });
	end

	if config.icon then
		pcall(vim.api.nvim_buf_set_extmark, cmdline.buffer, cmdline.namespace, h, 0, {
			virt_text_pos = "inline",
			virt_text = {
				{ config.icon, config.icon_hl }
			},

			hl_mode = "combine"
		});
	end

	h = h + 1;
	return h;

	---|fE
end

--- Updates cursor position(both fake & real ones).
---@param line_count integer
---@param config cmdline.opts
cmdline.__update_cursor = function (line_count, config)
	---|fS

	pcall(vim.api.nvim_buf_clear_namespace, cmdline.buffer, cmdline.cursor_ns, 0, -1);

	if not cmdline.window or vim.api.nvim_win_is_valid(cmdline.window) == false then
		return;
	end

	local pos = cmdline.__get_state("pos", 0);
	local offset = cmdline.__get_state("offset", 0);

	pcall(vim.api.nvim_win_set_cursor, cmdline.window, { line_count, pos - offset });

	if config.cursor then
		pcall(vim.api.nvim_buf_set_extmark, cmdline.buffer, cmdline.cursor_ns, line_count - 1, pos - offset, {
			invalidate = true, undo_restore = false,

			virt_text_pos = config.cursor_pos or "inline",
			virt_text = {
				{ config.cursor, config.cursor_hl or "Cursor" }
			},

			hl_mode = "combine",
		});
	else
		pcall(vim.api.nvim_buf_set_extmark, cmdline.buffer, cmdline.cursor_ns, line_count - 1, pos - offset, {
			invalidate = true, undo_restore = false,
			end_col = (pos - offset) + 1,

			hl_group = config.cursor_hl or "Cursor"
		});
	end

	---|fE
end

--- Updates cmdline UI.
cmdline.__update_ui = function ()
	---|fS

	if vim.g.__cmd_cursorline == nil then
		vim.g.__cmd_cursorline = vim.o.cursorline ~= false;
		vim.o.cursorline = false;
	end

	if not cmdline.buffer or vim.api.nvim_buf_is_valid(cmdline.buffer) == false then
		cmdline.buffer = vim.api.nvim_create_buf(false, true);
	end

	local text = "";

	for _, segmant in ipairs(cmdline.__get_state("content", {})) do
		text = text .. segmant[2];
	end

	---@type cmdline.opts
	local config = cmdline.get_config();
	local h = cmdline.__update_content(config);

	local set_ft = cmdline.__get_state("set_ft", false);

	if set_ft == false or (config.filetype and vim.bo[cmdline.buffer] ~= config.filetype) then
		if config.filetype then
			vim.bo[cmdline.buffer].ft = config.filetype;
		else
			vim.bo[cmdline.buffer].ft = "text";
		end

		cmdline.__update_state({
			set_ft = true
		});

		if cmdline.window and vim.api.nvim_win_is_valid(cmdline.window) then
			vim.wo[cmdline.window].winhl = config.winhl or "";
		end
	end

	if cmdline.__redraw ~= true and cmdline.__get_state("text", nil) == text then
		cmdline.__update_cursor(h, config);

		vim.api.nvim__redraw({
			flush = true,
		});
		return;
	else
		cmdline.__update_state({
			text = text
		});
	end

	local win_config = {
		relative = "editor",
		style = "minimal",
		zindex = 300,

		row = vim.o.lines - (cmdline.__statualine_visible and 1 or 0) - (vim.o.cmdheight + h),
		col = 0,

		width = vim.o.columns,
		height = h,
	};

	if not cmdline.window or vim.api.nvim_win_is_valid(cmdline.window) == false then
		cmdline.window = vim.api.nvim_open_win(cmdline.buffer, false, win_config);
	else
		pcall(vim.api.nvim_win_set_config, cmdline.window, win_config);
	end

	cmdline.__update_cursor(h, config);

	vim.api.nvim__redraw({
		flush = true,
	});

	cmdline.__redraw = false;

	---|fE
end

--- Closes cmdline UI.
cmdline.__close_ui = function ()
	pcall(vim.api.nvim_win_close, cmdline.window, true);

	if vim.g.__cmd_cursorline ~= nil then
		vim.o.cursorline = vim.g.__cmd_cursorline;
		vim.g.__cmd_cursorline = nil;
	end

	vim.api.nvim__redraw({
		flush = true,
		statusline = true
	});
end

-----------------------------------------------------------------------------

--- Cmdline draw event
---@param content [ string[], string ][]
---@param pos integer
---@param firstc string
---@param prompt string
---@param indent integer
---@param level integer
cmdline.cmdline_show = function (content, pos, firstc, prompt, indent, level)
	cmdline.__update_state({
		content = content,
		pos = pos,
		firstc = firstc,
		prompt = prompt,
		indent = indent,
		level = level
	});

	cmdline.__update_ui();
end

--- Hides the cmdline.
cmdline.cmdline_hide = function ()
	cmdline.__state = nil;

	cmdline.__close_ui();
end

--- Cursor position change.
---@param pos integer
---@param level integer
cmdline.cmdline_pos = function (pos, level)
	cmdline.__update_state({
		pos = pos,
		level = level
	});

	local config = cmdline.get_config();
	local h = cmdline.__update_content(config);

	local text = cmdline.__get_state("text", "");

	if string.match(text, "^.*s/") then
		local char = " ";

		vim.api.nvim_buf_call(vim.api.nvim_get_current_buf(), function ()
			local line = vim.api.nvim_get_current_line();
			local col = vim.fn.col(".");

			char = string.match(string.sub(line, col, col + 1), "^.") or " ";
		end)

		local _, code = pcall(vim.api.nvim_replace_termcodes, char .. "<BS>", true, false, true)
		pcall(vim.api.nvim_feedkeys, code, "c", false);
	end

	cmdline.__update_cursor(h, config);
end

-----------------------------------------------------------------------------

--- Is the custom cmdline Attached?
---@type boolean
cmdline.__enabled = false;

cmdline.__cmd_leave = nil;
cmdline.__win_enter = nil;

cmdline.__augroup = vim.api.nvim_create_augroup("cmdline", { clear = true });

cmdline.attach = function ()
	vim.o.cmdheight = 0;
	cmdline.__enabled = true;

	vim.ui_attach(cmdline.namespace, { ext_cmdline = true }, function (event, ...)
		if not cmdline[event] then
			return;
		end

		local args = { ... };

		---@type boolean, string | nil
		local success, error = pcall(cmdline[event], unpack(args));

		-- if success == false then
		-- 	vim.print(error)
		-- end
	end);

	vim.api.nvim_create_autocmd("CmdlineLeave", {
		group = cmdline.__augroup,

		callback = function ()
			pcall(cmdline.__close_ui);
		end
	});

	vim.api.nvim_create_autocmd("WinEnter", {
		group = cmdline.__augroup,

		callback = function ()
			local win = vim.api.nvim_get_current_win();
			local config = vim.api.nvim_win_get_config(win);

			if config.relative ~= "" then
				--- Floats do not have a statusline.
				cmdline.__statualine_visible = false;
			elseif vim.o.laststatus > 1 then
				cmdline.__statualine_visible = true;
			elseif #vim.api.nvim_list_wins() > 1 then
				--- laststatus == 1 and multiple
				--- windows exist.
				cmdline.__statualine_visible = true;
			else
				cmdline.__statualine_visible = false;
			end
		end
	});

	vim.api.nvim_create_autocmd("VimResized", {
		group = cmdline.__augroup,

		callback = function ()
			if not cmdline.window or vim.api.nvim_win_is_valid(cmdline.window) == false then
				return;
			end

			cmdline.__redraw = true;
		end
	});
end

cmdline.detach = function ()
	vim.o.cmdheight = 1;
	cmdline.__enabled = false;

	vim.ui_detach(cmdline.namespace);
	cmdline.__augroup = vim.api.nvim_create_augroup("cmdline", { clear = true });
end

--- Setup function.
---@param user_config cmdline.config
cmdline.setup = function (user_config)
	cmdline.config = vim.tbl_deep_extend("force", cmdline.config, user_config or {})
	cmdline.attach();

	vim.api.nvim_create_user_command("Cmd", function ()
		if cmdline.__enabled == true then
			cmdline.detach();
		else
			cmdline.attach();
		end
	end, {
		desc = "Custom cmdline toggle"
	})
end

return cmdline;
