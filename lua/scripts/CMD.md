# 🔰 A beginners guide to create custom cmdline

![showcase](https://gist.github.com/user-attachments/assets/1841184c-94dd-426f-b0eb-2077eab1fc9f)

Ever wanted to know how `noice` creates the cmdline or wanted your own one?

> No one? Guess it's just me 🥲.

Anyway, this post is a simple tutorial for creating a *basic* cmdline in Neovim.

>[!NOTE]
> Before you start doing this, I suggest you open at least 2 sessions of Neovim(1 for testing, 1 where you will be writing the code).

>[!CAUTION]
> In my previous attempt(a while ago), there used to be a few visual bugs with this(e.g. not showing anything when using `s/` replacements, keymaps using`:Command<CR>` never exiting out of cmdline mode, creating files with plugins, e.g. `telescope` causing a typewriter effect).
>
> These could be a side effect of copying codes from `noice` or some bug fix in 0.10.1 that fixed the issues.

If you experience any of these in latest or nightly(they should be fixed in 0.11-nightly) version I suggest waiting for the patch.

With that out of the way, let's talk about what we will be using.

```lua
vim.ui_attach();
```

This allows changing the various handlers(e.g. cmdline, popupmenu, messages) with your own lua functions.

Let's start by creating the basic things needed for the commandline.

```lua
-- I am using module to make this script portable
local cmd = {};

-- Namespace for highlights, extmarks & ui-events
cmd.ns = vim.api.nvim_create_namespace("cmd");
-- Buffer holding the cmdline text
cmd.buf = vim.api.nvim_create_buf(false, true);
-- We will store the cmdline window here later
cmd.win = nil;
-- Store cursor info, so that we can unhide it later
cmd.cursor = nil;

-- Different events peovide different information
-- so use ... to handle all of them with ease
vim.ui_attach(cmd.ns, { ext_cmdline = true }, function(event, ...)
    if event == "cmdline_show" then
        -- Cmdline is shown
    elseif event == "cmdline_close" then
        -- Cmdline is closed
    elseif event == "cmdline_pos" then
        -- Cursor moving in the cmdline
    end
end)
```

First, let's deal with `cmdline_show`.

```lua
if event == "cmdline_show" then
    local content, pos, firstc, prompt, indent, level = ...;
    -- Content: The text to show
    -- Pos: Cursor postion(byte-based)
    -- firstc: The symbol used to enter the cmdline
    --         E.g. :, ?, /, <CTRL-r>= etc.
    -- Prompt: Used when taking input via the cmdline
    -- Indent: Indentation for the text
    -- Level: Used for distinguishing recursive cmdlines
end
```
We will only be using `content`, `pos` & `firstc` for now.

Let's store them in a variable to use inside *other functions*.

```lua
-- Table to store all of the provided variable
cmd.state = {};

-- Wrapper function so that we can also only update
-- specific variables
-- This will come in handy later
cmd.update_state = function (state)
    cmd.state = vim.tbl_extend("force", cmd.state, state);
end
```

Now, we use `update_state` inside the `cmdline_show` condition.

```lua
if event == "cmdline_show" then
    local content, pos, firstc, prompt, indent, level = ...;
        
    cmd.update_state({
        content = content,
        position = pos,
        firstc = firstc,
        prompt = prompt,
        indent = indent,
        level = level
    });
end
```

Time to draw stuff!

```lua
cmd.open = function ()
    -- Cmdline width, height
    local w = math.floor(vim.o.columns * 0.6);
    local h = 1;

    if cmd.win and vim.api.nvim_win_is_valid(cmd.win) then
    end

    cmd.win = vim.api.nvim_open_win(cmd.buf, false, {
        relative = "editor",

        -- The borders take 2 extra rows
        row = math.floor((vim.o.lines - (h + 2)) / 2),
        col = math.floor((vim.o.columns - w) / 2),

        width = w, height = h,
        -- Very high zindex so it doesn't open under other
        -- windows, 250 should be enough
        zindex = 250,

        border = "rounded"
    });

    -- Generic options to make the window look clean
    vim.wo[cmd.win].number = false;
    vim.wo[cmd.win].relativenumber = false;
    vim.wo[cmd.win].statuscolumn = "";

    vim.wo[cmd.win].wrap = false;
    vim.wo[cmd.win].spell = false;
    vim.wo[cmd.win].cursorline = false;

    vim.wo[cmd.win].sidescrolloff = 10;

    -- Optional, for syntax highlighting
    vim.bo[cmd.buf].filetype = "vim";

    -- Store the value of `guicursor`
    if vim.opt.guicursor ~= "" then
        cmd.cursor = vim.opt.guicursor;
    else
        -- This is the default value, since we can't set it to ""
        cmd.cursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20";
    end

    -- First ceate a highlight group named `CursorHidden`.
    -- It's value should have "blend = 100" to become hidden.
    -- You can also set it's fg & bg to Neovim's background color.
    vim.opt.guicursor = "a:CursorHidden";
end
```

To actually see this window we will have to *redraw* the screen. But just calling `:redraw!` wouldn't work for us.

We only update the `cmdline` or else you might see the cursor jumping around.

```lua
-- Only updates the cmdline window and flushes out any
-- pending updates(e.g. text being changed)
vim.api.nvim__redraw({ win = cmd.win, flush = true })
```

You can either add it in the `if ... end` part or in the `open` function. But I suggest you add it inside `if ... end`

You should have something like this now.

```lua
if event == "cmdline_show" then
    local content, pos, firstc, prompt, indent, level = ...;
        
    cmd.update_state({
        content = content,
        position = pos,
        firstc = firstc,
        prompt = prompt,
        indent = indent,
        level = level
    });

    cmd.open();

    vim.api.nvim__redraw({ win = cmd.win, flush = true });
end
```

Now, let's handle the closing of the window. Let's create the closing function.

```lua
cmd.close = function ()
    -- If the cmdline's level is more then 1
    -- then it would return to it's previous level
    -- when exiting so the cmdline will still be open
    if cmd.state.level > 1 then
        return;
    end

    pcall(vim.api.nvim_win_close, cmd.win, true);

    cmd.win = nil;
    vim.opt.guicursor = cmd.cursor;
end
```

Now, we add it to the "cmdline_hide" condition.

```lua
if event == "cmdline_show" then
    local content, pos, firstc, prompt, indent, level = ...;
        
    cmd.update_state({
        content = content,
        position = pos,
        firstc = firstc,
        prompt = prompt,
        indent = indent,
        level = level
    });

    cmd.open();

    vim.api.nvim__redraw({ win = cmd.win, flush = true });
elseif event == "cmdline_hide" then
------------------------- *new* ------------------------------
    cmd.close();

    -- Call a redraw to update the ui
    -- Even if "cmd.win" is nil this will draw
    -- pending updates
    vim.api.nvim__redraw({ win = cmd.win, flush = true });
end
```

Now, Let's show stuff in the cmdline!

```lua
cmd.draw = function ()
    -- In case the text isn't available return early
    if not cmd.state or not cmd.state.content then
        return;
    end

    -- The text to show
    local txt = "";

    -- For every part in "content" we add the text of it
    -- to the "txt" variable
    for _, part in ipairs(cmd.state.content) do
        txt = txt .. part[2];
    end

    -- This shows the text
    vim.api.nvim_buf_set_lines(cmd.buf, 0, -1, false, { txt });
    -- This puts the cursor where the cursor should be inside
    -- the cmdline.
    -- This doesn't show the cursor!
    vim.api.nvim_win_set_cursor(cmd.win, { 1, cmd.state.position });

    -- Now we show a *fake* cursor
    if cmd.state.position >= #txt then
        -- Cursor is most likely at the end of the text
        -- Use a virtual text to show the cursor
        vim.api.nvim_buf_set_extmark(cmd.buf,
            cmd.ns,
            0,
            #txt,
            {
                virt_text_pos = "inline",
                virt_text = { { " ", "Cursor" } }
            }
        )
    else
        -- Cursor is inside the text
        -- Use a highlight to show it

        -- Text before the cursor
        -- Without using this we won't be able to correctly show
        -- the cursor when a character is *multi-byte*
        local before = string.sub(txt, 0, cmd.state.position);

        vim.api.nvim_buf_add_highlight(cmd.buf,
            cmd.ns,
            "Cursor",
            0,
            cmd.state.position,
            #vim.fn.strcharpart(txt, 0, vim.fn.strchars(before) + 1)
            --- Doing "(cmd.state.position - diff) + 1" doesn't
            --- work on multi-byte characters(e.g. emojis, nerd font
            --- characters)
        );
    end
end
```

Now, we add this to the "cmdline_show" & the "cmdline_pos" condition.

```lua
if event == "cmdline_show" then
    local content, pos, firstc, prompt, indent, level = ...;
        
    cmd.update_state({
        content = content,
        position = pos,
        firstc = firstc,
        prompt = prompt,
        indent = indent,
        level = level
    });

    cmd.open();
    cmd.draw();

    vim.api.nvim__redraw({ win = cmd.win, flush = true });
elseif event == "cmdline_hide" then
    cmd.close();

    -- Call a redraw to update the ui
    -- Even if "cmd.win" is nil this will draw
    -- pending updates
    vim.api.nvim__redraw({ win = cmd.win, flush = true });
elseif event == "cmdline_pos" then
------------------------- *new* ------------------------------
    cmd.draw();

    vim.api.nvim__redraw({ win = cmd.win, flush = true });
end
```

