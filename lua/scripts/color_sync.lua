--- Syncs terminals colors with the
--- colorscheme's color.
_G.terminal_color_sync = function ()
	---|fS

	local BG = vim.api.nvim_get_hl(0, { name = "Normal" }).bg or 1973806;
	local FG = vim.api.nvim_get_hl(0, { name = "Normal" }).fg or 13489908;

	if not BG or not FG then
		return;
	end

	if _G.is_within_termux() then
		pcall(io.write, string.format("\x1b]11;#%06x\x1b\\", BG));
		pcall(io.write, string.format("\x1b]10;#%06x\x1b\\", FG));
	end

	---|fE
end

--- Restores terminal's default colors.
_G.terminal_color_restore = function ()
	---|fS

	if _G.is_within_termux() then
		pcall(io.write, "\x1b]110\x1b\\");
		pcall(io.write, "\x1b]111\x1b\\");
	end

	---|fE
end

--- Changes the background to match neovim's colorscheme
vim.api.nvim_create_autocmd({ "UIEnter", "Colorscheme" }, {
	callback = function ()
		_G.terminal_color_sync();
	end
});

--- Reverts background color when leaving neovim
vim.api.nvim_create_autocmd({ "UILeave" }, {
	callback = function ()
		_G.terminal_color_restore();
	end
});

--- Setup a user command to sync/restore it.
vim.api.nvim_create_user_command("Color", function (cmd)
	local args = cmd.fargs;

	if #args == 0 then
		_G.terminal_color_sync();
	elseif args[1] == "sync" then
		_G.terminal_color_sync();
	elseif args[1] == "restore" then
		_G.terminal_color_restore();
	end
end, {
	desc = "Allows Syncing & Restoring terminal's color",
	nargs = "?",
	complete = function (arg_lead, cmdline)
		local args = vim.split(cmdline, " ", {});

		if #args > 2 or vim.list_contains({ "sync", "restore" }, args[2]) then
			return;
		end

		local _c = {};

		for _, sub_command in ipairs({ "sync", "restore" }) do
			if string.match(sub_command, arg_lead or "") then
				table.insert(_c, sub_command);
			end
		end

		return _c;
	end
})
