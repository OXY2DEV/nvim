local parser = {};
local scope_config = require("indent.scope_config");

local clamp = function (value, min, max)
	return math.max(math.min(value, max), min);
end

local tbl_clamp = function (from, index)
	if not vim.islist(from) then
		return from;
	end

	return from[index] or from[#from];
end

local split = function (callback, str, sep)
	local _r = {};

	for part in str:gmatch("^(.-)" .. sep) do
		table.insert(_r, callback(part));
	end

	return _r;
end

parser.process_indent = function (buffer, str)
	local shiftwidth = vim.bo[buffer].shiftwidth;
	local tabstop = vim.bo[buffer].tabstop;
	local vtabstop = split(tonumber, vim.bo[buffer].vartabstop, ",");

	local _o = {};
	local pos = 0;

	for sp in string.gmatch(str, ".") do
		if sp == "\t" then
			table.insert(_o, {
				type = "tab",
				position = pos,
				len = vim.fn.strdisplaywidth(sp)
			});

			pos = pos + vim.fn.strdisplaywidth(sp);
		else
			local div = shiftwidth;

			if shiftwidth == 0 then
				div = tabstop;
			end

			if #vtabstop > 1 then
				div = table.remove(vtabstop, 1);
			elseif #vtabstop == 1 then
				div = vtabstop[1];
			end

			if pos % div == 0 then
				table.insert(_o, {
					type = "space",
					position = pos,
					len = vim.fn.strdisplaywidth(sp)
				})
			end

			pos = pos + vim.fn.strdisplaywidth(sp);
		end
	end

	return _o;
end

parser.parse = function (buffer, from, to)
	local lines = vim.api.nvim_buf_get_lines(buffer, from, to, false);

	local indents = {};
	local cache = {};

	for _, line in ipairs(lines) do
		local before = line:match("^(%s+)");

		if not before then
			if line ~= "" then
				cache = {};
			end

			table.insert(indents, cache);
		else
			cache = parser.process_indent(buffer, before);

			table.insert(indents, cache);
		end
	end

	return indents;
end

parser.get_scope = function (buffer, position, from, to, language, ignore_injections)
	local has_tree, language_tree = pcall(vim.treesitter.get_parser, buffer);

	if not has_tree or not language_tree then
		return;
	end

	if not scope_config[vim.bo[buffer].filetype] then
		return;
	end

	local def = scope_config[vim.bo[buffer].filetype];

	-- vim.treesitter.get_parser(buffer):parse(from or 0, to or -1);
	--
	local node = vim.treesitter.get_node({
		bufnr = buffer,
		pos = position,
		lang = language,
		ignore_injections = ignore_injections
	});

	while node do
		if vim.list_contains(def, node:type()) then
			return node;
		end

		node = node:parent();
	end
end


return parser;
