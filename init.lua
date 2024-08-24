--[[
	Generated with 'conf-doc.nvim'

	Author: OXY2DEV
	Time: Thu Aug 22 17:30:00 2024
]]--

-- -+ ${link=dep} from: README.md;range: 55,59;
require("config.settings");   -- Options
require("config.keymaps");    -- Keymaps
-- -_

-- -+ ${link=dep} from: README.md;range: 64,69;
require("scripts.beacon");           -- Beacon to show cursor
require("scripts.cmdline");           -- Beacon to show cursor
require("scripts.diagnostic");       -- Fancy diagnostic messages
require("scripts.terminal_bg_sync"); -- Background sync for Termux
-- -_

-- -+ ${link=dep} from: README.md;range: 76,79;
require("config/lazy");
-- -_

