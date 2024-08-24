local cmd = {};

--- Turns a list of chunks into a string
---@param chunks table[]
---@return string
local concat = function (chunks)
	local _c = "";

	for _, chunk in ipairs(chunks) do
		_c = _c .. chunk[2];
	end

	return _c;
end

cmd.conf = {
	width = math.floor(0.6 * vim.o.columns),
	cmp_height = 7,

	default = {
		winopts = {
			title = {
				{ "", "CmdBlue" },
				{ "  ", "CmdText" },
				{ "v" .. vim.version().major .. "." .. vim.version().minor .. " ", "CmdText" },
				{ "", "CmdBlue" },
			},
			title_pos = "right"
		},

		icon = { { " 󰣖 ", "CmdBlue" } },
		winhl = "FloatBorder:CmdBlue,Normal:Normal",
		ft = "vim"
	},
	configs = {
		{
			firstc = ":",
			match = "^s/",
			icon = { { "  ", "CmdYellow" } },
		},
		{
			firstc = ":",
			match = "^%d+,%d+s/",
			icon = { { "  ", "CmdOrange" } },
		},
		{
			firstc = ":",
			match = "^=",
			icon = { { "  ", "CmdBlue" } },
			ft = "lua",

			text = function (inp)
				return inp:gsub("^=", "");
			end
		},
		{
			firstc = ":",
			match = "^lua%s",

			winopts = {
				title = {
					{ "", "CmdViolet" },
					{ "  " .. _VERSION .. " ", "LuaText" },
					{ "", "CmdViolet" },
				},
				title_pos = "right"
			},

			winhl = "FloatBorder:CmdViolet,Normal:Normal",
			icon = { { "  ", "CmdViolet" } },
			ft = "lua",

			text = function (inp)
				local init = inp:gsub("^lua", "")

				if init:match("^(%s+)") then
					return init:gsub("^%s+", "");
				end

				return init;
			end
		},
		{
			firstc = ":",
			match = "^Telescope",
			icon = { { " 󰭎 ", "CmdYellow" } },
		},
		{
			firstc = "?",
			winopts = {
				title = {
					{ "", "CmdOrange" },
					{ " 󰍉 Search ", "SearchUpText" },
					{ "", "CmdOrange" },
				},
				title_pos = "right"
			},
			icon = { { "  ", "CmdOrange" } },
			winhl = "FloatBorder:CmdOrange,Normal:Normal"
		},
		{
			firstc = "/",
			winopts = {
				title = {
					{ "", "CmdYellow" },
					{ " 󰍉 Search ", "SearchDownText" },
					{ "", "CmdYellow" },
				},
				title_pos = "right"
			},
			icon = { { "  ", "CmdYellow" } },
			winhl = "FloatBorder:CmdYellow,Normal:Normal"
		},
		{
			firstc = "=",
			winopts = {
				title = {
					{ "", "CmdGreen" },
					{ "  Calculate ", "CalculateText" },
					{ "", "CmdGreen" },
				},
				title_pos = "right"
			},
			icon = { { " 󰇼 ", "CmdGreen" } },
			winhl = "FloatBorder:CmdGreen,Normal:Normal"
		},
	},

	completion_default = {
		hl = "CmdViolet",
		icon = { { "  ", "CmdViolet" } }
	},
	completion_custom = {
		{
			cmd = "^h",
			hl = "CmdYellow",
			icon = { { " 󰮥 ", "CmdYellow" } }
		},
		{
			cmd = "^Lazy",
			hl = "CmdBlue",
			icon = { { " 💤 " } }
		},
		{
			cmd = "^Telescope",
			hl = "CmdGreen",
			icon = { { " 󰺮 ", "CmdGreen" } }
		},
	}
};

-- Cached config for the current iteration
cmd.current_conf = {};
-- Guicursor value
cmd.cursor = nil;

-- Custom namespace
cmd.ns = vim.api.nvim_create_namespace("cmd");
-- Scratch buffer for the cmdline
cmd.buf = vim.api.nvim_create_buf(false, true);
-- Window for the cmdline
cmd.win = nil;
-- Cmdline state variables(e.g. indent, content, cursor position etc.)
cmd.state = {};

-- Buffer for the completion menu
cmd.comp_buf = vim.api.nvim_create_buf(false, true);
-- Window for the completion menu
cmd.comp_win = nil;
-- completion state variable(e.g. selected item, items etc.)
cmd.comp_state = {};

-- Variable to check if the completion window is active
cmd.comp_enable = false;
-- Text before the completion menu was opened
cmd.comp_txt = nil;

--- Updates the current state of the cmdline
---@param state table
cmd.update_state = function (state)
	cmd.state = vim.tbl_deep_extend("force", cmd.state, state);
	local txt = concat(cmd.state.content);

	for _, conf in ipairs(cmd.conf.configs) do
		if conf.firstc == cmd.state.firstc then
			if conf.match and txt:match(conf.match) then
				cmd.current_conf = conf;
				return;
			elseif not conf.match then
				cmd.current_conf = conf;
				return;
			end
		elseif not conf.firstc and conf.match and txt:match(conf.match) then
			cmd.current_conf = conf;
			return;
		end
	end

	cmd.current_conf = cmd.conf.default;
end

--- Updates the completion state
---@param state table
cmd.update_comp_state = function (state)
	cmd.comp_state = vim.tbl_deep_extend("force", cmd.comp_state, state);
end

--- Opens the cmdline
--- Done many times per second via the `cmdline_show` event
---
--- Process:
--- 1. Is the menu open?
---   Yes: Update the window.
---   No : Create new window.
---       Go to step 4.
--- 2. Is completion menu open?
---   Yes: Use combined height of the cmdline & the completion menu
---        for calculating the row.
---   No : Use the height of the cmdline for calculating the row.
--- 3. Return
--- ---------------------------------------------------------------
--- 4. Set various window options
--- 5. Store the value of the `guicursor`
--- 5. Hide the cursor
--- 6. Set buffer related options
--- 7. Return
cmd.open = function ()
	local w = cmd.conf.width < 1 and
		math.floor(vim.o.columns * cmd.conf.width) or
		cmd.conf.width
	;
	local h = 3;
	local cmp_h = cmd.conf.cmp_height or 7;

	if cmd.win and vim.api.nvim_win_is_valid(cmd.win) then
		vim.api.nvim_win_set_config(cmd.win, vim.tbl_extend("force", {
			relative = "editor",

			row = cmd.comp_enable == true and
				math.floor((vim.o.lines - (h + cmp_h)) / 2) or
				math.floor((vim.o.lines - h) / 2)
			,
			col = math.floor((vim.o.columns - w) / 2),

			width = w, height = math.max(1, h - 2)
		}, cmd.current_conf.winopts or {}));

		if cmd.current_conf.winhl then
			vim.wo[cmd.win].winhighlight = cmd.current_conf.winhl;
		end

		if cmd.current_conf.ft then
			vim.bo[cmd.buf].filetype = cmd.current_conf.ft;
		end

		if not cmd.comp_win or not vim.api.nvim_win_is_valid(cmd.comp_win) then
			return;
		end

		vim.api.nvim_win_set_config(cmd.comp_win, {
			relative = "editor",

			row = math.floor((vim.o.lines - (h + cmp_h)) / 2) + h,
			col = math.floor((vim.o.columns - w) / 2),
		});

		return;
	end

	cmd.win = vim.api.nvim_open_win(cmd.buf, false, vim.tbl_extend("force", {
		relative = "editor",

		row = cmd.comp_enable == true and
			math.floor((vim.o.lines - (h + cmp_h)) / 2) or
			math.floor((vim.o.lines - h) / 2)
		,
		col = math.floor((vim.o.columns - w) / 2),

		width = w, height = math.max(1, h - 2),
		zindex = 500,

		border = "rounded"
	}, cmd.current_conf.winopts or {}));

	vim.wo[cmd.win].number = false;
	vim.wo[cmd.win].relativenumber = false;
	vim.wo[cmd.win].statuscolumn = "";

	vim.wo[cmd.win].wrap = false;
	vim.wo[cmd.win].spell = false;
	vim.wo[cmd.win].cursorline = false;

	vim.wo[cmd.win].sidescrolloff = 10;

	if vim.opt.guicursor ~= "" then
		cmd.cursor = vim.opt.guicursor;
	else
		cmd.cursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20";
	end

	vim.opt.guicursor = "a:CursorHidden";

	if cmd.current_conf.winhl then
		vim.wo[cmd.win].winhighlight = cmd.current_conf.winhl;
	end

	if cmd.current_conf.ft then
		vim.bo[cmd.buf].filetype = cmd.current_conf.ft;
	end
end

--- Opens the completion menu
---
--- Process:
--- 1. Is completion menu open?
---    Yes: Update cmdline window.
---         Update completion menu window.
---    No : Create completion menu window.
---         Update cmdline window.
---         Go to Step 3.
--- 2. Return.
--- ---------------------------------------------------------------
--- 3. Set necessary options
--- 4. Return.
cmd.open_completion = function ()
	if vim.tbl_isempty(cmd.comp_state) then
		return;
	end

	local w = cmd.conf.width < 1 and
		math.floor(vim.o.columns * cmd.conf.width) or
		cmd.conf.width
	;
	local h = 3;
	local cmp_h = cmd.conf.cmp_height or 7;

	if cmd.comp_win and vim.api.nvim_win_is_valid(cmd.comp_win) then
		vim.api.nvim_win_set_config(cmd.win, vim.tbl_extend("force", {
			relative = "editor",

			row = math.floor((vim.o.lines - (h + cmp_h)) / 2),
			col = math.floor((vim.o.columns - w) / 2),

			width = w, height = math.max(1, h - 2)
		}, cmd.current_conf.winopts or {}));

		vim.api.nvim_win_set_config(cmd.comp_win, {
			relative = "editor",

			row = math.floor((vim.o.lines - cmp_h) / 2),
			col = math.floor((vim.o.columns - w) / 2),

			width = w, height = math.max(1, h - 2)
		});

		if cmd.current_conf.winhl then
			vim.wo[cmd.win].winhighlight = cmd.current_conf.winhl;
		end

		if cmd.current_conf.ft then
			vim.bo[cmd.buf].filetype = cmd.current_conf.ft;
		end

		return;
	end

	vim.api.nvim_win_set_config(cmd.win, vim.tbl_extend("force", {
		relative = "editor",

		row = math.floor((vim.o.lines - (h + cmp_h)) / 2),
		col = math.floor((vim.o.columns - w) / 2),

		width = w, height = math.max(1, h - 2)
	}, cmd.current_conf.winopts or {}));

	cmd.comp_win = vim.api.nvim_open_win(cmd.comp_buf, false, {
		relative = "editor",

		row = math.floor((vim.o.lines - (h + cmp_h)) / 2) + h,
		col = math.floor((vim.o.columns - w) / 2),

		width = w, height = math.max(1, cmp_h - 0),
		zindex = 500,

		border = "rounded"
	});

	vim.wo[cmd.comp_win].number = false;
	vim.wo[cmd.comp_win].relativenumber = false;
	vim.wo[cmd.comp_win].statuscolumn = "";

	vim.wo[cmd.comp_win].wrap = false;
	vim.wo[cmd.comp_win].spell = false;
	vim.wo[cmd.comp_win].scrolloff = 30;

	vim.wo[cmd.comp_win].cursorline = true;
end

--- Closes the cmdline and completion menu
--- pcall() is used to avoid possible errors
---
--- Process:
--- 1. Close the cmdline window
--- 2. Close the completion menu window
--- 3. Show the cursor(by setting the `guicursor` again)
--- 4. Return.
cmd.close = function ()
	if cmd.state.level > 1 then
		return;
	end

	pcall(vim.api.nvim_win_close, cmd.win, true);
	pcall(vim.api.nvim_win_close, cmd.comp_win, true);

	cmd.win = nil;
	cmd.comp_win = nil;

	vim.opt.guicursor = cmd.cursor;
end

--- Closes the completion menu window
cmd.close_completion = function ()
	pcall(vim.api.nvim_win_close, cmd.comp_win, true);
	cmd.comp_win = nil;
end

--- Draws the cmdline
---
--- Process:
--- 1. Loop over the cached chunks of the cmdline and create
---    the string to show.
--- 2. If the config table has a text process function and it
---    can be run, run it over the string.
--- 3. Is the cursor within the removed part?
---    Yes: Do nothing. Difference is 0 
---    No : Store the difference in bytes between the original
---         And the output string.
--- 4. Clear the extmarks in the cmdline buffer.
--- 5. Clear the line of the cmdline buffer.
--- 6. If an icon is provided use it as an `inline virtual text`
---    before the text.
--- 7. Is the cursor's  byte-position larger or equal than
---    the byte length of the text to be shown?
---    Yes: Add a " " with the cursor's hl after the text.
---    No : Add a highlight from the byte-position of the cursor
---         and the ending byte position of the next character
cmd.draw = function ()
	if not cmd.state or not cmd.state.content then
		return;
	end

	local txt = "";
	local diff = 0;

	for _, part in ipairs(cmd.state.content) do
		txt = txt .. part[2];
	end

	if cmd.current_conf.text and pcall(cmd.current_conf.text, txt) then
		local tmp = cmd.current_conf.text(txt);

		if (#txt - #tmp) < cmd.state.position then
			diff = #txt - #tmp;
			txt = tmp;
		end
	end

	vim.api.nvim_buf_set_lines(cmd.buf, 0, -1, false, { txt });
	vim.api.nvim_win_set_cursor(cmd.win, { 1, cmd.state.position });

	vim.api.nvim_buf_clear_namespace(cmd.buf, cmd.ns, 0, -1);

	if cmd.current_conf.icon then
		vim.api.nvim_buf_set_extmark(cmd.buf,
			cmd.ns,
			0,
			0,
			{
				virt_text_pos = "inline",
				virt_text = cmd.current_conf.icon
			}
		)
	end

	if cmd.state.position >= #txt + diff then
		vim.api.nvim_buf_set_extmark(cmd.buf,
			cmd.ns,
			0,
			#txt,
			{
				virt_text_pos = "inline",
				virt_text = { { " ", "Cursor" } }
			}
		)
	else
		local before = string.sub(txt, 0, cmd.state.position - diff);

		vim.api.nvim_buf_add_highlight(cmd.buf,
			cmd.ns,
			"Cursor",
			0,
			cmd.state.position - diff,
			#vim.fn.strcharpart(txt, 0, vim.fn.strchars(before) + 1)
			--- Doing "(cmd.state.position - diff) + 1" doesn't
			--- work on multi-byte characters(e.g. emojis, nerd font
			--- characters)
		);
	end
end

--- Draws the completion menu items
---
--- Process:
--- 1. Remove extmarks from the completion buffer.
--- 2. Remove all the lines from the completion buffer.
--- 3. Loop over all the completions and,
---    1. Does it have an icon?
---       Yes: Draw the icon using extmarks.
---       No : Do nothing.
---    2. Does any part of the text match the cmdline text's
---       last part?
---       Yes: Highlight it with `nvim_buf_add_highlight()`.
---       No : Do nothing.
--- 4. Set the cursor position on the currently selected item.
cmd.draw_completion = function ()
	vim.api.nvim_buf_clear_namespace(cmd.comp_buf, cmd.ns, 0, -1);
	vim.api.nvim_buf_set_lines(cmd.comp_buf, 0, -1, false, {});

	if not cmd.comp_txt then
		cmd.comp_txt = "";

		for _, part in ipairs(cmd.state.content) do
			cmd.comp_txt = cmd.comp_txt .. part[2];
		end
	end

	local last_str = cmd.comp_txt:match("(%S+)$");

	for c, completion in ipairs(cmd.comp_state.items) do
		vim.fn.setbufline(cmd.comp_buf, c, { completion[1] });

		local _c = cmd.conf.completion_default;

		for _, conf in ipairs(cmd.conf.completion_custom) do
			if conf.match and completion[1]:match(conf.match) then
				_c = conf;
			elseif conf.cmd and cmd.comp_txt:match(conf.cmd) then
				_c = conf;
			end
		end

		if _c.icon then
			vim.api.nvim_buf_set_extmark(cmd.comp_buf, cmd.ns, c - 1, 0, {
				virt_text_pos = "inline",
				virt_text = _c.icon,

				hl_mode = "combine"
			})
		end

		if last_str then
			local hl_from, hl_to = completion[1]:find(last_str);

			if hl_from and hl_to then
				vim.api.nvim_buf_add_highlight(cmd.comp_buf, cmd.ns, _c.hl or "Special", c - 1, hl_from - 1, hl_to);
			end
		end
	end

	if cmd.comp_state.selected and cmd.comp_state.selected ~= -1 then
		vim.api.nvim_win_set_cursor(cmd.comp_win, { cmd.comp_state.selected + 1, 0 })
	end
end






vim.ui_attach(cmd.ns, { ext_cmdline = true, ext_popupmenu = true  }, function (event, ...)
	if event == "cmdline_show" then
		local content, pos, firstc, prompt, indent, level = ...;

		cmd.update_state({
			content = content,
			position = pos,
			firstc = firstc,
			prompt = prompt,
			indent = indent,
			level = level
		});

		cmd.open();
		cmd.draw();

		vim.api.nvim__redraw({ win = cmd.win, flush = true })
	elseif event == "cmdline_hide" then
		cmd.close();

		vim.api.nvim__redraw({ win = cmd.win, flush = true })
	elseif event == "cmdline_pos" then
		local pos, level = ...;

		cmd.update_state({
			position = pos,
			level = level
		});

		cmd.draw();

		vim.api.nvim__redraw({ win = cmd.win, flush = true })
	elseif event == "popupmenu_show" then
		local items, selected, row, col, grid = ...;

		cmd.update_comp_state({
			items = items,
			selected = selected,
			row = row,
			col = col,
			grid = grid
		});

		cmd.comp_enable = true;

		cmd.open_completion();
		cmd.draw_completion();
	elseif event == "popupmenu_select" then
		local selected = ...;

		cmd.update_comp_state({
			selected = selected
		});

		cmd.draw_completion();

		vim.api.nvim__redraw({ win = cmd.comp_win, flush = true })
	elseif event == "popupmenu_hide" then
		cmd.comp_enable = false;
		cmd.comp_txt = nil;

		cmd.close_completion();
	end
end);

return cmd;
