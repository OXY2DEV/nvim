-- Disable the virtual texts
vim.diagnostic.config({ virtual_text = false });

local diagnostics = {};

local get_len = function (list)
	local len = 0;

	for _, part in ipairs(list) do
		len = len + vim.fn.strchars(part[1]);
	end

	return len;
end

local out_of_bounds = function ()
	local current_win = vim.api.nvim_get_current_win();

	local X = vim.api.nvim_win_get_cursor(current_win)[2];
	local textoff = vim.fn.getwininfo(current_win)[1].textoff;
	local width = vim.api.nvim_win_get_width(current_win);

	if X >= ((width - textoff) - (diagnostics.max_len)) then
		return true
	end

	return false;
end

diagnostics.enable = true;

diagnostics.virt_ns = vim.api.nvim_create_namespace("fancy")
diagnostics.buffer = vim.api.nvim_create_buf(false, true);
diagnostics.window = nil;

diagnostics.max_len = 0;

diagnostics.config = {
	parts = {
		border = "│  ",
		item = "├─ ",
		bottom = "╰─ ",

		item_inv = " ─┤",
		bottom_inv = " ─╯"
	},
	parts_hl = {
		border = "Comment",
		item = "Comment",
		bottom = "Comment",

		item_inv = "Comment",
		bottom_inv = "Comment"
	},

	severity = {
		warn = " ",
		error = " ",
		info = " ",
		hint = "󰔨 "
	},
	severity_hl = {
		warn = "DiagnosticWarn",
		error = "DiagnosticError",
		info = "DiagnosticInfo",
		hint = "DiagnosticSignHint"
	}
}

diagnostics.text_cut = function (tolarance, text)
	if tolarance > 0 and tolarance < vim.fn.strchars(text) then
		return string.sub(text, 1, tolarance), string.sub(text, tolarance, -1);
	else
		return text;
	end
end

diagnostics.get_sign = function (lvl)
	local severity = vim.diagnostic.severity;

	if lvl == severity.WARN then
		return diagnostics.config.severity.warn or "";
	elseif lvl == severity.ERROR then
		return diagnostics.config.severity.error or "";
	elseif lvl == severity.INFO then
		return diagnostics.config.severity.info or "";
	elseif lvl == severity.HINT then
		return diagnostics.config.severity.hint or "";
	end
end

diagnostics.get_sign_hl = function (lvl)
	local severity = vim.diagnostic.severity;

	if lvl == severity.WARN then
		return diagnostics.config.severity_hl.warn or "";
	elseif lvl == severity.ERROR then
		return diagnostics.config.severity_hl.error or "";
	elseif lvl == severity.INFO then
		return diagnostics.config.severity_hl.info or "";
	elseif lvl == severity.HINT then
		return diagnostics.config.severity_hl.hint or "";
	end
end

diagnostics.create_diagnostics = function (data)
	for l, d in ipairs(data) do
		if out_of_bounds() then
			table.remove(d.extmarks, 1);
			table.insert(d.extmarks, { l == #data and diagnostics.config.parts.bottom_inv or diagnostics.config.parts.item_inv, last and diagnostics.config.parts_hl.bottom_inv or diagnostics.config.parts_hl.item_inv })
			local new_len = get_len(d.extmarks);

			table.insert(d.extmarks, 1, { string.rep(" ", diagnostics.max_len - new_len) })
		end

		vim.api.nvim_buf_set_lines(diagnostics.buffer, l - 1, l, false, { "H" });

		vim.api.nvim_buf_set_extmark(diagnostics.buffer, diagnostics.virt_ns, l - 1, 0, {
			virt_text_pos = "overlay",
			virt_text = d.extmarks
		})
	end
end

diagnostics.render = function (data)
	vim.api.nvim_buf_clear_namespace(vim.api.nvim_get_current_buf(), diagnostics.virt_ns, 0, -1);

	vim.bo[diagnostics.buffer].buftype = "nofile";

	diagnostics.window = vim.api.nvim_open_win(diagnostics.buffer, false, {
		relative = "cursor",

		anchor = out_of_bounds() and "NE" or "NW",
		row = 1, col = out_of_bounds() and 1 or 0,
		width = diagnostics.max_len, height = #data
	});

	vim.wo[diagnostics.window].number = false;
	vim.wo[diagnostics.window].relativenumber = false;
	vim.wo[diagnostics.window].cursorline = false;

	vim.wo[diagnostics.window].statuscolumn = "";

	diagnostics.create_diagnostics(data);
end

diagnostics.clear = function ()
	if diagnostics.window and vim.api.nvim_win_is_valid(diagnostics.window) then
		vim.bo[diagnostics.buffer].modifiable = true;
		vim.api.nvim_buf_set_lines(diagnostics.buffer, 0, -1, false, {});
		vim.api.nvim_win_close(diagnostics.window, true);
	end
end

diagnostics.wrap = function (text, severity, last, is_in_range)
	local _o = {
		{ last and diagnostics.config.parts.bottom or diagnostics.config.parts.item, last and diagnostics.config.parts_hl.bottom or diagnostics.config.parts_hl.item },
		{ diagnostics.get_sign(severity), diagnostics.get_sign_hl(severity) },
		{ text, is_in_range == true and "@character" or "@punctuation.bracket" }
	};

	if diagnostics.max_len < get_len(_o) then
		diagnostics.max_len = get_len(_o);
	end

	return _o;
end

diagnostics.get_diagnostics = function ()
	if diagnostics.enable == false then
		diagnostics.clear();
		return;
	end

	local cursor = vim.api.nvim_win_get_cursor(0);
	local data = vim.diagnostic.get(vim.api.nvim_get_current_buf(), { lnum = cursor[1] - 1 });
	local available = {};

	diagnostics.max_len = 0;

	for index, d in ipairs(data) do
		if cursor[2] >= d.col and cursor[2] <= d.end_col then
			local _o = diagnostics.wrap(d.message, d.severity, index == #data, true);

			table.insert(available, {
				within_range = true,

				extmarks = _o,
				severity = d.severity
			})
		else
			local _o = diagnostics.wrap(d.message, d.severity, index == #data, false);

			table.insert(available, {
				within_range = false,

				extmarks = _o,
				severity = d.severity
			})
		end
	end

	diagnostics.clear();

	if not vim.tbl_isempty(available) then
		diagnostics.render(available);
	end
end

-- vim.api.nvim_create_autocmd({ "LspRequest" }, {
-- 	callback = function ()
-- 		diagnostics.get_diagnostics()
-- 	end
-- })

vim.api.nvim_create_autocmd({ "CursorMoved", "ModeChanged", "LspRequest" }, {
	callback = function ()
		if vim.api.nvim_get_mode().mode == "n" then
			diagnostics.get_diagnostics()
		else
			diagnostics.clear();
		end
	end
})


vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = "󰔨 ",
		}
	}
});

return diagnostics
