return {
	"hrsh7th/nvim-cmp",

	dependencies = {
		"neovim/nvim-lspconfig",

		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-nvim-lua",
		"FelipeLema/cmp-async-path",

		"f3fora/cmp-spell",
		"chrisgrieser/cmp-nerdfont",
	},

	config = function ()
		local capabilities = require('cmp_nvim_lsp').default_capabilities();

		require("cmp").setup({
			performance = {
				debounce = 250,
				max_view_entries = 5
			},

			sources = {
				{ name = "nvim_lsp", keyword_length = 2 },
				{ name = "nvim_lua", keyword_length = 2 },
				--{ name = "treesitter" },
				--{ name = "luasnip" },

				{ name = "buffer", keyword_length = 4 },
				{ name = "async_path", keyword_length = 2 },

				--{ name = "spell", keyword_length = 3 },
				{ name = "nerdfont" },
			},

			completion = {
				 completeopt = 'menu,menuone,noinsert'
			},

			mapping = {
				["<CR>"] = require("cmp").mapping.confirm({ select = true }),
				["<C-c>"] = require("cmp").mapping.complete(),

				["<Up>"] = require("cmp").mapping.select_prev_item({ behavior = require("cmp").SelectBehavior.select }),
				["<Down>"] = require("cmp").mapping.select_next_item({ behavior = require("cmp").SelectBehavior.select }),

				["<C-Up>"] = require("cmp").mapping.scroll_docs(-4),
				["<C-Down>"] = require("cmp").mapping.scroll_docs(4),
				["<Left>"] = require("cmp").mapping.close(),
			},

			window = {
				completion = require("cmp").config.window.bordered(),
				documentation = require("cmp").config.window.bordered()
			},

			experimental = {
				ghost_text = true
			}
		});

		-- Set up lspconfig.
		require('lspconfig')['tsserver'].setup {
			capabilities = capabilities
		};
		require('lspconfig')['lua_ls'].setup {
			capabilities = capabilities
		}
	end
}
