local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)






require("lazy").setup({
	---------------------------------
	-------------Theme---------------
	---------------------------------
	{ 
		"catppuccin/nvim", 
		name = "catppuccin", 
		priority = 1000,
		config = function()
			require("plugins/catppuccin")
		end
	},
	---------------------------------
	----------Theme Picker------------
	---------------------------------
	{
		"zaldih/themery.nvim",
		config = function()
			require("plugins/themery")
		end
	},
	---------------------------------
	-------------CmdLine-------------
	---------------------------------
	{
		"windwp/windline.nvim",
		config = function()
			require("plugins/windline")
		end
	},
	---------------------------------
	---------Notifications-----------
	---------------------------------
	{
		'rcarriga/nvim-notify',
		config = function()
			require("plugins/notify")
		end
	},
	---------------------------------
	---------Key Suggestions---------
	---------------------------------
	{
		"folke/which-key.nvim"
	},
	---------------------------------
	-----------Better UI-------------
	---------------------------------
	{
		"folke/noice.nvim",
		event = "VeryLazy",
 		dependencies = {
 			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
 			"MunifTanjim/nui.nvim",
 			-- OPTIONAL:
 			--   `nvim-notify` is only needed, if you want to use the notification view.
 			--   If not available, we use `mini` as the fallback
 			"rcarriga/nvim-notify",
    },
		config = function()
			require("plugins/noice")
		end
	},
	---------------------------------
	-------------Mini+---------------
	---------------------------------
	{
		"echasnovski/mini.nvim", version = "*",
		config = function()
			require("plugins/mini")
		end
	},
	---------------------------------
	----------Start scdeen+-----------
	---------------------------------
	{
		'glepnir/dashboard-nvim',
		event = 'VimEnter',
		config = function()
			require('dashboard').setup {
      -- config
			}
		end,
		dependencies = { {'nvim-tree/nvim-web-devicons'}}
	}
})
