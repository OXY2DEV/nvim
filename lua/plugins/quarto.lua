-- plugins/quarto.lua
return {
  {
    "quarto-dev/quarto-nvim",
	enabled = false,
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
