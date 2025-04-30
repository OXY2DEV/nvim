return {
	{
		-- "OXY2DEV/ui.nvim",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/ui.nvim",
		name = "ui",
		priority = 500,
		lazy = false
	},
	{
		-- "OXY2DEV/icons.nvim",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/icons.nvim",
		name = "icons",
		priority = 500,
		lazy = false
	},
	{
		-- "OXY2DEV/bars.nvim",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/bars.nvim",
		name = "bars",
		priority = 500,
		lazy = false,

		dependencies = {
			{
				-- "OXY2DEV/icons.nvim",
				dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/icons.nvim",
			}
		}
	},

	{
		-- "OXY2DEV/foldtext.nvim",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/foldtext.nvim",
		name = "foldtext",
		priority = 500,
		lazy = false
	},

	{
		-- "OXY2DEV/markview.nvim",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/markview.nvim",
		name = "markview",
		priority = 100,
		lazy = false,

		opts = {
			preview = {
				enable = false
			}
		}
	},
	{
		-- "OXY2DEV/helpview.nvim",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/helpview.nvim",
		name = "helpview",
		priority = 100,
		lazy = false,
	},

	{
		-- "OXY2DEV/patterns.nvim",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/patterns.nvim",
		name = "patterns",
		priority = 100,
		lazy = false,

		dependencies = {
			"Saghen/blink.cmp"
		}
	},
	{
		-- "OXY2DEV/oops.nvim",
		dir = vim.fn.stdpath("config") .. "/lua/custom_plugins/oops.nvim",
		name = "oops",
		priority = 100,
		lazy = false,

		config = function ()
			vim.api.nvim_set_keymap("n", "O", "<CMD>Oops<CR>", {});
		end
	},
};
