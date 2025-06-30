local tree_maps = {};

tree_maps.injections = {
	default = {
		scope_hl = "MarkviewCode",
		icon = "󱏒 ",

		text = nil,
		hl = { "Injection0", "Injection1", "Injection2", },

		icon_hl = "@constant",
		text_hl = "@constant",
	},

	markdown_inline = {
		icon = "󰂽 ",
		text = "Markdown(inline)",

		hl = "Injection6",
		icon_hl = "@module",
		text_hl = "@module"
	},

	["^lua$"] = {
		icon = " ",
		text = "Lua",

		hl = "Injection5",
		icon_hl = "@function",
		text_hl = "@function"
	},

	luadoc = {
		icon = " ",
		text = "LuaDoc",

		hl = "Injection0",
		icon_hl = "@comment",
		text_hl = "@comment"

	},

	lua_patterns = {
		icon = " ",
		text = "Lua patterns",

		hl = "Injection2",
		icon_hl = "@constant",
		text_hl = "@constant"
	},

	yaml = {
		icon = "󰨑 ",
		text = "YAML",

		hl = "Injection2",
		icon_hl = "@constant",
		text_hl = "@constant"
	},
};

tree_maps.anon = {
	default = {
		icon = " ",
		icon_hl = "@constant"
	},
};

---@type table<string, table>
tree_maps.named = {
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

return tree_maps;
