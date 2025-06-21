local motions = {};

---@type string Mode shorthand.
motions.mode = "n";

---@type integer Namespace used for motions.
motions.ns = vim.api.nvim_create_namespace("motions");

---@type string Previous keys. Must be cleared after each motion!
motions.previous = "";

motions.parse = function (map, key, _)
	map = map or {};

	if motions.mode ~= "n" then
		-- Wrong mode.
		motions.previous = "";
		return;
	end

	if motions.previous == "" then
		if key == "." then
			pcall(map[key], key);
		elseif key == "~" then
			pcall(map[key], key);
		elseif key == "|" then
			pcall(map[key], key);
		elseif key == ";" then
			pcall(map[key], key);
		elseif key == "," then
			pcall(map[key], key);
		elseif key == "G" then
			pcall(map[key], key);
		elseif key == "-" or key == "+" then
			pcall(map[key], key);
		elseif key == "w" or key == "W" then
			pcall(map[key], key);
		elseif key == "e" or key == "E" then
			pcall(map[key], key);
		elseif key == "b" or key == "B" then
			pcall(map[key], key);
		elseif key == "(" or key == ")" then
			pcall(map[key], key);
		elseif key == "{" or key == "}" then
			pcall(map[key], key);
		elseif vim.list_contains({ "H", "M", "L" }, key) then
			pcall(map[key], key);
		elseif vim.list_contains({ "h", "j", "k", "l" }, key) then
			pcall(map[key], key);
		elseif vim.list_contains({ "i", "v", "V", "", ":" }, key) then
			pcall(map[key], key);
		elseif vim.list_contains({ "0", "^", "$" }, key) then
			pcall(map[key], key);
		else
			motions.previous = motions.previous .. key;
		end
	elseif motions.previous == "]" then
		if key == "]" then
			pcall(map["]]"], "]]");
		elseif key == "[" then
			pcall(map["]["], "][");
		elseif key == "'" then
			pcall(map["]'"], "]'");
		elseif key == "`" then
			pcall(map["]`"], "]`");
		elseif key == ")" then
			pcall(map["])"], "])");
		elseif key == "}" then
			pcall(map["]}"], "]}");
		elseif key == "m" then
			pcall(map["]m"], "]m");
		elseif key == "M" then
			pcall(map["]M"], "]M");
		elseif key == "*" or key == "/" then
			pcall(map["]" .. key], "]" .. key);
		end

		motions.previous = "";
	elseif motions.previous == "[" then
		if key == "[" then
			pcall(map["[["], "[[");
		elseif key == "]" then
			pcall(map["[]"], "[]");
		elseif key == "'" then
			pcall(map["['"], "['");
		elseif key == "`" then
			pcall(map["[`"], "[`");
		elseif key == "(" then
			pcall(map["[("], "[(");
		elseif key == "{" then
			pcall(map["[{"], "[{");
		elseif key == "m" then
			pcall(map["[m"], "[m");
		elseif key == "M" then
			pcall(map["[M"], "[M");
		elseif key == "#" then
			pcall(map["[#"], "[#");
		elseif key == "*" or key == "/" then
			pcall(map["[" .. key], "[" .. key);
		end

		motions.previous = "";
	elseif motions.previous == "}" then
		if key == "#" then
			pcall(map["}#"], "}#");
		end

		motions.previous = "";
	elseif motions.previous == "'" then
		if vim.list_contains({ "]", "[" }, key) then
			pcall(map["'" .. key], "'" .. key);
		elseif vim.list_contains({ "<", ">" }, key) then
			pcall(map["'" .. key], "'" .. key);
		elseif key == "'" then
			pcall(map["''"], "''");
		elseif key == '"' then
			pcall(map["'\""], "'\"");
		elseif key == "^" then
			pcall(map["'^"], "'^");
		elseif key == "." then
			pcall(map["'."], "'.");
		elseif key == "(" or key == ")" then
			pcall(map["'" .. key], "'" .. key);
		elseif key == "{" or key == "}" then
			pcall(map["'" .. key], "'" .. key);
		end

		motions.previous = ""
	elseif motions.previous == "g'" or motions.previous == "g`" then
			pcall(map[motions.previous .. key], "'" .. motions.previous .. key);
	elseif motions.previous == "g" then
		if vim.list_contains({ "_", "^", "m", "M", "$" }, key) then
			motions.previous = "";
			pcall(map[motions.previous .. key], "'" .. motions.previous .. key);
		elseif vim.list_contains({ "e", "E" }, key) then
			motions.previous = "";
			pcall(map[motions.previous .. key], "'" .. motions.previous .. key);
		elseif key == "g" then
		end

		motions.previous = "";
	elseif motions.previous == "m" then
		if string.match(key, "[%l%u]") then
		elseif key == "'" or key == "`" then
		elseif key == "[" or key == "]" then
		elseif key == "<" or key == ">" then
		end

		motions.previous = "";
	elseif motions.previous == "'" then
		motions.previous = "";
	elseif string.match(motions.previous, "%d+$") and key == "%" then
		-- % of file.
		motions.previous = "";
	elseif key == "%" then
	elseif motions.previous == "f" then
		-- [f]ind char.
		motions.previous = "";
	elseif motions.previous == "F" then
		-- [F]ind char back.
		motions.previous = "";
	elseif motions.previous == "t" then
		-- [t]ill char.
		motions.previous = "";
	elseif motions.previous == "T" then
		-- [T]ill char back.
		motions.previous = "";
	else
		motions.previous = motions.previous .. key;
	end
end

motions.event = function (map)
	vim.on_key(function (key, pressed)
		motions.parse(map, key, pressed);
	end, motions.ns, {});
end

vim.api.nvim_create_autocmd("ModeChanged", {
	callback = function (event)
		motions.mode = event.match;
	end
});

return motions;
