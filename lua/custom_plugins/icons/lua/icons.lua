local icons = {};

icons.config = {
	hl = {
		"Color0",
		"Palette1I", "Palette2I", "Palette3I",
		"Palette4I", "Palette5I", "Palette6I",
	};
};

--- Cached results.
icons.cache = {};

icons.get = function (ft, hls)
	local _o;

	if icons.cache[ft] then
		_o = icons.cache[ft];
	else
		_o = require("icons.filetypes").get(ft);
		icons.cache[ft] = _o;
	end

	return {
		name = _o.name,
		icon = _o.icon,

		hl = (hls or icons.config.hl)[_o.hl or 0]
	};
end

icons.setup = function (config)
	if type(config) ~= "table" then
		return;
	end

	icons.config = vim.tbl_extend("force", icons.config, config);

	--- Overwrite icons.
	require("icons.filetypes").overwrite(icons.config.overwrites or {});
end

return icons;
