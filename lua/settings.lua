local O = vim.o

vim.g.theme_id = 1

O.termguicolors = true
O.mouse = "a"                     -- Use Mouse(In this case Touch) gestures in All modes
O.timeoutlen = 300								-- Wait 300ms for next keystroke

O.wrap = false                    -- Do not wrap long text

O.number = true                   -- Show lins number
--O.numberwidth = 5
O.relativenumber = true           -- Show relative line numbers
O.signcolumn = "no"

O.cursorline = true               -- Highlight line under cursor
O.cursorcolumn = true							-- Highlight column under cursor
O.ruler = true										-- Show Cursor position at bottom


O.cindent = true                  -- Indent line .c files

O.tabstop = 2                     -- Tab size is 2 spaces
O.shiftwidth = 0                  -- ┠ 
O.softtabstop = -1                -- ┠ Needed to set tab size

--O.list = true
--O.listchars = 'trail:·,nbsp:◇,tab:→ ,extends:▸,precedes:◂'


