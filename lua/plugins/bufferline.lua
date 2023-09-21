require("bufferline").setup({
	options = {
		indicator = {
			icon = "▊",
			style = "icon"
		},
		color_icons = true,
		separator_style = "slope", --"slope" | "slant" | "thick" | "thin" | { 'any', 'any' },
		diagnostics = "coc"
	},
})
