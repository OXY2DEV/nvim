---@meta

--[[ Configuration for *fancy* diagnostics. ]]
---@class diagnostics.config
---
---@field keymap string Key used for keymap.
---
--- Maximum height for the diagnostics window.
---@field max_height
---| integer
---| fun(items: vim.Diagnostic[]): integer
---
--- Width for the diagnostics window.
---@field width
---| integer
---| fun(items: vim.Diagnostic[]): integer
---
---@field decoration_width integer Width of the decorations.
---@field decorations table<integer, diagnostics.decorations> Decorations for each diagnostic severity.


---@class diagnostics.decorations
---
---@field width integer Width of the decoration.
---
---@field line_hl_group? string | fun(item: table, current: boolean): string Highlight group for the line.
---
---@field icon diagnostics.decoration_fragment[] | fun(item: table, current: boolean): diagnostics.decoration_fragment[] Decoration for the start line.
---@field padding? diagnostics.decoration_fragment[] | fun(item: table, current: boolean): diagnostics.decoration_fragment[] Decoration for the other line(s).


---@class diagnostics.decorations__static
---
---@field width integer Width of the decoration.
---
---@field line_hl_group? string Highlight group for the line.
---@field icon diagnostics.decoration_fragment[] Decoration for the start line.
---@field padding? diagnostics.decoration_fragment[] Decoration for the other line(s).


---@class diagnostics.decoration_fragment Virtual text fragment.
---
---@field [1] string Text to show
---@field [2] string? Highlight group.


--- Internal representation of a diagnostic. Used by the custom sign column.
---@class diagnostics.signs.entry
---
---@field start_row integer
---@field current boolean
---@field width integer
---
---@field icon diagnostics.decoration_fragment[]
---@field line_hl_group string
---@field padding diagnostics.decoration_fragment[]

