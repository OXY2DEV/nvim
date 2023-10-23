require("settings")										-- Vim options
require("keymaps")										-- Mapoed Keys
require("plugins")										-- Plugin Information

require("current-theme")							-- Current theme 

local wl = { fg="#676788" }


-- {{{2 Highlights
-- After loading everything change the Fold Icon color(won't work if set before as Themes change it)
vim.api.nvim_set_hl(0, "FoldColumn", { fg="#90CAF9" })
vim.api.nvim_set_hl(0, "Folded", wl)
-- }}}2
