# 💻 OXY2DEV's setup for **Android** & **MacOS**

A bare-bones(& general purpose) `Neovim` configuration.

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




