local language = require('config.languages').jupyter

return {
  {
    'sheng-tse/jupynvim',
    ft = language.filetypes,
    build = function(plugin)
      loadfile(plugin.dir .. '/lua/jupynvim/install.lua')().run(plugin)
    end,
    keys = {
      {
        '<leader>cj',
        '<cmd>:edit<CR>',
        ft = language.filetypes,
        desc = 'Edit Jupyter Notebook',
      },
    },
    config = function() require('jupynvim').setup() end,
  },
}
