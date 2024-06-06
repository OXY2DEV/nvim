local bars = {};
local statuscol = require("bars/statuscolumn");

bars.defaultConfig = {
	statusColumn = {
		enabled = true,
		config = {
			segmants = { "gap", "folds", "line_numbers", "border" },

			gap = {
				length = 1,
				fill = " "
			},
			folds = {
				padding = " ",
				placeholder = " ",
				folds = {
					{
						open = "",
						close = "",

						open_hl = "bars_fold_1_o",
						close_hl = "bars_fold_1_c"
					},
					{
						open = "",
						close = "",

						open_hl = "bars_fold_2_o",
						close_hl = "bars_fold_2_c"
					},
					{
						open = "󰍀",
						close = "󰌾",

						open_hl = "bars_fold_3_o",
						close_hl = "bars_fold_3_c"
					},
					{
						open = "",
						close = "",

						open_hl = "bars_fold_4_o",
						close_hl = "bars_fold_4_c"
					}
				},

				borders = {
					{
						top = "│",
						normal = "│",
						bottom = "╰",

						hl = "bars_fold_1_b",

						mix_branch = "├",
						mix_tail = "─"
					},
					{
						top = "┆",
						normal = "┆",
						bottom = "╰",

						hl = "bars_fold_2_b",

						mix_branch = "├",
						mix_tail = "┄"
					},
					{
						top = "╎",
						normal = "╎",
						bottom = "╰",

						hl = "bars_fold_3_b",

						mix_branch = "├",
						mix_tail = "╌"
					},
					{
						top = "|",
						normal = "|",
						bottom = "╰",

						hl = "bars_fold_4_b",

						mix_branch = "├",
						mix_tail = "╶"
					},
				},

				custom_hls = {
					bars_fold_1_c = { fg = "#74C7EC" },
					bars_fold_1_o = { fg = "#3b566d" },
					bars_fold_1_b = { fg = "#585b70" },

					bars_fold_2_c = { fg = "#A6E3A1" },
					bars_fold_2_o = { fg = "#4b6054" },
					bars_fold_2_b = { fg = "#62657b" },

					bars_fold_3_c = { fg = "#F9E2AF" },
					bars_fold_3_o = { fg = "#675f59" },
					bars_fold_3_b = { fg = "#6c7086" },

					bars_fold_4_c = { fg = "#CBA6F7" },
					bars_fold_4_o = { fg = "#574b71" },
					bars_fold_4_b = { fg = "#757a91" },
				}
			},
			line_numbers = {
				colors = {
					from = "#9399B2",
					to = "#585B70",

					steps = 10,
					ease = "ease-in-sine",

					hl_prefix = "bars_number_",
					current_line = {
						hl_name = "bars_current_line",
						value = {
							fg = "#89B4FA"
						}
					}
				}
			},
			border = {
				colors = {
					from = "#89B4FA",
					to = "#585B70",

					steps = 10,
					ease = "ease-in-quad",

					hl_prefix = "bars_border_",
				},

				border_character = "│",
				fold_connector = "├─"
			}
		}
	}
};

--- Setup function for bars-N-lines
--- @param userConfig table | nil
bars.setup = function (userConfig)
	local use = vim.tbl_deep_extend("keep", userConfig or {}, bars.defaultConfig);

	vim.g.nestFolds = false;
	statuscol.setup(use.statusColumn);
end

return bars;
