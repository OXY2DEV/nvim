
--- Load the options first;
require("editor.options");
require("editor.keymaps");

require("editor.lazy");

-- vim.cmd.colorscheme("catppuccin");

--- Load scripts just before plugins.
require("scripts.highlights").setup();
require("scripts.bg_sync");

if pcall(require, "markview.highlights") then
	local hls = require("markview.highlights");

	hls.destroy();
	hls.create(hls.groups);
end

