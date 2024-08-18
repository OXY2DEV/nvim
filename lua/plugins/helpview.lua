return {
	-- "OXY2DEV/helpview.nvim",
	dir = "~/.config/nvim/lua/custom_plugins/helpview.nvim",
	-- enabled = false,
	lazy = false,

	config = function ()
		-- require("helpview.extras.h").init();
		-- require("helpview.extras.gO").init();
		-- require("helpview.extras.command").init();

		require("helpview").setup({
			-- hybrid_modes = { "n" }
			-- options = {
			-- 	on_enable = function (window, buffer)
			-- 		-- vim.wo[window].statuscolumn = "  ";
			-- 		vim.wo[window].sidescrolloff = 0;
			--
			-- 		if vim.bo[buffer].modifiable == true then
			-- 			vim.wo[window].colorcolumn = "+1"
			-- 		end
			--
			-- 		-- require("helpview.extras.column").set(window,buffer);
			-- 		require("helpview.extras.gO").keymap(window, buffer);
			-- 	end
			-- }
		});
	end
}
