local intro = {};
local shared = require("intro.shared");
intro.renderer = require("intro.renderer");

intro.detach = function (window)
	if not window or not vim.api.nvim_win_is_valid(window) then
		return;
	end

	vim.api.nvim_win_close(window, true);
end

intro.setup = function ()
	vim.api.nvim_create_user_command("Intro", function ()
		if shared.window and vim.api.nvim_win_is_valid(shared.window) then
			return;
		end

		shared.create_win();
		intro.renderer.init();
	end, {});

	vim.api.nvim_create_autocmd({ "VimEnter" }, {
		once = true,
		callback = function (event)
			local buffer = event.buf;

			---+ This part doesn't quite work yet ##code##

			-- Incorrect filetype
			if vim.list_contains(shared.configuration.disabled_filetypes, vim.bo[buffer].filetype) then
				return;
			end

			-- Incorrect buftype
			if vim.list_contains(shared.configuration.disabled_buftypes, vim.bo[buffer].buftype) then
				return;
			end

			---_

			-- Most likely a file is opened
			if vim.fn.argc() ~= 0 then
				return;
			end

			-- shared.hijack();
			shared.create_win();
			intro.renderer.init();
		end
	});
end


return intro;
