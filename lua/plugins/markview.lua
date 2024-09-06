---+ name: Markview.nvim; |looks| ##plugin##
---
---_

return {
	-- "OXY2DEV/markview.nvim",
	dir = "~/.config/nvim/lua/custom_plugins/markview.nvim/",
	name = "markview",
	-- enabled = false,

	lazy = false,
	-- ft = "markdown",

	dependencies = {
		"nvim-tree/nvim-web-devicons"
	},
	config = function ()
		-- local pre = require("markview.presets");
		-- require("markview").setup({
		--     modes = { "n", "i", "no", "c" },
		-- 	-- hybrid_modes = { "n", "i" }
		-- });
		-- require("markview").setup({
		-- 	            headings = {
		--               enable = true,
		--               shift_width = 0,
		--               textoff = 9,
		--               heading_1 = {
		--                   style = 'label',
		--                   align = 'center',
		--                   hl = 'CursorLineNr',
		--                   icon = '',
		--                   sign = '',
		--                   sign_hl = 'CursorLineNr',
		--               },
		--               heading_2 = {
		--                   style = 'label',
		--                   align = 'center',
		--                   hl = 'Character',
		--                   icon = '',
		--                   sign = '',
		--                   sign_hl = 'Character',
		--               },
		--               heading_3 = {
		--                   style = 'label',
		--                   align = 'center',
		--                   hl = 'DiagnosticInfo',
		--                   icon = '',
		--                   sign = '',
		--                   sign_hl = 'DiagnosticInfo',
		--               },
		--               heading_4 = {
		--                   style = 'label',
		--                   align = 'center',
		--                   hl = 'Identifier',
		--                   icon = '',
		--                   sign = '',
		--                   sign_hl = 'Identifier',
		--               },
		--               heading_5 = {
		--                   style = 'label',
		--                   align = 'center',
		--                   hl = 'Identifier',
		--                   icon = '',
		--                   sign = '',
		--                   sign_hl = 'Identifier',
		--               },
		--               heading_6 = {
		--                   style = 'label',
		--                   align = 'center',
		--                   hl = 'Identifier',
		--                   icon = '',
		--                   sign = '',
		--                   sign_hl = 'Identifier',
		--               },
		--           },
		-- });
		-- vim.cmd("Markview disableAll");
	end
}
