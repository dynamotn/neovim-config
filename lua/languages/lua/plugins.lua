return function(_, _)
  return {
    DEBUG and { 'jbyuki/one-small-step-for-vimkind' } or {}, -- Neovim debugger
    { 'hrsh7th/cmp-nvim-lua' }, -- Neovim LUA completion source
  }
end
