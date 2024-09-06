local doc = {};
local parser = require("conf-doc.parser");

doc.configuraton = {
	time = os.date,
	scan_till = 10,
}

doc.get_config = function (buffer)
	local lines = vim.api.nvim_buf_get_lines(buffer, 0, doc.configuraton.scan_till, false);
	local conf = {
		author = doc.configuraton.author,
		time = doc.configuraton.time,

		path = doc.configuraton.path,
		filename = doc.configuraton.filename,
		filetype = doc.configuraton.preferred_filetype,

		comment_multiline_end = "]]--",
		comment_multiline_start = "--[[",

		comment_singleline = "--"
	};
	local parsing = false;

	for _, line in ipairs(lines) do
		if line:match("##(conf%-doc)##$") then
			parsing = true;
		elseif parsing == true and line:match("##(conf%-doc%-end)##$") then
			parsing = false;
			break;
		elseif parsing == true then
			if line:match("author: (.-)[%s;]") then
				conf.author = line:match("author: (.-)[%s;]")
			end

			if line:match("time: (.-);") then
				conf.time = line:match("time: (.-);")
			end

			if line:match("path: (.-);") then
				conf.path = line:match("path: (.-);")
			end

			if line:match("fn: (.-)[%s;]") then
				conf.filename = line:match("fn: (.-)[%s;]");
			elseif line:match("filename: (.-)[%s;]") then
				conf.filename = line:match("filename: (.-)[%s;]");
			end

			if line:match("ft: (.-)[%s;]") then
				conf.filetype = line:match("ft: (.-)[%s;]");
			elseif line:match("filetype: (.-)[%s;]") then
				conf.filetype = line:match("filetype: (.-)[%s;]");
			end

			if line:match("ml%-comment: (.-), (.-)[%s;]") then
				conf.comment_multiline_start = line:match("ml%-comment: (.-), .-[%s;]");
				conf.comment_multiline_end = line:match("ml%-comment: .-, (.-)[%s;]");
			elseif line:match("multiline%-comment: (.-), (.-)[%s;]") then
				conf.comment_multiline_start = line:match("multiline%-comment: (.-), .-[%s;]");
				conf.comment_multiline_end = line:match("multiline%-comment: .-, (.-)[%s;]");
			end

			if line:match("sl%-comment: (.-)[%s;]") then
				conf.comment_singleline = line:match("sl%-comment: (.-)[%s;]");
			elseif line:match("singleline%-comment: (.-)[%s;]") then
				conf.comment_singleline = line:match("singleline%-comment: (.-)[%s;]");
			end
		end
	end

	return conf;
end

doc.render_top = function (config)
	local conf = vim.tbl_deep_extend("force", doc.configuraton, config or {});

	io.write(conf.comment_multiline_start, "\n");
	io.write("	" .. "Generated with 'conf-doc.nvim'", "\n");
	io.write("\n");

	io.write("	Author: " .. conf.author, "\n");

	if pcall(conf.time) then
		io.write("	Time: " .. conf.time(), "\n");
	elseif type(conf.time) == "string" then
		io.write("	Time: " .. conf.time, "\n");
	end

	io.write(conf.comment_multiline_end, "\n\n");
end

doc.render_part = function (buffer, data, config)
	local conf = vim.tbl_deep_extend("force", doc.configuraton, config or {});

	if conf.filetype ~= data.language then
		return;
	end

	local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buffer), ":~:.");

	local fold_start, fold_end = vim.wo.foldmarker:match("(.-),.+"), vim.wo.foldmarker:match(".-,(.+)");

	if data.fold == true then
		io.write(conf.comment_singleline,
			" " .. fold_start .. " ${link=" .. data.type .. "} ",
			"from: " .. path .. ";",
			"range: " .. (data.row_start + 1) .. "," .. (data.row_end + 1) .. ";",
			"\n"
		);
	else
		io.write(conf.comment_singleline,
			"from: " .. path .. ";",
			"range: " .. (data.row_start + 1) .. "," .. (data.row_end + 1) .. ";",
			"\n"
		);
	end

	for _, line in ipairs(data.lines) do
		io.write(line, "\n");
	end

	if data.fold == true then
		io.write(conf.comment_singleline,
			" " .. fold_end
		);
	end

	io.write("\n\n");
end

doc.io_fname = function (buffer, config)
	local conf = vim.tbl_deep_extend("force", doc.configuraton, config or {});
	local buf_name = vim.api.nvim_buf_get_name(buffer);

	if type(conf.path) == "string" then
		vim.print(conf.path)
		return vim.fn.fnamemodify(conf.path, ":p") .. "/" .. conf.filename .. "." .. conf.filetype;
	elseif type(conf.filename) == "string" then
		local path = vim.fn.fnamemodify(buf_name, ":h");
		return path .. "/" .. conf.filename .. "." .. conf.filetype;
	end

	local name = vim.fn.fnamemodify(buf_name, ":r");
	return name .. "." .. conf.filetype;
end

doc.setup = function ()
	vim.api.nvim_create_user_command("DocGen", function ()
		local buffer = vim.api.nvim_get_current_buf();

		local config = doc.get_config(buffer)

		local data = parser.init();
		local name = doc.io_fname(buffer, config);

		local file = io.open(name, "w");
		io.output(file);

		doc.render_top(config);

		for _, dat in ipairs(data) do
			doc.render_part(buffer, dat, config);
		end

		io.close(file)
	end, {
		desc = "Generates config files from markdown"
	})
end

return doc;
