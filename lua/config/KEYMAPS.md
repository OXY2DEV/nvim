<!--
##conf-doc##
author: OXY2DEV;
fn: keymaps; ft: lua;
##conf-doc-end##
-->
# 💻 Keymaps

As I am running `neovim` on my phone I realized that a lot of the keymaps were hard to use.

So, I had to make my own keymaps to *somewhat* add order to how I use keymaps.

## 🌯 Wrapper function

First, we make a **wrapper function** to make the process simpler.

```lua ${fold} ${type=func}
---@param config { mode: string?, opts: table?, lhs: string, rhs: string }
local keymap = function (config)
    config = vim.tbl_deep_extend("force", {
        mode = "n",
        opts = {
            silent = true
        }
    }, config);

    local success, _ = pcall(vim.api.nvim_set_keymap, config.mode, config.lhs, config.rhs, config.opts);

    if success == false then
        vim.notify("[ keymaps.lua ]: Failed to set keymap for <" .. (config.lhs or "") .. "> for " .. (config.mode or "") .. "mode", vim.log.levels.WARN);
    end
end
```

## 🔩 Setting the keympas

My keymap leader is set to `<Space>` as it's easy to access on my phone's keyboard.

So, all of the keymaps are designed with the `<Space>` key in mind.

### 🚦 Saving & quitting

Though exiting via `:q` is easy I still prefer using a simple keymap for saving & exiting.

```lua
keymap({ lhs = "<leader>q", rhs = "<CMD>q<CR>" });
keymap({ lhs = "<leader>w", rhs = "<CMD>w<CR>" });

keymap({ lhs = "<leader>W", rhs = "<CMD>wq<CR>" });
keymap({ lhs = "<leader>Q", rhs = "<CMD>q!<CR>" });

keymap({ lhs = "<leader>x", rhs = "<CMD>qa<CR>" });
keymap({ lhs = "<leader>X", rhs = "<CMD>qa!<CR>" });
```

### 🌟 Editing

Though `vim-motions` are made to be efficient, sometimes they either get in the way or hard just hard to use.

```lua
keymap({ lhs = "u", rhs = "" });
keymap({ mode = "v", lhs = "u", rhs = "" });

keymap({ lhs = "<leader>u", rhs = "<CMD>undo<CR>" });
keymap({ lhs = "<leader>r", rhs = "<CMD>redo<CR>" });
```

And now for toggling folds under cursor.

```lua
keymap({
    mode = "n",
    lhs = "ff",
    rhs = "",

    opts = {
        callback = function ()
            local cursor = vim.api.nvim_win_get_cursor(0);

            if vim.fn.foldlevel(cursor[1]) < 1 then
                return;
            end

            if vim.fn.foldclosed(cursor[1]) ~= -1 then
                vim.cmd("foldopen");
            else
                vim.cmd("foldclose");
            end
        end
    }
});
```

And obviously, I need a keymap to quickly run `lua` code for testing things.

```lua
keymap({ mode = "n", lhs = "<leader>l", rhs = "<CMD>.lua<CR>" });
keymap({ mode = "v", lhs = "<leader>l", rhs = ":...'<,'>lua<CR>" });
```

>[!Note]
> I prefer not to change the mode if possible to reduce bugs with the custom cmdline(until I manage to fix the bugs).

### 🔭 Telescope

I have a few keymaps dedicated just for `telescope`.

```lua
keymap({ mode = "n", lhs = "<leader>t", rhs = "<Cmd>Telescope<CR>" });
keymap({ mode = "n", lhs = "<leader>f", rhs = "<Cmd>Telescope file_browser<CR>" });
keymap({ mode = "n", lhs = "<leader>h", rhs = "<Cmd>Telescope highlights<CR>" });
```

### 🧭 Buffers & Tabs

I also set a few keymaps to navigate between buffers & tabs.

```lua
keymap({ mode = "n", lhs = "<leader>z", rhs = "<Cmd>tabp<CR>" })
keymap({ mode = "n", lhs = "<leader>m", rhs = "<Cmd>tabN<CR>" })

keymap({ mode = "n", lhs = "<leader>,", rhs = "<Cmd>BufScrollLeft<CR>" })
keymap({ mode = "n", lhs = "<leader>.", rhs = "<Cmd>TabScrollLeft<CR>" })
```

### 🚨 Diagnostic

I have a script that handles `diagnostic messages` and I toggle it via `<Space>d`.

```lua
keymap({
    mode = "n",
    lhs = "<leader>d",
    rhs = "",

    opts = {
        callback = function ()
            local module_found, diagnostic = pcall(
                require,
                "scripts.diagnostic"
            );

            if module_found == false then
                return;
            end

            if diagnostic.enable == true then
                diagnostic.enable = false;
                diagnostic.close();
            else
                diagnostic.enable = true;
                diagnostic.show();
            end
        end
    }
})
```

### 🌟 Compiler.nvim

I use `compiler.nvim` for quickly compiling C programs. So, I have a few keymaps for that.

```lua
keymap({ mode = "n", lhs = "<leader>c", rhs = "<Cmd>CompilerOpen<CR>" })
keymap({
    mode = "n",
    lhs = "<leader><S-c>",
    rhs = "<Cmd>CompilerStop<CR><Cmd>CompilerRedo<CR>"
})
keymap({ mode = "n", lhs = "<leader><S-t>", rhs = "<Cmd>CompilerToggleResults<CR>"})
```

## 🎁 Extras

I have these extra keymaps that are cool but not really *practical*.

### 🚨 Beacon

A beacon to show where the cursor currently is.

```lua ${ignore}
keymap({
    mode = "n",
    lhs = "<leader><leader>",
    rhs = "<Cmd>Beacon<CR>"
});
```

### ☄️ Smooth scroll

A set of keymaps to do smooth scrolling via `animations.nvim`.

```lua ${ignore}
local _guicursor;
local in_scroll = false;

createKeymap({
    mode = "n",
    lhs = "<PageDown>",
    rhs = "",

    opts = {
        callback = function ()
            local cursor = vim.api.nvim_win_get_cursor(0);

            if in_scroll == true then
                return;
            end

            require("animations").cursor.y(0, cursor[1] + math.floor(vim.o.lines * 0.75), {
                interval = 50,
                ease = "ease-out-sine",
                steps = 10,

                on_init = function ()
                    _guicursor = vim.g.guicursor;
                    in_scroll = true;

                    vim.cmd("set guicursor=a:CursorHidden");
                end,
                on_complete = function ()
                    in_scroll = false;
                    vim.cmd("set guicursor=" .. (_guicursor or "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"));
                end
            })
        end
    }
});
createKeymap({
    mode = "n",
    lhs = "<PageUp>",
    rhs = "",

    opts = {
        callback = function ()
            local cursor = vim.api.nvim_win_get_cursor(0);

            if in_scroll == true then
                return;
            end

            require("animations").cursor.y(0, cursor[1] - math.floor(vim.o.lines * 0.75), {
                interval = 50,
                ease = "ease-out-sine",
                steps = 10,

                on_init = function ()
                    _guicursor = vim.g.guicursor;
                    in_scroll = true;

                    vim.cmd("set guicursor=a:CursorHidden");
                end,
                on_complete = function ()
                    in_scroll = false;
                    vim.cmd("set guicursor=" .. (_guicursor or "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"));
                end
            })
        end
    }
});
```

