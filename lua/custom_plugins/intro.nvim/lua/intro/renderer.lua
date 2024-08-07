local renderer = {};
local shared = require("intro.shared");

renderer.namespace = vim.api.nvim_create_namespace("intro_ns");
renderer.height = 0;

renderer.get_len = function (line)
	if line.width then
		return line.width;
	end

	local text = line.value or "";

	if type(text) == "string" then
		return vim.fn.strchars(text);
	elseif vim.islist(text) then
		local _l = 0;

		for _, part in ipairs(text) do
			_l = _l + vim.fn.strchars(part[1]);
		end

		return _l;
	end

	return 0;
end

renderer.tbl_clamp = function (tbl, index, repeating)
	if type(tbl) ~= "table" then
		return tbl;
	end

	if not vim.tbl_isempty(tbl) and repeating == true and index > #tbl then
		-- Don't mess up when "repeating = n * #tbl"
		local new_index = index % #tbl == 0 and #tbl or index % #tbl;

		return tbl[new_index]
	else
		return tbl[index] or tbl[#tbl];
	end
end

renderer.transform_raw = function (config_table)
	if not config_table.text then
		return {
			align = "center",
			value = {},

			width = nil,
			hl_repeat = nil
		};
	end

	if vim.islist(config_table.text) then
		local _o = {};

		for index, part in ipairs(config_table.text) do
			if vim.islist(config_table.hl) and config_table.hl[index] then
				table.insert(_o, { part, renderer.tbl_clamp(config_table.hl, index) });
			elseif config_table.hl then
				table.insert(_o, { part, config_table.hl })
			else
				table.insert(_o, { part })
			end
		end

		return {
			align = config_table.align or "center",
			value = _o,

			width = config_table.width,
			hl_repeat = config_table.hl_repeat
		};
	end

	return {
		align = config_table.align or "center",
		value = { { config_table.text, config_table.hl } },

		width = config_table.width,
		hl_repeat = config_table.hl_repeat
	}
end

renderer.transform = function (config_table)
	local _t = {};

	for _, part in ipairs(config_table) do
		if part.type == "raw" then
			table.insert(_t, renderer.transform_raw(part));
		end
	end

	return _t;
end

renderer.init = function ()
	local conf = renderer.transform(shared.configuration.parts);

	if not shared.__redraw_hook then
		-- WinResized doesn't work with the buffer option
		shared.__redraw_hook = vim.api.nvim_create_autocmd({ "VimResized" }, {
			callback = function ()
				renderer.render(conf);
				shared.set_cursor();
			end
		});
	end

	renderer.render(conf);
end

renderer.draw_line = function (line, content)
	local _t = "";
	local hls = {};

	local len = renderer.get_len(content);
	local win_w = vim.api.nvim_win_get_width(shared.window);

	if content.align == "center" then
		_t = string.rep(" ", math.floor((win_w - len) / 2));
	end

	for _, part in ipairs(content.value or {}) do
		if type(part[2]) == "string" then
			local _b = #_t;
			local _a = #_t + #part[1];

			table.insert(hls, { _b, part[2], _a });
		elseif vim.islist(part[2]) then
			-- NOTE: strcharpart is 0-indexed
			for l = 0, vim.fn.strchars(part[1]) do
				local _b = #_t + #vim.fn.strcharpart(part[1], 0, l);
				local _a = _b + #vim.fn.strcharpart(part[1], l, l + 1);

				-- Lua lists are 1-indexed
				local grad_hl = renderer.tbl_clamp(part[2], l + 1, content.hl_repeat) or "Comment";

				vim.print(vim.fn.strcharpart(part[1], 0, l))
				table.insert(hls, { _b, grad_hl, _a })
			end
		end

		_t = _t .. part[1];
	end

	if content.align == "center" then
		_t = _t .. string.rep(" ", math.ceil((win_w - len) / 2));
	end

	vim.api.nvim_buf_set_lines(shared.buffer, line - 1, line, false, { _t });

	for _, hl in ipairs(hls) do
		vim.api.nvim_buf_add_highlight(shared.buffer, renderer.namespace, hl[2], line - 1, hl[1], hl[3]);
	end
end

renderer.update_line = function (buffer, window, line, content)
	local _t = "";
	local hls = {};

	local len = renderer.get_len(content);
	local win_w = vim.api.nvim_win_get_width(window);

	if content.align == "center" then
		_t = string.rep(" ", math.floor((win_w - len) / 2));
	end

	for _, part in ipairs(content.value or {}) do
		if type(part[2]) == "string" then
			local _b = #_t;
			local _a = #_t + #part[1];

			table.insert(hls, { _b, part[2], _a });
		elseif vim.islist(part[2]) then
			-- NOTE: strcharpart is 0-indexed
			for l = 0, vim.fn.strchars(part[1]) do
				local _b = #_t + #vim.fn.strcharpart(part[1], 0, l);
				local _a = _b + #vim.fn.strcharpart(part[1], l, l + 1);

				-- Lua lists are 1-indexed
				local grad_hl = renderer.tbl_clamp(part[2], l + 1, content.hl_repeat) or "Comment";

				vim.print(vim.fn.strcharpart(part[1], 0, l))
				table.insert(hls, { _b, grad_hl, _a })
			end
		end

		_t = _t .. part[1];
	end

	if content.align == "center" then
		_t = _t .. string.rep(" ", math.ceil((win_w - len) / 2));
	end

	vim.api.nvim_buf_set_lines(buffer, line, line + 1, false, { _t });

	for _, hl in ipairs(hls) do
		vim.api.nvim_buf_add_highlight(buffer, renderer.namespace, hl[2], line, hl[1], hl[3]);
	end
end

renderer.render = function (filtered_config)
	shared.line_count = #filtered_config;

	local win_h = vim.api.nvim_win_get_height(shared.window);
	local win_w = vim.api.nvim_win_get_width(shared.window);

	local wh_above = math.floor((win_h - shared.line_count) / 2);
	local wh_below = math.ceil((win_h - shared.line_count) / 2);

	vim.api.nvim_buf_set_lines(shared.buffer, 0, -1, false, {});

	if wh_above > 0 then
		for line = 1, wh_above do
			vim.api.nvim_buf_set_lines(shared.buffer,
				line - 1,
				line,
				false,
				{
					string.rep(" ", win_w)
				}
			);
		end
	end

	for l, part in ipairs(filtered_config) do
		renderer.draw_line((wh_above > 0 and wh_above or 0) + l, part);
	end

	if wh_below > 0 then
		for line = 1, wh_above do
			vim.api.nvim_buf_set_lines(shared.buffer,
				math.max(wh_above, 0) + #filtered_config + line - 1,
				math.max(wh_above, 0) + #filtered_config + line,
				false,
				{
					string.rep(" ", win_w)
				}
			);
		end
	end

end

return renderer;
