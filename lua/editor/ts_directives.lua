-- Gets the filetype for the quickfix item.
vim.treesitter.query.add_directive("set-qf-lang!", function (match, _, bufnr, pred, metadata)
	local capture_id = pred[2];
	local node = match[capture_id];

	if not node then
		return;
	end

	local delimiter = vim.treesitter.get_node_text(node, bufnr) or "";
	delimiter = delimiter:gsub("^%s*>!", ""):gsub("!<$", "");

	local ft = vim.filetype.match({
		filename = "a." .. string.lower(delimiter)
	});

	local exceptions = {
		ex = "elixir",
		pl = "perl",
		sh = "bash",
		uxn = "uxntl",
		ts = "typescript"
	};

	metadata["injection.language"] = ft or exceptions[delimiter] or "";
end, { force = true, all = false });
