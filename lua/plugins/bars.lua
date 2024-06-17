return {
	dir = "~/.config/nvim/lua/custom_plugins/bars-N-lines.nvim",
	name = "bars",

	dependencies = {
		"nvim-tree/nvim-web-devicons"
	},

	config = function ()
		require("bars").setup();
		require("bars.colors").setup({});
	end
}
