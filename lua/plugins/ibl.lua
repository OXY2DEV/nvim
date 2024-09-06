return {
	"lukas-reineke/indent-blankline.nvim",
	enabled = false,
    main = "ibl",

	dependencies = {
		dir = "~/.config/nvim/lua/custom_plugins/colors.nvim/",
	},

    opts = {
		indent = {
			char = "▏"
		},
		-- scope = {
		-- 	highlight = {
		-- 		"BarsStatuscolumnFold1Marker",
		-- 		"BarsStatuscolumnFold2Marker",
		-- 		"BarsStatuscolumnFold3Marker",
		-- 		"BarsStatuscolumnFold4Marker",
		-- 		"BarsStatuscolumnFold5Marker",
		-- 		"BarsStatuscolumnFold6Marker",
		-- 	}
		-- }
	}
}
