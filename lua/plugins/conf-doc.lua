return {
	dir = "~/.config/nvim/lua/custom_plugins/conf-doc.nvim/",
	config = function ()
		require("conf-doc").setup();
	end
}
