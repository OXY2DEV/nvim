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
			icon_hl = "@comment"
		},

		section = {
			icon = "󰛺 ",
			icon_hl = "@comment"
		},

		["fenced_code_block$"] = {
			icon = " ",
			icon_hl = "@module"
		},

		fenced_code_block_delimiter = {
			icon = " ",
			icon_hl = "@constant"
		},
	},

	lua = {
		["^comment"] = {
			icon = "󰔌 ",
		},

		["^func"] = {
			icon = "󰡱 ",
			icon_hl = "@function"
		}
	}
};

return node_maps;
