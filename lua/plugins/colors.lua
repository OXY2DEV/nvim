---+ name: Colors.nvim; |color| ##plugin##
---
---_

return {
	dir = "~/.config/nvim/lua/custom_plugins/colors.nvim/",
	name = "colors",
	priority = 999,

	config = function ()
		require("colors").setup();
	end
}
