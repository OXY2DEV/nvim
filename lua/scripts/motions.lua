local motions = {};

---@type string Mode shorthand.
motions.mode = "n";

---@type integer Namespace used for motions.
motions.ns = vim.api.nvim_create_namespace("motions");

---@type string Previous keys. Must be cleared after each motion!
motions.previous = "";

---@type string Last successfully run motion.
motions.last = "";

--[[
	if string.match(motions.previous, "^%d*$") then
		if key == "." then
			-- Dot repeat.
			exec_callback(true, ".", "dot_repeat", motions.last);
		elseif key == "~" then
			-- Case change under cursor.
			exec_callback(true, "~", "case_swap");
		elseif key == "|" then
			-- To [0]th screen col.

			---@type integer
			local count = tonumber(motions.previous) or 0;

			exec_callback(true, "|", "case_swap", count);
		elseif key == ";" then
			-- Repeat last f, t, F, T.

			exec_callback(true, ";", "repeat_find_character");
		elseif key == "," then
			-- Repeat last f, t, F, T in opposite direction.

			exec_callback(true, ",", "repeat_find_character_reverse");
		elseif key == "G" then
			-- Bottom of file.

			exec_callback(true, "G", "to_bottom");
		elseif key == "-" or key == "+" then
			-- Use -, + to move up/down.

			exec_callback(true, key, "quantified_movement", key);
		elseif key == "w" or key == "W" then
			-- Use w, W to move between to words.

			exec_callback(true, key, "to_word", key);
		elseif key == "e" or key == "E" then
			-- Use e, E to move between to end of words.

			exec_callback(true, key, "to_word_end", key);
		elseif key == "b" or key == "B" then
			-- Use b, B to move between to start of words.

			exec_callback(true, key, "to_word_start", key);
		elseif key == "(" or key == ")" then
			-- Use (, ) to move between sentences.

			exec_callback(true, key, key == ")" and "sentence_next" or "sentence_previous", key);
		elseif key == "{" or key == "}" then
			-- Use {, } to move between paragraph.

			exec_callback(true, key, key == "}" and "paragraph_next" or "paragraph_previous", key);
		elseif vim.list_contains({ "H", "M", "L" }, key) then
			-- Use H, M, L to go to specific part of the window.

			exec_callback(true, key, "to_window_line", key);
		elseif vim.list_contains({ "h", "j", "k", "l" }, key) then
			-- Use h, j, k, l to move around the buffer.

			exec_callback(true, key, "to_buffer_line", key);
		elseif vim.list_contains({ "i", "v", "V", "", ":" }, key) then
			-- Use v, V, , i, : to change mode.

			exec_callback(true, key, "mode_change", key);
		elseif vim.list_contains({ "0", "^", "$" }, key) then
			-- Use ^, 0, $ to move to specific parts of the line.

			exec_callback(true, key, "to_buffer_column", key);
		else
			motions.previous = motions.previous .. key;
		end
	elseif string.match(motions.previous, "%]$") then
		if key == "]" then
			-- Use ] to go to next section.

			exec_callback(true, "]", "section_next");
		elseif key == "[" then
			-- Use ][ to go to next section.

			exec_callback(true, "][");
		elseif key == "'" then
			-- ???

			exec_callback(true, "]'");
		elseif key == "`" then
			-- ???

			exec_callback(true, "]`");
		elseif key == ")" then
			-- Use to go to unmatched ).

			exec_callback(true, "])", "to_unmatch_bracket");
		elseif key == "}" then
			-- Use to go to unmatched }.

			exec_callback(true, "]}", "to_unmatch_paren");
		elseif key == "m" then
			-- Use to go to start of method.

			exec_callback(true, "]m");
		elseif key == "M" then
			-- Use to go to end of method.

			exec_callback(true, "]M");
		elseif key == "*" or key == "/" then
			-- Use ]* or ]/ to go to start of C comment.

			exec_callback(true, "]" .. key, "to_c_comment");
		end

		-- Doesn't matter what gets run, buffer should
		-- be cleared.
		motions.previous = "";
	elseif string.match(motions.previous, "%[$") then
		if key == "[" then
			-- Use [[ to go to previous section.

			exec_callback(true, "[[", "section_previous");
		elseif key == "]" then
			-- ???

			exec_callback(true, "[]");
		elseif key == "'" then
			-- ???

			exec_callback(true, "['");
		elseif key == "`" then
			-- ???

			exec_callback(true, "[`");
		elseif key == "(" then
			-- ???

			exec_callback(true, "[(");
		elseif key == "{" then
			-- ???

			exec_callback(true, "[{");
		elseif key == "m" then
			-- ???

			exec_callback(true, "[m");
		elseif key == "M" then
			-- ???

			exec_callback(true, "[M");
		elseif key == "#" then
			-- ???

			exec_callback(true, "[#");
		elseif key == "*" or key == "/" then
			-- ???

			exec_callback(true, "[" .. key);
		end

		motions.previous = "";
	elseif motions.previous == "}" then
		if key == "#" then
			-- ???

			exec_callback(true, "}#");
		end

		motions.previous = "";
	elseif motions.previous == "'" then
		if vim.list_contains({ "]", "[" }, key) then
			-- ???

			exec_callback(true, "'" .. key);
		elseif vim.list_contains({ "<", ">" }, key) then
			-- ???

			exec_callback(true, "'" .. key);
		elseif key == "'" then
			-- ???

			exec_callback(true, "''");
		elseif key == '"' then
			-- ???

			exec_callback(true, "'\"");
		elseif key == "^" then
			-- ???

			exec_callback(true, "'^");
		elseif key == "." then
			-- ???

			exec_callback(true, "'.");
		elseif key == "(" or key == ")" then
			-- ???

			exec_callback(true, "'" .. key);
		elseif key == "{" or key == "}" then
			-- ???

			exec_callback(true, "'" .. key);
		end

		motions.previous = ""
	elseif string.match(motions.previous, "g[`']") then
		-- ???

		exec_callback(true, motions.previous .. key);
	elseif motions.previous == "g" then
		if vim.list_contains({ "_", "^", "m", "M", "$" }, key) then
			-- ???

			exec_callback(true, motions.previous .. key);
			pcall(map[motions.previous .. key], motions.previous .. key);
			motions.previous = "";
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
--]]

motions.parse = function (map, key, _)
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

motions.event({});

return motions;
