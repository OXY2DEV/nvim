local bars = {};

bars.statuscolumn = require("bars.statuscolumn");
bars.statusline = require("bars.statusline");
bars.tabline = require("bars.tabline");

_G.bars_n_lines = require("bars.clicks");

local utils = require("bars.utils");

bars.configuration = {
	exclude_filetypes = { "help", "query" },
	exclude_buftypes = { "nofile", "prompt" },

	statuscolumn = true,
	statusline = true,
	tabline = true
};


bars.setup = function (config_table)
	bars.configuration = vim.tbl_extend("force", bars.configuration, config_table or {});

	vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType", "TermOpen" }, {
		callback = function (event)
			if vim.list_contains(bars.configuration.exclude_filetypes, vim.bo[event.buf].filetype) then
				for _, window in ipairs(utils.list_attached_wins(event.buf)) do
					bars.statuscolumn.disable(window);
					bars.statusline.disable(window);
				end
				return;
			end

			if vim.islist(bars.configuration.exclude_buftypes) and vim.list_contains(bars.configuration.exclude_buftypes, vim.bo[event.buf].buftype) then
				for _, window in ipairs(utils.list_attached_wins(event.buf)) do
					bars.statuscolumn.disable(window);
					bars.statusline.disable(window);
				end
				return;
			end

			for _, window in ipairs(utils.list_attached_wins(event.buf)) do
				if bars.configuration.statuscolumn == true then
					bars.statuscolumn.init(event.buf, window, bars.configuration);
				end

				if bars.configuration.statusline == true then
					bars.statusline.init(event.buf, window, bars.configuration);
				end
			end

			if bars.configuration.tabline == true then
				bars.tabline.init();
			end
		end
	})

end

return bars;
