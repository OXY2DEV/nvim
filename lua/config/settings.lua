--- File for various vim related settings

---+ type: look; title: Appearance;
vim.o.background = "dark";

-- vim.o.cursorcolumn = true;
vim.o.cursorline = true;

vim.o.foldcolumn = "auto";
vim.o.foldtext = "foldtext()";

vim.o.number = true;
vim.o.relativenumber = true;
vim.o.ruler = true;
vim.o.rulerformat = " %l  %c";

vim.o.cmdheight = 1;
vim.o.pumheight = 5;

vim.o.shiftwidth = 4;

vim.o.signcolumn = "number";
---_

---+ type: custom; icon: 󰇀 ; hl: @define; title: Touch;
vim.o.mouse = "n";
---_

---+ type: config; title: Keymap;
vim.g.mapleader = " ";
vim.o.timeoutlen = 500;
---_

---+ type: config; title: Editing;
vim.o.complete = ".";
vim.o.completeopt = "menu,popup";

vim.o.confirm = true;

vim.o.foldmethod = "marker";
vim.o.foldmarker = "-+,-_";

vim.o.scrolloff = 999;
vim.o.sidescrolloff = 10;

vim.o.spell = true;

vim.o.softtabstop = 4;
vim.o.tabstop = 4;

vim.o.wrap = false;
--_

---+ type: color; title: Colorscheme;
vim.o.termguicolors = true;
vim.cmd.colorscheme("habamax");
---_
