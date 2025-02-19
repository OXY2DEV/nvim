--- Load all the colorschemes(used for screenshots).
--- Lazy loading doesn't do anything significant here.
return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,

		config = function ()
			require("catppuccin").setup({
				flavour = "mocha",
				no_italic = _G.is_within_termux(),
				transparent_background = _G.is_within_termux() == false,

				dim_inactive = {
					enabled = true,
					shade = "dark",

					percentage = 0.10
				},
			});

			vim.cmd.colorscheme("catppuccin");
		end
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,

		config = function ()
			require("tokyonight").setup({
			});
		end,
	},
	{
		"scottmckendry/cyberdream.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			-- Enable transparent background
			transparent = true,
		}
	},
	{
		"bluz71/vim-nightfly-colors",
		name = "nightfly",
		lazy = false,
		priority = 1000
	},
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = false,
		priority = 1000,

		opts = {
			transparent = true, -- Disable setting background
			dim_inactive = true, -- Non focused panes set to alternative background
			styles = {
				sidebars = "transparent",
			},
		}
	},
	{
		"olimorris/onedarkpro.nvim",
		lazy = false,
		priority = 1000
	}
};
