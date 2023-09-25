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



--[[

List of Plugins goes here.

]]



require("lazy").setup({
	-----------------------------------
	----------- Treesitter ------------
	-----------------------------------
	{ -- is used by "Indent-Blankline" for underlined scope highlighting(That line under (, {, [ )
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("plugins/treesitter")
		end
	},
	

	-----------------------------------
	---------Window Resizer------------
	-----------------------------------
	{
		"ziontee113/syntax-tree-surfer",
		config = function()
			require("plugins/surfer")
		end
	},


	-----------------------------------
	----------------CoC-----------------
	------------------------------------
	{ -- is used for Auto Suggestions and a few more things
		"neoclide/coc.nvim",
		branch = "release",
	},

	-----------------------------------
	---------------Emmet---------------
	-----------------------------------
	{ -- is used for HTML snippet. Use <space>m on Normal mode to make a snippet from the given input
		"mattn/emmet-vim",
	},
	-----------------------------------
	---------------Emmet---------------
	-----------------------------------
	{
		"preservim/nerdcommenter"
	},




	-----------------------------------
	---------------Theme---------------
	-----------------------------------
	{ 
		"catppuccin/nvim", 
		name = "catppuccin", 
		priority = 1000,
		config = function()
			require("plugins/catppuccin")
		end
	},
	
	-----------------------------------
	------------Tokyonight-------------
	-----------------------------------
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},


	-----------------------------------
	-------------Kanagawa--------------
	-----------------------------------
	{
		"rebelot/kanagawa.nvim"
	},


	-----------------------------------
	-------------Nightfox--------------
	-----------------------------------
	{ 
		"EdenEast/nightfox.nvim" 
	},


	-----------------------------------
	--------------VScode---------------
	-----------------------------------
	{
		"Mofiqul/vscode.nvim"
	},


	-----------------------------------
	-------------Nightfox--------------
	-----------------------------------
	{
		"projekt0n/github-nvim-theme"
	},


	-----------------------------------
	-----------Theme Switcher----------
	-----------------------------------
	{ -- used by <space>th in Normal mode
		"andrew-george/telescope-themes",
		lazy = true
	},




	-----------------------------------
	--------------CmdLine--------------
	-----------------------------------
	{
		"windwp/windline.nvim",
		config = function()
			require("plugins/windline")
		end
	},


	-----------------------------------
	-------------Tab Bar---------------
	-----------------------------------
	{
		"akinsho/bufferline.nvim",
		version = "*", 
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("plugins/bufferline")
		end
	},





	-----------------------------------
	----------Notifications------------
	-----------------------------------
	{
		'rcarriga/nvim-notify',
		config = function()
			require("plugins/notify")
		end
	},


	-----------------------------------
	------------Ui Dresser-------------
	-----------------------------------
	{ -- used by Icon Picker
		"stevearc/dressing.nvim",
		config = function()
			require("plugins/dressing")
		end
	},




	-----------------------------------
	----------Key Suggestions----------
	-----------------------------------
	{
		"folke/which-key.nvim",
		config = function()
			require("plugins/which")
		end
	},


	-----------------------------------
	------------Icon Picker------------
	-----------------------------------
	{
		"ziontee113/icon-picker.nvim",
		dependencies = {
			"stevearc/dressing.nvim"
		},
		config = function()
			require("plugins/iconPicker")
		end
	},




	-----------------------------------
	-------------Better UI-------------
	-----------------------------------
	{ -- is used for the PopUp CmdLine, Floating Menus and Notifications.
		"folke/noice.nvim",
		event = "VeryLazy",
 		dependencies = {
 			"MunifTanjim/nui.nvim",
 			"rcarriga/nvim-notify",
    },
		config = function()
			require("plugins/noice")
		end
	},


	-----------------------------------
	---------------Mini----------------
	-----------------------------------
	{ -- used in <space>mn in Normal mode. Is also used in animated Window resize and cursor transitions.
		"echasnovski/mini.nvim", version = "*",
		config = function()
			require("plugins/mini")
		end
	},
	
	
	-----------------------------------
	-------Advance Indentations--------
	-----------------------------------
	{ 
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("plugins/blankline")
		end
	},


	-----------------------------------
	-----------Auto close ()-----------
	-----------------------------------
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("plugins/autopairs")
		end,
		enabled = true
	},
	

	-----------------------------------
	-------------Dims Code-------------
	-----------------------------------
	{ -- used by <space>z
		"folke/twilight.nvim",
		config = function()
			require("plugins/twilight")
		end
	},




	-----------------------------------
	------------Start screen-----------
	-----------------------------------
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




	-----------------------------------
	-------------Telescope-------------
	-----------------------------------
  { -- used by <space>t in Normal mode. Search anything easily!
		'nvim-telescope/telescope.nvim', tag = '0.1.3',
		-- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require("plugins/telescope")
		end
  },


	-----------------------------------
	-----------File Browser------------
	-----------------------------------
	{ -- uses by <space>fb in Normal mode.
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
	},

	


	-----------------------------------
	---------Cursor Centerer-----------
	-----------------------------------
	{ -- used for centering current line.
		"arnamak/stay-centered.nvim",
		config = function()
			require("plugins/centered")
		end
	},


	-----------------------------------
	---------Window Resizer------------
	-----------------------------------
	{ -- auto window resizer
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
  },


	

	-----------------------------------
	-----------Color Picker------------
	-----------------------------------
	{ -- used in <space>p in Normal mode.
		"ziontee113/color-picker.nvim",
    config = function()
        require("plugins/colorpicker")
    end,
	},
	

	-----------------------------------
	----------Color Preview------------
	-----------------------------------
	{ -- auto previews colors as Background.
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("plugins/colorizer")
		end
	},




	-----------------------------------
	--------------Compiler------------
	-----------------------------------
	{ -- used by <leader>c in Normal mode. C compiler.
		"Zeioth/compiler.nvim",
		cmd = {"CompilerOpen", "CompilerToggleResults", "CompilerRedo"},
		dependencies = { "stevearc/overseer.nvim" },
		opts = {},
	},


	-----------------------------------
	--------Compiler(2nd part)---------
	-----------------------------------
	{
		"stevearc/overseer.nvim",
		commit = "19aac0426710c8fc0510e54b7a6466a03a1a7377",
		cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
		opts = {
			task_list = {
				direction = "bottom",
				min_height = 30,
				max_height = 30,
				default_detail = 1,
				bindings = { ["q"] = function() vim.cmd("OverseerClose") end },
			},
		},
	},




	-----------------------------------
	------------Git signs--------------
	-----------------------------------
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("plugins/gitsigns")
		end
	},
	



	-----------------------------------
	------------Git signs--------------
	-----------------------------------
	{
		"kevinhwang91/nvim-ufo", 
		dependencies = {
			"kevinhwang91/promise-async",
			{
				"luukvbaal/statuscol.nvim",
				config = function()
					require("plugins/statuscol")
				end
			}
		},
		config = function()
			require("plugins/ufo")
		end
	},




	-----------------------------------
	-------------Terminal--------------
	-----------------------------------
	{
		"akinsho/toggleterm.nvim", 
		version = "*",
		config = function()
			require("plugins/toggleterm")
		end
	},
})
