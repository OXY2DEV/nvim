local quadrants = require("scripts.quadrants");
local hover = {};

--- LSP hover buffer.
---@type integer
hover.buffer = nil;

--- LSP hover window.
---@type integer
hover.window = nil;

--- LSP hover quadrant.
---@type
---| "center"
---| "top_left" 
---| "top_right"
---| "bottom_left"
---| "bottom_right"
hover.quad = nil;

--- Hover options.
---@class hover.opts
---
---@field border_hl? string | fun(): string
---
---@field name? [ string, string ][] | string | fun(): (string | [ string, string ][])
---
---@field min_width? integer | fun(): integer
---@field max_width? integer | fun(): integer


---@class hover.opts_static
---
---@field border_hl string
---
---@field name [ string, string ][] | string
---
---@field min_width integer
---@field max_width integer

--- Hover configuration.
---@type { default: hover.opts, [string]: hover.opts  }
hover.config = {
	default = {
		min_width = 5,
		max_width = function ()
			return math.floor(vim.o.columns * 0.75);
		end,

		name = {
			{ " " },
			{ "  LSP", "FloatBorder" },
			{ " " },
		},
		border_hl = "FloatBorder"
	},

	harper_ls = {
		name = {
			{ " " },
			{ "  Harper", "FloatBorder" },
			{ " " },
		},
		border_hl = "Color0"
	},
	clangd = {
		name = {
			{ " " },
			{ " Clangd", "FloatBorder" },
			{ " " },
		}
	},
	lua_ls = {
		name = {
			{ " " },
			{ " Lua", "Color5" },
			{ " " },
		},
		border_hl = "Color5"
	},
	ts_ls = {
		name = {
			{ " " },
			{ "󰖟 Tsserver", "FloatBorder" },
			{ " " },
		}
	},
	cssls = {
		name = {
			{ " " },
			{ " CSS", "FloatBorder" },
			{ " " },
		}
	},
	html = {
		name = {
			{ " " },
			{ " HTML", "FloatBorder" },
			{ " " },
		}
	}
};

--- Gets configuration for an LSP client.
---@param client_id integer
---@return hover.opts_static
hover.get_config = function (client_id)
	local client = vim.lsp.get_client_by_id(client_id);
	local keys = vim.tbl_keys(hover.config);

	keys = vim.tbl_filter(function (val)
		return val ~= "default";
	end, keys);
	table.sort(keys);

	---@type hover.opts
	local _c = hover.config.default or {};

	for _, key in ipairs(keys) do
		if string.match(client.name, key) then
			_c = vim.tbl_extend("force", _c, hover.config[key]);
			break;
		end
	end

	for k, v in pairs(_c) do
		if type(v) == "function" then
			local can_call, value = pcall(v);

			if can_call then
				_c[k] = value;
			else
				_c[k] = nil;
			end
		end
	end

	return _c;
end

hover.hover = function (error, result, context)
	if error then
		return;
	elseif hover.window and vim.api.nvim_win_is_valid(hover.window) then
		vim.api.nvim_set_current_win(hover.window);
	elseif vim.api.nvim_get_current_buf() ~= context.bufnr then
		return;
	elseif not result or not result.contents then
		return;
	else
		---@type string[]
		local lines = vim.split(result.contents.value, "\n", { trimempty = true });
		---@type hover.opts_static
		local config = hover.get_config(context.client_id);

		local max_w = config.max_width or 40;

		---@type integer
		local width = config.min_width;
		local height = 0;

		for _, line in ipairs(lines) do
			if vim.fn.strdisplaywidth(line) > width then
				width = math.min(config.max_width, vim.fn.strdisplaywidth(line));
				height = math.ceil(vim.fn.strdisplaywidth(line) / max_w);
			else
				height = height + 1;
			end
		end

		local ft;

		if type(result.contents) == "table" and result.contents.kind == "plaintext" then
			ft = "text";
		else
			ft = "markdown";
		end

		if not hover.buffer or vim.api.nvim_buf_is_valid(hover.buffer) == false then
			hover.buffer = vim.api.nvim_create_buf(false, true);
		end

		vim.bo[hover.buffer].ft = ft;
		vim.api.nvim_buf_set_lines(hover.buffer, 0, -1, false, lines);

		vim.api.nvim_buf_set_keymap(hover.buffer, "n", "q", "", {
			desc = "Close hover window",
			callback = function ()
				pcall(vim.api.nvim_win_close, hover.window, true);
			end
		});

		local winpos = vim.fn.getwinpos();

		width = width + 2;
		height = height + 2;

		hover.quad = quadrants.get_available_quadrant(nil, width, height, winpos[2], winpos[1]);
		quadrants.register(hover.quad);

		local win_config = {
			width = width,
			height = height - 1,

			style = "minimal"
		};

		if hover.quad == "center" then
			win_config.relative = "editor";

			win_config.row = math.ceil((vim.o.lines - height) / 2);
			win_config.col = math.ceil((vim.o.columns - width) / 2);

			win_config.title = config.name;
			win_config.title_pos = "left";

			win_config.border = {
				{ "╭", config.border_hl },
				{ "─", config.border_hl },
				{ "╮", config.border_hl },
				{ "│", config.border_hl },
				{ "╯", config.border_hl },
				{ "─", config.border_hl },
				{ "╰", config.border_hl },
				{ "│", config.border_hl },
			};
		elseif hover.quad == "top_left" then
			win_config.relative = "cursor";

			win_config.row = (-1 * height) - 1;
			win_config.col = (-1 * width) - 1;

			win_config.title = config.name;
			win_config.title_pos = "left";

			win_config.border = {
				{ "╭", config.border_hl },
				{ "─", config.border_hl },
				{ "╮", config.border_hl },
				{ "│", config.border_hl },
				{ "┤", config.border_hl },
				{ "─", config.border_hl },
				{ "╰", config.border_hl },
				{ "│", config.border_hl },
			};
		elseif hover.quad == "top_right" then
			win_config.relative = "cursor";

			win_config.row = (-1 * height) - 1;
			win_config.col = 0;

			win_config.title = config.name;
			win_config.title_pos = "right";

			win_config.border = {
				{ "╭", config.border_hl },
				{ "─", config.border_hl },
				{ "╮", config.border_hl },
				{ "│", config.border_hl },
				{ "╯", config.border_hl },
				{ "─", config.border_hl },
				{ "├", config.border_hl },
				{ "│", config.border_hl },
			};
		elseif hover.quad == "bottom_left" then
			win_config.relative = "cursor";

			win_config.row = 1;
			win_config.col = (-1 * width) - 1;

			win_config.footer = config.name;
			win_config.footer_pos = "left";

			win_config.border = {
				{ "╭", config.border_hl },
				{ "─", config.border_hl },
				{ "┤", config.border_hl },
				{ "│", config.border_hl },
				{ "╯", config.border_hl },
				{ "─", config.border_hl },
				{ "╰", config.border_hl },
				{ "│", config.border_hl },
			};
		elseif hover.quad == "bottom_right" then
			win_config.relative = "cursor";

			win_config.row = 1;
			win_config.col = 0;

			win_config.footer = config.name;
			win_config.footer_pos = "right";

			win_config.border = {
				{ "├", config.border_hl },
				{ "─", config.border_hl },
				{ "╮", config.border_hl },
				{ "│", config.border_hl },
				{ "╯", config.border_hl },
				{ "─", config.border_hl },
				{ "╰", config.border_hl },
				{ "│", config.border_hl },
			};
		end

		if not hover.window or vim.api.nvim_win_is_valid(hover.window) == false then
			hover.window = vim.api.nvim_open_win(hover.buffer, false, win_config);
		end

		vim.wo[hover.window].conceallevel = 3;
		vim.wo[hover.window].concealcursor = "n";
		vim.wo[hover.window].signcolumn = "no";

		vim.wo[hover.window].wrap = true;
		vim.wo[hover.window].linebreak = true;

		if package.loaded["markview"] and package.loaded["markview"].render then
			--- If markview is available use it to render stuff.
			--- This is for `v25`.
			require("markview").render(hover.buffer, { enable = true, hybrid_mode = false });
		end
	end
end

hover.setup = function (config)
	if type(config) == "table" then
		hover.config = vim.tbl_deep_extend("force", hover.config, config);
	end

	vim.lsp.handlers["textDocument/hover"] = hover.hover;

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		callback = function (event)
			if event.buf == hover.buffer then
				--- Don't do anything if the current buffer
				--- is the hover buffer.
				return;
			elseif hover.window and vim.api.nvim_win_is_valid(hover.window) then
				pcall(vim.api.nvim_win_close, hover.window, true);
				quadrants.clear(hover.quad);
				hover.window = nil;
			end
		end
	});
end

return hover;
