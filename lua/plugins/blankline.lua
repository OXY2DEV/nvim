vim.opt.termguicolors = true

vim.opt.list = true
vim.opt.listchars:append "space: "
vim.opt.listchars:append "eol:↴"

require("indent_blankline").setup({
	show_current_context = true,
	show_current_context_start = true,

  space_char_blankline = " ",
})



