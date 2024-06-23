#  🎇 bars-N-lines.nvim

Custom statuscolumn, statusline & tabline for `neovim`.

Features:
- Highly customisable statuscolumn, statusline & tabline.
- Custom fold column
- Custom sign column(with resize support when there are no signs)
- Buffer list/window list on tabline
- Click functionality on buffer names & tab numbers in tabline
- Built for small screens(e.g. mobile)

> 🎨 Color utility features
- Functions to turn `hex` & `rgb` colors into tables
- Built-in gradient generator function
- Various easing options for creating gradients

>[!NOTE]
> This plugin is meant for personal use case and as such **WILL** go through breaking changes quite often.

## Usage

For setting up the plugin you can just call `require("bars").setup()`.

The setup function with all of the available options is given below.

```lua
require("bars").setup({
    global_disable = {
        filetypes = {},
        buftypes = {}
    },

    default = {
        statuscolumn = {
            enable = true,
            options = {}
        },
        statusline = {
            enable = true,
            options = {}
        },

        tabline = {
            enable = true,
            options = {}
        }
    },

    custom_configs = {}
});
```

Here's what all of them do,

> global_disable `{ filetypes: string[], buftypes: string[] } or nil`

You can set specific filetypes and buftypes where the plugin will be *disabled*.

>[!NOTE]
> On buffers where the plugin is disabled the `statuscolumn`, `statusline` & `tabline` will not be set.
>
> If you would like to *hide* them for a specific buffer use the `custom_configs` option.

> default `{ statuscolumn: statuscolumn_config?, statusline: statusline_config?, tabline: tabline_config? }`

Default configuration of the plugin. More info on the various keys of this table is provided in their own sections.

>[!IMPORTANT]
> When using the `custom_configs` options, options that are not set will be *inherited* from the `default` option.
>
> So, if you only set the `statusline` for a buffer the `statuscolumn` & `tabline` will be configured using the values in the `default` table.

> custom_configs `{ { buftypes: string[]?, filetypes: string[]?, config: default }[] } or nil`

Custom configuration table for specific filetypes & buftypes. Inherits values from the `default` table.

>[!NOTE]
> If `filetypes` & `buftypes` are set together then the plugin will try to match both of them first and then will match them individually.
>
> This currently **has no extra functionality** and an option will be provided to better control this behaviour.

<!-- 
    vim:spell
-->
