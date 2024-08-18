local terminals = {};
local animations = require("animations");

local winanims = animations.window;

local get_attached_wins = function (buffer)
	local wins = vim.api.nvim_list_wins();
	local _w = {};

	for _, win in ipairs(wins) do
		if vim.api.nvim_win_get_buf(win) == buffer then
			table.insert(_w, win);
		end
	end

	return _w;
end

terminals.config = {
	shell = "zsh",

	prefered_method = "split",
	split_config = {
		direction = "below",
		height = 0.4
	}
}

terminals.active_terminals = {};
terminals.active_windows = {};
terminals.__cmdheight = 0;

terminals.set_defaults = function (window, buffer)
	vim.wo[window].number = false;
	vim.wo[window].relativenumber = false;

	terminals.__cmdheight = vim.o.cmdheight;

	vim.o.cmdheight = 0;
	vim.wo[window].statuscolumn = "";

	vim.wo[window].spell = false;
end

terminals.restore_options = function ()
	vim.o.cmdheight = 1;
end

terminals.set_keymaps = function (buffer)
	vim.api.nvim_buf_set_keymap(buffer, "c", "<leader><leader>", "<cmd>echo 'hi'<CR>", { silent = true })
end

terminals.close_terminal = function (terminal_window, terminal_buffer)
	winanims.to(terminal_window, {
		height = 1,
	}, {
		on_complete = function ()
			vim.api.nvim_win_close(terminal_window, true)
			vim.api.nvim_buf_delete(terminal_buffer, { force = true })

			for index, terminal in ipairs(terminals.active_terminals) do
				if terminal == terminal_buffer then
					table.remove(terminals.active_terminals, index)
				end
			end
		end
	})
end


terminals.configuration = {
	cmd = "zsh",

	open_from = {
		split = "below",
		height = 1
	},
	open_to = {
		height = 20
	},
	open_controls = {
		delay = 0,
		interval = 10,

		default = { "ease-in-circ", 20 },

		on_init = function (window)
			vim.wo[window].spell = false;
		end
	},

	close_to = {
		height = 1
	},
	close_controls = {
		delay = 0,
		interval = 10,

		default = { "ease-out-circ", 20 },

		on_complete = function (window)
			if window and vim.api.nvim_win_is_valid(window) then
				vim.api.nvim_win_close(window, true);
			end
		end
	},

	hide_to = {
		width = 1
	},
	hide_controls = {
		delay = 0,
		interval = 10,

		default = { "ease-out-circ", 20 },

		on_complete = function (window)
			if window and vim.api.nvim_win_is_valid(window) then
				vim.api.nvim_win_close(window, true);
			end
		end
	}
};

terminals.presets = {
	above = {
		cmd = "zsh",

		open_from = {
			split = "above",
			height = 1
		},
		open_to = {
			height = 20
		},
		open_controls = {
			delay = 0,
			interval = 10,

			default = { "ease-in-circ", 20 },

			on_init = function (window)
				vim.wo[window].spell = false;
			end
		},

		close_to = {
			height = 1
		},
		close_controls = {
			delay = 0,
			interval = 10,

			default = { "ease-out-circ", 20 },

			on_complete = function (window)
				if window and vim.api.nvim_win_is_valid(window) then
					vim.api.nvim_win_close(window, true);
				end
			end
		}
	},
	float = {
		cmd = "zsh",

		open_from = {
			relative = "editor",
			row = 2,
			col = 2,

			width = 1,
			height = vim.o.lines - 6,

			border = "rounded",
		},
		open_to = {
			width = vim.o.columns - 6
		},
		open_controls = {
			delay = 0,
			interval = 7,

			default = { "ease-in-circ", 20 },

			not_framee = { "border" },

			on_init = function (window)
				vim.wo[window].spell = false;
			end
		},

		close_to = {
			width = 1
		},
		close_controls = {
			delay = 0,
			interval = 7,

			default = { "ease-out-circ", 20 },

			not_frames = { "border" },

			on_complete = function (window)
				if window and vim.api.nvim_win_is_valid(window) then
					vim.api.nvim_win_close(window, true);
				end
			end
		}
	},
}

terminals.active = {};

terminals.init = function (buffer, config)
	vim.api.nvim_buf_call(buffer, function ()
		if vim.bo.buftype ~= "terminal" then
			vim.fn.termopen(config.cmd or terminals.configuration.shell, {
				on_exit = function ()
					terminals.close(buffer, config);
				end
			});

			vim.api.nvim_buf_set_keymap(buffer, "n", "q", "", {
				callback = function ()
					winanims.to(vim.api.nvim_get_current_win(), config.close_to, config.close_controls)
				end
			});
		end

		vim.api.nvim_feedkeys("i", "n", true);
	end);
end

terminals.open = function (id, config)
	local buf;

	if not config then
		config = terminals.configuration;
	end

	if id and type(id) == "number" then
		if terminals.active[id] and vim.api.nvim_buf_is_valid(terminals.active[id]) then
			buf = terminals.active[id];
		else
			buf = vim.api.nvim_create_buf(false, true);
			config.open_controls = vim.tbl_deep_extend("force", config.open_controls, {
				__pcall_complete = false,

				on_complete = function ()
					terminals.init(buf, config)
				end
			})

			terminals.active[id] = buf;
		end
	elseif vim.tbl_isempty(terminals.active) then
		buf = vim.api.nvim_create_buf(false, true);
		config.open_controls = vim.tbl_deep_extend("force", config.open_controls, {
			__pcall_complete = false,

			on_complete = function ()
				terminals.init(buf, config)
			end
		})

		table.insert(terminals.active, buf);
	else
		buf = terminals.active[#terminals.active];
		config.open_controls = vim.tbl_deep_extend("force", config.open_controls, {
			__pcall_complete = false,

			on_complete = function ()
				terminals.init(buf, config)
			end
		})

		table.insert(terminals.active, buf);
	end

	local wins = get_attached_wins(buf)

	if vim.tbl_isempty(wins) and config and config.open_from and config.open_to and config.open_controls then
		winanims.fromTo(buf, true, config.open_from, config.open_to, config.open_controls)
	end
end

terminals.close = function (buffer, config)
	local wins = get_attached_wins(buffer)

	for _, win in ipairs(wins) do
		winanims.to(win, config.close_to, config.close_controls)
	end

	for index, buf in ipairs(terminals.active) do
		if buf == buffer then
			table.remove(terminals.active, index);
		end
	end
end


terminals.create_commands = function ()
	vim.api.nvim_create_user_command("Terminal", function (opts)
		local fargs = opts.fargs;

		if #fargs < 1 then
			terminals.open();
		elseif #fargs == 1 and tonumber(fargs[1]) then
			terminals.open(tonumber(fargs[1]));
		elseif #fargs == 1 and not tonumber(fargs[1]) then
			terminals.open(nil, terminals.presets[fargs[1]])
		elseif #fargs == 2 and tonumber(fargs[1]) and not tonumber(fargs[2]) then
			terminals.open(tonumber(fargs[1]), terminals.presets[fargs[2]])
		end
	end, {
		desc = "Animated terminals for neovim",
		nargs = "*"
	})
end

return terminals;
