return {
  {
    -- Browser
    'glacambre/firenvim',
    name = 'firenvim',
    build = function()
      require('lazy').load({ plugins = 'firenvim', wait = true })
      vim.fn['firenvim#install'](0)
    end,
    cond = not not vim.g.started_by_firenvim,
    lazy = false,
  },
  {
    -- Terminal
    'akinsho/nvim-toggleterm.lua',
    name = 'toggleterm',
    event = 'VeryLazy',
  },
  {
    -- Translate
    'potamides/pantran.nvim',
    name = 'pantran',
    cmd = 'Pantran',
  },
  {
    -- Interact with database
    'tpope/vim-dadbod',
    name = 'dadbod',
  },
  {
    -- Open current word by other tools
    'ofirgall/open.nvim',
    name = 'open',
  },
  {
    -- Prompt AI
    'jackMort/ChatGPT.nvim',
    name = 'chatgpt',
    event = 'VeryLazy',
    dependencies = {
      'nui',
      'telescope',
    },
  },
}
