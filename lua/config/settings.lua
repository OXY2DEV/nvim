--- File for various vim related settings

---+ Title: "Appearance"
vim.o.background = "dark";

vim.o.cursorcolumn = true;
vim.o.cursorline = true;

vim.o.foldcolumn = "auto";
vim.o.foldtext = "foldtext()";

vim.o.number = true;
vim.o.relativenumber = false;
vim.o.ruler = true;
vim.o.rulerformat = " %l  %c";

vim.o.pumheight = 5;

vim.o.shiftwidth = 4;

vim.o.signcolumn = "number";
---_

---+ Title: "Mouse"
vim.o.mouse = "n";
---_

---+ Title: "Keymaps"
vim.g.mapleader = " ";
---_

---+ Title: "Editing"
vim.o.complete = ".";
vim.o.completeopt = "menu,popup";

vim.o.confirm = true;

vim.o.foldmethod = "marker";
vim.o.foldmarker = "-+,-_";

vim.o.scrolloff = 999;
vim.o.sidescrolloff = 999;

vim.o.spell = true;

vim.o.softtabstop = -4;
vim.o.tabstop = 4;

vim.o.wrap = false;
--_

---+ Title: "Others"
vim.o.timeoutlen = 500;
---_

---+ Title: "Colorscheme"
vim.o.termguicolors = true;
vim.cmd.colorscheme("habamax");
---_
