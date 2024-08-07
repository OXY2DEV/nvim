---+ name: Markview.nvim; |looks| ##plugin##
---
---_

return {
	-- "OXY2DEV/markview.nvim",
	dir = "~/.config/nvim/lua/custom_plugins/markview.nvim/",
	name = "markview",
	-- enabled = false,

	lazy = false,
	-- ft = "markdown",

	dependencies = {
		"nvim-tree/nvim-web-devicons"
	},

	config = function ()
-- require("markview").setup({
--     highlight_groups = {
--         {
--             group_name = "Heading1",
--             value = { fg = "#1e1e2e", bg = "#a6e3a1" }
--         },
--         {
--             group_name = "Heading1Corner",
--             value = { fg = "#a6e3a1" }
--         },
--     },
--     headings = {
--         enable = true,
--         shift_width = 0,
--
--         heading_1 = {
--             style = "label",
--
--             padding_left = " ",
--             padding_right = "",
--             padding_left_hl = "Heading1Corner",
--
--             hl = "Heading1"
--         }
--     }
-- });
		-- local def_conf = require("markview").configuration;
		--
		-- def_conf.tables = vim.tbl_extend("force", def_conf.tables, {
		-- 	enable = false
		-- })
		-- require("markview.extras.map").setup();
		-- local presets = require("markview.presets");
		--
		-- require("markview").setup({
		-- 	-- modes = { "n", "i", "c" },
		-- 	-- hybrid_modes = { "n" },
		-- 	--
		-- 	-- callbacks = {
		-- 	-- 	on_enable = function (_, win)
		-- 	-- 		vim.wo[win].conceallevel = 2;
		-- 	-- 		vim.wo[win].concealcursor = "c";
		-- 	-- 	end
		-- 	-- }
		--
		-- 	highlight_groups = presets.highlight_groups.h_decorated,
		-- 	-- tables = presets.tables.border_double
		-- 	headings = presets.headings.decorated_labels
		-- })
	end
}
