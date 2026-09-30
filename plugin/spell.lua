local spell_files = {
  vi = { '~/.config/dictionaries/vietnamese.txt' },
  zh = { '~/.config/dictionaries/chinese/*.txt' },

  proper = { '~/.config/nvim/spell/proper.txt' },
  technical = { '~/.config/nvim/spell/technical.txt' },
}

--- Build the spell file of one language from its dictionaries
---@param lang string Key of `spell_files`
local make_spell = function(lang)
  -- `lang` is the argument as typed, a plain string. Reaching for a field on
  -- it turned the complaint about a wrong name into a crash of its own.
  if spell_files[lang] == nil then
    vim.notify(
      "[spell] invalid spell file '" .. lang .. "'",
      vim.log.levels.ERROR
    )
    return
  end
  vim.cmd(
    'mkspell! ~/.config/nvim/spell/'
      .. lang
      .. ' '
      .. table.concat(spell_files[lang], ' ')
  )
end

vim.api.nvim_create_user_command(
  'DySpell',
  -- `nargs = 1` means the argument is always there, so there is nothing to
  -- fall back to
  function(opts) make_spell(opts.fargs[1]) end,
  {
    nargs = 1,
    desc = 'Make spell file from my dictionary',
    -- Neovim hands back a Lua completion list as it is, so the narrowing to
    -- what has been typed has to happen here
    complete = function(arg_lead)
      local names = vim.tbl_filter(
        function(name) return vim.startswith(name, arg_lead) end,
        vim.tbl_keys(spell_files)
      )
      table.sort(names)
      return names
    end,
  }
)
