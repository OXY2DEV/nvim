---+ name: Window-animations.nvim; |looks| ##plugin##
---
---_

return {
	dir = "~/.config/nvim/lua/custom_plugins/animations.nvim",

	config = function ()
		local tm = require("animations.extras.terminals");
		tm.create_commands();

		vim.api.nvim_create_user_command("Test", function ()
			require("animations.extras.layouts").show_wininfo();
		end, {})
	end
}
