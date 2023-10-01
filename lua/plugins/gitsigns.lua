require('gitsigns').setup({
	signs = {
    add          = { text = ' │' },
    change       = { text = ' │' },
    delete       = { text = ' _' },
    topdelete    = { text = ' ‾' },
    changedelete = { text = ' ~' },
    untracked    = { text = ' ┆' },
	},
	signcolumn = true,
	numhl = false,
	linehl = true,

	current_line_blame = true,
	current_line_blame_opts = {
		-- opts
	},
	on_attach = function()
		-- do not use Gitsigns on CSS files(xolor previw doesn't work)
		if (vim.bo.filetype == "css") then
			return false
		end
	end
})
