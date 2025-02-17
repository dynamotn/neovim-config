return {
  { import = 'lazyvim.plugins.extras.ai.codeium' },
  {
    'Exafunction/codeium.nvim',
    init = function()
      _G.completion_sources = vim.tbl_extend('force', _G.completion_sources, {
        codeium = '「AI」',
      })
    end,
  },
  {
    'olimorris/codecompanion.nvim',
    cmd = { 'CodeCompanion' },
    opts = {
      strategies = {
        chat = {
          adapter = 'ollama',
        },
        inline = {
          adapter = 'ollama',
        },
      },
    },
  },
}
