local utils = require("bars/utils");
local statuscolumn = {};

statuscolumn.used_in_bufs = {};
statuscolumn.buffers_with_folds = {};
statuscolumn.fold_positions = {};

statuscolumn.cachedConfig = {};

---@diagnostic disable undefined-global
statuscolumn.border = {
	hls = {},
	text = "",
	fold_connector= nil,

	init = function (self, segmantConfig)
		if segmantConfig == nil then
			return;
		end

		local colors = segmantConfig.colors;
		local from = utils.hexToTable(colors.from);
		local to = utils.hexToTable(colors.to);


		self.text = segmantConfig.border_character;
		self.steps = colors.steps;
		self.hl_prefix = segmantConfig.hl_prefix;
		self.fold_connector = segmantConfig.fold_connector;

		if #self.hls ~= 0 then
			return;
		end

		for c = 0, self.steps - 1 do
			local r = utils.ease(colors.ease, from.r, to.r, c * (1 / (colors.steps - 1)))
			local g = utils.ease(colors.ease, from.g, to.g, c * (1 / (colors.steps - 1)))
			local b = utils.ease(colors.ease, from.b, to.b, c * (1 / (colors.steps - 1)))

			table.insert(self.hls, colors.hl_prefix .. c);

			vim.api.nvim_set_hl(0,
				colors.hl_prefix .. c,
				vim.tbl_extend("keep", {
					fg = string.format("#%x%x%x", r, g, b),
				}, colors.extra_styles or {})
			);
		end
	end,

	component = function (self)
		local color = "";

		if vim.v.relnum == 0 then
			color = "%#" .. self.hls[1] .. "#";
		elseif vim.v.relnum < (self.steps - 1) then
			color = "%#" .. self.hls[vim.v.relnum] .. "#";
		else
			color = "%#" .. self.hls[#self.hls] .. "#";
		end

		if self.fold_connector == nil then
			return color .. self.text .. " ";
		else
			local txt = vim.fn.foldclosed(vim.v.lnum) == -1 and self.text .. " " or self.fold_connector;

			return color .. txt;
		end
	end
};

statuscolumn.line_numbers = {
	current_line = "Special",
	hls = {},


	init = function (self, segmantConfig)
		if segmantConfig == nil then
			return;
		end


		if vim.tbl_islist(segmantConfig.colors) == true and #self.hls == 0 then
			self.hls = segmantConfig.colors;
			return;
		end

		local colors = segmantConfig.colors;
		local from = utils.hexToTable(colors.from);
		local to = utils.hexToTable(colors.to);

		if #self.hls ~= 0 then
			return;
		end


		if colors.current_line ~= nil then
			vim.api.nvim_set_hl(0, colors.current_line.hl_name, vim.tbl_extend("keep", colors.current_line.value, colors.extra_styles or {}));
			self.current_line = colors.current_line.hl_name;
		end

		for c = 0, (colors.steps - 1) do
			local r = utils.ease(colors.ease, from.r, to.r, c * (1 / (colors.steps - 1)))
			local g = utils.ease(colors.ease, from.g, to.g, c * (1 / (colors.steps - 1)))
			local b = utils.ease(colors.ease, from.b, to.b, c * (1 / (colors.steps - 1)))

			table.insert(self.hls, colors.hl_prefix .. c);

			vim.api.nvim_set_hl(0,
				colors.hl_prefix .. c,
				vim.tbl_extend("keep", {
					fg = string.format("#%x%x%x", r, g, b)
				}, colors.extra_styles or {})
			);
		end
	end,

	component = function (self)
		local _o = "";

		if vim.v.relnum == 0 then
			_o = "%#" .. self.current_line .. "#" .. "%=%{" .. vim.v.lnum .. "} ";
		elseif vim.v.relnum <= #self.hls then
			_o = "%#" .. self.hls[vim.v.relnum] .. "#" .. "%=%{" .. vim.v.relnum .. "} ";
		else
			_o = "%#" .. self.hls[#self.hls] .. "#" .. "%=%{" .. vim.v.relnum .. "} ";
		end


		return _o;
	end
};

statuscolumn.folds = {
	borders = {},
	folds = {},
	padding = "",

	init = function (self, segmantConfig)
		if segmantConfig == nil then
			return;
		end

		self.borders = segmantConfig.borders;
		self.folds = segmantConfig.folds;
		self.padding = segmantConfig.padding;

		for hl_name, hl_val in pairs(segmantConfig.custom_hls) do
			vim.api.nvim_set_hl(0, hl_name, hl_val);
		end
	end,

	getFoldLevel = function (self, level)
		if level > #self.folds then
			return #selt.folds;
		end

		return level;
	end,

	validate = function (self)
		if statuscolumn.fold_positions[vim.api.nvim_get_current_buf()] == nil then
			return;
		end

		for index, value in ipairs(statuscolumn.fold_positions[vim.api.nvim_get_current_buf()]) do
			if vim.fn.foldclosed(value.close) ~= value.close or vim.fn.foldclosedend(value.close_end) ~= value.close_end or vim.fn.foldlevel(vim.v.lnum) ~= value.level then
				table.remove(statuscolumn.fold_positions[vim.api.nvim_get_current_buf()], index)
			end
		end
	end,

	component = function (self)
		local isBufferValid = vim.tbl_contains(statuscolumn.buffers_with_folds, vim.api.nvim_get_current_buf());

		if isBufferValid == false then
			return "";
		end

		if vim.api.nvim_get_mode().mode == "i" then
			return " ";
		end

		local foldLevel;
		local text, color = "", "";
		local foldLocs = statuscolumn.fold_positions;

		if foldLocs[vim.api.nvim_get_current_buf()] == nil then
			foldLocs[vim.api.nvim_get_current_buf()] = {};
		end

		-- lines that are in a fold
		if vim.fn.foldlevel(vim.v.lnum) > 0 then
			-- Lines that are the start of a folds
			if vim.fn.foldclosed(vim.v.lnum) ~= -1 then
				local foldRegisterComplete = false;
				local dataMatches = true;

				for index, value in ipairs(foldLocs[vim.api.nvim_get_current_buf()]) do
					-- already recorded fold
					if value.close == vim.v.lnum then
						statuscolumn.fold_positions[vim.api.nvim_get_current_buf()][index] = vim.tbl_extend("force", statuscolumn.fold_positions[vim.api.nvim_get_current_buf()][index], {
							close_end = vim.fn.foldclosedend(vim.v.lnum),
							level = vim.fn.foldlevel(vim.v.lnum)
						});

						foldRegisterComplete = true;

						if value.close_end ~= vim.fn.foldclosedend(vim.v.lnum) then
							dataMatches = false;
						end

						break;
					end
				end

				if foldRegisterComplete == false then
					table.insert(statuscolumn.fold_positions[vim.api.nvim_get_current_buf()], {
						close = vim.fn.foldclosed(vim.v.lnum),
						close_end = vim.fn.foldclosedend(vim.v.lnum),

						level = vim.fn.foldlevel(vim.v.lnum)
					});
				end


				foldLevel = self:getFoldLevel(vim.fn.foldlevel(vim.v.lnum));
				
				if vim.g.nestFolds == false then
					text = self.folds[foldLevel].close;
					color = self.folds[foldLevel].close_hl ~= nil and "%#" .. self.folds[foldLevel].close_hl .. "#" or "";
				else
					for f = 1, foldLevel - 1 do
						text = text .. (self.borders[f].hl ~= nil and "%#" .. self.borders[f].hl .. "#" or "") .. self.borders[f].normal;
					end

					text = text .. (self.folds[foldLevel].close_hl ~= nil and "%#" .. self.folds[foldLevel].close_hl .. "#" or "") .. self.folds[foldLevel].close;
				end
			else
				local markAdded = false;

				for index, value in ipairs(foldLocs[vim.api.nvim_get_current_buf()]) do
					if value.close == vim.v.lnum then
						foldLevel = self:getFoldLevel(vim.fn.foldlevel(vim.v.lnum));

						if vim.g.nestFolds == true then
							text = self.folds[foldLevel].open_hl ~= nil and text .. "%#" .. self.folds[foldLevel].open_hl .. "#" .. self.folds[foldLevel].open or text .. self.folds[foldLevel].open;
						else
							text = self.folds[foldLevel].open
							color = self.folds[foldLevel].open_hl ~= nil and "%#" .. self.folds[foldLevel].open_hl .. "#" or "";
						end

						markAdded = true;
						break
					elseif vim.fn.foldlevel(vim.v.lnum) == value.level and (vim.v.lnum > value.close and vim.v.lnum < value.close_end) then
						foldLevel = self:getFoldLevel(vim.fn.foldlevel(vim.v.lnum));

						if vim.g.nestFolds == true then
							text = self.borders[foldLevel].hl ~= nil and text .. "%#" .. self.borders[foldLevel].hl .. "#" .. self.borders[foldLevel].top or text .. self.borders[foldLevel].top;
						else
							text = self.borders[foldLevel].top;
							color = self.borders[foldLevel].hl ~= nil and "%#" .. self.borders[foldLevel].hl .. "#" or "";
						end

						markAdded = true;
						break
					elseif vim.v.lnum > value.close and vim.v.lnum < value.close_end then
						foldLevel = value.level;

						if vim.g.nestFolds == true then
							text = self.borders[foldLevel].hl ~= nil and text .. "%#" .. self.borders[foldLevel].hl .. "#" .. self.borders[foldLevel].normal or text .. self.borders[foldLevel].normal;
						else
							text = self.borders[foldLevel].normal;
							color = self.borders[foldLevel].hl ~= nil and "%#" .. self.borders[foldLevel].hl .. "#" or "";
						end

						markAdded = true;
					elseif value.close_end == vim.v.lnum then
						foldLevel = self:getFoldLevel(vim.fn.foldlevel(vim.v.lnum));

						if vim.g.nestFolds == true then
							text = self.borders[foldLevel].hl ~= nil and text .. "%#" .. self.borders[foldLevel].hl .. "#" .. self.borders[foldLevel].bottom or text .. self.borders[foldLevel].bottom;
						else
							local foldNext = self:getFoldLevel(vim.fn.foldlevel(vim.v.lnum + 1));

							if foldNext ~= 0 then
								text = (self.borders[foldLevel].hl ~= nil and "%#" .. self.borders[foldLevel].hl .. "#" .. self.borders[foldLevel].mix_branch or self.borders[foldLevel].mix_branch) .. (self.borders[foldNext].hl ~= nil and "%#" .. self.borders[foldNext].hl .. "#" .. self.borders[foldNext].mix_tail or self.borders[foldNext].mix_tail)
							else
								text = self.borders[foldLevel].bottom;
								color = self.borders[foldLevel].hl ~= nil and "%#" .. self.borders[foldLevel].hl .. "#" or "";
							end
						end

						markAdded = true;
						break
					end
				end

				if markAdded == false then
					text = "?";
				end
			end
		else
			text = " ";
		end

		return color .. text .. self.padding;
	end
};

statuscolumn.gap = {
	length = 0,
	fill = "",

	init = function (self, segmantConfig)
		self.length = segmantConfig.length;
		self.fill = segmantConfig.fill;
	end,

	component = function (self)
		return string.rep(self.fill, self.length);
	end
}

statuscolumn.ignore_filetypes = { "", "Lazy", "help" };


--- Create the column
statuscolumn.createColumn = function()
	local _out = ""

	for _, segmants in ipairs(statuscolumn.cachedConfig.segmants) do
		if segmants == "border" then
			_out = _out .. statuscolumn.border:component();
		elseif segmants == "line_numbers" then
			_out = _out .. statuscolumn.line_numbers:component();
		elseif segmants == "folds" then
			_out = _out .. statuscolumn.folds:component();
		elseif segmants == "gap" then
			_out = _out .. statuscolumn.gap:component();
		end
	end

	return _out;
end

--- Function to set up the statuscolumn
--- @param userConfig table
statuscolumn.setup = function (userConfig)
	if userConfig == nil or userConfig.enabled == false then
		return;
	end

	local returnParser = function (language)
		return pcall(function()
			return vim.treesitter.get_parser(vim.api.nvim_get_current_buf(), language)
		end)
	end

	vim.api.nvim_create_user_command("FUupdate", function ()
		statuscolumn.folds:validate();
	end, {
		desc = "Manually update the folds in the buffer"
	});

	statuscolumn.cachedConfig = userConfig.config;

	-- UIEnter for the first window and BufEnter for everything else
	vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "ModeChanged" }, {
		pattern = "*",
		callback = function ()
			local rootParser, fileLanguage;

			-- Ignore filetypes
			if vim.tbl_contains(statuscolumn.ignore_filetypes, vim.bo.filetype) then
				vim.wo.statuscolumn = "";
				return;
			end

			if vim.tbl_contains(statuscolumn.cachedConfig.segmants, "folds") == false then
				goto foldsDisabled;
			end

			fileLanguage = vim.treesitter.language.get_lang(vim.bo.filetype)

			if returnParser(fileLanguage) == false then
				table.insert(statuscolumn.buffers_with_folds, vim.api.nvim_get_current_buf());
				goto noParser;
			else
				rootParser = vim.treesitter.get_parser(vim.api.nvim_get_current_buf(), fileLanguage);
			end

			rootParser:for_each_tree(function (TStree, languageTree)
				local language = languageTree:lang();

				local folds = vim.treesitter.query.parse(language, [[
					((_) @element
						(#any-match? @element
							"-+"
							"-_")) @match
				]]);

				for captureID, captureNode, metadata, match in folds:iter_captures(TStree:root(), vim.api.nvim_get_current_buf()) do
					table.insert(statuscolumn.buffers_with_folds, vim.api.nvim_get_current_buf());
					break;
				end
			end);

			::noParser::
			::foldsDisabled::

			if vim.tbl_contains(statuscolumn.used_in_bufs, vim.api.nvim_get_current_buf()) == true then
				if vim.tbl_contains(statuscolumn.cachedConfig.segmants, "folds") then
					statuscolumn.folds:validate();
				end

				return;
			else
				table.insert(statuscolumn.used_in_bufs, vim.api.nvim_get_current_buf());
			end

			-- Create Base setup
			for _, segmant in ipairs(statuscolumn.cachedConfig.segmants) do
				if segmant == "border" then
					statuscolumn.border:init(statuscolumn.cachedConfig[segmant])
				elseif segmant == "line_numbers" then
					statuscolumn.line_numbers:init(statuscolumn.cachedConfig[segmant]);
				elseif segmant == "folds" then
					statuscolumn.folds:init(statuscolumn.cachedConfig[segmant]);
				elseif segmant == "gap" then
					statuscolumn.gap:init(statuscolumn.cachedConfig[segmant]);
				end
			end

			-- Set the default options
			vim.o.number = false;
			vim.o.foldcolumn = "0";
			vim.o.signcolumn = "no";

			vim.o.statuscolumn = "%!v:lua.require('bars/statuscolumn').createColumn()";
		end
	});
end
---@diagnostic enable

return statuscolumn;
