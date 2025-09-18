--[[

fix(tree-sitter): Fix concealing rows for TOCs.

Add the missing feature of the default quickfix syntax that hides the
`file path` & `range` of the entries in Table of Content style quickfix
lists.

See: `gO`

--]]


---@type integer
local buffer = vim.api.nvim_get_current_buf();

--[[ Hides the first 2 **rows** in quickfix TOCs. ]]
local function hide_toc ()
	---|fS

	--[[
		Check if we are in the correct quickfix window,
			• `qf_toc`, used by Vim's quickfix window.
			• `"Table of contents"`, title used by TOCs.
	--]]
	if not vim.w.qf_toc and vim.w.quickfix_title ~= "Table of contents" then
		return;
	end

	-- `Quickfix` buffers update correctly since 0.11.4-1. See neovim/neovim#31105.
	if vim.fn.has("nvim-0.11.4-1") == 0 then
		---|fS "fix: Fixes tree-sitter not updating on quickfix buffer"

		vim.bo[buffer].modifiable = true;
		vim.bo[buffer].undolevels = -1; -- Prevent undoing.

		local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false);
		vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines);

		vim.bo[buffer].modifiable = false;
		vim.bo[buffer].modified = false;

		vim.bo[buffer].undolevels = vim.api.nvim_get_option_value("undolevels", { scope = "global" });

		---|fE
	end

	vim.wo.conceallevel = 3;
	vim.wo.concealcursor = "nvc";

	local parser = vim.treesitter.get_parser(buffer, "qf", { error = false });

	local NS = vim.api.nvim_create_namespace("quickfix_toc");
	vim.api.nvim_buf_clear_namespace(buffer, NS, 0, -1);

	if not parser then
		return;
	end

	---@type TSTree?
	local TSTree = parser:parse(true)[1];

	if not TSTree then
		return;
	end

	local conceal_query = vim.treesitter.query.parse("qf", [[
		((filename)
			"|"
			(range)
			"|" @qf_range_end)
	]]);


	for _, node, _ ,_ in conceal_query:iter_captures(TSTree:root(), buffer) do
		local range = { node:range() };

		vim.api.nvim_buf_set_extmark(buffer, NS, range[1], 0, {
			end_col = range[4],
			conceal = ""
		});
	end

	---|fE
end

--[[ NOTE: do we need to also hook this to `TextChanged`? ]]
hide_toc();
