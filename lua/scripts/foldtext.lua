---+ Title: "Fold_text function" Icon: "󰡱 "
FoldText = function()
	local foldStartLine = table.concat(vim.fn.getbufline(vim.api.nvim_get_current_buf(), vim.v.foldstart));

	local title, icon, number;

	local border = foldStartLine:match('Border:%s*"([^"]+)"') or "─";
	local borderLeft = foldStartLine:match('BorderL:%s*"([^"]+)"') or "┤";
	local borderRight = foldStartLine:match('BorderR:%s*"([^"]+)"') or "├";

	local padding = foldStartLine:match('Padding:%s*"(%d+)"') ~= nil and tonumber(foldStartLine:match('Padding:%s*"(%d+)"')) or 1;
	local gap = foldStartLine:match('Gap:%s*"(%d+)"') ~= nil and tonumber(foldStartLine:match('Gap:%s*"(%d+)"')) or 3;

	--- Fold name
	if foldStartLine:match('Title:%s*"([^"]+)"') == "false" then
		title = "";
	elseif foldStartLine:match('Title:%s*"([^"]+)"') == nil and border == " " then
		title = "Fold";
	elseif foldStartLine:match('Title:%s*"([^"]+)"') == nil and border ~= " " then
		title = borderLeft .. " Fold " .. borderRight;
	else
		if border == " " then
			title = foldStartLine:match('Title:%s*"([^"]+)"');
		else
			title = borderLeft .. " " .. foldStartLine:match('Title:%s*"([^"]+)"') .. " " .. borderRight;
		end
	end

	--- Fold icon
	if foldStartLine:match('Icon:%s*"([^"]+)"') == "false" then
		icon = "";
	elseif foldStartLine:match('Icon:%s*"([^"]+)"') == nil and border == " " then
		icon = " ";
	elseif foldStartLine:match('Icon:%s*"([^"]+)"') == nil and border ~= " " then
		icon = borderLeft .. "   " .. borderRight;
	else
		if border == " " then
			icon = foldStartLine:match('Icon:%s*"([^"]+)"');
		else
			icon = borderLeft .. " " .. foldStartLine:match('Icon:%s*"([^"]+)"') .. " " .. borderRight;
		end
	end

	--- Number of lines
	if foldStartLine:match('Line count:%s*"([^"]+)"') == "false" then
		number = "";
	else
		if border == " " then
			number = tostring((vim.v.foldend - vim.v.foldstart) + 1) .. " Lines ";
		else
			number = borderLeft .. " " .. tostring((vim.v.foldend - vim.v.foldstart) + 1) .. " Lines " .. borderRight;
		end
	end


	local totalVirtualColumns = vim.api.nvim_win_get_width(0) - vim.fn.getwininfo(vim.fn.win_getid())[1].textoff;
	local fillCharLen = totalVirtualColumns - vim.fn.strchars(string.rep(border, padding) .. icon .. string.rep(border, gap) .. title .. number .. border);

	local _out = string.rep(border, padding) .. icon .. string.rep(border, gap) .. title .. string.rep(border, fillCharLen) .. number .. border;

	return _out;
end
---_

-- vim.o.foldtext = "v:lua.FoldText()"
