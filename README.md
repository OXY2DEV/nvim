<!--
##conf-doc##
author: OXY2DEV;
ft: lua;
fn: init;
##conf-doc-end
-->
# 📱 Dotfiles

Dotfiles to run `Neovim` on your phone using `termux`.

## 📖 Usage

First **backup** your old config files.

> If you don't have a config then you can skip this step.

```bash
mv ~/.config/nvim ~/.config/nvim.old
```

Now remove the **share** & **state** directories.

>[!Note]
> Not doing this may result in `plugin conflicts` or things not working properly.

```bash
rm -rf ~/.local/share/nvim/ ~/.local/state/nvim/
```

Now, clone the repository into your `~/.config/` directory.

```bash
git clone https://github.com/OXY2DEV/nvim.git/ ~/.config/
```

Now, open Neovim and install all the necessary plugins.

```bash
nvim
```

## 📂 Init file

The `init.lua` file is used to configure `Neovim`.

It has 3 parts.

### 🔩 Editor config

This part is used for configuring options, keymaps and other files that modifies the editor.

These files are meant to be loaded before the `plugin manager` and should create a usable setup even without any of the plugins.

```lua ${fold} ${type=dep}
require("config.settings");   -- Options
require("config.keymaps");    -- Keymaps
```

### 📜 Scripts

These are like a smaller version of `plugins`. They add some simple niceties.

```lua ${fold} ${type=dep}
require("scripts.beacon");           -- Beacon to show cursor
require("scripts.cmdline");          -- Custom cmdline
require("scripts.diagnostic");       -- Fancy diagnostic messages
require("scripts.terminal_bg_sync"); -- Background sync for Termux
```

### 💤 Lazy.nvim

I use `lazy.nvim` to install plugins. For plugin configuration I use the `plugins/plugin-name.lua` style.

So, I only load the plugin manager here.

```lua ${fold} ${type=dep}
require("config/lazy");
```

<!--
    vim:nospell:
-->
