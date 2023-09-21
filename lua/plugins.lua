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
		"neoclide/coc.nvim",
		branch = "release",
	},
	{
		"mattn/emmet-vim",
	},
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
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},
	{
		"rebelot/kanagawa.nvim"
	},
	{ 
		"EdenEast/nightfox.nvim" 
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
	
	{
		"akinsho/bufferline.nvim",
		version = "*", 
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("plugins/bufferline")
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
		"folke/which-key.nvim",
		config = function()
			require("plugins/which")
		end
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
	-------------Mini----------------
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
	},
	---------------------------------
	----------Telescope--------------
	---------------------------------
  {
		'nvim-telescope/telescope.nvim', tag = '0.1.3',
		-- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require("plugins/telescope")
		end
  },
	---------------------------------
	----------Telescope--------------
	---------------------------------
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
	},

	{
		"arnamak/stay-centered.nvim",
		config = function()
			require("plugins/centered")
		end
	},

	{ 
		"anuvyklack/windows.nvim",
    dependencies = {
			"anuvyklack/middleclass",
      "anuvyklack/animation.nvim"
    },
    config = function()
      vim.o.winwidth = 10
      vim.o.winminwidth = 10
      vim.o.equalalways = false
      require('windows').setup()
    end
  }
})
