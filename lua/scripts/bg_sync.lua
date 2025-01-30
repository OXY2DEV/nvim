--- Changes the background to match neovim's colorscheme
vim.api.nvim_create_autocmd({ "UIEnter", "Colorscheme" }, {
	callback = function ()
		local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg;

		if not bg then
			return;
		end

		pcall(io.write, string.format("\x1b]11;#%06x\x1b\\", bg));
	end
});

--- Reverts background color when leaving neovim
vim.api.nvim_create_autocmd({ "UILeave" }, {
	callback = function ()
		pcall(io.write, "\x1b]111\x1b\\");
	end
});

--- Command to manually update terminal's background
vim.api.nvim_create_user_command("BgSync", function ()
	local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg;

	if not bg then
		return;
	end

	pcall(io.write, string.format("\x1b]11;#%06x\x1b\\", bg));
end, {
	desc = "Syncs the terminal background"
});


--- Changes the cursor color to match the colorscheme
vim.api.nvim_create_autocmd({ "UIEnter", "Colorscheme", "CmdlineLeave" }, {
	callback = function ()
		local cursor = vim.api.nvim_get_hl(0, { name = "Cursor" });
		local cur_bg = cursor.bg or 1973806;

		pcall(io.write, string.format("\x1b]12;#%06x\x1b\\", cur_bg));
	end
});

--- Workaround to retain the cursor color when leaving
--- the cmdline
vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
	callback = function ()
		vim.defer_fn(function ()
			local cursor = vim.api.nvim_get_hl(0, { name = "Cursor" });
			local cur_bg = cursor.bg or 1973806;

			pcall(io.write, string.format("\x1b]12;#%06x\x1b\\", cur_bg));
		end, 50)
	end
});

--- Manually changes the color of the cursor
vim.api.nvim_create_user_command("CursorSync", function ()
	local cursor = vim.api.nvim_get_hl(0, { name = "Cursor" });
	local cur_bg = cursor.bg or 1973806;

	pcall(io.write, string.format("\x1b]12;#%06x\x1b\\", cur_bg));
end, {
	desc = "Syncs the terminal cursor color"
});

