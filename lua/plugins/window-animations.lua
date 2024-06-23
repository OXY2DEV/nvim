return {
	dir = "~/.config/nvim/lua/custom_plugins/window-animations.nvim",
	enabled = false,
	name = "winanims",

	config = function ()
		require("winanims").setup({});
	end
}
