--[[
	Generated with 'conf-doc.nvim'

	Author: OXY2DEV
	Time: Tue Aug 20 10:40:57 2024
]]--

--from: SETTINGS.md;range: 19,24;
vim.o.background = "dark";
vim.o.termguicolors = true;      -- Colors will look off without this
vim.cmd.colorscheme("habamax");


--from: SETTINGS.md;range: 27,30;
vim.o.cursorline = true;


--from: SETTINGS.md;range: 33,43;
vim.o.number = false;
vim.o.relativenumber = true;  -- Needed to update the statuscolumn

vim.o.foldcolumn = "0";       -- Managed by the statuscolumn
vim.o.signcolumn = "no";

vim.o.numberwidth = 1;        -- Prevents a click related bug in the
                              -- statuscolumn


--from: SETTINGS.md;range: 49,53;
vim.o.cmdheight = 1;  -- BUG: Can't be 0 due to a bug in neovim
vim.o.pumheight = 5;  -- Looks good on the cmdline


--from: SETTINGS.md;range: 56,60;
vim.o.ruler = false                 -- Managed by the statusline
vim.o.rulerformat = "  %l  %c";  -- For when I use the ruler


--from: SETTINGS.md;range: 63,67;
vim.o.scrolloff = 999;
vim.o.sidescrolloff = 10;  -- 999 causes too much lag


--from: SETTINGS.md;range: 77,80;
vim.o.mouse = "n";


--from: SETTINGS.md;range: 83,86;
vim.o.confirm = true;


--from: SETTINGS.md;range: 89,95;
vim.o.shiftwidth = 4;  -- 2 is too small, 8 is too big

vim.o.softtabstop = 4; -- Not necessary, but will still add it
vim.o.tabstop = 4;


--from: SETTINGS.md;range: 101,105;
vim.o.complete = ".";             -- Scan the buffer
vim.o.completeopt = "menu,popup"; -- Appearance


--from: SETTINGS.md;range: 108,112;
vim.o.foldmethod = "marker";      -- Maximum control
vim.o.foldmarker = "-+,-_";


--from: SETTINGS.md;range: 115,119;
vim.o.spell = true;  -- For fixing spelling in comments
vim.o.wrap = false;  -- To make reading code easier


--from: SETTINGS.md;range: 126,130;
vim.g.mapleader = " ";
vim.o.timeoutlen = 500;


