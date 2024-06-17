St = function ()
  return vim.api.nvim_get_mode().mode;
end

vim.o.statusline = "%!v:lua.St()";
