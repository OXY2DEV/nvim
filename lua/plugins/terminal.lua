return {
	dir = "~/.config/nvim/lua/custom_plugins/terminal.nvim",

	dependencies = {
		{
			dir = "~/.config/nvim/lua/custom_plugins/window-animations.nvim"
		}
	},

	config = function ()
		require("terminal").setup({});
	end
}
