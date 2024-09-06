local indent = require("indent");
local indent_window = require("indent.window");

local unload_invalid_bufs = function (buffer)
	local cond = false;

	for b, buf in ipairs(indent.attached_buffer) do
		if vim.api.nvim_buf_is_valid(buf) == false then
			table.remove(indent.attached_buffer, b);

			if buf == buffer then
				cond = true;
			end

			goto continue;
		end

		local attached_win = indent_window.get_attached_win(buf);

		if not attached_win then
			table.remove(indent.attached_buffer, b);

			if buf == buffer then
				cond = true;
			end

			goto continue;
		end

		local ft = vim.bo[buf].filetype;
		local bt = vim.bo[buf].buftype;

		if vim.api.nvim_buf_is_valid(buf) == false then
			table.remove(indent.attached_buffer, b);

			if buf == buffer then
				cond = true;
			end
		elseif vim.list_contains(indent.config.exclude_filetypes, ft) then
			table.remove(indent.attached_buffer, b);

			if buf == buffer then
				cond = true;
			end
		elseif vim.list_contains(indent.config.exclude_buftypes, bt) then
			table.remove(indent.attached_buffer, b);

			if buf == buffer then
				cond = true;
			end
		end

		::continue::
	end

	return cond;
end

local redraw_all = function ()
	for _, buf in ipairs(indent.attached_buffer) do
		indent.clear(buf);
		indent.draw(buf);
	end
end

local addListener = function (buffer)
	if vim.api.nvim_buf_is_valid(buffer) == false then
		return;
	end

	local timer = vim.uv.new_timer();
	local win = indent_window.get_attached_win(buffer);

	local cursor = vim.api.nvim_win_get_cursor(win)

	local au = vim.api.nvim_create_autocmd({
		"CursorMoved", "CursorMovedI",
		"TextChanged", "TextChangedI"
	}, {
		buffer = buffer,
		callback = function ()
			if not vim.list_contains(indent.attached_buffer, buffer) or vim.api.nvim_buf_is_valid(buffer) == false then
				pcall(vim.api.nvim_del_autocmd, indent.attached_autocmds[buffer]);
				return;
			end

			timer:stop();

			local current = vim.api.nvim_win_get_cursor(win);
			local debounce = 0;

			if cursor[2] ~= current[2] then
				cursor = current;
				debounce = 0;
			end

			timer:start(debounce, 0, vim.schedule_wrap(function ()
				indent.clear(buffer);
				indent.draw(buffer);
			end));
		end
	});

	indent.attached_autocmds[buffer] = au;
end

local scanned_bufs = {};

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
	callback = function (event)
		if not vim.list_contains(scanned_bufs, event.buf) then
			table.insert(scanned_bufs, event.buf);
		end

		if vim.list_contains(indent.attached_buffer, event.buf) then
			local thisBuffer = unload_invalid_bufs(event.buf);

			if thisBuffer == true then
				indent.clear(event.buf);
				indent.render(event.buf);
			end
		else
			unload_invalid_bufs(event.buf);

			local ft = vim.bo[event.buf].filetype;
			local bt = vim.bo[event.buf].buftype;

			if vim.api.nvim_buf_is_valid(event.buf) == false then
				return;
			elseif vim.list_contains(indent.config.exclude_filetypes, ft) then
				return;
			elseif vim.list_contains(indent.config.exclude_buftypes, bt) then
				return;
			else
				table.insert(indent.attached_buffer, event.buf)
				addListener(event.buf);
			end
		end

		redraw_all();
	end
});
