local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath);

require("lazy").setup("plugins", {
	ui = {
		size = {
			width = 0.9,
			height = 0.9
		},

		border = "rounded",
		title = "💤 Lazy.nvim",

		wrap = false,

		install = {
			colorscheme = { "habamax" }
		},

		icons = {
			cmd = "  ", ---+ ##code##

			config = "  ",
			event = "  ",
			ft = "  ",

			init = "  ",
			imports = "  ",

			keys = "  ",

			lazy = " ",
			loaded = " ",
			not_loaded = " ",

			plugin = "  ",
			runtime = "  ",
			require = "  ",

			source = " ",
			start = "",

			task = "  " ---_
		}
	}
})
