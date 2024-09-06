local indent = {};
local window = require("indent.window");
local parser = require("indent.parser");

indent.attached_buffer = {};
indent.attached_autocmds = {};

local clamp = function (value, min, max)
	return math.max(math.min(value, max), min);
end

local tbl_clamp = function (from, index)
	if not vim.islist(from) then
		return from;
	end

	return from[index] or from[#from];
end

local within_range = function (lnum, min, max)
	if lnum >= min and lnum <= max then
		return true;
	end

	return false;
end

indent.config = {
	exclude_buftypes = { "help", "nofile" },
	exclude_filetypes = {
		"",
		"Intro", "Telescope", "TelescopePrompt",
		"markdown"
	},

	virt_texts = {
		{ "▏", "BarsStatuscolumnFold1Marker" },
		{ "▏", "BarsStatuscolumnFold2Marker" },
		{ "▏", "BarsStatuscolumnFold3Marker" },
		{ "▏", "BarsStatuscolumnFold4Marker" },
		{ "▏", "BarsStatuscolumnFold5Marker" },
		{ "▏", "BarsStatuscolumnFold6Marker" },
	},
	current_scope = {
		{ "▏", "BarsStatuscolumnFold1" },
		{ "▏", "BarsStatuscolumnFold2" },
		{ "▏", "BarsStatuscolumnFold3" },
		{ "▏", "BarsStatuscolumnFold4" },
		{ "▏", "BarsStatuscolumnFold5" },
		{ "▏", "BarsStatuscolumnFold6" },
	}
};

indent.ns = vim.api.nvim_create_namespace("indent");

indent.scope_indent = function (buffer, node)
	if not node then
		return;
	end

	local r_start, _, r_stop, _ = node:range();

	local start = vim.api.nvim_buf_get_lines(buffer, r_start, r_start + 1, false)[1];
	local stop = vim.api.nvim_buf_get_lines(buffer, r_stop, r_stop + 1, false)[1];

	local indent_start, indent_stop = start:match("^(%s+)"), stop:match("^(%s+)");

	if indent_start and indent_stop then
		local i, j = parser.process_indent(buffer, indent_start), parser.process_indent(buffer, indent_stop);

		return math.min(#i, #j) + 1, r_start, r_stop;
	elseif indent_start then
		return #parser.process_indent(buffer, start), r_start, r_stop;
	elseif indent_stop then
		return #parser.process_indent(buffer, stop), r_start, r_stop;
	else
		return 1, r_start, r_stop;
	end
end

indent.clear = function (buffer)
	vim.api.nvim_buf_clear_namespace(buffer, indent.ns, 0, -1);
end

indent.draw = function (buffer)
	local win = window.get_attached_win(buffer);

	if vim.api.nvim_win_is_valid(win) == false then
		return;
	end

	local pos = vim.api.nvim_win_get_cursor(win);
	local safe_range = window.get_safe_region(win);

	local lines = vim.api.nvim_buf_line_count(buffer);
	local cursor = window.get_cursor_pos(buffer);

	local start, stop = clamp(cursor[1] - 50, 0, lines),
						clamp(cursor[1] + 50, 0, lines)
	;

	local scope = parser.get_scope(buffer, { pos[1] - 1, pos[2] });
	local scope_level, scope_start, scope_end;

	if scope then
		scope_level, scope_start, scope_end = indent.scope_indent(buffer, scope)
	end

	local parsed_content = parser.parse(buffer, start, stop);

	vim.api.nvim_buf_clear_namespace(buffer, indent.ns, 0, -1);

	for l, content in ipairs(parsed_content) do
		for i, item in ipairs(content) do
			if item.position < safe_range.col_start then
				goto ignore;
			end

			local chunk = tbl_clamp(indent.config.virt_texts, i)

			if scope_level and
			   within_range(start + l - 1, scope_start, scope_end) and
			   (i == scope_level)
			then
				chunk = tbl_clamp(indent.config.current_scope, i)
			end

			vim.api.nvim_buf_set_extmark(buffer, indent.ns, start + l - 1, 0, {
				virt_text_win_col = item.position - safe_range.col_start,
				virt_text = {
					chunk
				},

				hl_mode = "combine"
			});

			::ignore::
		end
	end
end

indent.timer = vim.uv.new_timer();

indent.setup = function ()
	-- vim.api.nvim_create_autocmd({
	-- 	"CursorMoved",
	-- 	"CursorMovedI",
	-- 	"TextChanged",
	-- 	"TextChangedI",
	-- 	"CompleteChanged"
	-- }, {
	-- 	pattern = "*",
	-- 	callback = function (event)
	-- 		indent.timer:stop();
	-- 		indent.timer:start(20, 0, vim.schedule_wrap(function ()
	-- 			if not vim.list_contains(indent.attached_buffer, event.buf) then
	-- 				return;
	-- 			end
	--
	-- 			if 1 < 2 then
	-- 				indent.clear(event.buf);
	-- 				indent.draw(event.buf)
	-- 			else
	-- 				for _, buf in ipairs(indent.attached_buffer) do
	-- 					indent.draw(buf);
	-- 				end
	-- 			end
	-- 		end))
	-- 	end
	-- })
end

return indent;
