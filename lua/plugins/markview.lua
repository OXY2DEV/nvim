---+ name: Markview.nvim; |looks| ##plugin##
---
---_

return {
	-- "OXY2DEV/markview.nvim",
	dir = "~/.config/nvim/lua/custom_plugins/markview.nvim/",
	name = "markview",

	lazy = false,
	-- ft = "markdown",

	dependencies = {
		"nvim-tree/nvim-web-devicons"
	},

	-- config = function ()
	-- 	-- require("markview.extras.map").setup();
	-- 	-- local presets = require("markview.presets");
	--
	-- 	require("markview").setup();
	-- 	-- 	-- highlight_groups = presets.highlight_groups.colorful_heading_bg,
	-- 	-- 	-- tables = presets.tables.border_double
	-- 	-- 	headings = presets.headings.glow_labels
	-- 	-- })
	-- end,

	opts = {
		modes = { "n", "i", "c" },
		hybrid_modes = { "i" },
	}
}
