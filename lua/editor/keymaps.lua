--- Use space for all keymaps.
vim.g.mapleader = " ";
vim.o.timeoutlen = 500;

--- Fancy notification helper.
---@param level integer?
---@param msg string
local function keymap_alert(level, msg)
	level = level or 1;
	local hls = {
		"DiagnosticVirtualTextOk",
		"DiagnosticVirtualTextWarn",
		"DiagnosticVirtualTextError",
		"DiagnosticVirtualTextHint",
		"DiagnosticVirtualTextInfo"
	};

	vim.api.nvim_echo({
		{ "  keymaps.lua ", hls[level] },
		{ ": ", "@comment" },
		{ msg, "@comment" }
	}, true, {});
end

---|fS "feat: Writing & Quitting"

vim.api.nvim_set_keymap("n", "<leader>q", "<CMD>q<CR>", {
	desc = "[q]uit Neovim."
});

vim.api.nvim_set_keymap("n", "<leader>x", "<CMD>qa<CR>", {
	desc = "E[x]it all."
});

vim.api.nvim_set_keymap("n", "<leader>w", "<CMD>w<CR>", {
	desc = "[w]rite changes."
});

vim.api.nvim_set_keymap("n", "<leader>wq", "<CMD>wq<CR>", {
	desc = "[w]rite & [q]uit Neovim."
});

---|fE

---|fS "refactor: Undo & Redo"

vim.api.nvim_set_keymap("n", "<leader>u", "<CMD>undo<CR>", {
	desc = "[u]ndo changes"
});

vim.api.nvim_set_keymap("n", "<leader>r", "<CMD>redo<CR>", {
	desc = "[r]edo changes"
});

---|fE

---|fS "feat: Tab movement"

vim.api.nvim_set_keymap("n", "<leader>m", "<CMD>tabnext<CR>", {
	desc = "Go to next Tab."
});

vim.api.nvim_set_keymap("n", "<leader>z", "<CMD>tabprevious<CR>", {
	desc = "Go to previous Tab."
});

---|fE

---|fS "refactor: Lua related"

vim.api.nvim_set_keymap("n", "<leader>l", "", {
	desc = "Run [l]ua",
	callback = function ()
		local buffer = vim.api.nvim_get_current_buf();
		local ft = vim.bo[buffer].filetype;

		if ft ~= "lua" then
			keymap_alert(4, "Not a Lua file!");
			return;
		end

		local line = "";

		vim.api.nvim_buf_call(buffer, function ()
			line = vim.fn.getline(".");
		end);

		if line:match("^%s*$") then
			vim.cmd("luafile %");
		else
			vim.cmd(".lua");
		end
	end
});



---|fS "feat: Completion"

--- Completion function.
local function complete ()
	---|fS

	---@type integer
	local buffer = vim.api.nvim_get_current_buf();
	---@type integer
	local win = vim.fn.win_findbuf(buffer)[1];

	if not win then
		return;
	end

	---@type [ integer, integer ]
	local cursor = vim.api.nvim_win_get_cursor(win);
	--- Cursor position is 1-indexed.
	--- We need the 0-indexed result.
	cursor[1] = cursor[1] - 1;

	---@type string Text before the cursor.
	local text = vim.api.nvim_buf_get_text(buffer, cursor[1], 0, cursor[1], cursor[2], {})[1];

	if text == "" or text:match("%s$") then
		--- If the line is empty or there are
		--- only spaces/tabs before the cursor,
		--- we just add a new tab.
		---
		--- We also update the cursor position.
		vim.api.nvim_buf_set_text(buffer, cursor[1], cursor[2], cursor[1], cursor[2], { "	" });
		vim.api.nvim_win_set_cursor(win, { cursor[1] + 1, cursor[2] + #("	") });
	else
		--- Otherwise, trigger completion.
		local keys = vim.api.nvim_replace_termcodes(vim.bo[buffer].omnifunc ~= "" and "<C-x><C-o>" or "<C-n>", true, true, true);
		vim.api.nvim_feedkeys(keys, "i", true);
	end

	---|fE
end

vim.api.nvim_set_keymap("i", "<Tab>", "", {
	desc = "Simple completion",
	callback = function ()
		local success, _ = pcall(complete);

		if success == false then
			--- Fallback stuff in case main function fails.

			---@type integer
			local win = vim.api.nvim_get_current_win();

			---@type integer
			local buffer = vim.api.nvim_get_current_buf();

			---@type [ integer, integer ]
			local cursor = vim.api.nvim_win_get_cursor(win);
			cursor[1] = cursor[1] - 1;

			vim.api.nvim_buf_set_text(buffer, cursor[1], cursor[2], cursor[1], cursor[2], { "	" });
			vim.api.nvim_win_set_cursor(win, { cursor[1] + 1, cursor[2] + #("	") });
		end
	end
});

---|fE

---|fS "refactor: Overwrites"

vim.api.nvim_set_keymap("n", "u", "<nop>", {
	desc = "Disable default [u]ndo"
});

vim.api.nvim_set_keymap("v", "u", "<nop>", {
	desc = "Disable [u] to prevent mistakes"
});

---|fE

