--- Custom LSP hover for Neovim.
local hover = {};

---|fS "Type definitions"


---@class hover.style Style for the hover window.
---
---@field condition? fun(client_name: string, result: table, context: table): boolean Condition for this style.
---
---@field width? integer | fun(client_name: string, result: table, context: table): integer Window width.
---@field height? integer | fun(client_name: string, result: table, context: table): integer Window height.
---@field winhl? string | fun(client_name: string, result: table, context: table): string Window's winhighlight.
---
---@field winopts? table | fun(client_name: string, result: table, context: table): table Options for `nvim_open_win()`.


---@class hover.style__static Static style, made after evaluating `hover.style`.
---
---@field width? integer Window width.
---@field height? integer Window height.
---@field winhl? string Window's winhighlight.
---
---@field winopts? table Options for `nvim_open_win()`.


---|fE

---@type table<string, hover.style>
hover.config = {
	default = {
		width = function ()
			return math.floor(vim.o.columns * 0.5)
		end,
	},

	lua_ls = {
		condition = function (client_name)
			return client_name == "lua_ls";
		end,

		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󰢱 LuaLS ", "@function" }
			}
		}
	},

	basedpyright = {
		condition = function (client_name)
			return client_name == "basedpyright";
		end,

		winopts = {
			footer_pos = "right",
			footer = {
				{ " 󰌠 BasedPyright ", "@constant" }
			}
		}
	},
};

--- Gets LSP style
---@param ... any
---@return hover.style__static
local function get_style (...)
	---|fS

	local keys = vim.tbl_keys(hover.config);
	local result = hover.config.default;

	table.sort(keys);

	for _, key in ipairs(keys) do
		if key ~= "default" then
			local val = hover.config[key];
			local ran_cond, cond = pcall(val.condition, ...);

			if ran_cond and cond then
				result = vim.tbl_deep_extend("force", result, val);
				break;
			end
		end
	end

	local final_val = {};

	for k, v in pairs(result) do
		if type(v) ~= "function" then
			final_val[k] = v;
		elseif k ~= "condition" then
			local can_eval, value = pcall(v, ...);

			if can_eval then
				final_val[k] = value;
			end
		end
	end

	return final_val;

	---|fE
end

------------------------------------------------------------------------------

---@type integer, integer Hover buffer & window.
hover.buffer, hover.window = nil, nil;

---@type "top_left" | "top_right" | "bottom_left" | "bottom_right"
hover.quad = nil;

--- Prepares the buffer for the hover window.
hover.__prepare = function ()
	---|fS

	if not hover.buffer or not vim.api.nvim_buf_is_valid(hover.buffer) then
		hover.buffer = vim.api.nvim_create_buf(false, true);

		vim.api.nvim_buf_set_keymap(hover.buffer, "n", "q", "", {
			callback = function ()
				vim.api.nvim_set_current_win(
					vim.fn.win_getid(
						vim.fn.winnr("#")
					)
				);
				pcall(vim.api.nvim_win_close, hover.window, true);

				hover.update_quad(hover.quad, false);
				hover.quad = nil;
			end
		});
	end

	---|fE
end

---@param quad "top_left" | "top_right" | "bottom_left" | "bottom_right"
---@param state boolean
hover.update_quad = function (quad, state)
	---|fS

	if not vim.g.__used_quads then
		vim.g.__used_quads = {
			top_left = false,
			top_right = false,

			bottom_left = false,
			bottom_right = false
		};
	end

	vim.g.__used_quads[quad] = state;

	---|fE
end

---@param window integer
---@param w integer
---@param h integer
---@return string[]
---@return "NE" | "NW" | "SE" | "SW"
---@return integer
---@return integer
hover.__win_args = function (window, w, h)
	---|fS

	---@type [ integer, integer ]
	local cursor = vim.api.nvim_win_get_cursor(window);
	---@type table<string, integer>
	local screenpos = vim.fn.screenpos(window, cursor[1], cursor[2]);

	local screen_width = vim.o.columns;
	local screen_height = vim.o.lines - vim.o.cmdheight - 1;

	local quad_pref = { "bottom_right", "bottom_left", "top_right", "top_left" };
	local quads = {
		---|fS

		top_left = {
			condition = function ()
				return screenpos.row + h >= screen_height and screenpos.curscol + w >= screen_width;
			end,

			border = { "╭", "─", "╮", "│", "┤", "─", "╰", "│" },
			anchor = "SE",
			row = 0,
			col = 1
		},
		top_right = {
			condition = function ()
				return screenpos.row + h >= screen_height and screenpos.curscol + w < screen_width;
			end,

			border = { "╭", "─", "╮", "│", "╯", "─", "├", "│" },
			anchor = "SW",
			row = 0,
			col = 0
		},

		bottom_left = {
			condition = function ()
				return screenpos.row + h < screen_height and screenpos.curscol + w >= screen_width;
			end,

			border = { "╭", "─", "┤", "│", "╯", "─", "╰", "│" },
			anchor = "NE",
			row = 1,
			col = 1
		},
		bottom_right = {
			condition = function ()
				return screenpos.row + h < screen_height and screenpos.curscol + w < screen_width;
			end,

			border = { "├", "─", "╮", "│", "╯", "─", "╰", "│" },
			anchor = "NW",
			row = 1,
			col = 0
		}

		---|fE
	};

	for _, pref in ipairs(quad_pref) do
		if vim.g.__used_quads and vim.g.__used_quads[pref] == true then
			goto continue;
		end

		if not quads[pref] then
			goto continue;
		end

		local quad = quads[pref];
		local ran_cond, cond = pcall(quad.condition);

		if ran_cond and cond then
			hover.quad = pref;
			return quad.border, quad.anchor, quad.row, quad.col;
		end

		::continue::
	end

	hover.quad = "bottom_right";
	local fallback = quads.bottom_right;
	return fallback.border, fallback.anchor, fallback.row, fallback.col;

	---|fE
end

------------------------------------------------------------------------------

--- Custom hover function
---@param window? integer
hover.hover = function (window)
	---|fS

	window = window or vim.api.nvim_get_current_win();

	if hover.window and vim.api.nvim_win_is_valid(hover.window) then
		vim.api.nvim_set_current_win(hover.window);
		return;
	end

	---@type boolean, table
	local got_position_params, position_params = pcall(vim.lsp.util.make_position_params, window, "utf-8");
	---@type integer
	local buf = vim.api.nvim_win_get_buf(window);

	if not got_position_params then
		vim.api.nvim_echo({
			{ "  Lsp hover: ", "DiagnosticVirtualTextWarn" },
			{ " " },
			{ "Couldn't get position parameters!", "Comment" }
		}, false, {})
		return;
	end

	vim.lsp.buf_request(buf, "textDocument/hover", position_params, function (err, result, ctx, config)
		if err then
			--- Error getting hover information.
			vim.api.nvim_echo({
				{ "  Lsp hover: ", "DiagnosticVirtualTextError" },
				{ " " },
				{ err.message, "Comment" }
			}, true, {})
			return;
		elseif not result then
			vim.api.nvim_echo({
				{ "  Lsp hover: ", "DiagnosticVirtualTextError" },
				{ " " },
				{ "No information available!", "Comment" }
			}, false, {})
			return;
		end

		hover.__prepare();

		---@type integer
		local client_id = ctx.client_id;
		local client = vim.lsp.get_client_by_id(client_id) or {};
		local client_name = client.name or "";

		local _config = get_style(client_name, result, ctx);
		local W, H = _config.width or math.floor(vim.o.columns * 0.25), _config.height or math.floor(vim.o.lines * 0.4);

		_config.winopts = vim.tbl_extend("force", config or {}, _config.winopts or {});

		local contents = result.contents or {};
		---@type string[]
		local lines = vim.split(contents.value or "", "\n", { trimempty = true });

		-- Set content
		vim.bo[hover.buffer].ft = contents.kind or "markdown";
		vim.bo[hover.buffer].tw = W;

		vim.api.nvim_buf_set_lines(hover.buffer, 0, -1, false, lines);

		-- Get wrapped width.
		vim.api.nvim_buf_call(hover.buffer, function ()
			vim.api.nvim_command("silent %normal gqq");
			H = math.min(
				vim.api.nvim_buf_line_count(hover.buffer),
				H,
				math.floor(vim.o.lines * 0.5)
			);
		end);

		-- Reset old text, otherwise it may break syntax highlighting.
		vim.api.nvim_buf_set_lines(hover.buffer, 0, -1, false, lines);

		local border, anchor, row, col = hover.__win_args(window, W, H);

		-- Open window
		hover.window = vim.api.nvim_open_win(hover.buffer, false, vim.tbl_extend("force", {
			relative = "cursor",

			row = row or 1, col = col or 0,
			width = W, height = H,

			anchor = anchor,

			border = border or "rounded",
			style = "minimal"
		}, _config.winopts));

		-- Set necessary options.
		vim.wo[hover.window].wrap = true;
		vim.wo[hover.window].linebreak = true;
		vim.wo[hover.window].breakindent = true;

		vim.wo[hover.window].signcolumn = "no";
		vim.wo[hover.window].conceallevel = 3;
		vim.wo[hover.window].concealcursor = "ncv";

		if type(_config.winhl) == "string" then
			vim.wo[hover.window].winhl = _config.winhl;
		end

		vim.api.nvim_win_set_cursor(hover.window, { 1, 0 });
		hover.update_quad(hover.quad, true);

		-- Markdown rendering.
		if package.loaded["markview"] then
			package.loaded["markview"].render(hover.buffer, {
				enable = true,
				hybrid_mode = false
			});
		end
	end);

	---|fE
end

---@param config? table<string, hover.style>
hover.setup = function (config)
	---|fS

	if type(config) == "table" then
		hover.config = vim.tbl_extend("force", hover.config, config);
	end

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function (ev)
			vim.api.nvim_buf_set_keymap(ev.buf, "n", "K", "", {
				callback = hover.hover
			});
		end
	});

	vim.api.nvim_create_autocmd({
		"CursorMoved", "CursorMovedI"
	}, {
		callback = function ()
			local win = vim.api.nvim_get_current_win();

			if hover.window and win ~= hover.window then
				pcall(vim.api.nvim_win_close, hover.window, true);

				if hover.quad then
					hover.update_quad(hover.quad, false);
					hover.quad = nil;
				end
			end
		end
	});

	---|fE
end

return hover;
