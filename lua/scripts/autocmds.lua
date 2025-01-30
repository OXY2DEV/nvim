vim.api.nvim_create_autocmd({ "ModeChanged" }, {
	callback = function (event)
		local bars_available = pcall(require, "bars");

		if bars_available == false then
			return;
		end

		pcall(vim.api.nvim__redraw, {
			buf = event.buf,
			flush = true,

			statuscolumn = true,
			statusline = true
		});
	end
});
