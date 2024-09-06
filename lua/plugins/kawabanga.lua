return {
	"rebelot/kanagawa.nvim",
	-- enabled = false,
	config = function ()
		-- Default options:
		require('kanagawa').setup({
			-- transparent = true,         -- do not set background color
		})

		-- setup must be called before loading
		-- vim.cmd("colorscheme kanagawa")
	end
}
