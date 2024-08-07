local shared = {};
local utils = require("intro.utils");

shared.configuration = {
	window = { border = "rounded" },
	disabled_filetypes = { "Lazy" },
	disabled_buftypes = { "nofile" },

	keymaps = {
		{
			lhs = "q", rhs = "<Cmd>q<CR>",
			opts = {}
		}
	},

	parts = {
		{
			type = "raw",

			text = { "      ████ ██████           ", "█████      ██                    " },
			hl = { "StartBlue", "StartGreen" }
		},
		{
			type = "raw",

			text = { "     ███████████             ", "█████                            " },
			hl = { "StartBlue", "StartGreen" }
		},
		{
			type = "raw",

			text = { "     █████████ ███████████", "████████ ███   ███████████  " },
			hl = { "StartBlue", "StartGreen" }
		},
		{
			type = "raw",

			text = { "    █████████  ███    █████", "████████ █████ ██████████████  " },
			hl = { "StartBlue", "StartGreen" }
		},
		{
			type = "raw",

			text = { "   █████████ ██████████ ██", "███████ █████ █████ ████ █████  " },
			hl = { "StartBlue", "StartGreen" }
		},
		{
			type = "raw",

			text = { " ███████████ ███    ███ ███", "██████ █████ █████ ████ █████ " },
			hl = { "StartBlue", "StartGreen" }
		},
		{
			type = "raw",

			text = { "██████  █████████████████████ ", "████ █████ █████ ████ ██████" },
			hl = { "StartBlue", "StartGreen" }
		},
		{ type = "raw" },
		{
			type = "raw",
			text = { "Version ", tostring(vim.version().major) .. "." .. tostring(vim.version().minor) .. "." .. tostring(vim.version().patch) },
			hl = { "@label", "Special" }
		},
		{ type = "raw" },
		{ type = "raw" },
		{
			type = "raw",
			text = { "Press", " q ", "to quit" },
			hl = { "Comment", "Special", "Comment" }
		}
	},
};


shared.buffer = vim.api.nvim_create_buf(false, true);
shared.window = nil;

shared.cursor = nil;

shared.__resize_hook = nil;
shared.__redraw_hook = nil;
shared.__leave_hook = nil;

shared.__cmdheight = nil;
shared.__keymaps_set = false;

shared.find_win = function (buffer)
	local windows = vim.api.nvim_list_wins();
	local primary, additionals = nil, {};

	for _, window in ipairs(windows) do
		if vim.api.nvim_win_get_buf(window) == buffer and not primary then
			primary = window;
		elseif vim.api.nvim_win_get_buf(window) == buffer then
			table.insert(additionals, window);
		end
	end

	return primary, additionals;
end

shared.on_open = function ()
	vim.bo[shared.buffer].filetype = "Intro";

	vim.wo[shared.window].spell = false;

	vim.wo[shared.window].number = false;
	vim.wo[shared.window].relativenumber = false;

	vim.wo[shared.window].cursorline = false;

	vim.wo[shared.window].statuscolumn = "";
	vim.wo[shared.window].statusline = "%#Normal#";
	vim.wo[shared.window].winhighlight = "Normal:Normal";

	vim.wo[shared.window].scrolloff = 0;
	vim.wo[shared.window].sidescrolloff = 0;

	shared.__cmdheight = vim.o.cmdheight;
	vim.o.cmdheight = 0;

	shared.__resize_hook = vim.api.nvim_create_autocmd({ "VimResized" }, {
		buffer = shared.buffer,
		callback = function ()
			shared.cursor = vim.api.nvim_win_get_cursor(shared.window);
			shared.on_resize();
		end
	});

	shared.__leave_hook = vim.api.nvim_create_autocmd({ "BufLeave" }, {
		buffer = shared.buffer,
		callback = function ()
			shared.on_leave();
		end
	});

	if not shared.configuration.keymaps or shared.__keymaps_set == true then
		return;
	end

	for _, item in ipairs(shared.configuration.keymaps) do
		vim.api.nvim_buf_set_keymap(shared.buffer, item.mode or "n", item.lhs, item.rhs, item.opts);
	end

	shared.__keymaps_set = true;
end

shared.on_leave = function ()
	if shared.window and vim.api.nvim_win_is_valid(shared.window) then
		shared.window = vim.api.nvim_win_close(shared.window, true);
	end

	if shared.__resize_hook then
		shared.__resize_hook = vim.api.nvim_del_autocmd(shared.__resize_hook);
	end

	if shared.__redraw_hook then
		shared.__redraw_hook = vim.api.nvim_del_autocmd(shared.__redraw_hook);
	end

	vim.o.cmdheight = shared.__cmdheight;
end

shared.on_resize = function ()
	if not shared.window or not vim.api.nvim_win_is_valid(shared.window) then
		return;
	end

	vim.api.nvim_win_set_width(shared.window, vim.o.columns);
	vim.api.nvim_win_set_height(shared.window, vim.o.lines);
end

shared.set_cursor = function ()
	local width = vim.api.nvim_win_get_width(shared.window);
	local height = vim.api.nvim_win_get_height(shared.window);

	if shared.cursor[1] > height then
		shared.cursor[1] = height;
	end

	if shared.cursor[2] > width then
		shared.cursor[2] = width;
	end

	vim.api.nvim_win_set_cursor(shared.window, shared.cursor);
end

shared.create_win = function ()
	if not shared.buffer or not vim.api.nvim_buf_is_valid(shared.buffer) then
		shared.buffer = vim.api.nvim_create_buf(false, true);
	end

	shared.window = vim.api.nvim_open_win(shared.buffer, true, {
		relative = "editor",

		row = 0, col = 0,
		width = vim.o.columns, height = vim.o.lines,

		border = shared.configuration.border or "none",
		zindex = shared.configuration.zindex or 99
	});
	shared.on_open();
end

shared.hijack = function ()
	vim.api.nvim_set_current_buf(shared.buffer);

	shared.window = vim.api.nvim_get_current_win();
	shared.on_open();
end

return shared;
