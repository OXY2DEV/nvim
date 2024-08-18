---+ name: Colors.nvim; |color| ##plugin##
---
---_

return {
	dir = "~/.config/nvim/lua/custom_plugins/colors.nvim/",
	name = "colors",

	dependencies = {
		{
			dir = "~/.config/nvim/lua/custom_plugins/window-animations.nvim",
		}
	},

	config = function ()
		require("colors").setup();
	end
}
