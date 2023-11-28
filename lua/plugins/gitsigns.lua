require('gitsigns').setup({
	signs = {
    add          = { text = ' ╿' },
    change       = { text = ' ┇' },
    delete       = { text = '┃ ' },
    topdelete    = { text = '╏ ' },
    changedelete = { text = '┃┇' },
    untracked    = { text = '┃╍' },
	},
	signcolumn = true,
	numhl = false,
	linehl = false,

	current_line_blame = true,
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "overlay",

		delay = 5000
	},
	on_attach = function()
		-- do not use Gitsigns on CSS files(color previw doesn't work)
		if (vim.bo.filetype == "css") then
			return false
		end
	end
})
