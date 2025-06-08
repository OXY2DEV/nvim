local inspect = {};

inspect.tostring = function (node)
	if not node then
		return {}, {};
	end

	local n_type = node:type();
	local lines, datas = {}, {};

	table.insert(datas, {
		type = node:type(),
		range = { node:range() },

		missing = node:missing(),
		named = node:named(),
		extra = node:extra(),
		has_error = node:has_error(),
	});

	if node:named() then
		table.insert(lines, string.format("(%s", n_type))
	else
		table.insert(lines, vim.inspect(n_type));
	end

	for child, field_name in node:iter_children() do
		local child_lines, child_datas = inspect.tostring(child);

		if field_name then
			child_lines[1] = field_name .. ": " .. child_lines[1];
		end

		for l, line in ipairs(child_lines) do
			child_lines[l] = "    " .. line;
		end

		vim.list_extend(lines, child_lines);
		vim.list_extend(datas, child_datas);
	end

	if node:named() then
		lines[#lines] = lines[#lines] .. ")";
	end

	return lines, datas;
end

inspect.setup = function ()
	vim.api.nvim_create_user_command("Is", function ()
		local parser = vim.treesitter.get_parser(0, nil, {});
		local tree = parser:parse()[1];

		local lines, datas = inspect.tostring(tree:root());

		vim.print(
			table.concat(lines, '\n')
		);
		vim.print(#datas == #lines)
	end, {});
end

return inspect;
