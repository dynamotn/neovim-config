local languages_list = require('config.languages')
local diagram_filetypes = {}
vim.list_extend(diagram_filetypes, languages_list.markdown.filetypes)
vim.list_extend(diagram_filetypes, languages_list.d2.filetypes)
return {
  {
    -- Render diagram as code
    '3rd/diagram.nvim',
    ft = diagram_filetypes,
    dependencies = {
      '3rd/image.nvim',
      ft = diagram_filetypes,
      commit = '21909e3eb03bc738cce497f45602bf157b396672',
      opts = {
        backend = vim.env.ZELLIJ ~= nil
            and vim.fn.executable('ueberzug') == 1
            and 'ueberzug'
          or 'kitty',
      },
    },
    opts = {
      events = {
        render_buffer = { 'BufWritePost', 'BufWinEnter' },
        clear_buffer = { 'BufLeave' },
      },
      renderer_options = {
        d2 = {
          theme_id = 4,
          dark_theme_id = 4,
          layout = 'tala',
        },
      },
    },
    config = function(_, opts)
      require('diagram').setup(vim.tbl_extend('force', {
        integrations = {
          require('diagram.integrations.markdown'),
          require('tools.diagram.d2.integration'),
        },
      }, opts))
    end,
    enabled = vim.fn.executable('magick') == 1 or _G.used_full_plugins,
  },
}
