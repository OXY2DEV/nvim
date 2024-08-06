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
		-- 	-- highlight_groups = presets.highlight_groups.colorful_heading_bg,
		-- 	-- tables = presets.tables.border_double
		-- 	-- headings = presets.headings.glow_labels
		-- })
	end
}
