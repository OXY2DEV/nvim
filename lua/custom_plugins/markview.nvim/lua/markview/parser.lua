local parser = {};

parser.init = function ()
	local root_parser = vim.treesitter.get_parser();
	root_parser:parse(true);

	root_parser:for_each_tree(function (TStree, language_tree)
		local tree_language = language_tree:lang();

		if tree_language == "markdown" then
			local query = vim.treesitter.query;

			local headers = query.parse("markdown", [[
				(atx_h1_marker) @h1
				(atx_h2_marker) @h2
				(atx_h3_marker) @h3
				(atx_h4_marker) @h4
				(atx_h5_marker) @h5
				(atx_h6_marker) @h6
			]])

			for captureID, captureNode, metadata, match in headers:iter_captures(TStree:root()) do
				local txt = vim.treesitter.get_node_text(captureNode, 0);
				vim.print(txt)
			end
		end
		-- Hi
	end)
end

return parser;
