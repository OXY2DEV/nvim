local window = {};

window.get_attached_win = function (buffer)
	local win = vim.api.nvim_get_current_win();

	vim.api.nvim_buf_call(buffer, function ()
		win = vim.api.nvim_get_current_win();
	end);

	return win;
end

window.get_safe_region = function (win)
	if vim.api.nvim_win_is_valid(win) == false then
		win = vim.api.nvim_get_current_win();
	end

	local view = vim.api.nvim_win_call(win, vim.fn.winsaveview);
	local width = vim.api.nvim_win_get_width(win);

	local l_start, l_stop;

	vim.api.nvim_win_call(win, function ()
		l_start = vim.fn.line("w0");
		l_stop = vim.fn.line("w$");
	end)

	return {
		line_start = l_start,
		line_end = l_stop,

		col_start = view.leftcol,
		col_end = view.leftcol + width
	}
end

window.get_cursor_pos = function (buffer)
	local win = window.get_attached_win(buffer);

	if not win then
		return { 0, 0 };
	end

	return vim.api.nvim_win_get_cursor(win);
end

window.get_render_range = function (pos, buffer)
	return clamp(pos[1] - 50, 0, vim.api.nvim_buf_line_count(buffer)),
		   clamp(pos[1] + 50, 0, vim.api.nvim_buf_line_count(buffer))
	;
end

window.ns = vim.api.nvim_create_namespace("indent");

window.render = function (parsed_content, buffer, start)
	for l, line in ipairs(parsed_content) do
		for _, item in ipairs(line) do
			vim.api.nvim_buf_set_extmark(buffer, window.ns, (start or 0) + l - 1, 0, {
				virt_text_win_col = item.position,
				virt_text = { { "H" } }
			});
		end
	end
end

return window;
