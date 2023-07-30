return {
  {
    -- Automatic session management
    'olimorris/persisted.nvim',
    name = 'session',
    event = 'UIEnter',
  },
  DEBUG
      and {
        -- Debug Treesitter
        'nvim-treesitter/playground',
        name = 'playground',
        dependencies = { 'treesitter' },
        cmd = 'TSPlaygroundToggle',
      }
    or nil,
  {
    -- Automatically ínstall language server, linter, dap server
    'williamboman/mason.nvim',
    name = 'mason',
  },
}
