local spell_files = {
  vi = { '~/.config/dictionaries/vietnamese.txt' },
  zh = { '~/.config/dictionaries/chinese/*.txt' },

  proper = { '~/.config/nvim/spell/proper.txt' },
  technical = { '~/.config/nvim/spell/technical.txt' },
}

local make_spell = function(lang)
  if spell_files[lang] ~= nil then
    vim.cmd(
      'mkspell! ~/.config/nvim/spell/'
        .. lang
        .. ' '
        .. table.concat(spell_files[lang], ' ')
    )
  else
    vim.notify(
      "[spell] invalid spell file '" .. lang.args .. "'",
      vim.log.levels.ERROR
    )
  end
end

vim.api.nvim_create_user_command('DySpell', function(opts)
  local subcommand = opts.fargs[1]
  if subcommand then
    make_spell(subcommand)
  else
    vim.notify(
      "[spell] invalid spell file '" .. subcommand.args .. "'",
      vim.log.levels.ERROR
    )
  end
end, {
  nargs = 1,
  desc = 'Make spell file from my dictionary',
  complete = function() return vim.tbl_keys(spell_files) end,
})
