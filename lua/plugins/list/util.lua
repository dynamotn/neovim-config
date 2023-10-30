return {
  {
    -- Automatic session management
    'olimorris/persisted.nvim',
    name = 'session',
    event = 'UIEnter',
  },
  {
    -- Debug Treesitter
    'nvim-treesitter/playground',
    name = 'playground',
    dependencies = { 'treesitter' },
    cmd = 'TSPlaygroundToggle',
    cond = DEBUG,
  },
  {
    -- Automatically ínstall language server, linter, dap server
    'williamboman/mason.nvim',
    name = 'mason',
  },
}
