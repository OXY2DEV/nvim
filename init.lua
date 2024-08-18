--[[
	Generated with 'conf-doc.nvim'

	Author: OXY2DEV
	Time: Sun Aug 18 13:04:18 2024
]]--

-- -+ ${link=dep} from: README.md;range: 55,60;
require("config/settings");   -- Options
require("config/keymaps");    -- Keymaps
require("config.diagnostic"); -- Fancy diagnostic messages
-- -_

-- -+ ${link=dep} from: README.md;range: 65,70;
require("scripts/beacon");           -- Beacon to show cursor
require("scripts.fancy_cmdline");    -- Cmd window
require("scripts.terminal_bg_sync"); -- Background sync for Termux
-- -_

-- -+ ${link=dep} from: README.md;range: 77,80;
require("config/lazy");
-- -_

