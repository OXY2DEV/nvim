---@alias beacon.color
---| string
---| number
---| number[]
---| fun(): ( string | number | number[] )


---@class beacon.config
---
---@field from beacon.color
---@field to beacon.color
---
---@field steps integer
---@field interval integer


--- Creates a new beacon.
---@class beacon.instance
---
---@field ns integer Anonymous namespace.
---
---@field window integer Window where the beacon should be shown(default is current window).
---@field buffer integer Buffer being shown in window.
---
---@field pos [ integer, integer ] A position(default is cursor position).
---
---@field from_color beacon.color Start color
---@field to_color beacon.color
---@field steps integer
---@field interval integer
---
---@field colors string[]
---@field step integer
---@field timer table
---
---@field __index beacon.instance
---
---@field __gradient fun(self: beacon.instance): string[]
---@field __list_render fun(self: beacon.instance): nil
---@field __nolist_render fun(self: beacon.instance): nil
---
---@field new fun(self: beacon.instance, window?: integer, config?: beacon.config): beacon.instance
---@field render fun(self: beacon.instance): nil

-----------------------------------------------------------------------------

---@param str string
---@return integer
local function last_width (str)
	local chars = vim.fn.strchars(str);
	local reduced = vim.fn.strcharpart(str, 0, chars - 1);

	return vim.fn.strdisplaywidth(str) - vim.fn.strdisplaywidth(reduced);
end

local M = {};

M.config = {
	from = function ()
		local fg = vim.api.nvim_get_hl(0, { name = "Function", create = false, link = false }).fg;
		return fg or { 203, 166, 247 };
	end,
	to = function ()
		local bg = vim.api.nvim_get_hl(0, { name = "CursorLine", create = false, link = false }).bg;
		return bg or { 30, 30, 46 }
	end,

	steps = 10,
	interval = 100,
};

---@type beacon.instance
---@diagnostic disable-next-line: missing-fields
local beacon = {};
beacon.__index = beacon;

function beacon:__gradient ()
	---@param val beacon.color
	---@return integer[]
	local function eval (val)
		if type(val) == "string" then
			---@cast val string

			local R, G, B = string.match(val, "^#?(..?)(..?)(..?)$")
			return { tonumber(R, 16), tonumber(G, 16), tonumber(B, 16) };
		elseif type(val) == "number" then
			---@cast val number

			local hex = string.format("%x", val);
			hex = string.sub(hex, 0, 6);

			local R, G, B = string.match(hex, "^#?(..?)(..?)(..?)$")
			return { tonumber(R, 16), tonumber(G, 16), tonumber(B, 16) };
		elseif  vim.islist(val --[[ @as any ]]) == true and type(val[1]) == "number" then
			---@cast val number[]

			return val;
		elseif pcall(val --[[ @as any ]]) then
			---@cast val fun(): ( string | number | number[] )

			local _, _val = pcall(val);
			return type(_val) ~= "function" and eval(_val) or { 0, 0, 0 };
		end

		return { 0, 0, 0 };
	end

	---@param n number
	---@param y number
	---@return integer
	local function lerp (n, y)
		local from = eval(self.from_color)[n];
		local to = eval(self.to_color)[n];

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

function beacon:__list_render ()
	if vim.wo[self.window].list == false then
		return;
	end

	local Y, X = self.pos[1] - 1, self.pos[2];
	vim.api.nvim_buf_clear_namespace(self.buffer, self.ns, Y, Y + 1);

	local line = vim.api.nvim_buf_get_lines(self.buffer, Y, Y + 1, false)[1] or "";
	local before = vim.fn.strcharpart(line, 0, X);
	local after = vim.fn.strcharpart(line, X);

	local C = 1;
	local removed = "";

	---@type table[]
	local virt_eol = {};

	while C <= #self.colors do
		---@type string
		local first = vim.fn.strcharpart(after, 0, 1);
		removed = removed .. first;

		---@type integer
		local width = last_width(before .. removed);

		if after == "" then
			-- Nothing after cursor. Add virtual text.
			table.insert(virt_eol, { " ", self.colors[C] });
			C = C + 1;
		elseif width > 1 then
			-- Multi-width character. Add multiple single characters.

			---@type integer
			local col = vim.fn.strchars(before .. removed) - 1;
			local virt_text = {};

			while width >= 1 do
				table.insert(virt_text, { " ", self.colors[C] });

				C = C + 1;
				width = width - 1;
			end

			vim.api.nvim_buf_set_extmark(self.buffer, self.ns, Y, col, {
				virt_text_pos = "overlay",
				virt_text = virt_text,

				hl_mode = "combine"
			});
		else
			-- Normal text. Only highlight the text.

			---@type integer
			local col = vim.fn.strchars(before .. removed) - 1;

			vim.api.nvim_buf_set_extmark(self.buffer, self.ns, Y, col, {
				end_col = col + 1,
				hl_group = self.colors[C],
			});

			C = C + 1;
		end

		after = vim.fn.strcharpart(after, 1);
	end

	if #virt_eol > 0 then
		local col = vim.fn.strchars(line);

		vim.api.nvim_buf_set_extmark(self.buffer, self.ns, Y, col, {
			virt_text_pos = "inline",
			virt_text = virt_eol,
		})
	end
end

function beacon:__nolist_render ()
	if vim.wo[self.window].list == true then
		return;
	end

	local Y, X = self.pos[1] - 1, self.pos[2];
	vim.api.nvim_buf_clear_namespace(self.buffer, self.ns, Y, Y + 1);

	local line = vim.api.nvim_buf_get_lines(self.buffer, Y, Y + 1, false)[1] or "";
	local before = vim.fn.strcharpart(line, 0, X);
	local after = vim.fn.strcharpart(line, X);

	local C = 1;
	local removed = "";

	---@type table[]
	local virt_eol = {};

	while C <= #self.colors do
		---@type string
		local first = vim.fn.strcharpart(after, 0, 1);
		removed = removed .. first;

		---@type integer
		local width = last_width(before .. removed);

		if after == "" then
			-- Nothing after cursor. Add virtual text.
			table.insert(virt_eol, { " ", self.colors[C] });
			C = C + 1;
		elseif width > 1 then
			-- Multi-width character. Add multiple single characters.

			---@type integer
			local col = vim.fn.strchars(before .. removed) - 1;
			local virt_text = {};

			while width >= 1 do
				-- If this character is under the cursor.
				-- We add empty spaces to align it correctly as
				-- the cursor is shown at the end of this character.
				if X == col and width > 1 then
					table.insert(virt_text, { " " });
				else
					table.insert(virt_text, { " ", self.colors[C] });
					C = C + 1;
				end

				width = width - 1;
			end

			vim.api.nvim_buf_set_extmark(self.buffer, self.ns, Y, col, {
				virt_text_pos = "overlay",
				virt_text = virt_text,

				hl_mode = "combine"
			});
		else
			-- Normal text. Only highlight the text.

			---@type integer
			local col = vim.fn.strchars(before .. removed) - 1;

			vim.api.nvim_buf_set_extmark(self.buffer, self.ns, Y, col, {
				end_col = col + 1,
				hl_group = self.colors[C],
			});

			C = C + 1;
		end

		after = vim.fn.strcharpart(after, 1);
	end

	if #virt_eol > 0 then
		local col = vim.fn.strchars(line);

		vim.api.nvim_buf_set_extmark(self.buffer, self.ns, Y, col, {
			virt_text_pos = "inline",
			virt_text = virt_eol,
		})
	end
end

function beacon:render ()
	self:__list_render();
	self:__nolist_render();

	table.remove(self.colors, 1);
	self.step = self.step + 1;
end

function beacon:new (window, config)
	local _config = type(config) == "table" and config or M.config;

	self = setmetatable({}, beacon);
	self.ns = vim.api.nvim_create_namespace("");

	self.window = window or vim.api.nvim_get_current_win();
	self.buffer = vim.api.nvim_win_get_buf(self.window);

	self.pos = vim.api.nvim_win_get_cursor(self.window);

	self.from_color = _config.from;
	self.to_color = _config.to;

	self.interval = _config.interval;
	self.steps = _config.steps;
	self.step = 0;

	self.colors = self:__gradient();

	---@diagnostic disable-next-line: undefined-field
	self.timer = vim.uv.new_timer();

	self.timer:start(0, self.interval, vim.schedule_wrap(function ()
		if self.step > self.steps then
			self.timer:stop();
			return;
		end

		self:render();
	end));

	return self;
end

M.setup = function ()
	vim.api.nvim_set_keymap("n", "<leader><leader>", "", {
		callback = function ()
			beacon:new();
		end
	});
end

return M;
