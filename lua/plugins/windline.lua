local wl = require("windline");

local utils = require("windline.utils");
local helpers = require("windline.helpers");

local anim = require("wlanimation");
local effe = require("wlanimation.effects");

local sep = helpers.separators;
local wlState = _G.WindLine.state;

utils.change_mode_name({
	["n"]		= { "   Normal", "Normal" },

	["v"]		= { "   Visual", "Visual" },
	["V"]		= { "   V-Line", "Visual" },
	[""]	= { "   V-Block", "Visual" },

	["i"]		= { "   Insert", "Insert" },

	["r?"]	= { "  Replace", "Replace" },

	["c"]		= { "   Command", "Command" },
	["t"]		= { "   Terminal", "Command" },
})

local barCol = 1;
local moon = "";
local shuttle = "";

local c_col = function()
	local cls = {};
	local phases = { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" };
	local ship	 = { "  ", "   ─", "  ──", "  ───", " ────", "─────󰑅", "────󰑅─", "───󰑅──", "──󰑅───", "─󰑅───󰑅", "󰑅───󰑅─", "───󰑅──", "──󰑅───", "─󰑅────", "󰑅─────", "────", "──── ", "── ", "─  ", "   ", "   ", "   ", "   ", "   ─", "  ──", "  ───", " ───󰑅", "────󰑅─", "───󰑅──", "──󰑅───", "─󰑅───󰑅", "󰑅───󰑅─", "───󰑅──", "──󰑅───", "─󰑅────", "󰑅─────", "──────", "──────", "────", "─── ", "───  ", "──  ", "─  ", "  ", "  " };

	if (barCol == 1) then
		cls = {
			"#d1effa", "#9fdff8", "#71cff3", "#42c0f0", "#12b0ed", "#42c0f0", "#71cff3", "#9fdff8", "#d1effa",
		}

		barCol = 2;
	elseif (barCol == 2) then
		cls = {
			"#aaa8f1", "#bab9f3", "#cccbf5", "#ddddf9", "#cccbf5", "#bab9f3", "#aaa8f1"
		}

		barCol = 1;
	end

	anim.stop_all();

	anim.animation({
		data = {
			{ "gradL1", effe.list_color(cls, 1) },
			{ "gradL2", effe.list_color(cls, 2) },
			{ "gradL3", effe.list_color(cls, 3) },
			{ "gradL4", effe.list_color(cls, 4) },
			{ "gradL5", effe.list_color(cls, 5) },
		},
		timeout = 100,
		interval = 150
	})
	
	anim.animation({
		data = {
			{ "gradR1", effe.list_color(cls, 5) },
			{ "gradR2", effe.list_color(cls, 4) },
			{ "gradR3", effe.list_color(cls, 3) },
			{ "gradR4", effe.list_color(cls, 2) },
			{ "gradR5", effe.list_color(cls, 1) },
		},
		timeout = 100,
		interval = 150
	})

	anim.basic_animation({
		timeout = nil,
		effect = effe.list_text(phases),
		
		on_tick = function(val)
			moon = val;
			vim.cmd.redrawstatus()
		end
	})
	
	anim.basic_animation({
		timeout = nil,
		effect = effe.list_text(ship),
		interval = 200,
		
		on_tick = function(val)
			shuttle = val;
			vim.cmd.redrawstatus()
		end
	})
end

vim.defer_fn(function()
	c_col()
end, 100)



local components = {};

components.space				= { "%=", "" };
components.gap					= { " ", "" };

components.bg						= { " ", "StatusLine" };

--components.ruler				= { [[ %3l:%-2c ]], { "fg2", "bg2" } };
components.progress			= { [[%3p%% ]],			{ "white", "black" } };

components.fileName_off	= { [[ %f ]],				{ "fg2", "bg2" }};


components.mode					= {
	name = "vi_mode",
	hl_colors = {
		Normal	= { "fg", "bg" },
		Insert	= { "bg", "fg" },
		Visual	= { "bg", "bgV" },
		Command	= { "bg", "bgC" },
		Replace = { "bg", "bgR" }
	},
	hl = function()
		return wlState.mode[2]
	end,

	text = function()
		local str = "";

		-- {{{ White space
		-- If the text is short add white spaces.
		if (wlState.mode[1]:len() < 13) then
			local l = 13 - wlState.mode[1]:len();
		
			for i = 0, l, 1 do
				str = str .. " ";
			end

		else 
			str = " "
		end
		-- }}}
		
		return " " .. wlState.mode[1] .. str;
	end
}

components.mode_sep = {
	name = "vi_mode_sep",
	hl_colors = {
		Normal	= { "bg2", "bg" },
		Insert	= { "bg2", "fg" },
		Visual	= { "bg2", "bgV" },
		Command	= { "bg2", "bgC" },
		Replace = { "bg2", "bgR" }
	},
	hl = function()
		return wlState.mode[2]
	end,

	text = function()
		return "";
	end
}

components.file_name = {
	name = "file_name",
	hl_colors = {
		"fg2", "bg2"
	},

	text = function()
		local name = vim.fn.expand("%:p:t");

		local icon = "";

		-- {{{ File Type Icons
		local type = vim.o.filetype;

		if (type == "vim") then
			icon = ""
		elseif (type == "help") then
			icon = ""
		elseif (type == "txt") then
			icon = ""
		elseif (type == "lua") then
			icon = "";
		elseif (type == "html") then
			icon = "";
		elseif (type == "css") then
			icon = "";
		elseif (type == "javascript") then
			icon = "";
		elseif (type == "json") then
			icon = "";
		else
			icon = "";
		end
		-- }}}

		if (name == "") then
			name = "New";
		elseif (name:len() >= 13) then
			name = string.sub(name, 1, 9) .. "..";
		end

		return " " .. icon .. " " .. name .. " "
	end
}

components.ripple = {
	text = function()
		return {
			{ "", { "gradL1", "bg2"}},
			{ "   ", { "", "gradL1"}},
			
			{ "", { "gradL2", "gradL1"}},
			{ "   ", { "", "gradL2"}},
			
			{ "", { "gradL3", "gradL2"}},
			{ "   ", { "", "gradL3"}},
			
			{ "", { "gradL4", "gradL3"}},
			{ "   ", { "", "gradL4"}},
			
			{ "", { "gradL5", "gradL4"}},
			{ "", { "gradR2", "gradR1"}},

			{ "   ", { "", "gradR2"}},
			{ "", { "gradR3", "gradR2"}},
			
			{ "   ", { "", "gradR3"}},
			{ "", { "gradR4", "gradR3"}},
			
			{ "   ", { "", "gradR4"}},
			{ "", { "gradR5", "gradR4"}},
			
			{ "   ", { "", "gradR5"}},
			{ "", { "bg2", "gradR5"}},
			
		}
	end,

	click = c_col
}


components.ruler = { 
	text = function()
		return "  " .. [[ %3l  %-2c ]];
	end,

	hl_colors = { "fg2", "bg2" } 
};

components.ruler_sep = {
	name = "vi_mode_sep",
	hl_colors = {
		Normal	= { "bg" , "bg2" },
		Insert	= { "fg" , "bg2" },
		Visual	= { "bgV", "bg2" },
		Command	= { "bgC", "bg2" },
		Replace = { "bgR", "bg2" }
	},
	hl = function()
		return wlState.mode[2]
	end,

	text = function()
		return "";
	end
}

components.credits = {
	width = 9,
	hl_colors = {
		Normal	= { "fg", "bg" },
		Insert	= { "bg", "fg" },
		Visual	= { "bg", "bgV" },
		Command	= { "bg", "bgC" },
		Replace = { "bg", "bgR" }
	},
	hl = function()
		return wlState.mode[2]
	end,

	text = function()
		return "  " .. shuttle;
	end
}



wl.setup({
	colors_name = function(cl)
		cl.fg		= "#cdd6f4";
		cl.bg		= "#1e1e2e";
		
		cl.bgV	= "#74c7ec";
		cl.bgC	= "#a6e3a1";
		cl.bgR	= "#e79bfd";

		cl.bg2	= "#313244";
		cl.fg2	= "#a6adc8";

		cl.gradL1= "#000000";
		cl.gradL2= "#000000";
		cl.gradL3= "#000000";
		cl.gradL4= "#000000";
		cl.gradL5= "#000000";

		cl.gradR1= "#000000";
		cl.gradR2= "#000000";
		cl.gradR3= "#000000";
		cl.gradR4= "#000000";
		cl.gradR5= "#000000";

		return cl;
	end,

	statuslines = {
		{
			filetypes = { "default" },

			active = {
				components.mode,
				components.mode_sep,
				components.file_name,
				components.ripple,
				components.ruler,
				components.ruler_sep,
				components.credits
			},
			inactive = {
				components.mode
			}
		}
	}
})


