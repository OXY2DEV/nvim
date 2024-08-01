---+ name: Terminal.nvim; |looks| ##plugin##
---
---_

return {
	dir = "~/.config/nvim/lua/custom_plugins/terminal.nvim",
	enabled = false,

	dependencies = {
		{
			dir = "~/.config/nvim/lua/custom_plugins/window-animations.nvim"
		}
	},

	config = function ()
		require("terminal").setup({});
	end
}
