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
end, { force = true });

if true then
	-- No need to load the next one. We don't use it at-the-moment!
	return;
end

vim.treesitter.query.add_directive("qf-fallback-lang!", function (match, _, bufnr, pred, metadata)
	local capture_id = pred[2];
	---@type TSNode
	local node = match[capture_id];

	if not node then
		-- Couldn't find node 
		return;
	end

	local parent = node:parent();

	if not parent then
		-- Couldn't find the list item node.
		return;
	end

	local filename = parent:child(0);

	if not filename or filename:type() ~= "filename" then
		-- Filename node doesn't exist or has wrong type.
		return;
	end

	local text = vim.treesitter.get_node_text(filename, bufnr);
	local ft = vim.filetype.match({ filename = text })

	if ft then
		-- Only add it if the filetype is found.
		metadata["injection.language"] = ft;
	end
end, { force = true });

