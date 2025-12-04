---@meta

--- Abstracted highlight group.
---@class config._hl
---
---@field name string Highlight group name.
---@field value vim.api.keyset.highlight Options for `vim.api.nvim_set_hl()`.


---@alias config.hl
---| config._hl Literal value.
---| fun(): config._hl Dynamic value.
---| fun(): config._hl[] Dynamic value list.


---@class config.hl.rgb RGB color.
---
---@field r integer
---@field g integer
---@field b integer


---@class config.hl.Lab OkLab color.
---
---@field L integer
---@field a integer
---@field b integer

