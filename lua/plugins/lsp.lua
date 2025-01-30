return {
	{
		"hrsh7th/nvim-cmp",
		enabled = false,

		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"FelipeLema/cmp-async-path",

			"chrisgrieser/cmp-nerdfont",
		},

		config = function ()
			require("cmp").setup({
				performance = {
					debounce = 250,
					max_view_entries = 5
				},

				sources = {
					{ name = "nvim_lua", keyword_length = 2 },
					{ name = "nvim_lsp", keyword_length = 2 },

					{ name = "buffer", keyword_length = 4 },
					{ name = "async_path", keyword_length = 2 },

					{ name = "nerdfont" },
				},

				completion = {
					 completeopt = "menu,menuone,noinsert"
				},

				experimental = {
					ghost_text = false
				},
				mapping = {
					["<CR>"] = require("cmp").mapping.confirm({ select = true }),
					-- ["<Tab>"] = require("cmp").mapping.complete(),

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
			});
		end
	},
	{
		"Saghen/blink.cmp",
		lazy = false,
		build = "RUSTC_BOOTSTRAP=1 cargo build --release",
		opts = {
			appearance = {
				nerd_font_variant = "normal"
			},
			completion = {
				menu = {
					auto_show = function(ctx)
						return ctx.mode ~= "cmdline";
					end,

					border = "rounded",
					-- max_width = math.floor(vim.o.columns * 0.5),
					max_height = math.floor(vim.o.lines * 0.5),

					winhighlight = "",

					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "custom_kinds" }
						},
						components = {
							custom_kinds = {
								text = function (context)
									local kind_config = vim.g.__completion_kinds or {
										default = {
											icon = "󰘎 ",
											hl = "Special"
										},
									};

									local kind = string.lower(context.kind or "");
									local config = kind_config[kind] or kind_config.default;

									return config.icon;
								end,
								highlight = function (context)
									local kind_config = vim.g.__completion_kinds or {
										default = {
											icon = "󰘎 ",
											hl = "Special"
										},
									};

									local kind = string.lower(context.kind or "");
									local config = kind_config[kind] or kind_config.default;

									return config.hl;
								end
							}
						}
					}
				},
				documentation = {
					window = { border = 'single' }
				},
				-- signature = {
				-- 	window = { border = 'single' }
				-- }
			},
			keymap = {
				preset = "none",

				["<Tab>"] = { "show", "show_documentation", "hide_documentation", "fallback" },
				["<CR>"] = { "accept", "fallback" },

				["<Left>"] = { "snippet_backward", "cancel", "fallback" },
				["<Right>"] = { "select_next", "snippet_forward", "fallback" },

				["<Up>"] = { "scroll_documentation_up", "fallback" },
				["<Down>"] = { "scroll_documentation_down", "fallback" },

				cmdline = {}
			}
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"Saghen/blink.cmp",
			-- "hrsh7th/nvim-cmp",
		},

		config = function ()
			local loaded_cmp, lsp_cmp = pcall(require, "cmp-nvim-lsp");
			local loaded_blink, blink = pcall(require, "blink.cmp");

			if loaded_blink then
				require("lspconfig")["lua_ls"].setup({
					capabilities = blink.get_lsp_capabilities()
				});
			elseif loaded_cmp == true then
				require("lspconfig")["lua_ls"].setup({
					capabilities = lsp_cmp["lua_ls"].default_capabilities()
				});
			else
				require("lspconfig")["lua_ls"].setup({})
			end
		end
	},
};
