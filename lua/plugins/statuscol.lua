local builtin = require("statuscol.builtin")

require("statuscol").setup({
	relculright = true,
  segments = {
		{ sign = { text = { " " } } },																--Empty column
		{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },				--Fold colukn
		{ text = { "%s" }, click = "v:lua.ScSa" },										--Gitsigns
		{ sign = { text = { " " } } },
		{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" }		--Line Numner
	}
})
