---+ name: noice.nvim; |looks| ##plugin##
---
---_

return {
	"folke/noice.nvim",
	event = "VeryLazy",
	enabled = false,

	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},

	config = function ()
		require("noice").setup({
			cmdline = {
				-- enabled = false
			},
			lsp = {
				progress = {
					enabled = false
				},
				message = {
					enabled = false
				}
			}
		});
	end
}
