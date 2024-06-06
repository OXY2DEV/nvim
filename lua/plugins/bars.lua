return {
	dir = "~/.config/nvim/lua/custom_plugins/bars-N-lines.nvim",
	name = "bars",

	config = function ()
		require("bars").setup();
	end
}
