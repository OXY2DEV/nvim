---+ name: Catppuccin.nvim; |color| ##plugin##
---
---_

return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,

	config = function ()
		require("catppuccin").setup({
			flavour = "mocha",
			-- transparent_background = true,

			-- dim_inactive = {
			-- 	enabled = true,
			-- 	shade = "dark",
			--
			-- 	percentage = 0.10
			-- },

			-- custom_highlights = function (colors)
				-- return {
				-- 	-- The cursor can be hidden by using a highlight group
					-- HiddenCursor = { blend = 100, nocombine = true }
			-- 		Folded = { bg = colors.none },
			-- 		CursorColumn = { bg = "#2a2b3c" }
			-- 	};
			-- end
		});

		vim.cmd.colorscheme("catppuccin");
	end
};
