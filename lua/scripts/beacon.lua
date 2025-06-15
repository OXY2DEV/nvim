local M = {};

M.config = {
	from = { 203, 166, 247 },
	to = { 30, 30, 46 },

	steps = 10,
	interval = 100,
};

local beacon = {};
beacon.__index = beacon;

function beacon:__gradient ()
	local function lerp (n, y)
		local from = self.from_color[n];
		local to = self.to_color[n];

		return math.floor(from + ((to - from) * y));
	end

	local gradient = {};
	local corrected_steps = self.steps - 1;

	for s = 0, corrected_steps do
		local multiplier = s / corrected_steps;
		local name = string.format("Beacon%dStep%d", self.ns, s);

		local color = string.format(
			"#%02x%02x%02x",
			lerp(1, multiplier),
			lerp(2, multiplier),
			lerp(3, multiplier)
		);

		table.insert(gradient, name);
		vim.api.nvim_set_hl(0, name, { bg = color });
	end

	return gradient;
end

function beacon:render ()
	local Y, X = self.pos[1] - 1, self.pos[2];
	vim.api.nvim_buf_clear_namespace(self.buffer, self.ns, Y, Y + 1);

	local _line = vim.api.nvim_buf_get_lines(self.buffer, Y, Y + 1, false)[1] or "";
	local eol = {};

	local color_index = 1;

	local tmp = _line:sub(X, #_line);
	local col, line;

	if vim.wo[self.window].list ~= true then
		col = X + 1;
		line = vim.fn.strcharpart(tmp, 1);
	else
		col = X;
		line = vim.fn.strcharpart(tmp, X == 0 and 0 or 1);
	end

	while color_index <= #self.colors do
		local color = self.colors[color_index];
		local char = vim.fn.strcharpart(line, 0, 1);

		local W = vim.fn.strdisplaywidth(char);

		if col >= vim.fn.strchars(_line) or _line == "" then
			table.insert(eol, { " ", color });
			color_index = color_index + 1;
		elseif W > 1 then
			local virt = {};

			if vim.wo[self.window].list == false then
				local fake = { { " ", color } };

				for _ = 1, W - 1 do
					table.insert(fake, 1, { " " })
				end

				vim.api.nvim_buf_set_extmark(self.buffer, self.ns, Y, col - 1, {
					virt_text_pos = "overlay",
					virt_text = fake,
				});

				color_index = color_index + 1;
				color = self.colors[color_index];
			end

			while color and W > 0 do
				table.insert(virt, { " ", color });

				W = W - 1;
				color_index = color_index + 1;
				color = self.colors[color_index];
			end

			vim.api.nvim_buf_set_extmark(self.buffer, self.ns, Y, col, {
				virt_text_pos = "overlay",
				virt_text = virt,
			});

			col = col + 1;
			line = vim.fn.strcharpart(line, 1);
		else
			vim.api.nvim_buf_set_extmark(self.buffer, self.ns, Y, col, {
				end_col = col + 1,

				hl_group = color,
				hl_mode = "combine"
			});

			color_index = color_index + 1;
			col = col + 1;

			line = vim.fn.strcharpart(line, 1);
		end
	end

	if #eol > 0 then
		vim.api.nvim_buf_set_extmark(self.buffer, self.ns, Y, #_line, {
			virt_text_pos = "inline",
			virt_text = eol,
		});
	end

	table.remove(self.colors, 1);
	self.step = self.step + 1;
end

function beacon:new (window, from, to, interval, steps)
	self = setmetatable({}, beacon);
	self.ns = vim.api.nvim_create_namespace("");

	self.window = window or vim.api.nvim_get_current_win();
	self.buffer = vim.api.nvim_win_get_buf(self.window);

	self.pos = vim.api.nvim_win_get_cursor(self.window);

	self.from_color = from or M.config.from;
	self.to_color = to or M.config.to;

	self.interval = interval or M.config.interval;
	self.steps = steps or M.config.steps;
	self.step = 0;

	self.colors = self:__gradient();
	self.timer = vim.uv.new_timer();

	self.timer:start(0, self.interval, vim.schedule_wrap(function ()
		if self.step > self.steps then
			self.timer:stop();
			return;
		end

		self:render();
	end));
end

M.setup = function ()
	vim.api.nvim_set_keymap("n", "<leader><leader>", "", {
		callback = function ()
			beacon:new();
		end
	});
end

return M;
