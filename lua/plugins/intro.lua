return {
	dir = "~/.config/nvim/lua/custom_plugins/intro.nvim/",
	config = function ()
		require("intro").setup();
	end
}
