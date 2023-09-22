local fb_actions = require("telescope._extensions.file_browser.actions")

require("telescope").setup {
  extensions = {
    file_browser = {
			-- Do not USE the theme "Ivy" if you want floating file browser
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
      mappings = {
        ["i"] = {
					["<leader>c"] = fb_actions.create,
					["<leader>r"] = fb_actions.rename,
					["<leader>m"] = fb_actions.move,
					["<leader>y"] = fb_actions.copy,
					["<leader>d"] = fb_actions.remove,
					["<leader>c"] = fb_actions.create,
					["<leader>b"] = fb_actions.toggle_browser,
					["<leader>h"] = fb_actions.toggle_hidden,
        },
        ["n"] = {
          -- your custom normal mode mappings
        },
      },
    },
  },
}
-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
require("telescope").load_extension "file_browser"
require('telescope').load_extension "notify"
