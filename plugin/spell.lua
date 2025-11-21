local subcommands = {
  vi = function()
    vim.cmd(
      'mkspell! '
        .. '~/.config/nvim/spell/vi'
        .. ' '
        .. '~/.config/dictionaries/vietnamese.txt'
    )
  end,
  zh = function()
    vim.cmd(
      'mkspell! '
        .. '~/.config/nvim/spell/zh'
        .. ' '
        .. '~/.config/dictionaries/chinese/*.txt'
    )
  end,
}

vim.api.nvim_create_user_command('DySpell', function(opts)
  local subcommand = subcommands[opts.fargs[1]]
  if subcommand then
    subcommand()
  else
    vim.notify(
      "[spell] invalid spell file '" .. subcommand.args .. "'",
      vim.log.levels.ERROR
    )
  end
end, {
  nargs = 1,
  desc = 'Make spell file from my dictionary',
  complete = function() vim.tbl_keys(subcommands) end,
})
