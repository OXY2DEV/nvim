local utils = {};

utils.list_rep = function (list, rep)
	local _o = {};

	for _, item in ipairs(list) do
		for _ = 1, rep do
			table.insert(_o, item);
		end
	end

	return _o;
end

return utils;
