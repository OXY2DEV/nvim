return {
	"Zeioth/compiler.nvim",
	-- enabled = false,
	cmd = {
		"CompilerOpen",
		"CompilerToggleResults",
		"CompilerRedo"
	},
	dependencies = {
		{ -- The task runner we use
			"stevearc/overseer.nvim",
			commit = "6271cab7ccc4ca840faa93f54440ffae3a3918bd",
			cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
			opts = {
				task_list = {
					direction = "bottom",
					min_height = 25,
					max_height = 25,
					default_detail = 1
				},
			},
		},
		"nvim-telescope/telescope.nvim"
	},
	opts = {},
}
