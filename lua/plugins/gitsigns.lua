---+ name: Gitsigns.nvim; |git| ##plugin##
---
---_

return {
	"lewis6991/gitsigns.nvim",
	-- enabled = false,

	config = function ()
		require("gitsigns").setup();
	end
}
