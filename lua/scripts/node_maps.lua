local node_maps = {};

---@type table<string, table>
node_maps.named = {
	default = {
		icon = "󰌪 ",
		icon_hl = "DiagnosticOk"
	},

	markdown = {
		document = {
			icon = "󰗚 ",
			icon_hl = "@property"
		},

		section = {
			icon = "󰛺 ",
			icon_hl = "@property"
		},

		["fenced_code_block$"] = {
			icon = " ",
			icon_hl = "@property"
		},

		fenced_code_block_delimiter = {
			icon = " ",
			icon_hl = "@constant"
		},

		info_string = {
			icon = "󰋼 ",
			icon_hl = "@property"
		},

		language = {
			icon = "󰗊 ",
			icon_hl = "@string"
		},

		block_continuation = {
			icon = "󱞦 ",
			icon_hl = "@comment"
		},
	},

	lua = {
		chunk = {
			icon = "󰐱 ",
			icon_hl = "@property"
		},

		["^comment"] = {
			icon = "󰔌 ",
		},

		["^func"] = {
			icon = "󰡱 ",
			icon_hl = "@function"
		},
	},

	lua_patterns = {
		pattern = {
			icon = "󰛪 ",
			icon_hl = "@property"
		},
		literal_character = {
			icon = "󰾽 ",
			icon_hl = "@string"
		},
	},
};

return node_maps;
