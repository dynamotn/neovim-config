return {
  {
    -- Automatic session management
    'echasnovski/mini.sessions',
    name = 'session',
    lazy = false,
  },
  {
    -- Debug Treesitter
    'nvim-treesitter/playground',
    name = 'playground',
    dependencies = { 'treesitter' },
    cmd = 'TSPlaygroundToggle',
    enabled = DEBUG,
  },
  {
    -- Automatically ínstall language server, linter, dap server
    'williamboman/mason.nvim',
    name = 'mason',
  },
}
