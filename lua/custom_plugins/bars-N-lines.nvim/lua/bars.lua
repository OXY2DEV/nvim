local bars = {};
local statuscolumn = require("bars/statuscolumn");
local statusline = require("bars/statusline");
local tabline = require("bars/tabline");

---+ Title: "Type definitions"

---@class primary_user_config table
---@field enabled boolean? Enables/Disables the sttauscolumn, can be set for specific windows too
---@field options table? Table containing various options related to the statuscolumn

---@class primary_user_options Options for the various bars & lines
---@field default_hl string? Default highlight group
---@field components component? | tabline_component?

---@class gap_config_table A table for creating empty spaces in the statuscolumn
---@field hl string? Highlight group for the gap
---@field text string The character(s) to use for the gap

---@class border_config_table A table for creating borders in the statuscolumn
---@field hl string | { from: number, to: number, prefix: string } | string[] | nil Highlight group for the border
---@field text string Text to use as the border

---@class number_config_table A table for creating line numbers
---@field mode string The mode for showing numbers
---@field hl string | { from: number, to: number, prefix: string } | string[] | nil Highlight group for the numbers
---@field right_align boolean? Right aligns the item when set to true

---@class fold_config_table A table for creating foldcolumn
---@field mode string The mode for showing folds
---@field hl { default: string?, opened: string?, closed: string?, scope: string?, branch: string?, edge: string? } Highlight groups for various parts of the foldcolumn
---@field text { closed: string?, opened: string?, scope: string?, branch: string?, edge: string? } The text used for various parts of the foldcolumn
---@field space string? The character(s) to use for lines with no folds


---@class component Raw component config
---@field bg string? The highlight to use for the component
---@field corner_left_hl string? Highlight group to use for the left corner
---@field corner_left string Text for the left corner
---@field padding_left_hl string? Highlight group for the left padding 
---@field padding_left string? Text for the left padding
---@field icon_hl string? Highlight group for the icon
---@field icon string? Text for the icon
---@field text_hl string? Highlight group for the text
---@field text string? Text for the text
---@field padding_right_hl string? Highlight group for the right padding 
---@field padding_right string? Text for the right padding
---@field corner_right_hl string? Highlight group to use for the right corner
---@field corner_right string Text for the right corner

---@class component_type_2 Raw component config
---@field bg string? The highlight to use for the component
---@field corner_left_hl string? Highlight group to use for the left corner
---@field corner_left string Text for the left corner
---@field padding_left_hl string? Highlight group for the left padding 
---@field padding_left string? Text for the left padding
---@field icon_hl string? Highlight group for the icon
---@field icon string? Text for the icon
---@field segmant_left_hl string? Highlight group for the left segmant
---@field segmant_left string? Text for the left segmant
---@field separator_hl string? Highlight group for the separator
---@field separator string? Text for the separator
---@field segmant_right_hl string? Highlight group for the right segmant
---@field segmant_right string? Text for the right segmant
---@field padding_right_hl string? Highlight group for the right padding 
---@field padding_right string? Text for the right padding
---@field corner_right_hl string? Highlight group to use for the right corner
---@field corner_right string Text for the right corner
---@class mode_component Component configuration table for showing vim mode
---@field default component Default values for unknown modes, gets inherited when they are not set for a mode
---@field modes table<string, component> } Configuration for various modes

---@class tabline_component Components for the tabline
---@field prefix string? Things to add before the component, doesn't count towards the text length
---@field click string? Click handler, enclosed within %@...@
---@field bg string? The highlight to use for the component
---@field corner_left_hl string? Highlight group to use for the left corner
---@field corner_left string Text for the left corner
---@field padding_left_hl string? Highlight group for the left padding 
---@field padding_left string? Text for the left padding
---@field icon_hl string? Highlight group for the icon
---@field icon string? Text for the icon
---@field text_hl string? Highlight group for the text
---@field text string? Text for the text
---@field padding_right_hl string? Highlight group for the right padding 
---@field padding_right string? Text for the right padding
---@field corner_right_hl string? Highlight group to use for the right corner
---@field corner_right string Text for the right corner
---@field postfix string? Things to add after the component, doesn't count towards the text length

---@class separator_config Configuration table for the separator
---@field direction string? The direction where the separator will be placed
---@field text string The text to use as the separator
---@field hl string? The highlight group for the separator
---@field condition function Function to determine whether to draw the separator
---@field on_complete function Function to dun after rendering the separator
---@field on_skip function Function to run after the component is rendered but the separator isn't

---_

---+ Title: "Default configuration"
---
--- A table containing various configuration related options for the plugin.
--- Used by the setup() function after merging(extending) with the user's
--- config table.
---

---+2 Title: "Code"

---@class default_config
---@field global_disable nil | table Filetypes where the plugin will be disabled
---@field custom_settings nil | table[] Configuration for specific filetupes and/or buftypes
---@field statuscolumn nil | table Configuration for the staruscolumn
bars.default_config = {
	global_disable = {
		filetypes = { "help", "Lazy" },
		buftypes = { "terminal", "nofile" }
	},
	custom_configs = {
	},

	default = {
		tabline = {
			enabled = true,
			options = {
				components = {
					{ type = "buffers_all" },
					{ type = "gap" },
					-- { type = "separator" },
					{ type = "tabs" }
				}
			}
		},
		statusline = {
			enabled = true,
			options = {
				set_defaults = true,

				components = {
					{ type = "mode" },
					{ type = "buf_name" },

					{ type = "gap" },

					{ type = "cursor_position" }
				}
			}
		},
		statuscolumn = {
			enabled = true,
			options = {
				set_defaults = true,

				default_hl = "statuscol_bg",
				components = {
					{
						type = "fold",
						mode = "line",

						text = {
							default = " ",
							closed = {
								"", "", ""
							},
							opened = "",

							edge = "╰",
							branch = "┝",
							scope = "│"
						},

						hl = {
							--default = "FloatShadow",
							closed = "Special",
							opened = "Normal",

							scope = "Bars_scope",
							edge = "Bars_scope"
						}
					},
					{
						type = "gap",

						text = " "
					},
					{
						type = "number",
						mode = "hybrid",

						hl = {
							prefix = "Bars_glow_num_",
							from = 0, to = 9
						},
						right_align = true
					},
					{
						type = "gap",

						text = " "
					},
					{
						type = "border",

						hl = {
							prefix = "Bars_glow_",
							from = 0, to = 7
						},
						text = "│"
					},
					{
						type = "gap",

						text = " "
					},
				}
			}
		}
	}
};

---_2
---_

--- Inherits value from the specified table
---@param table table Original table
---@param inherit_from table Table to inherit from
---@return table
local inherit = function (table, inherit_from)
	for key, value in pairs(table) do
		if value == "inherit" then
			table[key] = inherit_from[key];
		end
	end

	return table;
end

local winValidate = function (window, config)
	local use_config = {};

	if vim.tbl_contains(config.global_disable.filetypes or {}, vim.bo.filetype) then
		goto config_set
	end

	if vim.tbl_contains(config.global_disable.buftypes or {}, vim.bo.buftype) then
		goto config_set
	end


	if vim.islist(config.custom_configs) == true then
		for _, conf in ipairs(config.custom_configs) do
			if vim.tbl_contains(conf.filetypes or {}, vim.bo.filetype) and vim.tbl_contains(conf.buftypes or {}, vim.bo.buftype) then
				use_config = inherit(conf.config, config.default or {});

				goto config_set
			elseif vim.tbl_contains(conf.filetypes or {}, vim.bo.filetype) or vim.tbl_contains(conf.buftypes or {}, vim.bo.buftype) then
				use_config = inherit(conf.config, config.default or {});

				goto config_set
			end
		end
	end

	use_config = config.default;
	::config_set::

	statuscolumn.init(window, use_config.statuscolumn);
	statusline.init(window, use_config.statusline);
	tabline.init(use_config.tabline);
end

bars.setup = function (user_config)
	local merged_config = vim.tbl_deep_extend("force", bars.default_config, user_config or {});

	vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
		pattern = "*",
		callback = function (data)
			local windows = vim.fn.win_findbuf(data.buf);

			for _, window in ipairs(windows) do
				winValidate(window, merged_config);
			end
		end
	});

	vim.api.nvim_create_autocmd({ "WinEnter", "TabEnter" }, {
		pattern = "*",
		callback = function ()
		end
	});
end

return bars;
