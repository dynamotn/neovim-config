local filetypes = require('languages.list').markdown
local augend = require('dial.augend')

return vim.list_contains(_G.enabled_languages, 'markdown')
    and {
      {
        'dial.nvim',
        opts = {
          groups = {
            markdown = {
              augend.constant.new({
                elements = { '[ ]', '[x]' },
                word = false,
                cyclic = true,
              }),
              augend.misc.alias.markdown_header,
            },
          },
        },
      },
    }
  or {}
