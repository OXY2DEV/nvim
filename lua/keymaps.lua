local G = vim.g

G.mapleader = " "

function map(mode, key, action, options)
	local defaults = {
		noremap = true, silent = true
	}

	if options then
		defaults = vim.tbl_extend("force", defaults, options)
	end

	vim.keymap.set(mode, key, action, defaults)
end

---------------------------------
----------Read & Write-----------
---------------------------------
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")

map("n", "<leader>wq", ":wq<CR>")
map("n", "<leader>qq", ":q!<CR>")

map("n", "<leader>sv", ":vsp<CR>")
map("n", "<leader>sh", ":sp<CR>")

map("n", "<leader>fb", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")
map("n", "<leader>t", ":Telescope<CR>")
map("n", "<leader>th", ":Telescope themes<CR>")
map("n", "<leader>c", ":CompilerOpen<CR>")

map("n", "<leader>mn", ":lua MiniMap.toggle()<CR>")

map("n", "<leader>p", ":PickColor<CR>")

map("n", "<leader>tr", ":ToggleTerm<CR>")
map("n", "<leader>tf", ":ToggleTerm direction=horizontal<CR>")

map("n", "<leader>td", ":TermExec cmd='npm run dev'<CR>")
map("n", "<leader>tg", ":TermExec cmd='lazygit'<CR>")

map("n", "<leader>bp", ":BufferLinePick<CR>")
map("n", "<leader>b,", ":BufferLineCyclePrev<CR>")
map("n", "<leader>b.", ":BufferLineCycleNext<CR>")

map("n", "<leader>1", ":WindowsMaximize<CR>")
map("n", "<leader>5", ":WindowsEqualize<CR>")
map("n", "<leader>0", ":res 0<CR>")





