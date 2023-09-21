-- Minimal config
require("themery").setup({
  themes = {
		{
			name = "Mocha",
			colorscheme = "catppuccin-mocha"
		},
		{
			name = "Macchiato",
			colorscheme = "catppuccin-macchiato"
		},
		{
			name = "Frappe",
			colorscheme = "catppuccin-frappe"
		},
		{
			name = "Latte",
			colorscheme = "catppuccin-latte"
		},

		{
			name = " ",
			colorscheme = "default"
		},

		{
			name = "Night - Tokyonight",
			colorscheme = "tokyonight-night"
		},
		{
			name = "Moon - Tokyonight",
			colorscheme = "tokyonight-moon"
		},
		{
			name = "Storm - Tokyonight",
			colorscheme = "tokyonight-storm"
		},


		{
			name = "Dragon - Kanagawa",
			colorscheme = "kanagawa-dragon"
		},
		{
			name = "Lotus - Kanagawa",
			colorscheme = "kanagawa-lotus"
		},
		{
			name = "Wave - Kanagawa",
			colorscheme = "kanagawa-wave"
		},

		{
			name = " ",
			colorscheme = "default"
		},

		{
			name = "Nightfox - Nightfox",
			colorscheme = "nightfox"
		},
		{
			name = "Dayfox - Nightfox",
			colorscheme = "dayfox"
		},
		{
			name = "Dawnfox - Nightfox",
			colorscheme = "dawnfox"
		},
		{
			name = "Duskfox - Nightfox",
			colorscheme = "duskfox"
		},
		{
			name = "Nordfox - Nightfox",
			colorscheme = "nordfox"
		},
		{
			name = "Terafox - Nightfox",
			colorscheme = "terafox"
		},
		{
			name = "Carbonfox - Nightfox",
			colorscheme = "carbonfox"
		},
	}, -- Your list of installed colorschemes
  themeConfigFile = "~/.config/nvim/lua/plugins/theme.lua", -- Described below
  livePreview = true, -- Apply theme while browsing. Default to true.
})
