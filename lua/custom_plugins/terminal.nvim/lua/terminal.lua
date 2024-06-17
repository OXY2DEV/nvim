---+ Icon: " " Title: "Introduction" BorderL: "" BorderR: ""
---
--- Animated cursor trail for Neovim.
---
---_

local terminal = {};

terminal.default_width = 60;
terminal.default_height = 10;

terminal.openedTerminals = {};

terminal.config = {
	window_style = "split",
	shell = "zsh",

	split_config = {
		split = "below",

		height = 20
	},
	float_config = {
		col = terminal.default_width < vim.o.columns and math.floor((vim.o.columns - terminal.default_width) / 2),
		row = terminal.default_height < vim.o.lines and math.floor((vim.o.lines - terminal.default_height) / 2),

		col_before = (math.floor((vim.o.columns - terminal.default_width) / 2) - 10) >= 0 and (math.floor((vim.o.columns - terminal.default_width) / 2) - 10) or 0,

		winblend = 100,
		border = "rounded",
		width = terminal.default_width, height = terminal.default_height
	},

	transition_type = "height",
	transition_ease = "ease-in-sine",
	transition_steps = 15, transition_step_delay = 25
};

terminal.create_split = function (buffer)
	if vim.bo[buffer].filetype == "termAnim" then
		return;
	end

	vim.fn.termopen(terminal.config.shell, {
		on_exit = function ()
			for i, buf in ipairs(terminal.openedTerminals) do
				if buf == buffer then
					table.remove(terminal.openedTerminals, i);
				end
			end

			if vim.bo.filetype ~= "termAnim" then
				return;
			end

			require("winanims").closeSplit(0, { height = 0 }, {
				type = terminal.config.transition_type,
				ease = terminal.config.transition_ease,

				steps = terminal.config.transition_steps,
				step_delay = terminal.config.transition_step_delay
			});
		end
	});

	vim.bo[buffer].filetype = "termAnim";
end

terminal.create_float = function (buffer)
	if vim.bo[buffer].filetype == "termAnim" then
		return;
	end

	vim.fn.termopen(terminal.config.shell, {
		on_exit = function ()
			for i, buf in ipairs(terminal.openedTerminals) do
				if buf == buffer then
					table.remove(terminal.openedTerminals, i);
				end
			end

			if vim.bo.filetype ~= "termAnim" then
				return;
			end

			require("winanims").closeFloat(0, { row = terminal.config.float_config.row + 10, winblend = 100 }, {
				type = terminal.config.transition_type,
				ease = terminal.config.transition_ease,

				steps = terminal.config.transition_steps,
				step_delay = terminal.config.transition_step_delay
			});
		end
	});

	vim.bo[buffer].filetype = "termAnim";
end

terminal.setup = function (user_config)
	terminal.config = vim.tbl_deep_extend("keep", user_config, terminal.config);

	vim.api.nvim_create_user_command("Terminal", function (arguments)
		local term_number = #arguments.fargs == 0 and 1 or tonumber(arguments.fargs[1]);

		local buffer;

		if #terminal.openedTerminals == 0 or terminal.openedTerminals[term_number] == nil then
			buffer = vim.api.nvim_create_buf(false, true);
			table.insert(terminal.openedTerminals, buffer);
		else
			buffer = terminal.openedTerminals[term_number];
		end

		if terminal.config.window_style == "split" then
			require("winanims").openSplit(buffer, terminal.config.split_config, {
				type = terminal.config.transition_type,
				ease = terminal.config.transition_ease,

				steps = terminal.config.transition_steps,
				step_delay = terminal.config.transition_step_delay,

				on_complete = function ()
					terminal.create_split(buffer);

					vim.wo.number = false;
					vim.wo.statuscolumn = " ";
					vim.wo.spell = false;
					vim.wo.statusline = "%#Normal#";
				end
			})
		elseif terminal.config.window_style == "float" then
			require("winanims").openFloat(buffer, terminal.config.float_config, {
				type = terminal.config.transition_type,
				ease = terminal.config.transition_ease,

				steps = terminal.config.transition_steps,
				step_delay = terminal.config.transition_step_delay,

				on_complete = function ()
					terminal.create_float(buffer);

					vim.wo.number = false;
					vim.wo.statuscolumn = "";
					vim.wo.spell = false;
					vim.wo.statusline = "%#Normal#";
				end
			})
		end
	end, {
		nargs = "?",
		desc = "Opens a new terminal"
	});
end

return terminal;
