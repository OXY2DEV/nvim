return {
	"folke/tokyonight.nvim",
	lazy = false,
	-- priority = 1000,
	config = function ()
		require("tokyonight").setup({
  -- use the night style
  style = "night",
  -- disable italic for functions
  styles = {
    functions = {}
  },
  -- Change the "hint" color to the "orange" color, and make the "error" color bright red
  -- on_highlights = function(hl)
  --  hl["MarkviewHeading1"] = { fg = "#ffffff"}
  -- end
})
	end
}
