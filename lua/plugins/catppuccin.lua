return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,

	config = function ()
		require("catppuccin").setup({
			flavour = "mocha",

			dim_inactive = {
				enabled = true,
				shade = "dark",

				percentage = 0.10
			},

			custom_highlights = function (colors)
				return {
					Folded = { bg = colors.none },
					CursorColumn = { bg = "#2a2b3c" }
				};
			end
		});

		vim.cmd.colorscheme("catppuccin");
	end
};
