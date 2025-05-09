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
		lazy = true,
		priority = 1000,

		opts = {}
	},
	{
		"scottmckendry/cyberdream.nvim",
		lazy = true,
		priority = 1000,

		opts = {}
	},
	{
		"bluz71/vim-nightfly-colors",
		name = "nightfly",
		lazy = true,
		priority = 1000
	},
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = true,
		priority = 1000,

		opts = {
			transparent = false,
			dim_inactive = true, -- Non focused panes set to alternative background
		}
	},
	{
		"olimorris/onedarkpro.nvim",
		lazy = true,
		priority = 1000
	},
	{
		"rebelot/kanagawa.nvim",
		lazy = true,
		priority = 1000
	}
};
