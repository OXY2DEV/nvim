# 💻 OXY2DEV's setup for **Android** & **MacOS**

A general-purpose setup for `Neovim`.

## 📦 What's included?

- Single file scripts that extends Neovim's feature,
    + [color_sync.lua](https://github.com/OXY2DEV/nvim/blob/main/lua/scripts/color_sync.lua), Syncs Neovim's colorscheme with the terminal's colorscheme.
    + [diagnostics.lua](https://github.com/OXY2DEV/nvim/blob/main/lua/scripts/diagnostics.lua), Fancy diagnostics hover.
    + [lsp_hover.lua](https://github.com/OXY2DEV/nvim/blob/main/lua/scripts/lsp_hover.lua), Fancy LSP hover window.
    + [quickfix.lua](https://github.com/OXY2DEV/nvim/blob/main/lua/scripts/quickfix.lua), Fancy editable quickfix window with `tree-sitter` syntax highlighting.
    + [highlights.lua](5https://github.com/OXY2DEV/nvim/blob/main/lua/scripts/highlights.lua), Dynamic highlight groups for your custom stuffs without needing to worry about colorscheme support!

- Custom tree-sitter parsers,
    + [tree-sitter-vhs](https://github.com/OXY2DEV/tree-sitter-vhs/tree/main), Tree-sitter parser for VHS with improved syntax tree & highlighting!
    + [tree-sitter-lua_patterns](https://github.com/OXY2DEV/tree-sitter-lua_patterns/tree/main), Tree-sitter parser for `Lua patterns` with improved syntax tree, more nodes & bug fixes.

- Spell files with common words
- Completion setup for `nvim-cmp` & `blink.cmp`.
- LSP setup for various languages(e.g. Lua, Javascript, Python etc.)
- Multiple colorscheme setup.
- Various QOL plugins,
    + `OXY2DEV/bars.nvim`, Per window custom Statusline, Statuscolumn, Winbar & Tabline.
    + `OXY2DEV/helpview.nvim`, Fancy vim help files previewer.
    + `OXY2DEV/markview.nvim`, Fancy Markdown, Inline HTML, Latex, Typst, YAML previewer.
    + `OXY2DEV/patterns.nvim`, Fancy `Lua patterns` & `Regex` explainer with LSP-style hover support!
    + `OXY2DEV/foldtext.nvim`, Fancy `foldtext`.
    + `OXY2DEV/icons.nvim`, Custom icon set.
    + `OXY2DEV/ui.nvim`, Fancy `Cmdline`, `Pop-up menu` & `Messages`.

## 📥 Installation

>[!NOTE]
> You must have `git` installed on your system.
>
> On Termux install it via `pkg`,
> ```shell
>  pkg install git -y
> ```
>
> On MacOS use `homebrew`,
> ```shell
> brew install git
> ```

1. Backup your previous config.

```shell
mv ~/.config/nvim/ ~/.config/nvim_backup/
```

2. Go to `~/.config`.

```shell
cd ~/.config/
```

3. Clone this repository.

```shell
git clone https://www.github.com/OXY2DEV/nvim/
```

4. Open Neovim.

```shell
nvim
```

And you should be good to go!

## 📂 File structure

```txt
🔩 nvim
├─ 📜 init.lua
├─ 📂 lua
│  ├─ 📂 editor   # Editor configuration
│  ├─ 📂 scripts  # Standalone scripts for Neovim
│  ├─ 🔖 plugins  # Plugin configurtion(lazy.nvim is used)
│  └─ 📂 custom   # Custom plugins
└─ 📑 README.md
```




