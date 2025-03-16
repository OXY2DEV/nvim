return {
	{
		"hrsh7th/nvim-cmp",
		enabled = false,

		priority = 750,

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
					 completeopt = "menu,menuone,noinsert",
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
		version = "*",

		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		-- build = "RUSTC_BOOTSTRAP=1 cargo build --release",

		priority = 750,

		opts = {
			appearance = {
				nerd_font_variant = "normal"
			},
			cmdline = {
				enabled = false,
			},
			completion = {
				menu = {
					auto_show = false,

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
					window = { border = 'single' },
					-- draw = function (data)
					-- 	---|fS
					--
					-- 	if not data.item.documentation then
					-- 		-- Documentation not available.
					-- 		return;
					-- 	elseif data.item.documentation.kind ~= "markdown" then
					-- 		-- Documentation isn't in markdown.
					-- 		data.default_implementation();
					-- 		return;
					-- 	elseif package.loaded["markview"] == nil then
					-- 		-- markview.nvim not available.
					-- 		data.default_implementation();
					-- 		return;
					-- 	end
					--
					-- 	---@type integer
					-- 	local buf = data.window.buf;
					-- 	---@type string[]
					-- 	local lines = vim.split(data.item.documentation.value or "", "\n", { trimempty = true });
					-- 	---@type string[]
					-- 	local details = vim.split(data.item.detail or "", "\n", { trimempty = false });
					-- 	table.insert(details, "");
					--
					-- 	vim.print(data)
					-- 	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.list_extend(details, lines));
					--
					-- 	if vim.g.__reg_doc ~= true then
					-- 		vim.treesitter.language.register("markdown", "blink-cmp-documentation");
					-- 		vim.g.__reg_doc = true;
					-- 	end
					--
					-- 	if package.loaded["markview"] then
					-- 		local utils = package.loaded["markview.utils"];
					-- 		vim.defer_fn(function ()
					-- 			local window = utils.buf_getwin(buf);
					-- 			vim.wo[window].signcolumn = "no";
					-- 			vim.api.nvim_win_set_config(window, {
					-- 				border = "rounded",
					-- 			});
					--
					-- 			require("markview").strict_render:clear(buf);
					-- 			require("markview").strict_render:render(buf, 999);
					-- 		end, 25)
					-- 	end
					--
					-- 	---|fE
					-- end
				},
				-- signature = {
				-- 	window = { border = 'single' }
				-- }
			},
			keymap = {
				preset = "none",

				["<C-Space>"] = { "show", "show_documentation", "hide_documentation", "fallback" },
				["<CR>"] = { "accept", "fallback" },

				["<Left>"] = { "snippet_backward", "cancel", "fallback" },
				["<Right>"] = { "select_next", "snippet_forward", "fallback" },

				["<Up>"] = { "scroll_documentation_up", "fallback" },
				["<Down>"] = { "scroll_documentation_down", "fallback" },
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					markdown = { "markview" }
				}
			},
		},
	},
	{
		"neovim/nvim-lspconfig",

		priority = 750,

		dependencies = {
			"Saghen/blink.cmp",
			-- "hrsh7th/nvim-cmp",
		},

		config = function ()
			local loaded_cmp, lsp_cmp = pcall(require, "cmp-nvim-lsp");
			local loaded_blink, blink = pcall(require, "blink.cmp");

			---@type string[] LSP client names.
			local clients = { "lua_ls", "html", "ts_ls", "emmet_ls", "css_ls" };

			for _, client in ipairs(clients) do
				if loaded_blink then
					require("lspconfig")[client].setup({
						capabilities = blink.get_lsp_capabilities()
					});
				elseif loaded_cmp == true then
					require("lspconfig")[client].setup({
						capabilities = lsp_cmp[client].default_capabilities()
					});
				else
					require("lspconfig")[client].setup({})
				end
			end
		end
	},
};
