return {
	{
		"hrsh7th/nvim-cmp",
		enabled = false,

		priority = 750,

		dependencies = {
			-- "hrsh7th/cmp-nvim-lsp",
			-- "hrsh7th/cmp-nvim-lua",
			-- "FelipeLema/cmp-async-path",
			--
			-- "chrisgrieser/cmp-nerdfont",
		},

		config = function ()
			---|fS "feat: Cmp"

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
					["<BS>"] = require("cmp").mapping.close(),

					["<left>"] = require("cmp").mapping.select_prev_item({ behavior = require("cmp").SelectBehavior.select }),
					["<right>"] = require("cmp").mapping.select_next_item({ behavior = require("cmp").SelectBehavior.select }),

					["<Up>"] = require("cmp").mapping.scroll_docs(-4),
					["<Down>"] = require("cmp").mapping.scroll_docs(4),
				},

				window = {
					completion = require("cmp").config.window.bordered(),
					documentation = require("cmp").config.window.bordered()
				},
			});

			---|fE
		end
	},
	{
		"Saghen/blink.cmp",
		lazy = false,
		version = "*",

		priority = 750,

		opts = {
			---|fS "feat: Blink"

			enabled = function ()
				-- ISSUE: Query files causes error if `blink.cmp` is used.
				return not vim.list_contains({
					"query",
				}, vim.bo.filetype);
			end,
			fuzzy = { implementation = "prefer_rust" },
			appearance = { nerd_font_variant = "mono" },
			cmdline = { enabled = false },

			completion = {
				menu = {
					auto_show = false,

					border = "rounded",
					max_height = math.floor(vim.o.lines * 0.5),

					winhighlight = "",

					draw = {
						cursorline_priority = 1,

						columns = {
							{ "custom_kinds", "custom_border" },
							{ "label", "label_description", gap = 1 },
						},
						components = {
							custom_kinds = {
								---|fS "style: Completion item types"

								text = function (context)
									local kind_config = vim.g.__completion_kinds or {
										default = {
											icon = "󰘎 ",
											hl = "CompletionDefault",

											border_hl = "CompletionDefaultBg"
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
											hl = "CompletionDefault",

											border_hl = "CompletionDefaultBg"
										},
									};

									local kind = string.lower(context.kind or "");
									local config = kind_config[kind] or kind_config.default;

									return config.hl;
								end

								---|fE
							},
							custom_border = {
								---|fS "style: Completion item types"

								text = function (context)
									local kind_config = vim.g.__completion_kinds or {
										default = {
											icon = "󰘎 ",
											hl = "Special"
										},
									};

									local kind = string.lower(context.kind or "");
									local config = kind_config[kind] or kind_config.default;

									return "▌";
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

									return config.border_hl;
								end

								---|fE
							},
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
						---|fS "feat: markview.nvim integration"

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

				["<C-Space>"] = { "show", "hide_documentation", "show_documentation" },
				["<CR>"] = { "accept", "fallback" },
				["<BS>"] = { "cancel", "fallback" },

				["<Left>"] = { "select_prev", "snippet_backward", "fallback" },
				["<Right>"] = { "select_next", "snippet_forward", "fallback" },

				["<Up>"] = { "scroll_documentation_up", "fallback" },
				["<Down>"] = { "scroll_documentation_down", "fallback" },
			},
			sources = {
				default = { "lsp", "path", "snippets", "omni", "buffer" },
			},

			---|fE
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
			---|fS "feat: Configuring LSP servers based on completion plugin"

			local loaded_cmp, lsp_cmp = pcall(require, "cmp-nvim-lsp");
			local loaded_blink, blink = pcall(require, "blink.cmp");

			---@type string[] LSP client names.
			local clients = {
				"lua_ls",
				"html", "ts_ls", "emmet_language_server",
				"basedpyright",
				"clangd",
				"rust_analyzer"
			};

			---@type table<string, table> Additional configurations for LSP servers.
			local custom_settings = {
				lua_ls = {
					settings = {
						Lua = {
							runtime = {
								version = "LuaJIT",
							},
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								library = { vim.env.VIMRUNTIME },
								 -- optional, to prevent `prompts`
								checkThirdParty = false,
							},
						}
					},
				}
			};

			for _, client in ipairs(clients) do
				---@type table Additional settings for this server.
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

				if vim.fn.has("nvim-0.11") == 1 then
					-- Use the new `vim.lsp.*` stuff.
					vim.lsp.config(client, settings);
					vim.lsp.enable(client, true);
				elseif pcall(require, "lspconfig") then
					require("lspconfig")[client].setup(settings);
				else
					vim.api.nvim_echo({
						{ "  plugins/lsp.lua ", "DiagnosticVirtualTextError" },
						{ ": No ", "@comment" },
						{ " vim.lsp ", "DiagnosticVirtualTextHint" },
						{ " or ", "@comment" },
						{ " lspconfig ", "DiagnosticVirtualTextHint" },
						{ " module found!", "@comment" },
					}, true, {});
				end
			end

			---|fE
		end
	},
};
