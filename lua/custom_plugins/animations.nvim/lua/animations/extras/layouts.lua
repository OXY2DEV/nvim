local layouts = {};
local winanims = require("animations").window;

layouts.get_layouts = function (tabpage)
	local _w = {};
	local _f = {};
	local _s = {};

	local wins = vim.api.nvim_tabpage_list_wins(tabpage or 0);

	for _, win in ipairs(wins) do
		table.insert(_w, win);

		local conf = vim.api.nvim_win_get_config(win);

		_f[win] = {
			relative = conf.relative ~= "" and conf.relative or nil,
			split = conf.split,

			row = conf.row or 0,
			col = conf.col or 0,

			width = conf.width or 0,
			height = conf.height or 0,
		};

		if conf.split then
			if conf.split == "below" then
				table.insert(_s, { win });
			elseif conf.split == "above" then
				table.insert(_s, 1, { win });
			elseif conf.split == "left" then
				if #_s == 0 then
					_s = { {} }
				elseif not _s[#_s] then
					_s[#_s] = {};
				end

				table.insert(_s[#_s], 1, win);
			elseif conf.split == "right" then
				if #_s == 0 then
					_s = { {} }
				elseif not _s[#_s] then
					_s[#_s] = {};
				end

				table.insert(_s[#_s], win);
			end
		end
	end

	return _w, _f, _s;
end

layouts.get_gridcell_size = function (grid, row, col)
	local rows_in_col = 0;
	local cols_in_row = #grid[row];

	for _, grid_row in ipairs(grid) do
		if grid_row[col] then
			rows_in_col = rows_in_col + 1;
		end
	end

	return math.floor(vim.o.lines / (rows_in_col > 0 and rows_in_col or 1)), math.floor(vim.o.columns / (cols_in_row > 0 and cols_in_row or 1));
end

layouts.equalize = function (tabpage)
	local windows, configs, structure = layouts.get_layouts();

	for row, columns in ipairs(structure) do
		for col, column in ipairs(columns) do
			local height, width = layouts.get_gridcell_size(structure, row, col);

			winanims.to(column, { width = width, height = height }, { interval = 7, default = { "ease-in-quad", 10 } })
		end
	end
end

layouts.layout_buffer = vim.api.nvim_create_buf(false, true);

layouts.show_wininfo = function ()
	local window = winanims.fromTo(layouts.layout_buffer, true, {
		relative = "editor",

		row = math.floor((vim.o.lines - 1.5) / 2),
		col = math.floor((vim.o.columns - 1.5) / 2),

		width = 1,
		height = 1,

		border = "rounded"
	}, {
		relative = "editor",

		row = math.floor((vim.o.lines - 10) / 2),
		col = math.floor((vim.o.columns - 50) / 2),

		width = 50,
		height = 10,
	});
end

return layouts;
