local motions = {};

---@type string Mode shorthand.
motions.mode = "n";

vim.api.nvim_create_autocmd("ModeChanged", {
	callback = function (event)
		motions.mode = string.match(event.match, ":(.)$") or event.match;
	end
});

---@type string Previous keys. Must be cleared after each motion!
motions.previous = "";

---@type string Last successfully run motion.
motions.last = "";

--- Parses key presses.
---@param map table<string, function>
---@param key string
---@param _ string
motions.parse = function (map, key, _)
	---|fS

	map = map or {};

	local quantifier = tonumber(
		string.match(motions.previous, "%d+$")
	) or 0;

	---@param clear boolean
	---@param motion string
	---@param alt? string
	---@param ... any
	local function exec_callback (clear, motion, alt, ...)
		if type(map) ~= "table" then
			return;
		elseif clear then
			motions.previous = "";
		end

		motions.last = motion;

		if alt and map[alt] then
			pcall(map[alt], ...);
		else
			pcall(map[motion], ...);
		end
	end

	local single_keys = {
		"h", "j", "k", "l",
		"0", "^", "$", "|",
		"G",
		";", ",",
		"w", "W", "e", "E", "b", "B",
		"(", ")", "{", "}",
		"%",
		"H", "M", "L",


		"n", "N",
		"~",
	};

	if motions.mode ~= "n" then
		-- Wrong mode.
		motions.previous = "";
	elseif motions.previous == "" and string.match(key, "%d") then
		-- Quantifier.
		motions.previous = motions.previous .. key;
	elseif string.match(motions.previous, "%d*[fFtT]") then
		-- Character finder.
		exec_callback(true, string.match(motions.previous, "[fFtT]$"), nil, quantifier, key);
	elseif vim.list_contains(single_keys, key) then

		-- Single letter motions.
		exec_callback(true, key, nil, quantifier);
	elseif string.match(motions.previous, "g['`]$") then
		-- g'{mark}
		exec_callback(true, "g" .. key, nil, quantifier);
	elseif string.match(motions.previous, "g$") then
		local actions = {
			"_", "0", "^",
			"m", "M",
			"$",
			"k", "j",
			"g",
			"e", "E",
			";", ",",
		};

		if vim.list_contains(actions, key) then
			exec_callback(true, "g" .. key, nil, quantifier);
		elseif key == "'" or key == "`" then
			motions.previous = motions.previous .. key;
		else
			motions.previous = "";
		end
	else
		motions.previous = motions.previous .. key;
	end
	---|fE
end

--- Creates a new key press event listener.
---@param map table<string, function>
---@return integer
motions.add_event_listener = function (map)
	return vim.on_key(function (key, pressed)
		motions.parse(map, key, pressed);
	end, 0, {});
end

return motions;
