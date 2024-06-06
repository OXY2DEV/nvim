return {
	"neovim/nvim-lspconfig",
	enabled = true,

	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},

	config = function ()
		-- Helper functions
		local lsp_capa = require("cmp_nvim_lsp").default_capabilities();
		local def_setup = function(server)
			require("lspconfig")[server].setup({
				--on_attach = function(_, bufnr)
				--	local function buf_set_option(...)
		    --		vim.api.nvim_buf_set_option(bufnr, ...)
		  	--	end
				--end,
				capabilities = lsp_capa
			})
		end


		-- Servers
		def_setup("tsserver");
		def_setup("cssls");
		--def_setup("html");
		def_setup("emmet_language_server");
		def_setup("clangd");
		def_setup("css_variables");
	end
}
