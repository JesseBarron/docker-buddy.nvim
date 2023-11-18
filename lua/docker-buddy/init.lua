-- Create A Few Commads
vim.api.nvim_create_user_command('DocBudRestart', function(args)
  P(args)
end, {
    nargs = "*"
  })
