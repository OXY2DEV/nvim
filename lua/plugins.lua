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
	{ 
		"catppuccin/nvim", 
		name = "catppuccin", 
		priority = 1000,
		config = function()
			require("plugins/catppuccin")
		end
	},
	{
		"windwp/windline.nvim",
		config = function()
			require("plugins/windline")
		end
	},
	{
		'rcarriga/nvim-notify',
		config = function()
			require("plugins/notify")
		end
	},
	{
		"folke/which-key.nvim"
	},
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
	{
		"echasnovski/mini.nvim", version = "*"
	}
})
