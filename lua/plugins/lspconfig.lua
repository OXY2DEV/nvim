---+ name: Nvim-lspconfig; |lsp| ##plugin##
---
---_

return {
	"neovim/nvim-lspconfig",
	-- enabled = false,

	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},

	config = function ()
		-- Helper functions
		local capabilities = require("cmp_nvim_lsp").default_capabilities();

		local def_setup = function(server, config)
			require("lspconfig")[server].setup(vim.tbl_deep_extend("force", {
				capabilities = capabilities
			}, config or {}))
		end


		-- Servers
		def_setup("tsserver");
		def_setup("cssls");
		def_setup("html");
		def_setup("emmet_language_server");
		def_setup("clangd");
		def_setup("css_variables");
		def_setup("harper_ls", {
			filetypes = {
				"lua", "gitcommit"
			}
		});
	end
}
