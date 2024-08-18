return {
      "justinmk/vim-ipmotion",
      config = function()
          vim.g.ip_skipfold = 1
      end,
      keys = {
          { "{", desc = "Go to the previous paragraph including whitespace." },
          { "}", desc = "Go to the next paragraph including whitespace." },
      },
}
