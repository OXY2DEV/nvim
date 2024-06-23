return {
	dir = "~/.config/nvim/lua/custom_plugins/markview.nvim/",
	name = "markview", enabled = false,

	config = function ()
		require("markview").setup();
	end
}
