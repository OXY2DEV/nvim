require("catppuccin").setup({
	flavour = "mocha",																-- or use latte, frappe, macchiato, mocha
  background = {																	  -- :h background
    light = "latte",
    dark = "mocha",
  },
	transparent_background = false,										-- Background becomes transparent
	term_colors = false,															-- sets terminal colors (e.g. `g:terminal_color_0`). Has issues with windline
  dim_inactive = {
		enabled = true,																  -- dims the background color of inactive window
    shade = "dark",
    percentage = 0.05,														  -- percentage of the shade to apply to the inactive window
  },
	no_italic = true,																	-- Disablss Italics
	integrations = {																	-- Integrates with other plugins
		cmp = true,
    gitsigns = true,
    nvimtree = false,
    treesitter = true,
    notify = false,																	-- Disabled cause I don't like how it looks with the theme
    mini = true,
  }
})

vim.cmd.colorscheme "catppuccin"
