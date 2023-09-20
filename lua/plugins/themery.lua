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
		}
	}, -- Your list of installed colorschemes
  themeConfigFile = "~/.config/nvim/lua/plugins/theme.lua", -- Described below
  livePreview = true, -- Apply theme while browsing. Default to true.
})
