local scrolls = {};
local curanims = require("animations").cursor;


---+






---_



scrolls.vertical_to = function (window, to)
	local cursor = vim.api.nvim_win_get_cursor(window or 0);
	local buffer = vim.api.nvim_win_get_buf(window or 0);

	local scroll_lines = vim.api.nvim_buf_get_lines(buffer, cursor[1], cursor[1] + (to or 10), false);

	local terminal_lines = 0;
	local scroll_to = cursor[1];

	for lnum, _ in ipairs(scroll_lines) do
		if terminal_lines > to then
			break;
		end

		local extmarks = vim.api.nvim_buf_get_extmarks(buffer, -1, { cursor[1] + lnum, 0 }, { cursor[1] + lnum, -1 }, { type = "virt_lines" });
		local foldend = vim.fn.foldclosedend(lnum);

		terminal_lines = terminal_lines + 1 + #extmarks + (foldend ~= -1 and foldend or 0);
		scroll_to = scroll_to + 1;
	end

	curanims.to(window or 0, { scroll_to, cursor[2] })
end

scrolls.vertical_to(0, 20)

return scrolls;
