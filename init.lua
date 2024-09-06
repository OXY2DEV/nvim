--[[
	Generated with 'conf-doc.nvim'

	Author: OXY2DEV
	Time: Sun Aug 25 18:20:00 2024
]]--

-- -+ ${link=dep} from: README.md;range: 55,59;
require("config.settings");   -- Options
require("config.keymaps");    -- Keymaps
-- -_

-- -+ ${link=dep} from: README.md;range: 64,70;
require("scripts.beacon");           -- Beacon to show cursor
require("scripts.cmdline");          -- Custom cmdline
require("scripts.diagnostic");       -- Fancy diagnostic messages
-- require("scripts.msg");       -- Fancy diagnostic messages
require("scripts.terminal_bg_sync"); -- Background sync for Termux
-- -_

-- -+ ${link=dep} from: README.md;range: 77,80;
require("config/lazy");
-- -_

