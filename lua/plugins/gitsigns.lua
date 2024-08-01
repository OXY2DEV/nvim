---+ name: Gitsigns.nvim; |git| ##plugin##
---
---_

return {
	"lewis6991/gitsigns.nvim",

	config = function ()
		require("gitsigns").setup();
	end
}
