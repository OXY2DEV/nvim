vim.api.nvim_create_autocmd({ "UIEnter", "Colorscheme" }, {
	callback = function ()
		local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg;

		if not bg then
			return;
		end

		io.write(string.format("\x1b]11;#%06x\x1b\\", bg));
	end
});

vim.api.nvim_create_autocmd({ "UILeave" }, {
	callback = function ()
		io.write("\x1b]111\x1b\\");
	end
});

vim.api.nvim_create_user_command("BgSync", function ()
	local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg;

	if not bg then
		return;
	end

	io.write(string.format("\x1b]11;#%06x\x1b\\", bg));
end, {
	desc = "Syncs the terminal background"
});


