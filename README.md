# 💻 OXY2DEV's setup for **Android** & **MacOS**

![Preview image](https://raw.githubusercontent.com/OXY2DEV/nvim/refs/heads/images/images/mockup.png)

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

- Spell files with common words.
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

## ✨ Usage

If you have used `nvim` before, backup your old files!

```bash
mkdir ~/nvim.backup

mv ~/.config/nvim ~/nvim.backup/config
mv ~/.local/share/nvim ~/nvim.backup/share
mv ~/.local/state/nvim ~/nvim.backup/state
```

>[!TIP]
> Alternatively, you can use `NVIM_APPNAME` variable.
>
> For example, if you cloned the repo to `~/.config/new_vim` then you can set the app name to `new_vim`.

------

Clone the repository to your machine(use any 1 of those commands),

```bash
git clone https://github.com/OXY2DEV/nvim.git
# git clone git@github.com:OXY2DEV/nvim.git
# gh repo clone OXY2DEV/nvim
```

Run `nvim`,

```bash
nvim
```

Everything else should be installed automatically and you should be good to go!

### 🌋 Gallery

![Main demo](https://raw.githubusercontent.com/OXY2DEV/nvim/refs/heads/images/images/nvim-main.png)

> Custom quickfix(with diagnostic hover), markdown preview, custom statuscolumn/statusline/foldtext.

![Demo 2](https://raw.githubusercontent.com/OXY2DEV/nvim/refs/heads/images/images/nvim-fold-hover.png)

> Custom LSP hover, tree-sitter node hierarchy, different foldtext based on fold method(markers & expression).

![Demo 3](https://raw.githubusercontent.com/OXY2DEV/nvim/refs/heads/images/images/nvim-help-message.png)

> Decorated help files, custom message window(output of `:ls!`).

![Demo 4](https://raw.githubusercontent.com/OXY2DEV/nvim/refs/heads/images/images/nvim-blink.png)

> Completion(via `blink.cmp`) with documentation window(with markdown preview).

![Demo 5](https://raw.githubusercontent.com/OXY2DEV/nvim/refs/heads/images/images/nvim-ui.png)

> Custom UI for the cmdline, popup menu & messages.

