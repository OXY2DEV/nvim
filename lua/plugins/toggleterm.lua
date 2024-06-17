return {
	"akinsho/toggleterm.nvim",

	dependencies = {
		{
			dir = "~/.config/nvim/lua/custom_plugins/window-animations.nvim"
		}
	},

	config = function ()
		require("toggleterm").setup({
			--on_open = function (terminal)
			--	require("winanims").openFloat(0, {}, {})
			--end
		});
	end
}
