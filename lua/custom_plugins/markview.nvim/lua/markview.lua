local markview = {};
local parser = require("markview/parser");

markview.setup = function ()
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		pattern = "*.md",
		callback = function ()
			parser.init();
		end
	});
end

return markview;
