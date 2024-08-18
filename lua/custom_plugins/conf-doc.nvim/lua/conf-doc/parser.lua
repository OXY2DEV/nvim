local parser = {};
parser.parsed_content = {};

parser.md = function (buffer, TStree, from, to)
	local scanned_queies = vim.treesitter.query.parse("markdown", [[
		((fenced_code_block) @code)
	]]);

	for capture_id, capture_node, _, _ in scanned_queies:iter_captures(TStree:root(), buffer, from, to) do
		local capture_name = scanned_queies.captures[capture_id];
		local r_start, c_start, r_end, c_end = capture_node:range();

		if capture_name == "code" then
			local lines = vim.api.nvim_buf_get_lines(buffer, r_start, r_end, false);
			local lang = string.match(lines[1] or "", "```(%S+)");

			local _l = {};

			if string.match(lines[1] or "", "%${(ignore)}") then
				goto ignore;
			end

			for l, line in ipairs(lines) do
				if l ~= 1 and l ~= #lines then
					table.insert(_l, vim.fn.strcharpart(line, c_start));
				end
			end

			table.insert(parser.parsed_content, {
				indent = tonumber(string.match(lines[1] or "", "%${indent=(%d+)}") or 0),
				type = string.match(lines[1] or "", "%${type=(%S+)}") or "default",
				fold = string.match(lines[1] or "", "%${(fold)}") and true or false,
				language = lang,

				lines = _l,

				row_start = r_start,
				row_end = r_end,

				col_start = c_start,
				col_end = c_end
			})
		end

		::ignore::
	end
end

parser.init = function (buffer, from, to)
	buffer = buffer or vim.api.nvim_get_current_buf();

	local root_parser = vim.treesitter.get_parser(buffer);
	root_parser:parse();

	parser.parsed_content = {};

	root_parser:for_each_tree(function (TStree, language_tree)
		local tree_language = language_tree:lang();

		if tree_language == "markdown" then
			parser.md(buffer, TStree, from, to);
		end
	end);

	return parser.parsed_content;
end

return parser;
