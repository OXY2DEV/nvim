---+ name: Markview.nvim; |looks| ##plugin##
---
---_

return {
	-- "OXY2DEV/markview.nvim",
	dir = "~/.config/nvim/lua/custom_plugins/markview.nvim/",
	name = "markview",
	-- enabled = false,

	lazy = false,
	-- ft = "markdown",

	dependencies = {
		"nvim-tree/nvim-web-devicons"
	},
	config = function ()
		-- require("markview").setup();
		-- vim.cmd("Markview disableAll");
	end
}
