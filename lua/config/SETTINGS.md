<!--
##conf-doc##
author: OXY2DEV;
fn: settings;
ft: lua;
##conf-doc-end##
-->

# 🔩 Editor configuration

Neovim is highly customisable and it is one of the reasons I use it. But with so many options it can easily become a pain to track which option is doing what.

So, the options are divided into different parts.

## ✨ Appearance

First is obviously customising the colorscheme.

```lua
vim.o.background = "dark";
vim.o.termguicolors = true;      -- Colors will look off without this
vim.cmd.colorscheme("habamax");
```

I also use the `cursorline`. So, 

```lua
vim.o.cursorline = true;
```

Since I use a custom `statuscolumn`. I need to modify a few options.

```lua
vim.o.number = false;
vim.o.relativenumber = true;  -- Needed to update the statuscolumn

vim.o.foldcolumn = "0";       -- Managed by the statuscolumn
vim.o.signcolumn = "no";

vim.o.numberwidth = 1;        -- Prevents a click related bug in the
                              -- statuscolumn
```

I usually change `cmdheight` to 0.

>[!Caution]
> Due to a bug with `cmdheight=0` it doesn't work with `nvim-cmp`.

```lua
vim.o.cmdheight = 1;  -- BUG: Can't be 0 due to a bug in neovim
vim.o.pumheight = 5;  -- Looks good on the cmdline
```

I also modify the `ruler`.

```lua
vim.o.ruler = false                 -- Managed by the statusline
vim.o.rulerformat = "  %l  %c";  -- For when I use the ruler
```

Since I am on a small screen I will use `sidescroll` & `sidescrolloff` to make scrolling easier.

```lua
vim.o.scrolloff = 999;
vim.o.sidescrolloff = 10;  -- 999 causes too much lag
```

## 📑 Usage

I change some of the default options to make editing on phone easier.

First is obviously `mouse` which in my case would allow using the touch screen.

>[!Note]
> Even though I set it to only work on **normal-mode** I can still scroll using `swipes` in any mode.

```lua
vim.o.mouse = "n";
```

To prevent accidentally quitting neovim I use confirmation for saving & quitting.

```lua
vim.o.confirm = true;
```

For indentation, I use 4 spaces as it is easier to distinguish indentation and allows fitting more text in a small screen.

```lua
vim.o.shiftwidth = 4;  -- 2 is too small, 8 is too big

vim.o.softtabstop = 4; -- Not necessary, but will still add it
vim.o.tabstop = 4;
```

For the completion, I want the `popup` menu instead of the long list of items shown at the bottom of the screen.

>[!Tip]
> Even without a `completion plugin` CTRL-N, CTRL-P can be used to get word completion from the buffer.

```lua
vim.o.complete = ".";             -- Scan the buffer
vim.o.completeopt = "menu,popup"; -- Appearance
```

I also use `folds` a lot so I configure them to be more *practical*.

```lua
vim.o.foldmethod = "marker";      -- Maximum control
vim.o.foldmarker = "-+,-_";
```

A few *quality of life* changes I make are.

```lua
vim.o.spell = true;  -- For fixing spelling in comments
vim.o.wrap = false;  -- To make reading code easier
```

## 💻 Keymaps

I use `<space>` as the leader key. Unfortunately, this comes at the cost of not being very useful in `insert-mode` and easily gets in the way sometimes.

So, I use a small `timeout` duration to reduce accidental keymaps from happening.

```lua
vim.g.mapleader = " ";
vim.o.timeoutlen = 500;
```


