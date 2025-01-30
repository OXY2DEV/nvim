--- Path containing `lazy.nvim`.
---@type string
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim";

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	--- If `lazy.nvim` doesn't exits we
	--- clone the repository.
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath);

require("lazy").setup("plugins", {
	git = {
		log = { "-4" },
	},
	dev = {
		--- Personal plugins exist in `config/lua/custom_plugins`
		path = vim.fn.stdpath("config") .. "lua/custom_plugins",
		patterns = { "OXY2DEV" }
	},
	install = {
		colorscheme = { "default", "habamax" }
	},
	change_detection = {
		--- I currently don't have a use for this.
		enabled = false
	},
	ui = {
		size = { width = 1, height = 1 },

		border = "none",
		backdrop = 100,

		wrap = false,

		icons = {
			cmd = "  ",

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

			task = "  "
		}
	}
});
