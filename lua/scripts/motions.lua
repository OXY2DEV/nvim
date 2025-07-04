--- Maps motions to callbacks.
---@class motions.map
---
---@field [string] fun(quqntifier: integer): nil

------------------------------------------------------------------------------

-- Allows running callbacks when triggering motions.
-- Usage,
--
-- ```lua
-- require("motions").add_event_listener({
--     gg = function ()
--         vim.print("hello world!");
--     end
-- });
-- ```
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
---@param map motions.map
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
		-- g'{mark} or g`{mark}
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
	elseif vim.list_contains({ "(", ")", "{", "}" }, key) then
		-- Sentence & paragraph movements.
		exec_callback(true, key, nil, quantifier);
	elseif string.match(motions.previous, "%]$") then
		local actions = {
			"]", "[",
			"'", "`",
			")", "}",
			"m", "M",
			"#",
			"*", "/",
		};

		if vim.list_contains(actions, key) then
			exec_callback(true, "]" .. key, nil, quantifier);
		else
			motions.previous = "";
		end
	elseif string.match(motions.previous, "%[$") then
		local actions = {
			"[", "]",
			"'", "`",
			"(", "{",
			"m", "M",
			"#",
			"*", "/",
		};

		if vim.list_contains(actions, key) then
			exec_callback(true, "[" .. key, nil, quantifier);
		else
			motions.previous = "";
		end
	elseif string.match(motions.previous, "a$") then
		local actions = {
			"w", "W",
			"s",
			"p",
			"]", "[",
			"(", ")", "b",
			">", "<",
			"t",
			"{", "}", "B",
			'"', "'", "`",
		};

		if vim.list_contains(actions, key) then
			exec_callback(true, "a" .. key, nil, quantifier);
		else
			motions.previous = "";
		end
	elseif string.match(motions.previous, "i$") then
		local actions = {
			"w", "W",
			"s",
			"p",
			"]", "[",
			"(", ")", "b",
			">", "<",
			"t",
			"{", "}", "B",
			'"', "'", "`",
		};

		if vim.list_contains(actions, key) then
			exec_callback(true, "i" .. key, nil, quantifier);
		else
			motions.previous = "";
		end
	elseif string.match(motions.previous, "['`]$") then
		local marker = string.match(motions.previous, "['`]$");
		local special = {
			"[", "]",
			"<", ">",
			"'", "`", '"',
			"^", ".",
			"(", ")",
			"{", "}",
		};

		if string.match(key, "[%a%d]") or vim.list_contains(special, key) then
			-- '{mark} or `{mark}
			exec_callback(true, marker .. key, nil, quantifier);
		else
		end
	else
		motions.previous = motions.previous .. key;
	end

	---|fE
end

--- An instance of motion parser.
---@class motions.instance
---
---@field map motions.map
---@field id integer ID of this handler.
local instance = {};
instance.__index = instance;

instance.map = {};
instance.id = nil

--- Creates a new key press event listener.
---@param map motions.map
---@return table
motions.add_event_listener = function (map)
	local new = setmetatable({}, instance);
	new.map = map;

	new.id = vim.on_key(function (key, pressed)
		motions.parse(map, key, pressed);
	end, 0, {});

	return new;
end

return motions;
