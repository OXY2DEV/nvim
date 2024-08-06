local utils = {};

local validate_config = function (config, key)
	if not config or not config.default then
		error("Incorrect config structure")
	end

	if not config[key] or type(config[key]) ~= type(config.default) then
		return config.default;
	end

	return config[key]
end

local isColor = function (input)
	if type(input) == "string" and pcall(tonumber, input:gsub("#", ""), 16) then
		return true;
	elseif type(input) == "number" then
		return true;
	elseif type(input) == "table" and input.r and input.g and input.b then
		return true;
	end

	return false;
end

local to_color = function (color)
	if type(color) == "string" then
		color = color:gsub("#", "");

		if #color == 6 then
			return {
				r = tonumber(color:sub(1, 2), 16),
				g = tonumber(color:sub(3, 4), 16),
				b = tonumber(color:sub(5, 6), 16),
			}
		else
			return {
				r = tonumber(color:sub(1, 1), 16),
				g = tonumber(color:sub(2, 2), 16),
				b = tonumber(color:sub(3, 3), 16),
			}
		end
	elseif type(color) == "number" then
		color = string.format("%x", color);

		if #color == 6 then
			return {
				r = tonumber(color:sub(1, 2), 16),
				g = tonumber(color:sub(3, 4), 16),
				b = tonumber(color:sub(5, 6), 16),
			}
		else
			return {
				r = tonumber(color:sub(1, 1), 16),
				g = tonumber(color:sub(2, 2), 16),
				b = tonumber(color:sub(3, 3), 16),
			}
		end
	elseif type(color) == "table" and color.r and color.g and color.b then
		return color;
	end
end

local to_hex = function (color)
	return string.format("#%02x%02x%02x", color.r, color.g, color.b)
end

utils.get_maxlen = function (tbl)
	local max = 0;

	for key, value in pairs(tbl) do
		if key ~= "border" and vim.islist(value) and #value > max then
			max = #value;
		end
	end

	return max;
end

utils.list_get_maxlen = function (tbl)
	local max = 0;

	for _, value in ipairs(tbl) do
		if vim.islist(value) and #value > max then
			max = #value;
		end
	end

	return max;
end

utils.get_current_frame = function (animation, frame, config)
	local _o = {};

	for key, value in pairs(animation) do
		local v = value[frame] or value[#value];

		if config and config.not_frames and vim.list_contains(config.not_frames, key) then
			_o[key] = value;
		elseif type(v) == "number" then
			_o[key] = math.floor(v);
		else
			_o[key] = v;
		end
	end

	return _o;
end

utils.clamp = function (value, min, max)
	return math.min(math.max(value, min), max);
end

utils.interpolate = function (ease, x, y, t)
	local mulitplier = 0;

	t = utils.clamp(t, 0, 1);

	if ease == "ease-in-sine" then
		mulitplier = 1 - math.cos((t * math.pi) / 2);
	elseif ease == "ease-out-sine" then
		mulitplier = math.sin((t * math.pi) / 2);
	elseif ease == "ease-in-out-sine" then
		mulitplier = -1 * ((math.cos(t * math.pi) - 1) / 2);
	elseif ease == "ease-in-quad" then
		mulitplier = t ^ 2;
	elseif ease == "ease-out-quad" then
		mulitplier = 1 - ((1 - t) ^ 2);
	elseif ease == "ease-in-out-quad" then
		mulitplier = t < 0.5 and 2 * (y ^ 2) or 1 - (((-2 * t + 2) ^ 2) / 2);
	elseif ease == "ease-in-cubic" then
		mulitplier = t ^ 3;
	elseif ease == "ease-out-cubic" then
		mulitplier = 1 - ((1 - t) ^ 3);
	elseif ease == "ease-in-out-cubic" then
		mulitplier = t < 0.5 and 4 * (t ^ 3) or 1 - (((-2 * t + 2) ^ 3) / 2);
	elseif ease == "ease-in-quart" then
		mulitplier = t ^ 4;
	elseif ease == "ease-out-quart" then
		mulitplier = 1 - ((1 - t) ^ 4);
	elseif ease == "ease-out-quart" then
		mulitplier = t < 0.5 and 8 * (t ^ 4) or 1 - (((-2 * t + 2) ^ 4) / 2);
	elseif ease == "ease-in-quint" then
		mulitplier = t ^ 5;
	elseif ease == "ease-out-quint" then
		mulitplier = 1 - ((1 - t) ^ 5);
	elseif ease == "ease-in-out-quint" then
		mulitplier = t < 0.5 and 16 * (t ^ 5) or 1 - (((-2 * t + 2) ^ 5) / 2);
	elseif ease == "ease-in-circ" then
		mulitplier = 1 - math.sqrt(1 - (t ^ 2));
	elseif ease == "ease-out-circ" then
		mulitplier = math.sqrt(1 - ((t - 1) ^ 2));
	elseif ease == "ease-in-out-circ" then
		mulitplier = t < 0.5 and (1 - math.sqrt(1 - ((2 * y) ^ 2))) / 2 or (math.sqrt(1 - ((-2 * y + 2) ^ 2)) + 1) / 2;
	elseif ease == "linear" then
		mulitplier = t;
	end

	return x + ((y - x) * mulitplier);
end

utils.frameGenerator = function (from, to, config)
	local conf = vim.tbl_extend("keep", config or {}, {
		default = { "linear", 10 }
	});

	local _o = {};

	if not vim.islist(from) then
		for key, value in pairs(from) do
			if not to[key] or type(value) ~= "number" or type(to[key]) ~= "number" then
				_o[key] = vim.islist(value) and value or { value };
				goto invalidValue;
			end

			_o[key] = {};
			local current_config = validate_config(conf, key);

			for s = 0, current_config[2] ~= nil and current_config[2] - 1 or 9 do
				table.insert(_o[key], utils.interpolate(current_config[1] or "linear", value, to[key], s / (current_config[2] ~= nil and current_config[2] - 1 or 9)))
			end

			::invalidValue::
		end
	elseif type(from) == "table" then
		for index, value in ipairs(from) do
			if not to[index] or type(value) ~= "number" or type(to[index]) ~= "number" then
				_o[index] = vim.islist(value) and value or { value };
				goto invalidValue;
			end

			_o[index] = {};
			local current_config = validate_config(conf, index);

			for s = 0, current_config[2] ~= nil and current_config[2] - 1 or 9 do
				table.insert(_o[index], utils.interpolate(current_config[1] or "linear", value, to[index], s / (current_config[2] ~= nil and current_config[2] - 1 or 9)))
			end

			::invalidValue::
		end
	end

	return _o;
end

utils.colorframeGenerator = function (from, to, config)
	local conf = vim.tbl_extend("keep", config or {}, {
		default = { "linear", 10 }
	});

	local _o = {};

	for key, value in pairs(from) do
		if not to[key] then
			_o[key] = vim.islist(value) and value or { value };
			goto invalidValue;
		end

		_o[key] = {};
		local current_config = validate_config(conf, key);

		if type(value) == "number" and type(to[key]) == "number" then
			for s = 0, current_config[2] ~= nil and current_config[2] - 1 or 9 do
				table.insert(_o[key], utils.interpolate(current_config[1] or "linear", value, to[index], s / (current_config[2] ~= nil and current_config[2] - 1 or 9)))
			end
		elseif isColor(value) and isColor(to[key]) then
			_o[key] = utils.color_transition(value, to[key], config);
		end

		::invalidValue::
	end

	return _o;
end

utils.get_virt_line_num = function (extmarks)
	local lines = 0;

	for _, ext in ipairs(extmarks) do
		local _d = ext[4];

		lines = lines + #_d.virt_lines;
	end

	return lines;
end

utils.get_visible_lines = function (buffer, from, to)
	local v = 0;
	local lnums = {};

	local add = from > to and -1 or 1;

	for l = from, to, add do
		if l > vim.api.nvim_buf_line_count(buffer) or l < 0 then
			break;
		end

		if vim.fn.foldclosed(l) ~= vim.fn.foldclosed(utils.clamp(l + 1, from, to)) then
			v = v + 1;
			table.insert(lnums, l);
		elseif #vim.api.nvim_buf_get_extmarks(buffer, -1, { l, 0 }, { l, -1 }, { type = "virt_lines" }) > 0 then
			local ext = vim.api.nvim_buf_get_extmarks(buffer, -1, { l, 0 }, { l, -1 }, { type = "virt_lines", details = true });
			local v_lines = utils.get_virt_line_num(ext);

			for _ = 1, v_lines do
				table.insert(lnums, l);
			end

			v = v + v_lines + 1;
		elseif vim.fn.foldclosed(l) == -1 then
			v = v + 1
			table.insert(lnums, l);
		end
	end

	return v, lnums;
end

utils.get_scroll = function (buffer, from, to)
	local buf_line = from;
	local add = from < to and 1 or -1;

	local covered_lines = 0;
	local will_scroll = {};

	while covered_lines < math.abs(from - to) do
		if buf_line < 0 or buf_line > vim.api.nvim_buf_line_count(buffer) then
			break;
		end

		if vim.fn.foldclosed(buf_line) == buf_line then
			table.insert(will_scroll, buf_line);
			covered_lines = covered_lines + 1;

			--- When scrolling backwards we have already crossed the folded lines,
			--- So we only need to reduce the line by 1
			buf_line = buf_line + (add == 1 and (vim.fn.foldclosedend(buf_line) - vim.fn.foldclosed(buf_line)) or -1);
		elseif vim.fn.foldclosed(buf_line) == -1 then
			if #vim.api.nvim_buf_get_extmarks(buffer, -1, { buf_line, 0 }, { buf_line, -1}, { type = "virt_lines" }) > 0 then
				local ext = vim.api.nvim_buf_get_extmarks(buffer, -1, { buf_line, 0 }, { buf_line, -1 }, { type = "virt_lines", details = true });
				local v_lines = utils.get_virt_line_num(ext);

				table.insert(will_scroll, buf_line);
				covered_lines = covered_lines + v_lines;
				buf_line = buf_line + add;
			else
				table.insert(will_scroll, buf_line);

				covered_lines = covered_lines + 1;
				buf_line = buf_line + add;
			end
		else
			buf_line = buf_line + add;
		end
	end

	return covered_lines, will_scroll;
end

utils.scrollFrameGenerator_y = function (from, to, config)
	local conf = vim.tbl_extend("keep", config or {}, {
		ease = "linear", steps = 10
	});

	local _, available_lines = utils.get_scroll(0, from, to);
	local _o = {};

	vim.print()

	for i = 0, conf.steps - 1 do
		local use = math.floor(utils.interpolate(conf.ease, 1, #available_lines, i / (conf.steps - 1)))

		table.insert(_o, available_lines[use])
	end

	return _o;
end

utils.color_transition = function (from, to, config)
	if not from or not to or not isColor(from) or not isColor(to) then
		return;
	end

	local start = to_color(from);
	local stop = to_color(to);

	local _c = {};

	for s = 0, config.steps or 9 do
		table.insert(_c, to_hex({
			r = utils.interpolate(config.ease or "linear", start.r, stop.r, s / (config.steps and (config.steps - 1) or 9)),
			g = utils.interpolate(config.ease or "linear", start.g, stop.g, s / (config.steps and (config.steps - 1) or 9)),
			b = utils.interpolate(config.ease or "linear", start.b, stop.b, s / (config.steps and (config.steps - 1) or 9)),
		}));
	end

	return _c;
end

return utils;
