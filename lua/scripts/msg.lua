local msg = {};

msg.log = {};
msg.active = {};

msg.buf = vim.api.nvim_create_buf(false, true);
msg.win = nil;

msg.ns = vim.api.nvim_create_namespace("msg");

-- Closes the message box
msg.ui_close = function ()
	pcall(vim.api.nvim_win_close, msg.win, true);
	msg.win = nil;
end

msg.ui_print = function (kind, content, replace_last)
	msg.ui_update();
	msg.ui_content();
end

msg.ui_content = function ()
	local l = {};

	for _, item in ipairs(msg.active) do
		local tmp = "";

		for _, part in ipairs(item.content) do
			tmp = tmp .. part[2];
		end

		table.insert(l, tmp);
	end

	vim.api.nvim_buf_set_lines(msg.buf, 0, -1, false, l);
end

msg.add = function (message, hl)
	local timer = vim.uv.new_timer();

	table.insert(msg.log, {
		timer = timer,
		content = message
	});

	local id = #msg.log + 1;

	table.insert(msg.active, {
		timer = timer,
		id = id,
		content = message
	});

	vim.schedule(function ()
		msg.ui_update();
		vim.cmd.redraw();
	end);

	timer:start(5000, 0, vim.schedule_wrap(function ()
		msg.remove(id);
	end));
end

msg.remove = function (id)
	for index, item in ipairs(msg.active) do
		if item.id == id then
			table.remove(msg.active, index);
			msg.ui_update();
			return;
		end
	end
end

msg.update = function (message)
	if #msg.active == 0 then
		msg.add(message);
		return;
	else
		local timer = msg.active[#msg.active].timer;
		local id = msg.active[#msg.active].id;

		msg.active[#msg.active] = vim.tbl_extend("force", msg.active[#msg.active], {
			content = message
		})

		msg.ui_update();

		timer:stop();
		timer:start(5000, 0, vim.schedule_wrap(function ()
			msg.remove(id);
		end))
	end
end

msg.confirm = function (message)
	vim.schedule(function ()
		msg.add(message);
	end);
end

msg.return_prompt = function ()
	vim.api.nvim_input("<CR>");
	vim.cmd.redraw();
end

--- Opens or updates the window
msg.ui_update = function ()
	if msg.win and vim.api.nvim_win_is_valid(msg.win) then
		vim.api.nvim_win_set_config(msg.win, {
			relative = "editor",
			anchor = "SW",

			row = vim.o.lines - 1, col = vim.o.columns,
			width = 50, height = 5,

			border = "rounded"
		});
	else
		msg.win = vim.api.nvim_open_win(msg.buf, false, {
			relative = "editor",
			anchor = "SW",

			row = vim.o.lines - 1, col = vim.o.columns,
			width = 50, height = 5,

			border = "rounded"
		});
	end

	local lines = {};

	for _, item in ipairs(msg.active) do
		local tmp = "";

		for _, part in ipairs(item.content) do
			tmp = tmp .. part[2];
		end

		table.insert(lines, tmp);
	end

	vim.api.nvim_buf_set_lines(msg.buf, 0, -1, false, lines);
end


vim.ui_attach(msg.ns, { ext_messages = true }, function (event, ...)
	msg.add({ { nil, event }});

	if event == "msg_show" then
		local kind, content, replace_last = ...;

		if kind == "" then
			if not replace_last then
				msg.add(content);
			else
				msg.update(content);
			end
		elseif kind == "echo" or kind == "echomsg" then
			if not replace_last then
				msg.add(content);
			else
				msg.update(content);
			end
		elseif kind == "return_prompt" then
			msg.return_prompt();
		elseif kind == "confirm" or kind == "confirm_sub" then
			msg.confirm(content)
		end
	else
	end
end);
