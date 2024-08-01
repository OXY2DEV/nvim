local fancy_cmdline = {};
local ffi = require("ffi");

ffi.cdef("bool cmdpreview;")

local Special = "Þ";
local BS = vim.api.nvim_replace_termcodes("<BS>", true, true, true);

local get_attached_wins = function (buffer)
	local windows = vim.api.nvim_list_wins();
	local attached_wins = {};

	for _, window in ipairs(windows) do
		if vim.api.nvim_win_get_buf(window) == buffer then
			table.insert(attached_wins, window);
		end
	end

	return attached_wins;
end

local get_val = function (value)
	if type(value) == "function" and pcall(value) then
		return value();
	end

	return value;
end

local clamp = function (value, min, max)
	return math.min(math.max(value, min), max);
end

local get_window_pos = function ()
	local width = vim.o.columns;
	local height = vim.o.lines;

	return {
		clamp(math.floor((height - 3) / 2), 0, height),
		clamp(math.floor((width - (fancy_cmdline.width + 2)) / 2), 0, width)
	}
end

local to_str = function (list)
	local _o = "";

	for _, val in ipairs(list) do
		_o = _o .. val[2];
	end

	return _o;
end

fancy_cmdline.__cmds = {};

fancy_cmdline.__set = false;
fancy_cmdline.__popup_set = false;
fancy_cmdline.__level = 1;

fancy_cmdline.namespace = vim.api.nvim_create_namespace("fancy_cmdline");
fancy_cmdline.cursor_namespace = vim.api.nvim_create_namespace("fancy_cmdline_cursor");
fancy_cmdline.buffer = vim.api.nvim_create_buf(false, true);
fancy_cmdline.window = nil;

fancy_cmdline.is_open = false;

fancy_cmdline.width = 60;
fancy_cmdline.icon_size = 0;
fancy_cmdline.popup_height = 5;

fancy_cmdline.styles = {
	default = {
		icon = "  ", icon_hl = "rainbow4",
		title_pos = "right",

		filetype = "vim",
		title = function ()
			local v = vim.version();

			return " NVIM v" .. v.major .. "." .. v.minor .. " "
		end
	},

	modes = {
		["?"] = {
			icon = "  ", icon_hl = "rainbow5",
			title_pos = "right",

			winhl = "FloatBorder:rainbow3",
			title = function ()
				return " Search down "
			end
		},
		["/"] = {
			icon = "  ", icon_hl = "rainbow5",
			title_pos = "right",

			winhl = "FloatBorder:rainbow2",
			title = function ()
				return " Search up "
			end
		},
		["="] = {
			icon = "  ", icon_hl = "rainbow5",
			title_pos = "right",

			winhl = "FloatBorder:rainbow4",
			title = function ()
				return " Calculate "
			end
		},
	},

	matches = {
		{
			pattern = "^=",
			icon = "  ", icon_hl = "DevIconLua",

			filetype = "lua",
		},
		{
			pattern = "lua",
			icon = "  ", icon_hl = "DevIconLua",

			filetype = "lua",
		},
		{
			pattern = "^%d,%ds/",
			icon = "  ", icon_hl = "Special",

			filetype = "vim",
		},
		{
			pattern = "^s/",
			icon = "  ", icon_hl = "Special",

			filetype = "vim",
		},
		{
			pattern = "^h%s+",
			icon = " 󰋗 ", icon_hl = "rainbow5",

			filetype = "vim",
		},
		{
			pattern = "^TS",
			icon = " 󰙅 ", icon_hl = "rainbow4",

			filetype = "vim",
		},
		{
			pattern = "^Lsp",
			icon = " 󰒋 ", icon_hl = "rainbow4",

			filetype = "vim",
		},
		{
			pattern = "^Lazy%s*",
			icon = " 💤 ",
			title = " 💤 Lazy.nvim ",
			title_pos = "right",

			filetype = "vim",
		}
	},


	default_completion = {
		icon = "  ", icon_hl = "rainbow3",
	},
	completions = {
		{
			context = "^Lazy(.*)",
			icon = " 💤 "
		},
		{
			context = "^Markview%s+%a+%s+(%d*)",
			icon = "  ", icon_hl = "rainbow4"
		},
		{
			context = "^Helpview%s+%a+%s+(%d*)",
			icon = "  ", icon_hl = "rainbow4"
		},
		{
			context = "^Markview%s+(%a*)",
			icon = "  ", icon_hl = "rainbow4"
		},
		{
			context = "^Helpview%s+(%a*)",
			icon = "  ", icon_hl = "rainbow5"
		},
		{
			pattern = "Telescope",
			icon = "  ", icon_hl = "rainbow5"
		},
		{
			pattern = "Lsp",
			icon = "  ", icon_hl = "rainbow2"
		},
		{
			context = "^h%s*(%S*)$",
			icon = "  ", icon_hl = "rainbow5"
		}
	},
	match_hl = "Title",
	select_hl = "PmenuKindSel"
}



fancy_cmdline.destroy_windows = function (windows)
	for _, window in ipairs(windows) do
		vim.api.nvim_win_close(window, true);
	end
end

fancy_cmdline.create_ui = function ()
	if fancy_cmdline.window and vim.api.nvim_win_is_valid(fancy_cmdline.window) then
		return;
	end

	local cmd_wins = get_attached_wins(fancy_cmdline.buffer);

	if not vim.tbl_isempty(cmd_wins) then
		fancy_cmdline.destroy_windows(cmd_wins);
	end

	-- Get the coordinates for the window
	local pos = get_window_pos();

	fancy_cmdline.window = vim.api.nvim_open_win(fancy_cmdline.buffer, false, {
		relative = "editor",
		row = pos[1], col = pos[2],
		width = fancy_cmdline.width, height = 1,

		zindex = 250,
		border = "rounded"
	});
end

fancy_cmdline.remove_wins = function ()
	local cmd_wins = get_attached_wins(fancy_cmdline.buffer);

	if not vim.tbl_isempty(cmd_wins) then
		fancy_cmdline.destroy_windows(cmd_wins);
	end
end

fancy_cmdline.clear_buffer = function ()
	vim.api.nvim_buf_clear_namespace(fancy_cmdline.buffer, fancy_cmdline.namespace, 0, -1)
end

fancy_cmdline.set_defaults = function ()
	if fancy_cmdline.__set == true then
		return;
	end

	vim.wo[fancy_cmdline.window].number = false;
	vim.wo[fancy_cmdline.window].relativenumber = false;

	vim.wo[fancy_cmdline.window].wrap = false;
	vim.wo[fancy_cmdline.window].spell = false;
	vim.wo[fancy_cmdline.window].cursorline = false;

	vim.wo[fancy_cmdline.window].sidescrolloff = 10;
end

fancy_cmdline.set_text = function ()
	local current_cmd = fancy_cmdline.__cmds[fancy_cmdline.__level];
	local text = to_str(current_cmd.content);

	vim.api.nvim_buf_set_lines(fancy_cmdline.buffer, 0, -1, false, { text });

end

fancy_cmdline.style = function ()
	local cmd = fancy_cmdline.__cmds[fancy_cmdline.__level];
	local firstc = cmd.firstc;
	local text = to_str(cmd.content);

	local conf = fancy_cmdline.styles.default;

	if fancy_cmdline.styles.modes and fancy_cmdline.styles.modes[firstc] then
		conf = fancy_cmdline.styles.modes[firstc];
	end

	if fancy_cmdline.styles.matches then
		for _, config in ipairs(fancy_cmdline.styles.matches) do
			if text:match(config.pattern) then
				if config.on_firstcs  and not vim.list_contains(config.on_firstcs or {}, firstc) then
					goto invalidMode;
				end

				conf = config

				::invalidMode::
			end
		end
	end

	vim.api.nvim_win_set_config(fancy_cmdline.window, {
		title = conf.title and get_val(conf.title),
		title_pos = conf.title and get_val(conf.title_pos)
	})

	vim.bo[fancy_cmdline.buffer].filetype = conf.filetype;
	vim.wo[fancy_cmdline.window].winhl = conf.winhl or "";

	if conf.icon then
		fancy_cmdline.icon_size = vim.fn.strdisplaywidth(conf.icon or "");

		vim.api.nvim_buf_set_extmark(fancy_cmdline.buffer, fancy_cmdline.namespace, 0, 0, {
			virt_text_pos = "inline",
			virt_text = {
				{ conf.icon, conf.icon_hl }
			}
		})
	end
end

fancy_cmdline.create_cursor = function ()
	local cmd = fancy_cmdline.__cmds[fancy_cmdline.__level];
	local text = to_str(cmd.content);
	local cursor_position = cmd.pos;

	vim.api.nvim_buf_clear_namespace(fancy_cmdline.buffer, fancy_cmdline.cursor_namespace, 0, -1)

	local length = #text;

	if length == 0 or cursor_position >= length then
		vim.api.nvim_buf_set_extmark(fancy_cmdline.buffer, fancy_cmdline.cursor_namespace, 0, length, {
			virt_text_pos = "overlay",
			virt_text = { { " ", "Cursor" } }
		})
	else
		local y = #vim.fn.strcharpart(text, 0, cursor_position);
		local char_len = #vim.fn.strcharpart(text, 0, 1);

		vim.api.nvim_buf_add_highlight(fancy_cmdline.buffer, fancy_cmdline.cursor_namespace, "Cursor", 0, y, y + char_len);
	end

	vim.api.nvim_win_set_cursor(fancy_cmdline.window, { 1 , clamp(cursor_position, 0, 1000) });
end

fancy_cmdline.hide_real_cursor = function ()
	fancy_cmdline.__guicursor = vim.go.guicursor ~= "a:CursorHidden" and vim.go.guicursor or fancy_cmdline.__guicursor;
	vim.go.guicursor = "a:CursorHidden";
end

fancy_cmdline.show_real_cursor = function ()
	if fancy_cmdline.__guicursor then
		vim.go.guicursor = fancy_cmdline.__guicursor;
	end
end


fancy_cmdline.save_state = function (content, pos, firstc, prompt, indent, level)
	if not fancy_cmdline.__cmds[level] then
		fancy_cmdline.__cmds[level] = {};
	end

	fancy_cmdline.__cmds[level] = vim.tbl_deep_extend("force", fancy_cmdline.__cmds[level], {
		content = content,
		pos = pos,
		firstc = firstc,
		prompt = prompt,
		indent = indent,
		level = level
	});

	fancy_cmdline.__level = level;
end

fancy_cmdline.update_state = function (level, key, value)
	if not fancy_cmdline.__cmds[level] then
		fancy_cmdline.__cmds[level] = {};
	end

	fancy_cmdline.__cmds[level][key] = value;
end



fancy_cmdline.popup_buffer = vim.api.nvim_create_buf(false, true);

fancy_cmdline.__cmp_state = {};

fancy_cmdline.save_popupmemu_state = function (items, selected, row, col, grid)
	fancy_cmdline.__cmp_state = {
		items = items,
		selected = selected,

		row = row, col = col,
		grid = grid
	};
end

fancy_cmdline.update_popupmemu_state = function (key, value)
	fancy_cmdline.__cmp_state[key] = value;
end

fancy_cmdline.create_popupmenu = function ()
	local cmd_pos = get_window_pos();

	local shifted_row = cmd_pos[1] - math.floor(fancy_cmdline.popup_height / 2);

	vim.api.nvim_win_set_config(fancy_cmdline.window, {
		relative = "editor",
		row = shifted_row, col = cmd_pos[2],
	});

	if fancy_cmdline.popup_window and vim.api.nvim_win_is_valid(fancy_cmdline.popup_window) then
		vim.api.nvim_win_set_config(fancy_cmdline.popup_window, {
			relative = "editor",
			row = shifted_row + 3, col = cmd_pos[2],

			width = fancy_cmdline.width, height = 5,

			border = "rounded"
		});
	else
		fancy_cmdline.popup_window = vim.api.nvim_open_win(fancy_cmdline.popup_buffer, false, {
			relative = "editor",
			row = shifted_row + 3, col = cmd_pos[2],

			zindex = 250,
			width = fancy_cmdline.width, height = 5,

			border = "rounded"
		})
	end
end

fancy_cmdline.set_popup_defaults = function ()
	if fancy_cmdline.__popup_set == true then
		return;
	end

	vim.wo[fancy_cmdline.popup_window].number = false;
	vim.wo[fancy_cmdline.popup_window].relativenumber = false;

	vim.wo[fancy_cmdline.popup_window].wrap = false;
	vim.wo[fancy_cmdline.popup_window].spell = false;
	vim.wo[fancy_cmdline.popup_window].cursorline = false;

	vim.wo[fancy_cmdline.popup_window].scrolloff = fancy_cmdline.popup_height;
end

fancy_cmdline.completions_decorator = function (item, cmd_text)
	local decoration = fancy_cmdline.styles.default_completion;

	for _, comp in ipairs(fancy_cmdline.styles.completions) do
		if comp.pattern and item[1]:match(comp.pattern) then
			decoration = comp;
		elseif comp.context and cmd_text:match(comp.context) then
			decoration = comp;
			break;
		end
	end

	return decoration;
end

fancy_cmdline.show_completions = function ()
	vim.api.nvim_buf_clear_namespace(fancy_cmdline.popup_buffer, fancy_cmdline.namespace, 0, -1);
	vim.api.nvim_buf_set_lines(fancy_cmdline.popup_buffer, 0, -1, false, {})

	local cmd = fancy_cmdline.__cmds[fancy_cmdline.__level];
	local rendered_text = to_str(cmd.content);

	local tail = rendered_text:match("%s*(%S*)$")

	for line, item in ipairs(fancy_cmdline.__cmp_state.items) do
		local decoration = fancy_cmdline.completions_decorator(item, rendered_text)

		vim.api.nvim_buf_set_lines(fancy_cmdline.popup_buffer, line - 1, line, false, { item[1] })

		if item[1]:find(tail) then
			local from, to = item[1]:find(tail);

			vim.api.nvim_buf_add_highlight(fancy_cmdline.popup_buffer, fancy_cmdline.namespace, fancy_cmdline.styles.match_hl or "Special", line - 1, from - 1, to)
		end

		vim.api.nvim_buf_set_extmark(fancy_cmdline.popup_buffer, fancy_cmdline.namespace, line - 1, 0, {
			virt_text_pos = "inline",
			virt_text = { { decoration.icon, decoration.icon_hl } },
		})
	end
end

fancy_cmdline.select_completion = function ()
	local selected = fancy_cmdline.__cmp_state.selected;

	if selected ~= -1 then
		vim.api.nvim_buf_clear_namespace(fancy_cmdline.popup_buffer, fancy_cmdline.cursor_namespace, 0, -1);

		vim.api.nvim_win_set_cursor(fancy_cmdline.popup_window, { selected + 1 , 0 });
		vim.api.nvim_buf_set_extmark(fancy_cmdline.popup_buffer, fancy_cmdline.cursor_namespace, selected, 0, {
			line_hl_group = fancy_cmdline.styles.select_hl or "CursorLine"
		})
	end
end

fancy_cmdline.remove_popup_wins = function ()
	local wins = get_attached_wins(fancy_cmdline.popup_buffer);

	if not vim.tbl_isempty(wins) then
		fancy_cmdline.destroy_windows(wins)
	end

	if fancy_cmdline.window and vim.api.nvim_win_is_valid(fancy_cmdline.window) then
		local cmd_pos = get_window_pos();

		vim.api.nvim_win_set_config(fancy_cmdline.window, {
			relative = "editor",
			row = cmd_pos[1], col = cmd_pos[2],
		});
	end
end

vim.ui_attach(fancy_cmdline.namespace, { ext_cmdline = true, ext_popupmenu = true  }, function (event, ...)
	if event == "cmdline_show" then
		local content, pos, firstc, prompt, indent, level = ...;

		fancy_cmdline.save_state(content, pos, firstc, prompt, indent, level)

		--- Skip in case we see the special character
		local str = to_str(fancy_cmdline.__cmds[fancy_cmdline.__level].content);

		if str:find(Special, 1, true) then
			return;
		end

		fancy_cmdline.create_ui();
		fancy_cmdline.set_defaults();

		fancy_cmdline.set_text();

		fancy_cmdline.style();
		fancy_cmdline.create_cursor();

		fancy_cmdline.hide_real_cursor();

		fancy_cmdline.__set = true;

		vim.api.nvim__redraw({ flush = true })
		return true;
	elseif event == "cmdline_pos" then
		local pos, level = ...;

		--- Skip in case we see the special character
		local str = to_str(fancy_cmdline.__cmds[fancy_cmdline.__level].content);

		if str:find(Special, 1, true) then
			return;
		end

		fancy_cmdline.update_state(level, "pos", pos)
		fancy_cmdline.create_cursor();

		vim.api.nvim__redraw({ flush = true })
		return true;
	elseif event == "cmdline_hide" and fancy_cmdline.__level == 1 then
		fancy_cmdline.__set = false;

		fancy_cmdline.clear_buffer();
		fancy_cmdline.remove_wins();
		fancy_cmdline.remove_popup_wins();

		fancy_cmdline.show_real_cursor();

		vim.api.nvim__redraw({ flush = true, statusline = true })
		return true;
	end


	if event == "popupmenu_show" then
		local items, selected, row, col, grid = ...;

		fancy_cmdline.save_popupmemu_state(items, selected, row, col, grid)
		fancy_cmdline.create_popupmenu();
		fancy_cmdline.set_popup_defaults();

		fancy_cmdline.show_completions();
		fancy_cmdline.select_completion();

		fancy_cmdline.__popup_set = true;
	elseif event == "popupmenu_select" then
		local selected = ...;

		fancy_cmdline.update_popupmemu_state("selected", selected)
		fancy_cmdline.select_completion();
	elseif event == "popupmenu_hide" then
		fancy_cmdline.__popup_set = false;
		fancy_cmdline.remove_popup_wins();
	end
end)

vim.api.nvim_create_autocmd({ "CmdlineChanged" }, {
	callback = function ()
		if ffi.C.cmdpreview then
			ffi.C.cmdpreview = false;
			vim.api.nvim_feedkeys(Special .. BS, "n", false);
		end

		ffi.C.cmdpreview = false;
		vim.api.nvim_exec("redraw", { output = false });
		-- vim.cmd("redraw");
	end
})




