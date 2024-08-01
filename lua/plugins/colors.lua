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

		vim.api.nvim_set_keymap("n", "<leader>c", "", {
			callback = function ()
				require("colors/picker").colorPicker:init()
			end
		})
	end
}
