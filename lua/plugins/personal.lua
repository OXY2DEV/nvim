return {
	{
		-- "OXY2DEV/icons",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/icons",
		name = "icons",
		priority = 500,
		lazy = false
	},
	{
		-- "OXY2DEV/bars",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/bars",
		name = "bars",
		priority = 500,
		lazy = false,

		dependencies = {
			{
				-- "OXY2DEV/icons",
				dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/icons",
			}
		}
	},

	{
		-- "OXY2DEV/markview.nvim",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/markview.nvim",
		name = "markview",
		priority = 100,
		lazy = false
	},
};
