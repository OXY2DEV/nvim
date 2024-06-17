local bars = {};
local statuscolumn = require("bars/statuscolumn");
local statusline = require("bars/statusline");
local tabline = require("bars/tabline");

---+ Title: "Default configuration"
---+2 Title: "Description"
---
--- A table containing various configuration related options for the plugin.
--- Used by the setup() function after merging(extending) with the user's
--- config table.
---
---_2

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
