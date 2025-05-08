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

		priority = 750,

		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		-- build = "RUSTC_BOOTSTRAP=1 cargo build --release",

		opts = {
			fuzzy = {
				implementation = "lua",
			},
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
					auto_show = true,
					auto_show_delay_ms = 0,

					window = {
						border = "rounded",
						min_width = 30,
						winhighlight = ""
					},
					draw = function (data)
						---|fS

						---@type integer
						local buf = data.window.buf;
						---@type integer
						local src_buf = vim.api.nvim_get_current_buf();

						---@type string[]
						local lines = {};

						if data.item and data.item.documentation then
							lines = vim.split(data.item.documentation.value or "", "\n", { trimempty = true });
						end

						---@type string[]
						local details = vim.split(data.item.detail or "", "\n", { trimempty = true });

						if #details > 0 then
							table.insert(details, 1, string.format("```%s", vim.bo[src_buf].ft or ""));
							table.insert(details, "```");

							if #lines > 0 then
								details = vim.list_extend(details, {
									"",
									"Detail: ",
									"--------",
									""
								});
							end
						end

						local visible_lines = vim.list_extend(details, lines);
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, visible_lines);

						if vim.g.__reg_doc ~= true then
							vim.treesitter.language.register("markdown", "blink-cmp-documentation");
							vim.g.__reg_doc = true;
						end

						if package.loaded["markview"] then
							local win = data.window:get_win();

							if win then
								vim.bo[buf].ft = "markdown";
								require("markview").render(buf, { enable = true, hybrid_mode = false });
								vim.bo[buf].ft = "blink-cmp-documentation";
							end

							vim.defer_fn(function ()
								win = data.window:get_win();

								if win then
									vim.wo[win].signcolumn = "no";
								end

									vim.bo[buf].ft = "markdown";
									require("markview").render(buf, { enable = true, hybrid_mode = false });
									vim.bo[buf].ft = "blink-cmp-documentation";
							end, 25);
						end

						---|fE
					end,
				},
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
			local clients = {
				"lua_ls",
				"html", "ts_ls", "emmet_ls",
				"basedpyright",
				"clangd"
			};
			local custom_settings = {
				lua_ls = {
					settings = {
						Lua = {
							runtime = {
								version = 'LuaJIT', -- Neovim uses LuaJIT
							},
							diagnostics = {
								globals = {'vim'}, -- recognize `vim` global
							},
							workspace = {
								library = _G.is_within_termux() and nil or _G.BASE_RUNTIME,
								checkThirdParty = false, -- optional, to prevent prompts
							},
						}
					},
				}
			};

			for _, client in ipairs(clients) do
				local settings = custom_settings[client] or {};

				if loaded_blink then
					settings = vim.tbl_deep_extend("keep", settings, {
						capabilities = blink.get_lsp_capabilities()
					});
				elseif loaded_cmp == true then
					settings = vim.tbl_deep_extend("keep", settings, {
						capabilities = lsp_cmp[client].default_capabilities()
					});
				end

				require("lspconfig")[client].setup(settings);
			end
		end
	},
};
