return {
  -- Codeium
  { import = 'lazyvim.plugins.extras.ai.codeium' },
  {
    -- AI Engine for coding
    'Exafunction/codeium.nvim',
    build = function()
      require('lazy').load({ plugins = { 'codeium.nvim' }, wait = true })
      vim.cmd(':Codeium Auth')
    end,
    init = function()
      _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
        codeium = '「AI」',
      })
    end,
  },
  {
    -- AI Chat
    'olimorris/codecompanion.nvim',
    cmd = { 'CodeCompanion' },
    opts = {
      strategies = {
        chat = {
          adapter = vim.env.VIM_COMPANION_ADAPTER or _G.companion_adapter or 'ollama',
        },
        inline = {
          adapter = vim.env.VIM_COMPANION_ADAPTER or _G.companion_adapter or 'ollama',
        },
      },
    },
  },
}
